-- Title: iLvLr
-- Author: JerichoHM / LownIgnitus
-- Version: 2.3.7
-- Desc: iLvL identifier

--Version Information
local iLvLr    = {}
local addon    = iLvLr
local Title    = "|cff00ff00iLvLr|r"
local Core     = "|cffFF45002|r"
local Revision = "|cffFF45003|r"
local Build    = "|cffFF45006|r"
SLASH_ILVLR1, SLASH_ILVLR2   = '/ilvlr', '/iLvLr'

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

local isEnchantableBfA = {"HandsSlot",
							"MainHandSlot",
							"SecondaryHandSlot",
							"Finger0Slot",
							"Finger1Slot"
							}

local legionARSockets = {
						["Arcane"] = "Arca",
						["Blood"]  = "Bloo",
						["Fel"]    = "Fel",
						["Fire"]   = "Fire",
						["Frost"]  = "Fros",
						["Holy"]   = "Holy",
						["Iron"]   = "Iron",
						["Life"]   = "Life",
						["Shadow"] = "Shad",
						["Wind"]   = "Stor",
						["Water"]  = "Wate"
						}

local iLevelFilter = ITEM_LEVEL:gsub( "%%d", "(%%d+)" )
local lad          = LibStub("LibArtifactData-1.0")
local iEqAvg, iAvg, lastInspecReady, InspecGUID

local inspec       = false
local z            = 0
local iLvlAR1      = {}
local iLvlAR2      = {}
local iLvlAR3      = {}
local iLvlAR1Text
local iLvlAR2Text
local iLvlAR3Text
local relics       = {}
local mainSave     = 0
local mainISave    = 0
local offSave      = 0
local offISave     = 0
local iLvlFrames   = {}
local iLvlAR1Frame = {}
local iLvlAR2Frame = {}
local iLvlAR3Frame = {}
local iDuraFrames  = {}
local iModFrames   = {}

local iLvLrReportFrame = CreateFrame("Frame", "iLvLrInspecFrame")
iLvLrReportFrame:ClearAllPoints()
iLvLrReportFrame:SetHeight(300)
iLvLrReportFrame:SetWidth(1000)
iLvLrReportFrame.text = iLvLrReportFrame:CreateFontString(nil, "BACKGROUND", "PVPInfoTextFont")
iLvLrReportFrame.text:SetAllPoints()
iLvLrReportFrame.text:SetTextHeight(13)
iLvLrReportFrame:SetAlpha(1)

function iLvLrVariableCheck()
	if iDuraState == nil then
		iDuraState = true
	elseif iDuraState == "enabled" or iDuraState == "disabled" then
		if iDuraState == "enabled" then
			iDuraState = true
		elseif iDuraState == "disabled" then
			iDuraState = false
		end
	else
		-- do nothing
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
	else
	-- do nothing
	end

	if iRelicState == nil then
		iRelicState = true
	elseif iRelicState == "enabled" or iRelicState == "disabled" then 
		if iRelicState == "enabled" then
			iRelicState = true
		elseif  iRelicState == "disabled" then
			iRelicState = false
		end
	else
		-- do nothing
	end

	if iRelicState == false then
		iRelicToggle(iRelicState)
	end
end

addon.f = CreateFrame("Frame", "iLvLrmain", CharacterFrame)
addon.f:SetScript("OnShow", function(self)
	--print("ILvLrOnLoad call @showpaperdoll")
	iLvLrOnLoad()
end)
				
function iLvLrMain()
	iLvLrFrame = CreateFrame("Frame", "iLvLrFrame", UIParent)
	iLvLrFrame:RegisterEvent("ADDON_LOADED")
	iLvLrFrame:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
	iLvLrFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	iLvLrFrame:RegisterEvent("SOCKET_INFO_UPDATE")
	iLvLrFrame:RegisterEvent("ITEM_UPGRADE_MASTER_UPDATE")
	iLvLrFrame:RegisterEvent("INSPECT_READY")
	iLvLrFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	iLvLrFrame:SetScript("OnEvent", iLvLrOnEvent)
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
	elseif msg == "relics" then
		if iRelicState == true then
			iRelicState = false
			iRelicToggle(iRelicState)
			print("relic information turned |cffff0000off|r!")
		elseif iRelicState == false then
			iRelicState = true
			iRelicToggle(iRelicState)
			print("relic information turned |cff00ff00on|r!")
		end
	else
		print("Thank you for using " .. Title)
		print("Version: " .. Core .. "." .. Revision .. "." .. Build)
		print("Author: |cffffcc00JerichoHM|r / Maintainer: |cffDA70D6LownIgnitus|r")
		print("Slash Commands are listed below and start with /iLvLr")
		print("      durability - Disables or Enables the durability tracker")
		print("      colour - Disables colouring ilvl by +/- avg")
		print("      relics - Disables or Enables display of slotted relics in Artifact")
	end
end

--Thanks to John454ss for code help
function iLvLrOnEvent(self, event, what)
	if event == "ADDON_LOADED" then
		iLvLrVariableCheck()
	elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then
--		print("Talent Change.")
		mainSave = 0
		offSave  = 0
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
		--print("Gem Change/Upgrade Update")
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
				makeIlvl(frameDB[k], v, iLevel)
				makeDurability(frameDB[k], v)
				makeMod(frameDB[k], v, iLevel)
			end
		end
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
				makeIlvl(frameDB[k], v, iLevel)
				makeDurability(frameDB[k], v)
				makeMod(frameDB[k], v, iLevel)
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
		local iLevel = fetchIlvl(v, "player")
		if iLevel then
			if v == "ShirtSlot" or v == "TabardSlot" then
				-- Do Nothing
			else
				makeMod(frameDB[k], v, iLevel)
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
		if itemLink == nil or itemLink == "" or itemLink == "0" then
			print("Hyperlink has not loaded fully yet.")
		else
			ttScanner:SetHyperlink(itemLink)
			if ttScanner == nil then
				print("Hyperlink has not loaded fully yet.")
			end
		end

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

function fetchProfs()
	local prof1, prof2 = GetProfessions()
	local profs = {prof1, prof2}
	local profNames = {}
	
	for k, v in pairs(profs) do
		local name = GetProfessionInfo(v)
		tinsert(profNames, name)
	end
	
	return profNames
end

function fetchIlvl(slotName, unit)
	--print("in fetchIlvl")
	local slotId    = GetInventorySlotInfo(slotName)
	local itemLink  = GetInventoryItemLink(unit, slotId)
	local iLvl      = getIlvlTooltip(itemLink)
	--print("ttScanner iLvl: ", iLvl)
	local itemlevel = iLvl

	return itemlevel
end

function checkEquippedRelic(artifactID)
	local id, data = lad:GetArtifactRelics(artifactID)
	local rData = {}
	rData[1] = {}
	rData[2] = {}
	rData[3] = {}
	for i = 1, 3 do
--		print("i = " .. i)
		if data[i].name then
--			print("data[i].name = " .. data[i].name)
			rData[i].rilvl = checkRelicIlvl(data[i].link)
			_,_,rData[i].colour = string.find(data[i].link, "|?c?f?f?(%x*)")
			for k,v in pairs(legionARSockets) do
--				print("k: "..k)
--				print("v: "..v)
				if k == data[i].type then
--					print("type: " .. data[i].type)
					rData[i].rtype = v
				end
			end
		end
--	print("relicName" .. i .. ": " .. data[i].link .. ", relicType: " .. rData[i].rtype .. ", colour: " .. rData[i].colour .. ", ilvl: " .. rData[i].rilvl)
	end
	return rData
end

function checkRelicIlvl(relicItemLink)
	if relicItemLink then
		if not iLvLrScanner then CreateFrame("GameToolTip", "iLvLrScanner", UIParent, "GameTooltipTemplate") end
		local ttScanner = iLvLrScanner
		
		ttScanner:SetOwner(iLvLrFrame, "ANCHOR_NONE")
		ttScanner:ClearLines()
		--[[if relicItemLink == nil or relicItemLink == "" or relicItemLink == "0" then
			print("Hyperlink has not loaded fully yet.")
		else]]
			ttScanner:SetHyperlink(relicItemLink)
			--[[if ttScanner == nil then
				print("Hyperlink has not loaded fully yet.")
			end
		end]]
		for i = 1,4 do
			if _G["iLvLrScannerTextLeft" .. i]:GetText() then
				local rilvl = _G["iLvLrScannerTextLeft" .. i]:GetText():match(iLevelFilter);
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
				if itemlevel > 151 then
					if slot == "MainHandSlot" or slot == "SecondaryHandSlot" then
						local weapon = GetInventoryItemID(unit, GetInventorySlotInfo(slot))
						local _, _, itemRarity, _, _, _, _, _, _, _, _ = GetItemInfo(weapon)
						--print("Slot: " .. slot .. ", itemRarity = " .. itemRarity)
						if itemRarity == 6 then
							if slot == "MainHandSlot" then
--								print("Main Hand ilvl start: " .. iLevel)
								mainISave = iLevel
								if offISave == 0 then
									offISave = mainISave
								elseif offISave > 152 then
									if offISave > mainISave then
										mainISave = offISave
										iLevel    = mainISave
									end
								end
--								print("Main Hand ilvl end: " .. iLevel)
							elseif slot == "SecondaryHandSlot" then
--								print("Off Hand ilvl start: " .. iLevel)
								offISave = iLevel
								if mainISave == 0 then
									mainISave = offISave
								elseif mainISave > 152 then
									if mainISave > offISave then
										offISave = mainISave
										iLevel   = offISave
									end
								end
--								print("Off Hand ilvl end: " .. iLevel)
							end
						end
					end
				end
				if (itemlevel and itemlevel > 0) then
					item  = item + 1
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

function fetchSocketCount(slotName)
	local inventoryID = GetInventorySlotInfo(slotName)
	local itemLink = GetInventoryItemLink("player", inventoryID)
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
			socketCount = socketCount + 1
		end
	end
	
	ttScanner:Hide()
	
	return socketCount
end

function fetchGem(slotName)
	local inventoryID   = GetInventorySlotInfo(slotName)
	local itemLink      = GetInventoryItemLink("player", inventoryID)
	
	local missingGems   = 0
							
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

function fetchBaseSocket(slotName)
	local inventoryID = GetInventorySlotInfo(slotName)
	local itemLink    = GetInventoryItemLink("player", inventoryID)
	
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

function fetchChant(slotName)
	local inventoryID         = GetInventorySlotInfo(slotName)
	local itemLink            = GetInventoryItemLink("player", inventoryID)
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

function makeIlvl(frame, slot, iLevel)
	--print("in makeText")
	iAvg, iEqAvg = GetAverageItemLevel()
	
	local iLvl = iLvlFrames[slot]

	--print("Slot: " .. slot .. ", iLevel: " .. iLevel)
	if not iLvl then
		iLvl = CreateFrame("Frame", nil, frame)
		if frame == CharacterHeadSlot or frame == CharacterNeckSlot or frame == CharacterShoulderSlot or frame == CharacterBackSlot or frame == CharacterChestSlot or frame == CharacterWristSlot or frame == CharacterShirtSlot or frame == CharacterTabardSlot then
			iLvl:SetPoint("CENTER", frame, "CENTER", 38, -1)
		elseif frame == CharacterHandsSlot or frame == CharacterWaistSlot or frame == CharacterLegsSlot or frame == CharacterFeetSlot or frame == CharacterFinger0Slot or frame == CharacterFinger1Slot or frame == CharacterTrinket0Slot or frame == CharacterTrinket1Slot then
			iLvl:SetPoint("CENTER", frame, "CENTER", -38, -1)
		elseif frame == CharacterMainHandSlot or frame == CharacterSecondaryHandSlot then
			iLvl:SetPoint("CENTER", frame, "CENTER", 0, 41)
		end
		
		iLvl:SetSize(10,10)
		iLvl:SetBackdrop({bgFile = nil, edgeFile = nil, tile = false, tileSize = 32, edgeSize = 0, insets = {left = 0, right = 0, top = 0, bottom = 0}})
		iLvl:SetBackdropColor(0,0,0,0)
		
		local iLvlText = iLvl:CreateFontString(nil, "ARTWORK")
		isValid = iLvlText:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
		iLvlText:SetPoint("CENTER", iLvl, "CENTER", 0, 0)
		iLvl.text = iLvlText
	end
		
	if iLevel > 151 then
		if slot == "MainHandSlot" or slot == "SecondaryHandSlot" then
			local weapon = GetInventoryItemID("player", GetInventorySlotInfo(slot))
			local name, _, itemRarity, _, _, _, itemSubType, _, _, _, _, _, _, _, _, _, _ = GetItemInfo(weapon)
			--print("Slot: " .. slot .. ", itemRarity = " .. itemRarity .. ", name: " .. name .. ", itemID: " .. weapon)
			
			iLvlAR1 = iLvlAR1Frame[slot]
			iLvlAR2 = iLvlAR2Frame[slot]
			iLvlAR3 = iLvlAR3Frame[slot]

			if not iLvlAR1 then
				iLvlAR1 = CreateFrame("Frame", nil, frame)
				
				iLvlAR1:SetSize(10,10)
				iLvlAR1:SetBackdrop({bgFile = nil, edgeFile = nil, tile = false, tileSize = 32, edgeSize = 0, insets = {left = 0, right = 0, top = 0, bottom = 0}})
				iLvlAR1:SetBackdropColor(0,0,0,0)
				
				iLvlAR1Text = iLvlAR1:CreateFontString(nil, "ARTWORK")
			end

			if not iLvlAR2 then
				iLvlAR2 = CreateFrame("Frame", nil, frame)

				iLvlAR2:SetSize(10,10)
				iLvlAR2:SetBackdrop({bgFile = nil, edgeFile = nil, tile = false, tileSize = 32, edgeSize = 0, insets = {left = 0, right = 0, top = 0, bottom = 0}})
				iLvlAR2:SetBackdropColor(0,0,0,0)
				
				iLvlAR2Text = iLvlAR2:CreateFontString(nil, "ARTWORK")
			end
			
			if not iLvlAR3 then
				iLvlAR3 = CreateFrame("Frame", nil, frame)
				
				iLvlAR3:SetSize(10,10)
				iLvlAR3:SetBackdrop({bgFile = nil, edgeFile = nil, tile = false, tileSize = 32, edgeSize = 0, insets = {left = 0, right = 0, top = 0, bottom = 0}})
				iLvlAR3:SetBackdropColor(0,0,0,0)
					
				iLvlAR3Text = iLvlAR3:CreateFontString(nil, "ARTWORK")
			end

			isValid = iLvlAR1Text:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
			iLvlAR1.text = iLvlAR1Text
			isValid = iLvlAR2Text:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
			iLvlAR2.text = iLvlAR2Text
			isValid = iLvlAR3Text:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
			iLvlAR3.text = iLvlAR3Text

			iLvlAR1.text:SetText("")
			iLvlAR2.text:SetText("")
			iLvlAR3.text:SetText("")

			if itemRarity == 6 then
				if slot == "MainHandSlot" then
					--print("Main Hand ilvl start: " .. iLevel)
					mainSave = iLevel
					if offSave == 0 then
						offSave = mainSave
					elseif offSave > 152 then
						if offSave > mainSave then
							mainSave = offSave
							iLevel   = mainSave
						end
					end
					--print("Main Hand ilvl end: " .. iLevel)
				elseif slot == "SecondaryHandSlot" then
					--print("Off Hand ilvl start: " .. iLevel)
					offSave = iLevel
					if mainSave == 0 then
						mainSave = offSave
					elseif mainSave > 152 then
						if mainSave > offSave then
							offSave = mainSave
							iLevel  = offSave
						end
					end
					--print("Off Hand ilvl end: " .. iLevel)
				end

				if iRelicState == true and itemSubType ~= "Fishing Poles" then
--					print("Artifact, not a Fishing Pole")
					iLvlAR1:Hide()
					iLvlAR2:Hide()
					iLvlAR3:Hide()

					if frame == CharacterMainHandSlot then
						iLvlAR1:SetPoint("TOPRIGHT", frame, "TOPLEFT", 0, -2)
						iLvlAR1Text:SetPoint("RIGHT", iLvlAR1, "RIGHT", 0, 0)
						iLvlAR2:SetPoint("RIGHT", frame, "LEFT", 0, -2)
						iLvlAR2Text:SetPoint("RIGHT", iLvlAR2, "RIGHT", 0, 0)
						iLvlAR3:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", 0, -2)
						iLvlAR3Text:SetPoint("RIGHT", iLvlAR3, "RIGHT", 0, 0)
					elseif frame == CharacterSecondaryHandSlot then
						iLvlAR1:SetPoint("TOPLEFT", frame, "TOPRIGHT", 1, -2)
						iLvlAR1Text:SetPoint("LEFT", iLvlAR1, "LEFT", 0, 0)
						iLvlAR2:SetPoint("LEFT", frame, "RIGHT", 1, -2)
						iLvlAR2Text:SetPoint("LEFT", iLvlAR2, "LEFT", 0, 0)
						iLvlAR3:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", 1, -2)
						iLvlAR3Text:SetPoint("LEFT", iLvlAR3, "LEFT", 0, 0)
					end

					local artifactID = lad:GetArtifactInfo()
--					print("artifactID: " .. artifactID)
					if weapon == artifactID then
--						print("Artifact & weapon match")
						local rData = checkEquippedRelic(artifactID)
--[[						if rData ~= nil then
							print("rData is here")
						end
]]						for aw = 1, 3 do
							if slot == "MainHandSlot" then
--								print("MainHandSlot")
								if aw == 1 then
--									print("rData[aw] = " .. aw)
									if rData[aw].rtype ~= nil then
										iLvlAR1.text:SetFormattedText("%s |cff"..rData[aw].colour.."%i|r", rData[aw].rtype, rData[aw].rilvl)
									else
										iLvlAR1.text:SetText("")
									end
								elseif aw == 2 then
									if rData[aw].rtype ~= nil then
										iLvlAR2.text:SetFormattedText("%s |cff"..rData[aw].colour.."%i|r", rData[aw].rtype, rData[aw].rilvl)
									else
										iLvlAR2.text:SetText("")
									end
								elseif aw == 3 then
									if rData[aw].rtype ~= nil then
										iLvlAR3.text:SetFormattedText("%s |cff"..rData[aw].colour.."%i|r", rData[aw].rtype, rData[aw].rilvl)
									else
										iLvlAR3.text:SetText("")
									end
								end
							elseif slot == "SecondaryHandSlot" then
								if aw == 1 then
									if rData[aw].rtype ~= nil then
										iLvlAR1.text:SetFormattedText("%s |cff"..rData[aw].colour.."%i|r", rData[aw].rtype, rData[aw].rilvl)
									else
										iLvlAR1.text:SetText("")
									end
								elseif aw == 2 then
									if rData[aw].rtype ~= nil then
										iLvlAR2.text:SetFormattedText("%s |cff"..rData[aw].colour.."%i|r", rData[aw].rtype, rData[aw].rilvl)
									else
										iLvlAR2.text:SetText("")
									end
								elseif aw == 3 then
									if rData[aw].rtype ~= nil then
										iLvlAR3.text:SetFormattedText("%s |cff"..rData[aw].colour.."%i|r", rData[aw].rtype, rData[aw].rilvl)
									else
										iLvlAR3.text:SetText("")
									end
								end
							end
						end
						iLvlAR1Frame[slot] = iLvlAR1
						iLvlAR2Frame[slot] = iLvlAR2
						iLvlAR3Frame[slot] = iLvlAR3
						iLvlAR1:Show()
						iLvlAR2:Show()
						iLvlAR3:Show()
					else
					iLvlAR1:Hide()
					iLvlAR2:Hide()
					iLvlAR3:Hide()
					end
				end
			else
				iLvlAR1:Hide()
				iLvlAR2:Hide()
				iLvlAR3:Hide()
			end
		end
	end

	--print("Slot " .. slot .. ": ilvl :")
	--print(iLevel)
	if iColourState == true then
		if iLevel <= iEqAvg - 10 then
			iLvl.text:SetFormattedText("|cffff0000%i|r", iLevel)
		elseif iLevel >= iEqAvg + 10 then
			iLvl.text:SetFormattedText("|cff00ff00%i|r", iLevel)
		else
			iLvl.text:SetFormattedText("|cffffffff%i|r", iLevel)
		end
	elseif iColourState == false then
		iLvl.text:SetFormattedText("|cffffffff%i|r", iLevel)
	end

	iLvlFrames[slot] = iLvl

	iLvl:Show()
end

function makeDurability(frame, slot)
	--print("in makeDurability")
	local iDura = iDuraFrames[slot]
	if not iDura then
		iDura = CreateFrame("Frame", nil, frame)
		
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
		isValid = iDuraText:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
		iDuraText:SetPoint("CENTER", iDura, "CENTER", 0, 0)
		iDura.text = iDuraText
		itemDurability, itemMaxDurability = fetchDura(slot, "player")
	else
		itemDurability, itemMaxDurability = fetchDura(slot, "player")
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

function makeMod(frame, slot, iLevel)
	--print("in makeMod")
	local profNames = fetchProfs()
	local missingGem, numSockets, isEnchanted, canEnchant
	local iMod   = {}
	iMod = iModFrames[slot]
--	local iLevel = fetchIlvl(slot, "player")
--	print("Slot: " .. slot .. ", iLvL: " .. iLevel)
	if not iMod then
		iMod = CreateFrame("Frame", nil, frame)
		
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
		isValid        = iModText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
		iModText:SetPoint("CENTER", iMod, "CENTER", 0, 0)
		iMod.text      = iModText
		
		missingGem     = fetchGem(slot)
		numSockets     = fetchSocketCount(slot)
		canEnchant     = false
		missingSpecial = 0
	else
		missingGem     = fetchGem(slot)
		numSockets     = fetchSocketCount(slot)
		canEnchant     = false
		missingSpecial = 0
	end

	if iLevel <= 136 then
		if slot == "WaistSlot" then
			canEnchant = true

			local baseSockets = fetchBaseSocket(slot)
			if (baseSockets - numSockets) == -1 then
				isEnchanted = 1
			else
				isEnchanted = 0
			end
		else
			for k ,v in pairs(isEnchantable) do
				if v == slot then
					canEnchant = true
					isEnchanted = fetchChant(slot)
				end
			end
		end
	elseif iLevel > 136 then
		if slot == "SecondaryHandSlot" and iLevel < 151 then
			local offHand = GetInventoryItemID("player", GetInventorySlotInfo("SecondaryHandSlot"))
			local _, _,itemRarity, _, _, itemClass, itemSubclass, _, _, _, _ = GetItemInfo(offHand)
			if itemClass == "Weapon" or itemRarity == 7 then
				canEnchant = true
				isEnchanted = fetchChant(slot)
			end
			--print(itemClass)
			--print(itemSubclass)
		elseif iLevel > 151 and iLevel <265 then
			local mainHand = GetInventoryItemID("player", GetInventorySlotInfo("MainHandSlot"))
			if mainHand ~= nil then
				local _, _, _, _, _, itemClass, _, _, _, _, _ = GetItemInfo(mainHand)
				local _, englishClass, _ = UnitClass("player")
				if slot == "MainHandSlot" or slot == "SecondaryHandSlot" then
					if itemClass == "Weapon" then
						if englishClass == "DEATHKNIGHT" then
							canEnchant = true
							isEnchanted = fetchChant(slot)
						end
					else
						canEnchant = false
					end
				else 
					for k ,v in pairs(isEnchantableWoD) do
						if v == slot then
							canEnchant = true
							isEnchanted = fetchChant(slot)
						end
					end
				end
			end
		elseif iLevel > 264 then
			if slot == "SecondaryHandSlot" then
				local offHand = GetInventoryItemID("player", GetInventorySlotInfo("SecondaryHandSlot"))
				local _, _, _, _, _, itemClass, _, _, _, _, _ = GetItemInfo(offHand)
				if offhand ~= nil then
					if itemClass ~= "Weapon" then
						canEnchant = false
					else
						canEnchant = true
						isEnchanted = fetchChant(slot)
					end
				end
			elseif slot == "WristSlot" then
				for k, v in pairs(profNames) do
					if v == "Enchanting" then
						canEnchant = true
						isEnchanted = fetchChant(slot)
					end
				end
			elseif slot == "WaistSlot" then
				for k, v in pairs(profNames) do
					if v == "Engineering" then
						canEnchant = true
						isEnchanted = fetchChant(slot)
					end
				end
			elseif slot == "BackSlot" then
				for k, v in pairs(profNames) do
					if v == "Tailoring" then
						canEnchant = true
						isEnchanted = fetchChant(slot)
					end
				end
			else
				for k ,v in pairs(isEnchantableBfA) do
					if v == slot then
						canEnchant = true
						isEnchanted = fetchChant(slot)
					end
				end
			end
		else 
			for k ,v in pairs(isEnchantable) do
				if v == slot then
					canEnchant = true
					isEnchanted = fetchChant(slot)
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
		
	iModFrames[slot] = iMod
		
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

function iRelicToggle(state)
	if state == true then
		iLvlAR1:Show()
		iLvlAR2:Show()
		iLvlAR3:Show()
	elseif state == false and iLvlAR1 ~= null then
		iLvlAR1:Hide()
		iLvlAR2:Hide()
		iLvlAR3:Hide()
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