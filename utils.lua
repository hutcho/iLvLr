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


function utils:SplitString(itemString)
    -- itemString = 222817:7407:::::::80:72::13:5:10421:9633:8902:9624:10222:6:28:2734:29:40:30:32:38:5:40:2352:46:211296::::Player-3725-09D2C3B8:
    local list = {}
    local basestring = itemString .. ":"
    -- [] is a char-set. it matches all characters inside []
    -- ^ is a complement operator. so ^: means any character that is not :
    -- * means 0 or more repeats
    local pattern = "([^:]*):"
    -- return a string in which basestring has ALL occurences of pattern
    --  function is called every time a match occurs
    -- with all captured substrings passed as arguments
    -- in order; if the pattern specifies no captures, then the whole match is passed as a sole argument.

    local repl = function(match) table.insert(list, match) end
    local _ = string.gsub(basestring, pattern, repl);

    -- parts = {}
    -- for part in string.gfind(itemString, "[^:]") do
    --   table.insert(parts, part)
    -- end

    -- or try
    -- _, _, gemID1, gemID2, gemID3, gemID4  = strsplit(":", itemLink)

    return list
end
