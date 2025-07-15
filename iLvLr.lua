-- Original author: JerichoHM
-- Original maintainer: LownIgnitus
-- Current maintainer (2024-09-24): hutcho

local addonName, addonTable = ...
local Title = "|cff00ff00" .. addonName .. "|r"
local core_version, revision_version, build_version = 1, 2, 0
local Core = "|cff00ff00" .. core_version .. "|r"
local Revision = "|cff00ff00" .. revision_version .. "|r"
local Build = "|cff00ff00" .. build_version .. "|r"
SLASH_ILVLR1 = "/ilvlr"

local utils = addonTable.utils

addonTable.ilvlr = {}

---@class ilvlr
local ilvlr = addonTable.ilvlr

local frameDB = {
    CharacterHeadSlot,
    CharacterNeckSlot,
    CharacterShoulderSlot,
    CharacterBackSlot,
    CharacterChestSlot,
    CharacterWristSlot,
    CharacterShirtSlot,
    CharacterTabardSlot,
    CharacterMainHandSlot,
    CharacterSecondaryHandSlot,
    CharacterHandsSlot,
    CharacterWaistSlot,
    CharacterLegsSlot,
    CharacterFeetSlot,
    CharacterFinger0Slot,
    CharacterFinger1Slot,
    CharacterTrinket0Slot,
    CharacterTrinket1Slot
}

local left_side_character_pane = {
    CharacterHeadSlot,
    CharacterNeckSlot,
    CharacterShoulderSlot,
    CharacterBackSlot,
    CharacterChestSlot,
    CharacterWristSlot,
    CharacterShirtSlot,
    CharacterTabardSlot,
}

local right_side_character_pane = {
    CharacterHandsSlot,
    CharacterWaistSlot,
    CharacterLegsSlot,
    CharacterFeetSlot,
    CharacterFinger0Slot,
    CharacterFinger1Slot,
    CharacterTrinket0Slot,
    CharacterTrinket1Slot
}

local slotDB = {
    "HeadSlot",
    "NeckSlot",
    "ShoulderSlot",
    "BackSlot",
    "ChestSlot",
    "WristSlot",
    "ShirtSlot",
    "TabardSlot",
    "MainHandSlot",
    "SecondaryHandSlot",
    "HandsSlot",
    "WaistSlot",
    "LegsSlot",
    "FeetSlot",
    "Finger0Slot",
    "Finger1Slot",
    "Trinket0Slot",
    "Trinket1Slot"
}

local EnchantableSlotsTWW = {
    "MainHandSlot",
    "SecondaryHandSlot",
    "BackSlot",
    "ChestSlot",
    "WristSlot",
    "FeetSlot",
    "Finger0Slot",
    "Finger1Slot"
}

local dualWield = {
    251, -- DK Frost
    577, -- Demon Hunter Havoc
    581, -- Demon Hunter Vengeance
    103, -- Feral
    268, -- Brewmaster
    296, -- Windwalker
    259, -- Assassination
    260, -- Outlaw
    261, -- Subtlety
    263, -- Enhancement
    72   -- Fury
}

local iLvlFrames = {}
local iDuraFrames = {}
local iModFrames = {}


function ilvlr:main()
    addonTable.f = CreateFrame("Frame", "iLvLrmain", CharacterFrame, "BackdropTemplate")
    addonTable.f:SetScript("OnShow", function(self) ilvlr:iLvLrOnLoad() end)
    ilvlr.iLvLrFrame = CreateFrame("Frame", "iLvLrFrame", UIParent)
    ilvlr.iLvLrFrame:RegisterEvent("ADDON_LOADED")
    ilvlr.iLvLrFrame:RegisterEvent("PLAYER_AVG_ITEM_LEVEL_UPDATE")
    ilvlr.iLvLrFrame:RegisterEvent("SOCKET_INFO_UPDATE")
    ilvlr.iLvLrFrame:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
    ilvlr.iLvLrFrame:SetScript("OnEvent", ilvlr.iLvLrOnEvent)
end

function ilvlr:iLvLrOnLoad()
    -- Loop over all item slots by name
    for i, slot_name in pairs(slotDB) do
        if slot_name ~= "ShirtSlot" and slot_name ~= "TabardSlot" then
            local ilvl = utils:get_ilevel_from_slot_name(slot_name)
            if ilvl then
                ilvlr:iLvlrUpdateAll(frameDB[i], slot_name, ilvl)
            end
        end
    end
end

function ilvlr:init_variables()
    if iDuraState == nil then
        -- Show durability by default
        iDuraState = true
    end

    if iColourState == nil then
        -- show colour by default
        iColourState = true
    end

    if iRelicState == nil then
        iRelicState = true
    elseif iRelicState == "enabled" or iRelicState == "disabled" then
        if iRelicState == "enabled" then
            iRelicState = true
        elseif iRelicState == "disabled" then
            iRelicState = false
        end
    end
end

function SlashCmdList.ILVLR(msg)
    if msg == "durability" or msg == "dura" or msg == "d" then
        iDuraState = not iDuraState
        ilvlr:apply_durability_visibility()
        print("iLvLr: Durability turned " .. (iDuraState and "|cff00ff00on|r!" or "|cffff0000off|r!"))
    elseif msg == "colour" or msg == "color" or msg == "c" then
        iColourState = not iColourState
        ilvlr:iLvLrOnItemUpdate()
        print("iLvLr: Colour turned " .. (iColourState and "|cff00ff00on|r!" or "|cffff0000off|r!"))
    else
        print(Title .. " v" .. Core .. "." .. Revision .. "." .. Build)
        print("Available commands:")
        print("|cff00cc66/ilvlr durability|r - Toggle durability display")
        print("|cff00cc66/ilvlr colour|r - Toggle colouring of item level number")
    end
end

--Thanks to John454ss for code help
function ilvlr:iLvLrOnEvent(event)
    if event == "ADDON_LOADED" then
        ilvlr:init_variables()
        ilvlr:apply_durability_visibility()
        ilvlr:iLvLrOnItemUpdate()
    elseif event == "PLAYER_AVG_ITEM_LEVEL_UPDATE" or event == "SOCKET_INFO_UPDATE" then
        ilvlr:iLvLrOnItemUpdate()
    elseif event == "UPDATE_INVENTORY_DURABILITY" then
        ilvlr:iLvLrOnDuraUpdate()
    end
end

function ilvlr:iLvlrUpdateAll(frame, slot_name, ilvl)
    ilvlr:make_ilvl_frame(frame, slot_name, ilvl)
    ilvlr:makeDurability(frame, slot_name)
    ilvlr:makeMod(frame, slot_name)
end

function ilvlr:iLvLrOnItemUpdate()
    for i, slot_name in pairs(slotDB) do
        local ilvl = utils:get_ilevel_from_slot_name(slot_name)
        if ilvl then
            if slot_name ~= "ShirtSlot" and slot_name ~= "TabardSlot" then
                ilvlr:iLvlrUpdateAll(frameDB[i], slot_name, ilvl)
            end
        else
            if iLvlFrames[slot_name] then
                iLvlFrames[slot_name]:Hide()
            end
            if iDuraFrames[slot_name] then
                iDuraFrames[slot_name]:Hide()
            end
            if iModFrames[slot_name] then
                iModFrames[slot_name]:Hide()
            end
        end
    end
end

function ilvlr:iLvLrOnDuraUpdate()
    for i, slot_name in pairs(slotDB) do
        local iLevel = utils:get_ilevel_from_slot_name(slot_name)
        if iLevel then
            ilvlr:makeDurability(frameDB[i], slot_name)
        else
            if iDuraFrames[slot_name] then
                iDuraFrames[slot_name]:Hide()
            end
        end
    end
end

function ilvlr:iLvLrOnModUpdate()
    for i, slot_name in pairs(slotDB) do
        local iLevel = utils:get_ilevel_from_slot_name(slot_name)
        if iLevel then
            if slot_name == "ShirtSlot" or slot_name == "TabardSlot" then
                -- Do Nothing
            else
                ilvlr:makeMod(frameDB[i], slot_name)
            end
        else
            if iModFrames[slot_name] then
                iModFrames[slot_name]:Hide()
            end
        end
    end
end

function ExtractItemString(link)
    local itemString
    if (link) then
    -- itemLink = "|cnIQ4:|Hitem:225749:7345:213743::::::80:72::81:7:6652:10354:10270:1507:10255:10395:10878:1:28:2462:::::|h[Seal of the Void-Touched]|h|r"
        itemString = link:match("|Hitem:([-%d:%a]+)|h")
    end
    return itemString
end


function fetchProfs()
    local prof1, prof2 = GetProfessions()
    local profs = { prof1, prof2 }
    local profIDs = {}

    for _, v in pairs(profs) do
        local _, _, _, _, _, _, skillID = GetProfessionInfo(v)
        tinsert(profIDs, skillID)
    end

    return profIDs
end

function ilvlr:fetchDura(slotName)
    local slotId, _ = GetInventorySlotInfo(slotName)
    if slotId then
        local itemDurability, itemMaxDurability = GetInventoryItemDurability(slotId)
        if itemDurability and itemMaxDurability then
            return itemDurability, itemMaxDurability
        else
            return -1, -1
        end
    end
end

---@return number? socketCount The number of sockets on an item (includes socketed and unsocketed slots)
function ilvlr:get_number_of_sockets(slotName)
    local itemLink = GetInventoryItemLink("player", GetInventorySlotInfo(slotName))
    if itemLink then
        local itemStats = C_Item.GetItemStats(itemLink)
        socketCount = (itemStats["EMPTY_SOCKET_RED"]       or 0) +
            (itemStats["EMPTY_SOCKET_YELLOW"]    or 0) +
            (itemStats["EMPTY_SOCKET_BLUE"]      or 0) +
            (itemStats["EMPTY_SOCKET_META"]      or 0) +
            (itemStats["EMPTY_SOCKET_PRISMATIC"] or 0)
        return socketCount
    end
end

function ilvlr:ilvlr_get_socketed_gem_count(slotName)
    local itemLink = GetInventoryItemLink("player", GetInventorySlotInfo(slotName))
    -- itemLink = "|cnIQ4:|Hitem:225749:7345:213743::::::80:72::81:7:6652:10354:10270:1507:10255:10395:10878:1:28:2462:::::|h[Seal of the Void-Touched]|h|r"
    local itemString = ExtractItemString(itemLink)
    local itemString_parts = strsplittable(":", itemString)

    local gem_count = 0
    -- loop over gem info in itemString (all 4 gem info parts)
    for i = 3, 6 do
        local has_gem = tonumber(itemString_parts[i])
        if has_gem then gem_count = gem_count + 1 end
    end

    return gem_count
end

function ilvlr:make_ilvl_frame(frame, slot_name, ilvl)
    local ilvl_frame = iLvlFrames[slot_name]
    if not ilvl_frame then
        ilvl_frame = CreateFrame("Frame", nil, frame, "BackdropTemplate")
        if utils:is_in_table(frame, left_side_character_pane) then
            ilvl_frame:SetPoint("CENTER", frame, "CENTER", 38, -1)
        elseif utils:is_in_table(frame, right_side_character_pane) then
            ilvl_frame:SetPoint("CENTER", frame, "CENTER", -38, -1)
        elseif frame == CharacterMainHandSlot or frame == CharacterSecondaryHandSlot then
            ilvl_frame:SetPoint("CENTER", frame, "CENTER", 0, 41)
        end

        ilvl_frame:SetSize(10, 10)
        ilvl_frame:SetBackdrop({ bgFile = nil, edgeFile = nil, tile = false, tileSize = 32, edgeSize = 0, insets = { left = 0, right = 0, top = 0, bottom = 0 } })
        ilvl_frame:SetBackdropColor(0, 0, 0, 0)

        local iLvlText = ilvl_frame:CreateFontString(nil, "ARTWORK")
        iLvlText:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
        iLvlText:SetPoint("CENTER", ilvl_frame, "CENTER", 0, 0)
        ilvl_frame.text = iLvlText
    end

    if iColourState then
        local avgItemLevelBags, _, _ = GetAverageItemLevel()
        if ilvl <= avgItemLevelBags - 5 then
            -- red
            ilvl_frame.text:SetFormattedText("|cffff0000%i|r", ilvl)
        elseif ilvl >= avgItemLevelBags + 5  then
            -- green
            ilvl_frame.text:SetFormattedText("|cff00ff00%i|r", ilvl)
        else
            -- white
            ilvl_frame.text:SetFormattedText("|cffffffff%i|r", ilvl)
        end
    elseif iColourState == false then
        ilvl_frame.text:SetFormattedText("|cffffffff%i|r", ilvl)
    end

    ilvl_frame:Show()
    iLvlFrames[slot_name] = ilvl_frame
end

function ilvlr:makeDurability(frame, slot)
    local itemDurability, itemMaxDurability
    local iDura = iDuraFrames[slot]
    if not iDura then
        iDura = CreateFrame("Frame", nil, frame, "BackdropTemplate")
        if utils:is_in_table(frame, left_side_character_pane) then
            iDura:SetPoint("BOTTOM", frame, "BOTTOM", 38, 0)
        elseif utils:is_in_table(frame, right_side_character_pane) then
            iDura:SetPoint("BOTTOM", frame, "BOTTOM", -38, 0)
        elseif frame == CharacterMainHandSlot or frame == CharacterSecondaryHandSlot then
            iDura:SetPoint("BOTTOM", frame, "BOTTOM", 0, 42)
        end

        iDura:SetSize(10, 10)
        iDura:SetBackdrop({ bgFile = nil, edgeFile = nil, tile = false, tileSize = 32, edgeSize = 0, insets = { left = 0, right = 0, top = 0, bottom = 0 } })
        iDura:SetBackdropColor(0, 0, 0, 0)

        local iDuraText = iDura:CreateFontString(nil, "ARTWORK")
        iDuraText:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
        iDuraText:SetPoint("CENTER", iDura, "CENTER", 0, 0)
        iDura.text = iDuraText
        itemDurability, itemMaxDurability = ilvlr:fetchDura(slot)
    else
        itemDurability, itemMaxDurability = ilvlr:fetchDura(slot)
    end

    if itemDurability == -1 and itemMaxDurability == -1 then
        iDura.text:SetFormattedText("|cffffffff|r")
    else
        if itemDurability then
            local itemDurabilityPercentage = (itemDurability / itemMaxDurability) * 100
            if itemDurabilityPercentage > 25 then
                iDura.text:SetFormattedText("|cff00ff00%i%%|r", itemDurabilityPercentage)
            elseif itemDurabilityPercentage > 0 and itemDurabilityPercentage <= 25 then
                iDura.text:SetFormattedText("|cff00ffff%i%%|r", itemDurabilityPercentage)
            elseif itemDurabilityPercentage == 0 then
                iDura.text:SetFormattedText("|cffff0000%i%%|r", itemDurabilityPercentage)
            end
        else
            iDura.text:SetFormattedText("")
        end
        iDuraFrames[slot] = iDura
    end

    if iDuraState then
        iDura:Show()
    end
end

function ilvlr:makeMod(frame, slot_name)
    local iMod = iModFrames[slot_name]
    local slot_ilvl = utils:get_ilevel_from_slot_name(slot_name)
    if not iMod then
        iMod = CreateFrame("Frame", nil, frame, "BackdropTemplate")

        if utils:is_in_table(frame, left_side_character_pane) then
            iMod:SetPoint("TOP", frame, "TOP", 38, -3)
        elseif utils:is_in_table(frame, right_side_character_pane) then
            iMod:SetPoint("TOP", frame, "TOP", -38, -3)
        elseif frame == CharacterMainHandSlot or frame == CharacterSecondaryHandSlot then
            iMod:SetPoint("TOP", frame, "TOP", 0, 39)
        end

        iMod:SetSize(10, 10)
        iMod:SetBackdrop({ bgFile = nil, edgeFile = nil, tile = false, tileSize = 32, edgeSize = 0, insets = { left = 0, right = 0, top = 0, bottom = 0 } })
        iMod:SetBackdropColor(0, 0, 0, 0)

        local iModText = iMod:CreateFontString(nil, "ARTWORK")
        iModText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
        iModText:SetPoint("CENTER", iMod, "CENTER", 0, 0)
        iMod.text = iModText
    end

    local socket_count = ilvlr:get_number_of_sockets(slot_name)
    local gem_count = 0
    if socket_count > 0 then
        gem_count = ilvlr:ilvlr_get_socketed_gem_count(slot_name)
    end

    local item_is_enchantable
    local enchant_id

    if slot_ilvl >= 350 then
        for _, enchantable_slot in pairs(EnchantableSlotsTWW) do
            if enchantable_slot == slot_name then
                item_is_enchantable = true
                enchant_id = utils:get_enchantid_for_slotname(slot_name)
            end
        end
    end

    local is_missing_gems = false
    if socket_count > gem_count then
        is_missing_gems = true
    end

    if socket_count > 0 and item_is_enchantable then
        if not enchant_id and is_missing_gems then      -- Missing (Red E) Enchant and Missing (Red G) Gem
            iMod.text:SetFormattedText("|cffff0000%s|r|cffff0000%s|r", "E", "G")
        elseif not enchant_id and not is_missing_gems then -- Missing (Red E) Enchant, Found (Green G) Gem
            iMod.text:SetFormattedText("|cffff0000%s|r|cff00ff00%s|r", "E", "G")
        elseif enchant_id and is_missing_gems then      -- Found (Green E) Enchant, Missing (Red G) Gem
            iMod.text:SetFormattedText("|cff00ff00%s|r|cffff0000%s|r", "E", "G")
        elseif enchant_id and not is_missing_gems then     -- Found (Green E) Enchant and Found (Green G) Gem
            iMod.text:SetFormattedText("|cff00ff00%s|r|cff00ff00%s|r", "E", "G")
        end
    elseif socket_count > 0 and not item_is_enchantable then
        if is_missing_gems then
            iMod.text:SetFormattedText("|cffff0000%s|r", "G")  -- Red G, missing a gem
        else
            iMod.text:SetFormattedText("|cff00ff00%s|r", "G") -- Green G, has full gems
        end
    elseif socket_count == 0 and item_is_enchantable then
        if not enchant_id then
            iMod.text:SetFormattedText("|cffff0000%s|r", "E") -- Red E, missing enchant
        else
            iMod.text:SetFormattedText("|cff00ff00%s|r", "E") -- Green E, has enchant
        end
    elseif socket_count == 0 and not item_is_enchantable then
        iMod.text:SetFormattedText("")
    end

    iModFrames[slot_name] = iMod

    iMod:Show()
end

function ilvlr:apply_durability_visibility()
    for _, frame in pairs(iDuraFrames) do
        if iDuraState then
            frame:Show()
        else
            frame:Hide()
        end
    end
end

ilvlr:main()
