local addonName, addonTable = ...

addonTable.utils = {}

---@class utilityfunctions
local utils = addonTable.utils


---@return number? ilvl ilvl for the slot_name
function utils:get_ilevel_from_slot_name(slot_name)
    local itemLink = GetInventoryItemLink("player", GetInventorySlotInfo(slot_name))
    if itemLink then
        return utils:get_ilevel_from_item_link(itemLink)
    end
end

---@return number? ilvl ilvl for the item link
function utils:get_ilevel_from_item_link(itemLink)
    if itemLink then
        local effectiveILvl, _, _ = C_Item.GetDetailedItemLevelInfo(itemLink)
        return effectiveILvl
    end
end

function utils:is_in_table(slot, table)
    for _, table_slot in ipairs(table) do
        if slot == table_slot then
            return true
        end
    end
    return false
end

---@param slotName string The slot name e.g. "ChestSlot", or "BackSlot"
---@return string? enchantId The enchant on the item
function utils:get_enchantid_for_slotname(slotName)
    ---@type string
    local enchantId, _
    ---@type string?
    local itemLink = GetInventoryItemLink("player", GetInventorySlotInfo(slotName))
    if itemLink then
        _, _, enchantId = strsplit(":", itemLink)
        -- print("Enchant ID:", enchantId)
        if enchantId == "" then
            return nil
        end
        return enchantId
    end
end
