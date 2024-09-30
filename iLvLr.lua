-- Original author: JerichoHM
-- Original maintainer: LownIgnitus
-- Current maintainer (2024-09-24): hutcho

local addonName, addonTable = ...
local Title = "|cff00ff00" .. addonName .. "|r"
local core_version, revision_version, build_version = 1, 2, 0
local Core = "|cffFF4500" .. core_version .. "|r"
local Revision = "|cffFF4500" .. revision_version .. "|r"
local Build = "|cffFF4500" .. build_version .. "|r"
SLASH_ILVLR1 = '/ilvlr'

local utils = addonTable.utils

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
    72 -- Fury
}

local iLvlFrames = {}
local iDuraFrames = {}
local iModFrames = {}

addonTable.f = CreateFrame("Frame", "iLvLrmain", CharacterFrame, "BackdropTemplate")
addonTable.f:SetScript("OnShow", function(self) iLvLrOnLoad() end)

function iLvLrMain()
    addonTable.iLvLrFrame = CreateFrame("Frame", "iLvLrFrame", UIParent)
    addonTable.iLvLrFrame:RegisterEvent("ADDON_LOADED")
    addonTable.iLvLrFrame:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
    addonTable.iLvLrFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    addonTable.iLvLrFrame:RegisterEvent("SOCKET_INFO_UPDATE")
    addonTable.iLvLrFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    addonTable.iLvLrFrame:SetScript("OnEvent", iLvLrOnEvent)
end

function iLvLrVariableCheck()
    if iDuraState == nil then
        iDuraState = true
    elseif iDuraState == "enabled" or iDuraState == "disabled" then
        if iDuraState == "enabled" then
            iDuraState = true
        elseif iDuraState == "disabled" then
            iDuraState = false
        end
    end

    if iDuraState == false then
        iDuraToggle(iDuraState)
    end

    if iColourState == nil then
        iColourState = true
    elseif iColourState == "enabled" or iColourState == "disabled" then
        if iColourState == "enabled" then
            iColourState = true
        elseif  iColourState == "disabled" then
            iColourState = false
        end
    end

    if iRelicState == nil then
        iRelicState = true
    elseif iRelicState == "enabled" or iRelicState == "disabled" then
        if iRelicState == "enabled" then
            iRelicState = true
        elseif  iRelicState == "disabled" then
            iRelicState = false
        end
    end
end



function SlashCmdList.ILVLR(msg)
    if msg == "durability" then
        if iDuraState == true then
            iDuraState = false
            iDuraToggle(iDuraState)
            print("Durability turned |cffff0000off|r!")
        elseif iDuraState == false then
            iDuraState = true
            iDuraToggle(iDuraState)
            print("Durability turned |cff00ff00on|r!")
        end
    elseif msg == "colour" then
        if iColourState == true then
            iColourState = false
            print("ilvl colour turned |cffff0000off|r!")
        elseif iColourState == false then
            iColourState = true
            print("ilvl colour turned |cff00ff00on|r!")
        end
    else
        print("Thank you for using " .. Title)
        print("Version: " .. Core .. "." .. Revision .. "." .. Build)
        print("Author: |cffffcc00JerichoHM|r / Maintainer: |cffDA70D6LownIgnitus|r")
        print("Slash Commands are listed below and start with /iLvLr")
        print("      durability - Disables or Enables the durability tracker")
        print("      colour - Disables colouring ilvl by +/- avg")
    end
end

--Thanks to John454ss for code help
function iLvLrOnEvent(self, event, what)
    if event == "ADDON_LOADED" then
        iLvLrVariableCheck()
    elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then
--		print("Talent Change.")
        mainSave = 0
        offSave = 0
--		print("Saves cleared.")
    elseif event == "PLAYER_EQUIPMENT_CHANGED" then
        addonTable.iLvLrFrame:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")
        addonTable.iLvLrFrame:RegisterEvent("BAG_UPDATE_DELAYED")
    elseif event == "BAG_UPDATE_DELAYED" then
        addonTable.iLvLrFrame:UnregisterEvent("BAG_UPDATE_DELAYED")
        if not InCombatLockdown() then
            --print("Equipment Update")
            iLvLrOnItemUpdate()
            iLvLrOnDuraUpdate()
            iLvLrOnModUpdate()
            addonTable.iLvLrFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
        else
            addonTable.iLvLrFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        --print("Equipment Update")
        addonTable.iLvLrFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
        iLvLrOnItemUpdate()
        iLvLrOnModUpdate()
        addonTable.iLvLrFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    elseif event == "SOCKET_INFO_UPDATE" then
        --print("Gem Change/Upgrade Update")
        iLvLrOnItemUpdate()
        iLvLrOnModUpdate()
    elseif event == "UPDATE_INVENTORY_DURABILITY" then
        --print("Durability Update")
        iLvLrOnDuraUpdate()
    end
end


function iLvlrUpdateAll(frame, slot_name, ilvl)
    make_ilvl_frame(frame, slot_name, ilvl)
    makeDurability(frame, slot_name)
    makeMod(frame, slot_name)
end

function iLvLrOnLoad()
    -- Loop over all item slots by name
    for i, slot_name in pairs(slotDB) do
        if slot_name ~= "ShirtSlot" and slot_name ~= "TabardSlot" then
            local ilvl = utils:get_ilevel_from_slot_name(slot_name)
            if ilvl then
                iLvlrUpdateAll(frameDB[i], slot_name, ilvl)
            end
        end
    end
end

function iLvLrOnItemUpdate()
    for i, slot_name in pairs(slotDB) do
        local ilvl = utils:get_ilevel_from_slot_name(slot_name)
        if ilvl then
            if slot_name ~= "ShirtSlot" and slot_name ~= "TabardSlot" then
                iLvlrUpdateAll(frameDB[i], slot_name, ilvl)
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
    --print("in OnDuraUpdate")
    for k ,v in pairs(slotDB) do
        local iLevel = utils:get_ilevel_from_slot_name(v)
        if iLevel then
            makeDurability(frameDB[k], v)
        else
            if iDuraFrames[v] then
                iDuraFrames[v]:Hide()
            end
        end
    end
end

function iLvLrOnModUpdate()
    for k ,v in pairs(slotDB) do
        local iLevel = utils:get_ilevel_from_slot_name(v)
        if iLevel then
            if v == "ShirtSlot" or v == "TabardSlot" then
                -- Do Nothing
            else
                makeMod(frameDB[k], v)
            end
        else
            if iModFrames[v] then
                iModFrames[v]:Hide()
            end
        end
    end
end

function GetItemLinkInfo(link)
    local itemColor, itemString, itemName
    if ( link ) then
        itemColor, itemString, itemName = link:match("(|c%x+)|Hitem:([-%d:%a]+)|h%[(.-)%]|h|r");
    end
    return itemName, itemString, itemColor
end

function SplitString(seperator, value)
    local list = {}
    gsub(value..seperator, "([^"..seperator.."]*)"..seperator, function(v) table.insert(list, v) end);
    return list
end

function SplitValue(value)
    if ( value == "" ) then
        value = "0"
    end
    return tonumber(value)
end

function fetchProfs()
    local prof1, prof2 = GetProfessions()
    local profs = {prof1, prof2}
    local profIDs = {}

    for k, v in pairs(profs) do
        local _,_,_,_,_,_,skillID = GetProfessionInfo(v)
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

function fetchBaseSocket(slotName)
    local itemLink = GetInventoryItemLink("player", GetInventorySlotInfo(slotName))

    local parsedItemDataTable = {}
    local _, _, parsedItemData = string.find(itemLink, "^|c%x+|H(.+)|h%[.*%]")

    for v in string.gmatch(parsedItemData, "[^:]+") do
        tinsert(parsedItemDataTable, v)
    end

    local baseItem = "|Hitem:" .. parsedItemDataTable[2] .. ":0"
    local _, itemLink = C_Item.GetItemInfo(baseItem)
    local baseSocketCount = 0
    for i = 1, 4 do
        if  _G["iLvLrScannerTexture" .. i]  then
             _G["iLvLrScannerTexture" .. i]:SetTexture("")
         end
    end

    if not iLvLrScanner then CreateFrame("GameToolTip", "iLvLrScanner", UIParent, "GameTooltipTemplate") end
    local ttScanner = iLvLrScanner

    ttScanner:SetOwner(addonTable.iLvLrFrame, "ANCHOR_NONE")
    ttScanner:ClearLines()
    if itemLink == nil or itemLink == "" or itemLink == "0" then
        print("Hyperlink has not loaded fully yet.")
    else
        ttScanner:SetHyperlink(itemLink)
        if ttScanner == nil then
            print("Hyperlink has not loaded fully yet.")
        end
    end

    for i = 1, 4 do
        local texture = _G["iLvLrScannerTexture" .. i]:GetTexture()
        if texture then
            baseSocketCount = baseSocketCount + 1
        end
    end



    return baseSocketCount
end



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

        ilvl_frame:SetSize(10,10)
        ilvl_frame:SetBackdrop({bgFile = nil, edgeFile = nil, tile = false, tileSize = 32, edgeSize = 0, insets = {left = 0, right = 0, top = 0, bottom = 0}})
        ilvl_frame:SetBackdropColor(0,0,0,0)

        local iLvlText = ilvl_frame:CreateFontString(nil, "ARTWORK")
        iLvlText:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
        iLvlText:SetPoint("CENTER", ilvl_frame, "CENTER", 0, 0)
        ilvl_frame.text = iLvlText
    end

    if iColourState then
        local _, avgItemLevelEquipped, _ = GetAverageItemLevel()
        if ilvl <= avgItemLevelEquipped - 10 then
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

        if frame == CharacterHeadSlot or frame == CharacterNeckSlot or frame == CharacterShoulderSlot or frame == CharacterBackSlot or frame == CharacterChestSlot or frame == CharacterWristSlot or frame == CharacterShirtSlot or frame == CharacterTabardSlot then
                iDura:SetPoint("BOTTOM", frame, "BOTTOM", 38, 0)
            elseif frame == CharacterHandsSlot or frame == CharacterWaistSlot or frame == CharacterLegsSlot or frame == CharacterFeetSlot or frame == CharacterFinger0Slot or frame == CharacterFinger1Slot or frame == CharacterTrinket0Slot or frame == CharacterTrinket1Slot then
                iDura:SetPoint("BOTTOM", frame, "BOTTOM", -38, 0)
            elseif frame == CharacterMainHandSlot or frame == CharacterSecondaryHandSlot then
                iDura:SetPoint("BOTTOM", frame, "BOTTOM", 0, 42)
            end

        iDura:SetSize(10,10)
        iDura:SetBackdrop({bgFile = nil, edgeFile = nil, tile = false, tileSize = 32, edgeSize = 0, insets = {left = 0, right = 0, top = 0, bottom = 0}})
        iDura:SetBackdropColor(0,0,0,0)

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

    if iDuraState == true then
        iDura:Show()
    end
end

function makeMod(frame, slot_name)
    local iMod = iModFrames[slot_name]
    local slot_ilvl = utils:get_ilevel_from_slot_name(slot_name)
    if not iMod then
        iMod = CreateFrame("Frame", nil, frame, "BackdropTemplate")

        if frame == CharacterHeadSlot or frame == CharacterNeckSlot or frame == CharacterShoulderSlot or frame == CharacterBackSlot or frame == CharacterChestSlot or frame == CharacterWristSlot or frame == CharacterShirtSlot or frame == CharacterTabardSlot then
                iMod:SetPoint("TOP", frame, "TOP", 38, -3)
            elseif frame == CharacterHandsSlot or frame == CharacterWaistSlot or frame == CharacterLegsSlot or frame == CharacterFeetSlot or frame == CharacterFinger0Slot or frame == CharacterFinger1Slot or frame == CharacterTrinket0Slot or frame == CharacterTrinket1Slot then
                iMod:SetPoint("TOP", frame, "TOP", -38, -3)
            elseif frame == CharacterMainHandSlot or frame == CharacterSecondaryHandSlot then
                iMod:SetPoint("TOP", frame, "TOP", 0, 39)
            end

        iMod:SetSize(10,10)
        iMod:SetBackdrop({bgFile = nil, edgeFile = nil, tile = false, tileSize = 32, edgeSize = 0, insets = {left = 0, right = 0, top = 0, bottom = 0}})
        iMod:SetBackdropColor(0,0,0,0)

        local iModText = iMod:CreateFontString(nil, "ARTWORK")
        iModText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
        iModText:SetPoint("CENTER", iMod, "CENTER", 0, 0)
        iMod.text = iModText
    end

    local foundGems = fetchGem(slot_name)
    local numSockets = fetchSocketCount(slot_name)
    local item_is_enchantable = false

    local enchant_id


    -- if slot_ilvl <= 376 then
    --     if slot_name == "WaistSlot" then
    --         item_is_enchantable = true

    --         local baseSockets = fetchBaseSocket(slot_name)
    --         if (baseSockets - numSockets) == -1 then
    --             enchant_id = 1
    --         else
    --             enchant_id = nil
    --         end
    --     else
    --         for i, slot_name in pairs(item_is_enchantable) do
    --             if v == slot_name then
    --                 item_is_enchantable = true
    --                 enchant_id = utils:get_enchantid_for_slotname(slot_name)
    --             end
    --         end
    --     end
    -- end

    -- elseif slot_ilvl ~= "" and slot_ilvl > 20 then
    --     if slot_name == "SecondaryHandSlot" and slot_ilvl < 151 then
    --         local offHand = GetInventoryItemID("player", GetInventorySlotInfo("SecondaryHandSlot"))
    --         local _, _,itemRarity, _, _, itemClass, itemSubclass, _, _, _, _ = GetItemInfo(offHand)
    --         if itemClass == "Weapon" or itemRarity == 7 then
    --             item_is_enchantable = true
    --             enchant_id = utils:get_enchantid_for_slotname(slot_name)
    --         end
    --         --print(itemClass)
    --         --print(itemSubclass)
    --     elseif slot_ilvl > 48 and slot_ilvl < 61 then
    --         local mainHand = GetInventoryItemID("player", GetInventorySlotInfo("MainHandSlot"))
    --         if mainHand ~= nil then
    --             local _, _, _, _, _, itemClass, _, _, _, _, _ = GetItemInfo(mainHand)
    --             local _, englishClass, _ = UnitClass("player")
    --             if slot_name == "MainHandSlot" or slot_name == "SecondaryHandSlot" then
    --                 if itemClass == "Weapon" then
    --                     if englishClass == "DEATHKNIGHT" then
    --                         item_is_enchantable = true
    --                         enchant_id = utils:get_enchantid_for_slotname(slot_name)
    --                     end
    --                 else
    --                     item_is_enchantable = false
    --                 end
    --             else
    --                 for k ,v in pairs(isEnchantableWoD) do
    --                     if v == slot_name then
    --                         item_is_enchantable = true
    --                         enchant_id = utils:get_enchantid_for_slotname(slot_name)
    --                     end
    --                 end
    --             end
    --         end
    --     elseif slot_ilvl > 60 and slot_ilvl < 141 then
    --         if slot_name == "SecondaryHandSlot" then
    --             local offHand = GetInventoryItemID("player", GetInventorySlotInfo("SecondaryHandSlot"))
    --             -- itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo()
    --             local _, _, _, _, _, itemType, _, _, _, _, _ = GetItemInfo(offHand)
    --             if offHand ~= nil then
    --                 if itemType == "Weapon" then
    --                     item_is_enchantable = true
    --                     enchant_id = utils:get_enchantid_for_slotname(slot_name)
    --                 else
    --                     item_is_enchantable = false
    --                 end
    --             end
    --         elseif slot_name == "WristSlot" then
    --             for k, v in pairs(profIDs) do
    --                 if v == 333 then
    --                     item_is_enchantable = true
    --                     enchant_id = utils:get_enchantid_for_slotname(slot_name)
    --                 end
    --             end
    --         elseif slot_name == "WaistSlot" then
    --             for k, v in pairs(profIDs) do
    --                 if v == 202 then
    --                     item_is_enchantable = true
    --                     enchant_id = utils:get_enchantid_for_slotname(slot_name)
    --                 end
    --             end
    --         elseif slot_name == "BackSlot" then
    --             for k, v in pairs(profIDs) do
    --                 if v == 197 then
    --                     item_is_enchantable = true
    --                     enchant_id = utils:get_enchantid_for_slotname(slot_name)
    --                 end
    --             end
    --         else
    --             for k ,v in pairs(isEnchantableBfA) do
    --                 if v == slot_name then
    --                     item_is_enchantable = true
    --                     enchant_id = utils:get_enchantid_for_slotname(slot_name)
    --                 end
    --             end
    --         end
    --     elseif slot_ilvl > 140 then
    --         if slot_name == "SecondaryHandSlot" then
    --             for k,v in pairs(dualWield) do
    --                 if v == specID then
    --                     item_is_enchantable = true
    --                     enchant_id = utils:get_enchantid_for_slotname(slot_name)
    --                 end
    --             end
    --         elseif slot_name == "HandsSlot" then
    --             item_is_enchantable = false
    --             if englishClass == "DEATHKNIGHT" or englishClass == "WARRIOR" or englishClass == "PALADIN" then
    --                 item_is_enchantable = true
    --                 enchant_id = utils:get_enchantid_for_slotname(slot_name)
    --             end
    --             for k,v in pairs(profIDs) do
    --                 if v == 182 or v == 186 or v == 393 then --182 Herbalism, 186 Mining, 393 Skining
    --                     item_is_enchantable = true
    --                     enchant_id = utils:get_enchantid_for_slotname(slot_name)
    --                 end
    --             end
    --         else
    --             for k,v in pairs(isEnchantableSL) do
    --                 if v == slot_name then
    --                     item_is_enchantable = true
    --                     enchant_id = utils:get_enchantid_for_slotname(slot_name)
    --                 end
    --             end
    --         end
    --     else


    if slot_ilvl >= 350 then
        for _, enchantable_slot in pairs(EnchantableSlotsTWW) do
            if enchantable_slot == slot_name then
                item_is_enchantable = true
                enchant_id = utils:get_enchantid_for_slotname(slot_name)
            end
        end
    end

    if numSockets > 0 and item_is_enchantable then
        if not enchant_id and foundGems < numSockets then -- Missing (Red) Enchant and Gem
            iMod.text:SetFormattedText("|cffff0000%s|r|cffff0000%s|r", "E", "G")
        elseif not enchant_id and foundGems == numSockets then -- Missing (Red) Enchant, Found (Green) Gem
            iMod.text:SetFormattedText("|cffff0000%s|r|cff00ff00%s|r", "E", "G")
        elseif enchant_id and foundGems < numSockets then -- Found (Green) Enchant, Missing(Red) Gem
            iMod.text:SetFormattedText("|cff00ff00%s|r|cffff0000%s|r", "E", "G")
        elseif enchant_id and foundGems == numSockets then -- Found (Green) Enchant and Gem
            iMod.text:SetFormattedText("|cff00ff00%s|r|cff00ff00%s|r", "E", "G")
        end
    elseif numSockets > 0 and not item_is_enchantable then
        if foundGems < numSockets then -- Missing (Red) Gem
            iMod.text:SetFormattedText("|cffff0000%s|r", "G")
        elseif foundGems == numSockets then -- Found (Green) Gem
            iMod.text:SetFormattedText("|cff00ff00%s|r", "G")
        end
    elseif numSockets == 0 and item_is_enchantable then
        if enchant_id then -- Item is enchanted
            iMod.text:SetFormattedText("|cff00ff00%s|r", "E")
        else -- Item not chanted
            iMod.text:SetFormattedText("|cffff0000%s|r", "E")
        end
    elseif numSockets == 0 and not item_is_enchantable then
        iMod.text:SetFormattedText("")
    end

    iModFrames[slot_name] = iMod

    iMod:Show()
end

function iDuraToggle(state)
--[[	if iDuraState == false then
        print("iDuraState = false.")
    elseif iDuraState == true then
        print("iDuraState = true.")
    end]]
    for k, v in pairs(iDuraFrames) do
        if state == true then
            v:Show()
        elseif state == false then
            v:Hide()
        end
    end
end

iLvLrMain()
