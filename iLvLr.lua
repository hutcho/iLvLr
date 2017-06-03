-- Title: iLvLr
-- Author: JerichoHM / LownIgnitus
-- Version: 2.3.305
-- Desc: iLvL identifier

--Version Information
local iLvLr    = {}
local addon    = iLvLr
local Title    = "|cff00ff00iLvLr|r"
local Core     = "|cffFF45002|r"
local Revision = "|cffFF45003|r"
local Build    = "|cffFF4500305|r"
SLASH_ILVLR1 = '/ilvlr'

local frameDB = {CharacterHeadSlot,
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

local frameIDB = {InspectHeadSlot,
					InspectNeckSlot,
					InspectShoulderSlot,
					InspectBackSlot,
					InspectChestSlot,
					InspectWristSlot,
					InspectShirtSlot,
					InspectTabardSlot,
					InspectMainHandSlot,
					InspectSecondaryHandSlot,
					InspectHandsSlot,
					InspectWaistSlot,
					InspectLegsSlot,
					InspectFeetSlot,
					InspectFinger0Slot,
					InspectFinger1Slot,
					InspectTrinket0Slot,
					InspectTrinket1Slot
				}

local slotDB = {"HeadSlot",
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

local isEnchantable = {"ShoulderSlot",
					"BackSlot",
					"ChestSlot",
					"MainHandSlot",
					"SecondaryHandSlot",
					"LegsSlot",
					"FeetSlot"
					}

local isEnchantableWoD = {"NeckSlot",
							"ShoulderSlot",
							"BackSlot",
							"HandsSlot",
							"MainHandSlot",
							"Finger0Slot",
							"Finger1Slot"
							}
					
local iLevelFilter = ITEM_LEVEL:gsub( "%%d", "(%%d+)" )

local iEqAvg, iAvg, lastInspecReady, InspecGUID
local inspec = false
local z = 0
local iLvl = {}
local mainSave = 0
local mainISave = 0
local offSave = 0
local offISave = 0
local iLvlFrames  = {}
local iDuraFrames = {}
local iModFrames  = {}
local iLvlIFrames  = {}
local iDuraIFrames = {}
local iModIFrames  = {}
local iLvLrReportFrame = CreateFrame("Frame", "iLvLrInspecFrame")
iLvLrReportFrame:ClearAllPoints()
iLvLrReportFrame:SetHeight(300)
iLvLrReportFrame:SetWidth(1000)
iLvLrReportFrame.text = iLvLrReportFrame:CreateFontString(nil, "BACKGROUND", "PVPInfoTextFont")
iLvLrReportFrame.text:SetAllPoints()
iLvLrReportFrame.text:SetTextHeight(13)
iLvLrReportFrame:SetAlpha(1)

addon.f = CreateFrame("Frame", "iLvLrmain", CharacterFrame)
addon.f:SetScript("OnShow", function(self, elapsed)
	--print("ILvLrOnLoad call @showpaperdoll")
	iLvLrOnLoad()
end)
				
function iLvLrMain()
	iLvLrFrame = CreateFrame("Frame", "iLvLrFrame", UIParent)
	iLvLrFrame:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
	iLvLrFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	iLvLrFrame:RegisterEvent("SOCKET_INFO_UPDATE")
	iLvLrFrame:RegisterEvent("ITEM_UPGRADE_MASTER_UPDATE")
	iLvLrFrame:RegisterEvent("INSPECT_READY")
--	iLvLrFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
	iLvLrFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	iLvLrFrame:SetScript("OnEvent", iLvLrOnEvent)
end

function SlashCmdList.ILVLR(msg)
	if msg == "durability" then
		if iDuraState == "enabled" then
			iDuraState = "disabled"
			iDuraToggle(iDuraState)
			print("Durability turned |cffff0000off|r!")
		elseif iDuraState == "disabled" then
			iDuraState = "enabled"
			iDuraToggle(iDuraState)
			print("Durability turned |cff00ff00on|r!")
		end
	elseif msg == "colour" then
		if iColourState == "enabled" then
			iColourState = "disabled"
			print("ilvl colour turned |cffff0000off|r!")
		elseif iColourState == "disabled" then
			iColourState = "enabled"
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
function iLvLrOnEvent(self, event, what, what2)
	if event == "ACTIVE_TALENT_GROUP_CHANGED" then
--		print("Talent Change.")
		mainSave = 0
		offSave = 0
--		print("Saves cleared.")
	elseif event == "PLAYER_EQUIPMENT_CHANGED" then
		iLvLrFrame:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")
		iLvLrFrame:RegisterEvent("BAG_UPDATE_DELAYED")
	elseif event == "BAG_UPDATE_DELAYED" then
		iLvLrFrame:UnregisterEvent("BAG_UPDATE_DELAYED")
		if not InCombatLockdown() then
			--print("Equipment Update")
			iLvLrOnItemUpdate()
			iLvLrOnDuraUpdate()
			iLvLrOnModUpdate()
			iLvLrFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
		else
			iLvLrFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
		end
	elseif event == "PLAYER_REGEN_ENABLED" then
		--print("Equipment Update")
		iLvLrFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
		iLvLrOnItemUpdate()
		iLvLrOnModUpdate()
		iLvLrFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	elseif event == "SOCKET_INFO_UPDATE" or event == "ITEM_UPGRADE_MASTER_UPDATE" then
		--pront("Gem Change/Upgrade Update")
		iLvLrOnItemUpdate()
		iLvLrOnModUpdate()
	elseif event == "UPDATE_INVENTORY_DURABILITY" then
		--print("Durability Update")
		iLvLrOnDuraUpdate()
	elseif event == "INSPECT_READY" then
		iLvLrOnInspec(what)
	end
end

function iLvLrOnLoad()
	--print("in OnLoad")
	for k ,v in pairs(slotDB) do
		--print("k: " .. k .. ", v: " .. v)
		local iLevel = fetchIlvl(v, "player")
		if iLevel then
			if v == "ShirtSlot" or v == "TabardSlot" then
				-- Do Nothing
			else
				makeIlvl(frameDB[k], v, "player", iLevel)
				makeDurability(frameDB[k], v, "player")
				makeMod(frameDB[k], v, "player", iLevel)
			end
		end
	end

	if not iDuraState then
		iDuraState = "enabled"
	end

	if iDuraState == "disabled" then
		iDuraToggle(iDuraState)
	end

	if not iColourState then
		iColourState = "enabled"
	end
end

function iLvLrOnItemUpdate()
	--print("in OnItemUpdate")
	for k ,v in pairs(slotDB) do
		local iLevel = fetchIlvl(v, "player")
		if iLevel then
			if v == "ShirtSlot" or v == "TabardSlot" then
				-- Do Nothing
			else
				makeIlvl(frameDB[k], v, "player", iLevel)
				makeDurability(frameDB[k], v, "player")
				makeMod(frameDB[k], v, "player", iLevel)
			end
		else
			if iLvlFrames[v] then
				iLvlFrames[v]:Hide()
			end
			if iDuraFrames[v] then
				iDuraFrames[v]:Hide()
			end
			if iModFrames[v] then
				iModFrames[v]:Hide()
			end
		end
	end
end

function iLvLrOnDuraUpdate()
	--print("in OnDuraUpdate")
	for k ,v in pairs(slotDB) do
		local iLevel = fetchIlvl(v, "player")
		if iLevel then
			makeDurability(frameDB[k], v, "player")
		else
			if iDuraFrames[v] then
				iDuraFrames[v]:Hide()
			end
		end
	end
end

function iLvLrOnModUpdate()
	for k ,v in pairs(slotDB) do
		local iLevel = fetchIlvl(v, "player")
		if iLevel then
			if v == "ShirtSlot" or v == "TabardSlot" then
				-- Do Nothing
			else
				makeMod(frameDB[k], v, "player", iLevel)
			end
		else
			if iModFrames[v] then
				iModFrames[v]:Hide()
			end
		end
	end
end

function iLvLrOnInspec(GUID)
	iLvLrReportFrame.text:SetText(format("Avg ilvl: ??"))
	lastInspecReady = GetTime()
	InspecGUID = GUID
	inspec = true
end

function iLvLInspecInit()
	if InspectFrame and InspectFrame.unit then
		--print("in call @showinspectframe")
		local inspecIlvl = 0
		mainSave = 0
		offSave = 0
		inspecIlvl = calcIlvlAvg(InspectFrame.unit)
--		print("inspecIlvl: " .. inspecIlvl)
		iLvLrReportFrame:SetParent(InspectPaperDollFrame)
		iLvLrReportFrame:SetPoint("BOTTOM", InspectFrame, "RIGHT", -45, 15)
		iLvLrReportFrame.text:SetText(format("Avg ilvl: " .. tostring(inspecIlvl)))
		for k ,v in pairs(slotDB) do
			z = z + 1
			if v == "ShirtSlot" or v == "TabardSlot" then
				-- Do Nothing
				--print("Slot is " .. v)
			else
				local iLevel = fetchIlvl(v, InspectFrame.unit)
				--print(v .. " iLevel: " .. iLevel)
				if iLevel then
					makeIlvl(frameIDB[k], v, InspectFrame.unit, iLevel, z)
					makeMod(frameIDB[k], v, InspectFrame.unit, iLevel)
				else
					if iLvlIFrames[v] then
						iLvlIFrames[v]:Hide()
					end
					if iModIFrames[v] then
						iModIFrames[v]:Hide()
					end
				end
			end
		end
	end
end

function getIlvlTooltip(itemLink)
	local iLevel = 0
	if(itemLink and type(itemLink) == "string") then
		if not iLvLrScanner then CreateFrame("GameToolTip", "iLvLrScanner", UIParent, "GameTooltipTemplate") end
		local ttScanner = iLvLrScanner
		ttScanner:SetOwner(iLvLrFrame, "ANCHOR_NONE")
		ttScanner:ClearLines()
		ttScanner:SetHyperlink(itemLink)

		local tname = ttScanner:GetName().."TextLeft%s";
		for i = 2, ttScanner:NumLines() do
			local text = _G[tname:format(i)]:GetText()
			if(text and text ~= "") then
				local value = tonumber(text:match(iLevelFilter))
				if(value) then
					iLevel = value
				end
			end
		end

		ttScanner:Hide()
		return iLevel
	end
end

function fetchIlvl(slotName, unit)
	--print("in fetchIlvl")
	local slotId = GetInventorySlotInfo(slotName)
	local itemLink = GetInventoryItemLink(unit, slotId)
	local iLvl = getIlvlTooltip(itemLink)
	--print("ttScanner iLvl: ", iLvl)
	local itemlevel = iLvl

	return itemlevel
end

function checkRelicIlvl(relicLink)
	if relicLink then
	if not iLvLrScanner then CreateFrame("GameToolTip", "iLvLrScanner", UIParent, "GameTooltipTemplate") end
	local ttScanner = iLvLrScanner
	
	ttScanner:SetOwner(iLvLrFrame, "ANCHOR_NONE")
	ttScanner:ClearLines()
	ttScanner:SetHyperlink(relicLink)
		for i = 1,4 do
			if _G["iLvLrScannerTextLeft" .. i]:GetText() then
				local rilvl = _G["iLvLrScannerTextLeft" .. i]:GetText():match(ITEM_LEVEL:gsub("%%d","(%%d+)"));
				if rilvl then
					return tonumber(rilvl)
				end
			else
				break
			end
		end
	end
	return 0;
end

function calcIlvlAvg(unit)
	--print("in calc")
	local total = 0
	local item = 0
	for k ,v in pairs(slotDB) do
		--print(v)
		if v == "ShirtSlot" or v == "TabardSlot" then
			-- Do Nothing
		else
			local itemLink = GetInventoryItemLink(unit, GetInventorySlotInfo(v))
			if (itemLink ~= nil) then
				--print("in itemlink ~= nil")
				local itemlevel = getIlvlTooltip(itemLink)
				--print(itemlevel)
				if itemlevel > 749 then
					if slot == "MainHandSlot" or slot == "SecondaryHandSlot" then
						local weapon = GetInventoryItemID(unit, GetInventorySlotInfo(slot))
						local _, _, itemRarity, _, _, _, _, _, _, _, _ = GetItemInfo(weapon)
						--print("Slot: " .. slot .. ", itemRarity = " .. itemRarity)
						if itemRarity == 6 then
							if slot == "MainHandSlot" then
--								print("Main Hand ilvl start: " .. iLevel)
								mainSave = iLevel
								if offSave == 0 then
									offSave = mainSave
								elseif offSave > 750 then
									if offSave > mainSave then
										mainSave = offSave
										iLevel = mainSave
									end
								end
--								print("Main Hand ilvl end: " .. iLevel)
							elseif slot == "SecondaryHandSlot" then
--								print("Off Hand ilvl start: " .. iLevel)
								offSave = iLevel
								if mainSave == 0 then
									mainSave = offSave
								elseif mainSave > 750 then
									if mainSave > offSave then
										offSave = mainSave
										iLevel = offSave
									end
								end
--								print("Off Hand ilvl end: " .. iLevel)
							end
						end
					end
				end
				if (itemlevel and itemlevel > 0) then
					item = item + 1
					--print("items: " .. item)
					total = total + itemlevel
					--print("total: " .. total)
				end
			end
		end
	end

	if (total < 1) then
		return 0
	end
	return floor((total / item) + 0.5)
end

function fetchDura(slotName)
	--print("in fetchDura")
	local slotId, texture = GetInventorySlotInfo(slotName)
	if slotId then
		local itemDurability, itemMaxDurability = GetInventoryItemDurability(slotId)
		if itemDurability and itemMaxDurability then
			return itemDurability, itemMaxDurability
		else
			return -1, -1
		end
	end
end

function fetchSocketCount(slotName, unit)
	local inventoryID = GetInventorySlotInfo(slotName)
	local itemLink = GetInventoryItemLink(unit, inventoryID)
	local socketCount = 0
	for i = 1, 4 do
		if  _G["iLvLrScannerTexture" .. i]  then
	 		_G["iLvLrScannerTexture" .. i]:SetTexture("")
	 	end
	end
	
	if not iLvLrScanner then CreateFrame("GameToolTip", "iLvLrScanner", UIParent, "GameTooltipTemplate") end
	local ttScanner = iLvLrScanner
	
	ttScanner:SetOwner(iLvLrFrame, "ANCHOR_NONE")
	ttScanner:ClearLines()
	ttScanner:SetHyperlink(itemLink)
	
	for i = 1, 4 do
		local texture = _G["iLvLrScannerTexture" .. i]:GetTexture()
		if texture then
			socketCount = socketCount + 1
		end
	end
	
	ttScanner:Hide()
	
	return socketCount
end

function fetchGem(slotName, unit)
	local inventoryID = GetInventorySlotInfo(slotName)
	local itemLink    = GetInventoryItemLink(unit, inventoryID)
	
	local missingGems = 0
							
	local emptyTextures = {"Interface\\ItemSocketingFrame\\UI-EmptySocket-Meta", 
							"Interface\\ItemSocketingFrame\\UI-EmptySocket-Red",
							"Interface\\ItemSocketingFrame\\UI-EmptySocket-Yellow",
							"Interface\\ItemSocketingFrame\\UI-EmptySocket-Blue",
							"Interface\\ItemSocketingFrame\\UI-EmptySocket-CogWheel",
							"Interface\\ItemSocketingFrame\\UI-EmptySocket-Hydraulic",
							"Interface\\ItemSocketingFrame\\UI-EmptySocket-Prismatic",
							"Interface\\ItemSocketingFrame\\UI-EmptySocket"
							}
	
	for i = 1, 4 do
		if ( _G["iLvLrScannerTexture" .. i] ) then
	 		_G["iLvLrScannerTexture" .. i]:SetTexture("");
	 	end;
	end;
	
	if not iLvLrScanner then CreateFrame("GameToolTip", "iLvLrScanner", UIParent, "GameTooltipTemplate") end
	local ttScanner = iLvLrScanner
	
	ttScanner:SetOwner(iLvLrFrame, "ANCHOR_NONE")
	ttScanner:ClearLines()
	ttScanner:SetHyperlink(itemLink)
	
	for i = 1, 4 do
		local texture = _G["iLvLrScannerTexture" .. i]:GetTexture()
		if texture then
			for k, v in pairs(emptyTextures) do
				if texture == v then
					missingGems = missingGems + 1
				end
			end
		end
	end
	
	ttScanner:Hide()
	
	return missingGems
end

function fetchBaseSocket(slotName, unit)
	local inventoryID = GetInventorySlotInfo(slotName)
	local itemLink = GetInventoryItemLink(unit, inventoryID)
	
	local parsedItemDataTable = {}
	local foundStart, foundEnd, parsedItemData = string.find(itemLink, "^|c%x+|H(.+)|h%[.*%]")
	
	for v in string.gmatch(parsedItemData, "[^:]+") do
		tinsert(parsedItemDataTable, v)
	end
	
	local baseItem = "|Hitem:" .. parsedItemDataTable[2] .. ":0"
	local itemName, itemLink, itemQuality, itemLevel, itemReqLevel, itemClass, itemSubclass, itemMaxStack, itemEquipSlot, itemTexture, itemVendorPrice = GetItemInfo(baseItem)
	local baseSocketCount = 0
	for i = 1, 4 do
		if  _G["iLvLrScannerTexture" .. i]  then
	 		_G["iLvLrScannerTexture" .. i]:SetTexture("")
	 	end
	end
	
	if not iLvLrScanner then CreateFrame("GameToolTip", "iLvLrScanner", UIParent, "GameTooltipTemplate") end
	local ttScanner = iLvLrScanner
	
	ttScanner:SetOwner(iLvLrFrame, "ANCHOR_NONE")
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
		
	ttScanner:Hide()
	
	return baseSocketCount
end

function fetchChant(slotName, unit)
	local inventoryID         = GetInventorySlotInfo(slotName)
	local itemLink            = GetInventoryItemLink(unit, inventoryID)
	local parsedItemDataTable = {}
	local _, itemId, enchantId, jewelId1, jewelId2, jewelId3, jewelId4, suffixId, uniqueId,
    linkLevel, specializationID, reforgeId, unknown1, unknown2 = strsplit(":", itemLink)
--[[    print(itemId .. ", " .. enchantId .. ", " .. jewelId1 .. ", " .. jewelId2 .. ", " .. jewelId3 .. ", " .. jewelId4 .. ", " .. suffixId .. ", " .. uniqueId .. ", " .. 
    linkLevel .. ", " .. specializationID .. ", " .. reforgeId .. ", " .. unknown1 .. ", " .. unknown2)]]
	if enchantId == "" then
			return 0
		else
			return enchantId
	end
end

--[[function fetchProfs()
	local prof1, prof2, archaeology, fishing, cooking, firstAid = GetProfessions()
	local profs = {prof1, prof2, archaeology, fishing, cooking, firstAid}
	local profNames = {}
	
	for k, v in pairs(profs) do
		local name, texture, rank, maxRank, numSpells, spelloffset, skillLine, rankModifier = GetProfessionInfo(v)
		tinsert(profNames, name)
	end
	
	return profNames
end]]

function fetchSubclass(slotName, unit)
	local slotId, texture, checkRelic = GetInventorySlotInfo(slotName)
	local itemId = GetInventoryItemID(unit, slotId)
	if itemId then
		local _, _, _, _, _, _, subclass, _, _, _, _ = GetItemInfo(itemId)
		return(subclass)
	end
end

function makeIlvl(frame, slot, unit, iLevel, z)
	--print("in makeText")
	iAvg, iEqAvg = GetAverageItemLevel()
	if unit == "player" then
		iLvl = iLvlFrames[slot]
	elseif unit ~= "player" then
		iLvl = iLvlIFrames[slot]
		--print("iLvlIFrames make")
	end
	--print("Unit: " .. unit .. ", Slot: " .. slot .. ", iLevel: " .. iLevel)
	if not iLvl then
		iLvl = CreateFrame("Frame", nil, frame)
		if unit == "player" then
			if frame == CharacterHeadSlot or frame == CharacterNeckSlot or frame == CharacterShoulderSlot or frame == CharacterBackSlot or frame == CharacterChestSlot or frame == CharacterWristSlot or frame == CharacterShirtSlot or frame == CharacterTabardSlot then
				iLvl:SetPoint("CENTER", frame, "CENTER", 42, -1)
			elseif frame == CharacterHandsSlot or frame == CharacterWaistSlot or frame == CharacterLegsSlot or frame == CharacterFeetSlot or frame == CharacterFinger0Slot or frame == CharacterFinger1Slot or frame == CharacterTrinket0Slot or frame == CharacterTrinket1Slot then
				iLvl:SetPoint("CENTER", frame, "CENTER", -42, -1)
			elseif frame == CharacterMainHandSlot or frame == CharacterSecondaryHandSlot then
				iLvl:SetPoint("CENTER", frame, "CENTER", 0, 41)
			end
		elseif unit ~= "player" then
			--print("InspectPaperDollFrame " .. z)
			if frame == InspectHeadSlot or frame == InspectNeckSlot or frame == InspectShoulderSlot or frame == InspectBackSlot or frame == InspectChestSlot or frame == InspectWristSlot or frame == InspectShirtSlot or frame == InspectTabardSlot then
				iLvl:SetPoint("CENTER", frame, "CENTER", 42, -1)
			elseif frame == InspectHandsSlot or frame == InspectWaistSlot or frame == InspectLegsSlot or frame == InspectFeetSlot or frame == InspectFinger0Slot or frame == InspectFinger1Slot or frame == InspectTrinket0Slot or frame == InspectTrinket1Slot then
				iLvl:SetPoint("CENTER", frame, "CENTER", -42, -1)
			elseif frame == InspectMainHandSlot or frame == InspectSecondaryHandSlot then
				iLvl:SetPoint("CENTER", frame, "CENTER", 0, 41)
			end
		end
		
		iLvl:SetSize(10,10)
		iLvl:SetBackdrop({bgFile = nil, edgeFile = nil, tile = false, tileSize = 32, edgeSize = 0, insets = {left = 0, right = 0, top = 0, bottom = 0}})
		iLvl:SetBackdropColor(0,0,0,0)
		
		local iLvlText = iLvl:CreateFontString(nil, "ARTWORK")
		isValid = iLvlText:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
		iLvlText:SetPoint("CENTER", iLvl, "CENTER", 0, 0)
		iLvl.text = iLvlText
	end
	
	if iLevel > 749 then
		if slot == "MainHandSlot" or slot == "SecondaryHandSlot" then
			local weapon = GetInventoryItemID(unit, GetInventorySlotInfo(slot))
			local _, _, itemRarity, _, _, _, _, _, _, _, _ = GetItemInfo(weapon)
			--print("Slot: " .. slot .. ", itemRarity = " .. itemRarity)
			if itemRarity == 6 then
				if slot == "MainHandSlot" then
--					print("Main Hand ilvl start: " .. iLevel)
					mainSave = iLevel
					if offSave == 0 then
						offSave = mainSave
					elseif offSave > 750 then
						if offSave > mainSave then
							mainSave = offSave
							iLevel = mainSave
						end
					end
--					print("Main Hand ilvl end: " .. iLevel)
				elseif slot == "SecondaryHandSlot" then
--					print("Off Hand ilvl start: " .. iLevel)
					offSave = iLevel
					if mainSave == 0 then
						mainSave = offSave
					elseif mainSave > 750 then
						if mainSave > offSave then
							offSave = mainSave
							iLevel = offSave
						end
					end
--					print("Off Hand ilvl end: " .. iLevel)
				end
				for aw = 1, 3 do
					local relicName, relicLink = GetItemGem(itemLink, aw)
					if relicLink then
						print("relicName: " .. relicName .. ".")
					end
				end
			end
		end
	end

	if iColourState == "enabled" then
		if iLevel <= iEqAvg - 10 then
			iLvl.text:SetFormattedText("|cffff0000%i|r", iLevel)
		elseif iLevel >= iEqAvg + 10 then
			iLvl.text:SetFormattedText("|cff00ff00%i|r", iLevel)
		else
			iLvl.text:SetFormattedText("|cffffffff%i|r", iLevel)
		end
	elseif iColourState == "disabled" then
		iLvl.text:SetFormattedText("|cffffffff%i|r", iLevel)
	end

	if unit == "player" then
		iLvlFrames[slot] = iLvl
		iLvl:SetParent(PaperDollItemsFrame)
	elseif unit ~= "player" then
		iLvlIFrames[slot] = iLvl
		iLvl:SetParent(InspectPaperDollFrame)
		--print("iLvlIFrames save")
	end

	iLvl:Show()
end

function makeDurability(frame, slot, unit)
	--print("in makeDurability")
	local iDura = {}
	if unit == "player" then
		iDura = iDuraFrames[slot]
	elseif unit ~= "player" then
		iDura = iDuraIFrames[slot]
	end
	if not iDura then
		iDura = CreateFrame("Frame", nil, frame)
		
		if unit == "player" then
			if frame == CharacterHeadSlot or frame == CharacterNeckSlot or frame == CharacterShoulderSlot or frame == CharacterBackSlot or frame == CharacterChestSlot or frame == CharacterWristSlot or frame == CharacterShirtSlot or frame == CharacterTabardSlot then
				iDura:SetPoint("BOTTOM", frame, "BOTTOM", 42, 0)
			elseif frame == CharacterHandsSlot or frame == CharacterWaistSlot or frame == CharacterLegsSlot or frame == CharacterFeetSlot or frame == CharacterFinger0Slot or frame == CharacterFinger1Slot or frame == CharacterTrinket0Slot or frame == CharacterTrinket1Slot then
				iDura:SetPoint("BOTTOM", frame, "BOTTOM", -42, 0)
			elseif frame == CharacterMainHandSlot or frame == CharacterSecondaryHandSlot then
				iDura:SetPoint("BOTTOM", frame, "BOTTOM", 0, 42)
			end
		elseif unit ~= "player" then
			if frame == InspectHeadSlot or frame == InspectNeckSlot or frame == InspectShoulderSlot or frame == InspectBackSlot or frame == InspectChestSlot or frame == InspectWristSlot or frame == InspectShirtSlot or frame == InspectTabardSlot then
				iDura:SetPoint("BOTTOM", frame, "BOTTOM", 42, 0)
			elseif frame == InspectHandsSlot or frame == InspectWaistSlot or frame == InspectLegsSlot or frame == InspectFeetSlot or frame == InspectFinger0Slot or frame == InspectFinger1Slot or frame == InspectTrinket0Slot or frame == InspectTrinket1Slot then
				iDura:SetPoint("BOTTOM", frame, "BOTTOM", -42, 0)
			elseif frame == InspectMainHandSlot or frame == InspectSecondaryHandSlot then
				iDura:SetPoint("BOTTOM", frame, "BOTTOM", 0, 42)
			end
		end
		
		iDura:SetSize(10,10)
		iDura:SetBackdrop({bgFile = nil, edgeFile = nil, tile = false, tileSize = 32, edgeSize = 0, insets = {left = 0, right = 0, top = 0, bottom = 0}})
		iDura:SetBackdropColor(0,0,0,0)
		
		local iDuraText = iDura:CreateFontString(nil, "ARTWORK")
		isValid = iDuraText:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
		iDuraText:SetPoint("CENTER", iDura, "CENTER", 0, 0)
		iDura.text = iDuraText
		itemDurability, itemMaxDurability = fetchDura(slot, unit)
	else
		itemDurability, itemMaxDurability = fetchDura(slot, unit)
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
		if unit == "player" then
			iDuraFrames[slot] = iDura
		elseif unit ~= "player" then
			iDuraIFrames[slot] = iDura
		end
	end
	
    if iDuraState == "enabled" then
    	iDura:Show()
    end
end

function makeMod(frame, slot, unit, iLevel)
	--print("in makeMod")
	local missingGem, numSockets, isEnchanted, canEnchant
	local iMod   = {}
	if unit == "player" then
		iMod = iModFrames[slot]
	elseif unit ~= "player" then
		iMod = iModIFrames[slot]
	end
--	local iLevel = fetchIlvl(slot, unit)
--	print("Slot: " .. slot .. ", iLvL: " .. iLevel)
	if not iMod then
		iMod = CreateFrame("Frame", nil, frame)
		
		if unit == "player" then
			if frame == CharacterHeadSlot or frame == CharacterNeckSlot or frame == CharacterShoulderSlot or frame == CharacterBackSlot or frame == CharacterChestSlot or frame == CharacterWristSlot or frame == CharacterShirtSlot or frame == CharacterTabardSlot then
				iMod:SetPoint("TOP", frame, "TOP", 42, -3)
			elseif frame == CharacterHandsSlot or frame == CharacterWaistSlot or frame == CharacterLegsSlot or frame == CharacterFeetSlot or frame == CharacterFinger0Slot or frame == CharacterFinger1Slot or frame == CharacterTrinket0Slot or frame == CharacterTrinket1Slot then
				iMod:SetPoint("TOP", frame, "TOP", -42, -3)
			elseif frame == CharacterMainHandSlot or frame == CharacterSecondaryHandSlot then
				iMod:SetPoint("TOP", frame, "TOP", 0, 39)
			end
		elseif unit ~= "player" then
			if frame == InspectHeadSlot or frame == InspectNeckSlot or frame == InspectShoulderSlot or frame == InspectBackSlot or frame == InspectChestSlot or frame == InspectWristSlot or frame == InspectShirtSlot or frame == InspectTabardSlot then
				iMod:SetPoint("TOP", frame, "TOP", 42, -3)
			elseif frame == InspectHandsSlot or frame == InspectWaistSlot or frame == InspectLegsSlot or frame == InspectFeetSlot or frame == InspectFinger0Slot or frame == InspectFinger1Slot or frame == InspectTrinket0Slot or frame == InspectTrinket1Slot then
				iMod:SetPoint("TOP", frame, "TOP", -42, -3)
			elseif frame == InspectMainHandSlot or frame == InspectSecondaryHandSlot then
				iMod:SetPoint("TOP", frame, "TOP", 0, 39)
			end
		end

		iMod:SetSize(10,10)
		iMod:SetBackdrop({bgFile = nil, edgeFile = nil, tile = false, tileSize = 32, edgeSize = 0, insets = {left = 0, right = 0, top = 0, bottom = 0}})
		iMod:SetBackdropColor(0,0,0,0)
		
		local iModText = iMod:CreateFontString(nil, "ARTWORK")
		isValid = iModText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
		iModText:SetPoint("CENTER", iMod, "CENTER", 0, 0)
		iMod.text = iModText
		
		missingGem     = fetchGem(slot, unit)
		numSockets     = fetchSocketCount(slot, unit)
		canEnchant     = false
		missingSpecial = 0
	else
		missingGem     = fetchGem(slot, unit)
		numSockets     = fetchSocketCount(slot, unit)
		canEnchant     = false
		missingSpecial = 0
	end

	if iLevel <= 599 then
		if slot == "WaistSlot" then
			canEnchant = true

			local baseSockets = fetchBaseSocket(slot, unit)
			if (baseSockets - numSockets) == -1 then
				isEnchanted = 1
			else
				isEnchanted = 0
			end
		else
			for k ,v in pairs(isEnchantable) do
				if v == slot then
					canEnchant = true
					isEnchanted = fetchChant(slot, unit)
				end
			end
		end
	elseif iLevel > 599 then
		if slot == "SecondaryHandSlot" and iLevel < 749 then
			local offHand = GetInventoryItemID(unit, GetInventorySlotInfo("SecondaryHandSlot"))
			local _, _, _, _, _, itemClass, itemSubclass, _, _, _, _ = GetItemInfo(offHand)
			if itemClass == "Weapon" then
				canEnchant = true
				isEnchanted = fetchChant(slot, unit)
			end
			--print(itemClass)
			--print(itemSubclass)
		elseif iLevel > 749 then
			local mainHand = GetInventoryItemID(unit, GetInventorySlotInfo("MainHandSlot"))
			local _, _, _, _, _, itemClass, itemSubclass, _, _, _, _ = GetItemInfo(mainHand)
			local _, englishClass, _ = UnitClass(unit)
			if slot == "MainHandSlot" or slot == "SecondaryHandSlot" then
				if itemClass == "Weapon" then
					if englishClass == "DEATHKNIGHT" then
						canEnchant = true
						isEnchanted = fetchChant(slot, unit)
					else
						canEnchant = false
					end
				end
			else 
				for k ,v in pairs(isEnchantableWoD) do
					if v == slot then
						canEnchant = true
						isEnchanted = fetchChant(slot, unit)
					end
				end
			end
		else 
			for k ,v in pairs(isEnchantableWoD) do
				if v == slot then
					canEnchant = true
					isEnchanted = fetchChant(slot, unit)
				end
			end
		end
	end

	isEnchanted = tonumber(isEnchanted)
		
	if numSockets > 0 and canEnchant == true then
		if isEnchanted == 0 and missingGem > 0 then
			iMod.text:SetFormattedText("|cffff0000%s|r|cffff0000%s|r", "E", "G")
		elseif isEnchanted == 0 and missingGem == 0 then
			iMod.text:SetFormattedText("|cffff0000%s|r|cff00ff00%s|r", "E", "G")
		elseif isEnchanted > 0 and missingGem > 0 then
			iMod.text:SetFormattedText("|cff00ff00%s|r|cffff0000%s|r", "E", "G")
		elseif isEnchanted > 0 and missingGem == 0 then
			iMod.text:SetFormattedText("|cff00ff00%s|r|cff00ff00%s|r", "E", "G")
		end
	elseif numSockets > 0 and canEnchant == false then
		if missingGem > 0 then
			iMod.text:SetFormattedText("|cffff0000%s|r", "G")
		elseif missingGem == 0 then
			iMod.text:SetFormattedText("|cff00ff00%s|r", "G")
		end
	elseif numSockets == 0 and canEnchant == true then
		if isEnchanted == 0 then
			iMod.text:SetFormattedText("|cffff0000%s|r", "E")
		elseif isEnchanted > 0 then
			iMod.text:SetFormattedText("|cff00ff00%s|r", "E")
		end
	elseif numSockets == 0 and canEnchant == false then
		iMod.text:SetFormattedText("")
	end
		
	if unit == "player" then
		iModFrames[slot] = iMod
	elseif unit ~= "player" then
		iModIFrames[slot] = iMod
	end
		
	iMod:Show()
end

function iDuraToggle(state)
	for k, v in pairs(iDuraFrames) do
		if state == "enabled" then
			v:Show()
		elseif state == "disabled" then
			v:Hide()
		end
	end
end

local function onIUpdate(self, elapsed)
	if (inspec) then
		if (GetTime() - lastInspecReady + elapsed > .25) then
			inspec = false
			iLvLInspecInit()			
		end
	end
end
iLvLrMain()
iLvLrReportFrame:SetScript("OnUpdate", onIUpdate)