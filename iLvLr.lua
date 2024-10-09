-- Original author: JerichoHM
-- Original maintainer: LownIgnitus
-- Current maintainer (2024-09-24): hutcho

local addonName, addonTable = ...
local Title = "|cff00ff00" .. addonName .. "|r"
local core_version, revision_version, build_version = 1, 1, 0
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
    ilvlr.iLvLrFrame:SetScript("OnEvent", iLvLrOnEvent)
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
        iLvLrOnItemUpdate()
        print("iLvLr: Colour turned " .. (iColourState and "|cff00ff00on|r!" or "|cffff0000off|r!"))
    else
        print(Title .. " v" .. Core .. "." .. Revision .. "." .. Build)
        print("Available commands:")
        print("|cff00cc66/ilvlr durability|r - Toggle durability display")
        print("|cff00cc66/ilvlr colour|r - Toggle colouring of item level number")
    end
end

--Thanks to John454ss for code help
function iLvLrOnEvent(self, event)
    if event == "ADDON_LOADED" then
        ilvlr:init_variables()
        ilvlr:apply_durability_visibility()
        iLvLrOnItemUpdate()
    elseif event == "PLAYER_AVG_ITEM_LEVEL_UPDATE" or event == "SOCKET_INFO_UPDATE" then
        iLvLrOnItemUpdate()
    elseif event == "UPDATE_INVENTORY_DURABILITY" then
        iLvLrOnDuraUpdate()
    end
end

function ilvlr:iLvlrUpdateAll(frame, slot_name, ilvl)
    make_ilvl_frame(frame, slot_name, ilvl)
    makeDurability(frame, slot_name)
    makeMod(frame, slot_name)
end

function iLvLrOnItemUpdate()
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

function iLvLrOnDuraUpdate()
    for i, slot_name in pairs(slotDB) do
        local iLevel = utils:get_ilevel_from_slot_name(slot_name)
        if iLevel then
            makeDurability(frameDB[i], slot_name)
        else
            if iDuraFrames[slot_name] then
                iDuraFrames[slot_name]:Hide()
            end
        end
    end
end

function iLvLrOnModUpdate()
    for i, slot_name in pairs(slotDB) do
        local iLevel = utils:get_ilevel_from_slot_name(slot_name)
        if iLevel then
            if slot_name == "ShirtSlot" or slot_name == "TabardSlot" then
                -- Do Nothing
            else
                makeMod(frameDB[i], slot_name)
            end
        else
            if iModFrames[slot_name] then
                iModFrames[slot_name]:Hide()
            end
        end
    end
end

function GetItemLinkInfo(link)
    local itemColor, itemString, itemName
    if (link) then
        itemColor, itemString, itemName = link:match("(|c%x+)|Hitem:([-%d:%a]+)|h%[(.-)%]|h|r");
    end
    return itemName, itemString, itemColor
end

function SplitString(seperator, value)
    local list = {}
    gsub(value .. seperator, "([^" .. seperator .. "]*)" .. seperator, function(v) table.insert(list, v) end);
    return list
end

function SplitValue(value)
    if (value == "") then
        value = "0"
    end
    return tonumber(value)
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

function fetchDura(slotName)
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

function fetchSocketCount(slotName)
    local itemLink = GetInventoryItemLink("player", GetInventorySlotInfo(slotName))
    if itemLink then
        local itemStats = C_Item.GetItemStats(itemLink)

        local socketCount = 0
        socketCount = (itemStats["EMPTY_SOCKET_RED"] or 0) +
            (itemStats["EMPTY_SOCKET_YELLOW"] or 0) +
            (itemStats["EMPTY_SOCKET_BLUE"] or 0) +
            (itemStats["EMPTY_SOCKET_META"] or 0) +
            (itemStats["EMPTY_SOCKET_PRISMATIC"] or 0)

        return socketCount
    end
end

function fetchGem(slotName)
    local itemLink = GetInventoryItemLink("player", GetInventorySlotInfo(slotName))
    local foundGems = 0

    local _, itemString, _ = GetItemLinkInfo(itemLink)
    local ids = SplitString(":", itemString)
    local gem1 = SplitValue(ids[3])
    local gem2 = SplitValue(ids[4])
    local gem3 = SplitValue(ids[5])
    local gem4 = SplitValue(ids[6])

    if gem1 > 0 then foundGems = foundGems + 1 end
    if gem2 > 0 then foundGems = foundGems + 1 end
    if gem3 > 0 then foundGems = foundGems + 1 end
    if gem4 > 0 then foundGems = foundGems + 1 end

    return foundGems
end

-- function fetchBaseSocket(slotName)
--     local itemLink = GetInventoryItemLink("player", GetInventorySlotInfo(slotName))

--     local parsedItemDataTable = {}
--     local _, _, parsedItemData = string.find(itemLink, "^|c%x+|H(.+)|h%[.*%]")

--     for v in string.gmatch(parsedItemData, "[^:]+") do
--         tinsert(parsedItemDataTable, v)
--     end

--     local baseItem = "|Hitem:" .. parsedItemDataTable[2] .. ":0"
--     local _, itemLink = C_Item.GetItemInfo(baseItem)
--     local baseSocketCount = 0
--     for i = 1, 4 do
--         if  _G["iLvLrScannerTexture" .. i]  then
--              _G["iLvLrScannerTexture" .. i]:SetTexture("")
--          end
--     end

--     if not iLvLrScanner then CreateFrame("GameToolTip", "iLvLrScanner", UIParent, "GameTooltipTemplate") end
--     local ttScanner = iLvLrScanner

--     ttScanner:SetOwner(addonTable.iLvLrFrame, "ANCHOR_NONE")
--     ttScanner:ClearLines()
--     if itemLink == nil or itemLink == "" or itemLink == "0" then
--         print("Hyperlink has not loaded fully yet.")
--     else
--         ttScanner:SetHyperlink(itemLink)
--         if ttScanner == nil then
--             print("Hyperlink has not loaded fully yet.")
--         end
--     end

--     for i = 1, 4 do
--         local texture = _G["iLvLrScannerTexture" .. i]:GetTexture()
--         if texture then
--             baseSocketCount = baseSocketCount + 1
--         end
--     end



--     return baseSocketCount
-- end



function make_ilvl_frame(frame, slot_name, ilvl)
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
        elseif ilvl >= avgItemLevelEquipped + 10 then
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

function makeDurability(frame, slot)
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
        itemDurability, itemMaxDurability = fetchDura(slot)
    else
        itemDurability, itemMaxDurability = fetchDura(slot)
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

function makeMod(frame, slot_name)
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

    local foundGems = fetchGem(slot_name)
    local numSockets = fetchSocketCount(slot_name)
    local item_is_enchantable = false

    local enchant_id

    if slot_ilvl >= 350 then
        for _, enchantable_slot in pairs(EnchantableSlotsTWW) do
            if enchantable_slot == slot_name then
                item_is_enchantable = true
                enchant_id = utils:get_enchantid_for_slotname(slot_name)
            end
        end
    end

    if numSockets > 0 and item_is_enchantable then
        if not enchant_id and foundGems < numSockets then      -- Missing (Red) Enchant and Gem
            iMod.text:SetFormattedText("|cffff0000%s|r|cffff0000%s|r", "E", "G")
        elseif not enchant_id and foundGems == numSockets then -- Missing (Red) Enchant, Found (Green) Gem
            iMod.text:SetFormattedText("|cffff0000%s|r|cff00ff00%s|r", "E", "G")
        elseif enchant_id and foundGems < numSockets then      -- Found (Green) Enchant, Missing(Red) Gem
            iMod.text:SetFormattedText("|cff00ff00%s|r|cffff0000%s|r", "E", "G")
        elseif enchant_id and foundGems == numSockets then     -- Found (Green) Enchant and Gem
            iMod.text:SetFormattedText("|cff00ff00%s|r|cff00ff00%s|r", "E", "G")
        end
    elseif numSockets > 0 and not item_is_enchantable then
        if foundGems < numSockets then      -- Missing (Red) Gem
            iMod.text:SetFormattedText("|cffff0000%s|r", "G")
        elseif foundGems == numSockets then -- Found (Green) Gem
            iMod.text:SetFormattedText("|cff00ff00%s|r", "G")
        end
    elseif numSockets == 0 and item_is_enchantable then
        if enchant_id then -- Item is enchanted
            iMod.text:SetFormattedText("|cff00ff00%s|r", "E")
        else               -- Item not chanted
            iMod.text:SetFormattedText("|cffff0000%s|r", "E")
        end
    elseif numSockets == 0 and not item_is_enchantable then
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
