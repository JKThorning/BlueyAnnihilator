local BA = {}
local swapFrame
local version = "1.2.2"
local sversion = "1.0"
local prefix = "Bluey_refresh_"..version
local PLAYERNAME = UnitName("PLAYER")
local BoldFont = "Interface\\AddOns\\BlueyAnnihilator\\Media\\Fonts\\BF.ttf"

anniButtonAlpha = 0.3
local colors = {
	["red"] = "fa8072",
	["redrgb"] = {250/255, 128/255, 114/255, anniButtonAlpha},
	["green"] = "4cbb17",
	["greenrgb"] = {76/255, 187/255, 23/255, anniButtonAlpha},
	["blue"] = "4666ff",
	["bluergb"] = {70/255, 102/255, 255/255, anniButtonAlpha},
}

local weaponEnchants = {
	["3225"] = { -- executioner
		id = 42976, 
		name = "Executioner"},

	["2673"] = { -- mongoose
		id = 28093, 
		name = "Mongoose"},

	["1900"] = { -- crusader
		id = 20007, 
		name = "Crusader"},

	["2668"] = { -- potency, has Scroll of Strength V aura texture
		id = 33082, 
		name = "Potency"},
}

local function getEnchantInfo(enchant)
	for k,v in pairs(weaponEnchants) do
		if k == enchant then
			return v.id, v.name
		end
	end
	return false, false
end

local defaultSettings = {
	["mhSliderVal"] = 0,
	["point"] = "CENTER",
	["active"] = true,
	["scale"] = 1.5,
	["xOfs"] = 0,
	["lastSave"] = date("%m/%d/%y %H:%M:%S"),
	["stacks"] = 0,
	["k"] = false,
	["relativePoint"] = "CENTER",
	["ohSliderVal"] = 0,
	["yOfs"] = 0,
	["MH_anniLink"] = nil,
	["version"] = version,
	["sversion"] = sversion,
	["OH_anniLink"] = nil,
	["timer"] = 0,
	["applied"] = false,
	["delay"] = 0.1,
	["autoswap"] = false,
}

local ANNIHILATOR_TEXTURE = select(10,GetItemInfo(12798))
--[[ local RAID_CLASS_COLORS = {
	["HUNTER"] = { r = 0.67, g = 0.83, b = 0.45, colorStr = "ffabd473" },
	["WARLOCK"] = { r = 0.58, g = 0.51, b = 0.79, colorStr = "ff9482c9" },
	["PRIEST"] = { r = 1.0, g = 1.0, b = 1.0, colorStr = "ffffffff" },
	["PALADIN"] = { r = 0.96, g = 0.55, b = 0.73, colorStr = "fff58cba" },
	["MAGE"] = { r = 0.41, g = 0.8, b = 0.94, colorStr = "ff69ccf0" },
	["ROGUE"] = { r = 1.0, g = 0.96, b = 0.41, colorStr = "fffff569" },
	["DRUID"] = { r = 1.0, g = 0.49, b = 0.04, colorStr = "ffff7d0a" },
	["SHAMAN"] = { r = 0.0, g = 0.44, b = 0.87, colorStr = "ff0070de" },
	["WARRIOR"] = { r = 0.78, g = 0.61, b = 0.43, colorStr = "ffc79c6e" },
} ]]

local floor = math.floor
local next = next

-- config slash options --
function SlashCmdList_AddSlashCommand(name, func, ...)
    SlashCmdList[name] = func
    local command = ''
    for i = 1, select('#', ...) do
        command = select(i, ...)
        if strsub(command, 1, 1) ~= '/' then
            command = '/' .. command
        end
        _G['SLASH_'..name..i] = command
    end
end
SlashCmdList_AddSlashCommand('BLUEY_SLASH', function(msg)
	local substring = strsub(msg,0,5)

	if string.match(msg, "off") then
		BlueyAnnihilatorSV.active = false
		BA.print("Bluey Annihilator disabled. Type </bluey on> to enable.")
		swapFrame.setActive(false)
		BA.mf:Hide()
	elseif string.match(msg, "on") then
		BlueyAnnihilatorSV.active = true
		BA.mf:Show()
		BA.print("Bluey Annihilator enabled.")
	elseif string.match(substring, "scale") then
		local len = string.len(msg)
		local val = tonumber(strsub(msg,7,len))
		local minscale = 0.5
		if val>=minscale then
			BA.print("Scale set to "..val)
			BlueyAnnihilatorSV.scale = val
			BA.tf.text:SetFont(BoldFont, 14*val, "THINOUTLINE")
			BA.mf:SetWidth(50*val)
			BA.mf:SetHeight(50*val)
			BA.mf.activeText:SetFont(BoldFont, 6*val, "OUTLINE")
		else
			BA.print("Scale size too low. Minimum is "..minscale..".")
		end
	else
		BA.print("No such option: " ..msg)
		BA.print("Syntax: /bluey [on/off/scale x]")
	end
end, 'BLUEY', 'BLUEYANNIHILATOR')

function BA.print( msg )
	if msg == nil then
		DEFAULT_CHAT_FRAME:AddMessage("<|cFFAAAAFFBluey Annihilator|r> ".."a nil value")
		return
	end
	DEFAULT_CHAT_FRAME:AddMessage("<|cFFAAAAFFBluey Annihilator|r> "..msg)
end

BA.ini = CreateFrame("Frame")
BA.ini:RegisterEvent("VARIABLES_LOADED")
BA.ini:RegisterEvent("PLAYER_LOGOUT")
BA.ini:SetScript("OnEvent", function(self, event, ...)
	
	if event == "VARIABLES_LOADED" then
		self:UnregisterEvent("VARIABLES_LOADED")

		if (BlueyAnnihilatorSV == nil) then
			BA.print("First addon use, applying default settings. Please report bugs to me on discord @ |cFFAAAAFFBluey:0480|r")
			BlueyAnnihilatorSV = defaultSettings
		elseif not(BlueyAnnihilatorSV.version == version) then
			BA.print("New major addon version, applying default settings. Please report bugs to me on discord @ |cFFAAAAFFBluey:0480|r")
			BlueyAnnihilatorSV = defaultSettings
		elseif not(BlueyAnnihilatorSV.sversion == sversion) then
			BA.print("New addon subversion, applying default settings. Please report bugs to me on discord @ |cFFAAAAFFBluey:0480|r")
			BlueyAnnihilatorSV = defaultSettings
		else
			BA.print("Addon loaded from state saved ".. BlueyAnnihilatorSV.lastSave..". Please report bugs to me on discord @ |cFFAAAAFFBluey:0480|r")
		end
		
		BlueyAnnihilatorSV.timer = 0
		BlueyAnnihilatorSV.duration = 0
		local point, relativePoint, xOfs, yOfs = BlueyAnnihilatorSV.point, BlueyAnnihilatorSV.relativePoint, BlueyAnnihilatorSV.xOfs, BlueyAnnihilatorSV.yOfs
		
		BA.mf:SetPoint(point,UIParent,relativePoint,xOfs,yOfs)
		BA.mf:SetWidth(50*BlueyAnnihilatorSV.scale)
		BA.mf:SetHeight(50*BlueyAnnihilatorSV.scale)
		BA.mf.activeText:SetFont(BoldFont, 6*BlueyAnnihilatorSV.scale, "OUTLINE")
		BA.receiver:RegisterEvent("CHAT_MSG_ADDON")
		BA.tracker:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		BA.anniWatcher:RegisterEvent("RAID_ROSTER_UPDATE")
		BA.anniWatcher:RegisterEvent("PLAYER_REGEN_ENABLED")
		BA.anniWatcher:RegisterEvent("PLAYER_REGEN_DISABLED")
		BA.anniWatcher:RegisterEvent("UNIT_INVENTORY_CHANGED")
		BA.anniWatcher:RegisterEvent("PLAYER_TARGET_CHANGED")

		BA.tf.text:SetFont(BoldFont, 14*BlueyAnnihilatorSV["scale"], "THINOUTLINE")
		BA.tf.text:SetPoint("CENTER")
		BA.tf.text:SetJustifyH("CENTER")
		BA.tf.text:SetJustifyV("CENTER")
		BA.tf.text:SetText("t (s)")

		swapFrame:RegisterEvent("UNIT_INVENTORY_CHANGED")
		swapFrame:RegisterEvent("PLAYER_LOGIN")
		swapFrame.setActive(BlueyAnnihilatorSV.autoswap)

		if BlueyAnnihilatorSV.mhSliderVal then
			swapFrame.mhSlider:SetValue(BlueyAnnihilatorSV.mhSliderVal)
		else
			swapFrame.mhSlider:SetValue(0)
		end

		if BlueyAnnihilatorSV.ohSliderVal then
			swapFrame.ohSlider:SetValue(BlueyAnnihilatorSV.ohSliderVal)
		else
			swapFrame.ohSlider:SetValue(0)
		end
		
		if BlueyAnnihilatorSV.active then
			BA.mf:Show()
		else
			BA.mf:Hide()
		end		
	elseif event == "PLAYER_LOGOUT" then
		BlueyAnnihilatorSV.lastSave = date("%m/%d/%y %H:%M:%S")
	end
end)

BA.mf = CreateFrame("Button", "BA_MF" , UIParent)
BA.mf:SetMovable(true)
BA.mf:SetFrameStrata("BACKGROUND")
BA.mf:EnableMouse(true)
BA.mf:RegisterForDrag("LeftButton")
BA.mf:RegisterForClicks("AnyUp")
BA.mf:SetClampedToScreen(true)
BA.mf:SetScript("OnDragStart", BA.mf.StartMoving)
BA.mf:SetScript("OnDragStop", function()

	BA.mf:StopMovingOrSizing()
	local point, relativeTo, relativePoint, xOfs, yOfs = BA.mf:GetPoint()
	BlueyAnnihilatorSV.point = point
	BlueyAnnihilatorSV.relativePoint = relativePoint
	BlueyAnnihilatorSV.xOfs = xOfs
	BlueyAnnihilatorSV.yOfs = yOfs
	
end)
BA.mf:SetScript("OnClick", function(self, button, down)
	if button == "RightButton" then
		if swapFrame:IsShown() then
			swapFrame:Hide()
		else
			swapFrame.update("player")
			swapFrame:Show()
		end
	elseif button == "LeftButton" then
		swapFrame.setActive(not(BlueyAnnihilatorSV.autoswap))
	end
end)

BA.mf.mfTexture = BA.mf:CreateTexture()
BA.mf.mfTexture:SetAllPoints()
BA.mf.mfTexture:SetTexture(ANNIHILATOR_TEXTURE) -- item ID of Annihilator

BA.mfCooldown = CreateFrame("Cooldown", "myCooldown", BA.mf, "CooldownFrameTemplate")
BA.mfCooldown:SetPoint("TOPLEFT", 3,-3)
BA.mfCooldown:SetPoint("BOTTOMRIGHT", -3,3)
BA.mfCooldown:SetReverse(true)
BA.mfCooldown:SetFrameStrata("LOW")
BA.mfCooldown:SetCooldown(GetTime(),1)

BA.tf = CreateFrame("Frame",nil,BA.mf) -- text frame inside the annihilator icon
BA.tf:SetAllPoints()
BA.tf:SetFrameStrata("LOW")
BA.tf.text = BA.tf:CreateFontString("maintext","OVERLAY","GameFontNormalLarge")
BA.tf.A_users = BA.tf:CreateFontString("userstext","OVERLAY","GameFontNormalLarge")
BA.tf.A_users:SetFont(BoldFont, 12, "THINOUTLINE")
BA.tf.A_users:SetPoint("TOPLEFT", BA.tf, "TOPRIGHT", 5,-2)
BA.tf.A_users:SetJustifyH("LEFT")
BA.tf.A_users:SetJustifyV("TOP")
BA.tf.A_users:SetText("")

BA.receiver = CreateFrame("Frame")
BA.receiver:SetScript("OnEvent", function(self, event, message, ...)
	if message == prefix then
		local stacks = select(1,...)
		if tonumber(stacks) > 2 then
			BlueyAnnihilatorSV.stacks = tonumber(stacks)
			-- MH --
			if swapFrame.MH_enabled then
				if swapFrame.MH_threshold and swapFrame.MH_anniLink then
					if swapFrame.OLD_MH_itemLink and BlueyAnnihilatorSV.mhSliderVal < 45 then
						EquipItemByName(swapFrame.OLD_MH_itemLink,16)
						swapFrame.MH_anni = false
					end
				end
			end
			-- OH --
			if swapFrame.OH_enabled then
				if swapFrame.OH_threshold and swapFrame.OH_anniLink then
					if swapFrame.OLD_OH_itemLink and BlueyAnnihilatorSV.ohSliderVal < 45 then
						EquipItemByName(swapFrame.OLD_OH_itemLink,17)
						swapFrame.OH_anni = false
					end
				end
			end
		end
		BlueyAnnihilatorSV.applied = true
		BlueyAnnihilatorSV.timer = GetTime()
		BA.mfCooldown:SetCooldown(GetTime(),45)
	end
end)

BA.auraScanner = CreateFrame("FRAME")
function BA.scanAuras()
	if not UnitExists("TARGET") then return end
	local i = 1
	BA.auraScanner:SetScript("OnUpdate", function(self, elapsed)
		if UnitDebuff("TARGET",i) then	
			local name, _, texture, count, _, duration, expirationTime  = UnitDebuff("TARGET", i)
			if UnitDebuff("TARGET", i) == "Armor Shatter" then
				BlueyAnnihilatorSV.stacks = tonumber(count)
				BA.auraScanner:SetScript("OnUpdate", nil)
				return
			end
			i = i + 1
		else
			BlueyAnnihilatorSV.stacks = 0
			BA.auraScanner:SetScript("OnUpdate", nil)
		end
	end)
end

BA.tracker = CreateFrame("Frame", "trackerframe", UIParent)
BA.tracker:SetScript("OnEvent", function(self, event, ...)
	local timestamp,eventType,source,_,_,_,_,_,spellID, spellName = ...
	-- simulate a switch
	if spellName == "Armor Shatter" then
		local now = GetTime()

		if eventType == "SPELL_AURA_APPLIED" then
			BA.mfCooldown:SetCooldown(now,45)
			BlueyAnnihilatorSV.timer = now
			BlueyAnnihilatorSV.stacks = 1
			BlueyAnnihilatorSV.applied = true

		elseif eventType == "SPELL_AURA_APPLIED_DOSE" or eventType == "SPELL_AURA_REMOVED_DOSE" then
		-- removed for the first proc, applied for 2 and 3 stack procs
			BA.mfCooldown:SetCooldown(now,45)
			BlueyAnnihilatorSV.timer = now
			BlueyAnnihilatorSV.stacks = select(13,...) 
			BlueyAnnihilatorSV.applied = true

		elseif eventType == "SPELL_AURA_REMOVED" then
		-- Armor Shatter has faded
			BlueyAnnihilatorSV.applied = false
			BlueyAnnihilatorSV.stacks = 0
			BA.tf.text:SetText("t (s)")
		elseif eventType == "SPELL_AURA_REFRESH" then
			BlueyAnnihilatorSV.timer = now
			BA.mfCooldown:SetCooldown(now,45)
			BlueyAnnihilatorSV.applied = true
			if tonumber(BlueyAnnihilatorSV.stacks) < 3 then
				BA.scanAuras()
			end
			SendAddonMessage(prefix, BlueyAnnihilatorSV.stacks , "RAID")
			if BlueyAnnihilatorSV.stacks == 3 then
				if swapFrame.OLD_OH_itemLink and BlueyAnnihilatorSV.ohSliderVal < 45 then
					EquipItemByName(swapFrame.OLD_OH_itemLink,17)
					swapFrame.OH_anni = false
				end
				if swapFrame.OLD_MH_itemLink and BlueyAnnihilatorSV.mhSliderVal < 45 then
					EquipItemByName(swapFrame.OLD_MH_itemLink,16)
					swapFrame.MH_anni = false
				end
			end
		end
	end
end)

local updatedelay = 0.2
local scandelay = 10
local timesincelastupdate = 0
local timesincelastscan = 0
BA.tracker:SetScript("OnUpdate", function(self, elapsed)
	timesincelastupdate = timesincelastupdate + elapsed
	timesincelastscan = timesincelastscan + elapsed

	if BlueyAnnihilatorSV.applied then
		if timesincelastupdate > updatedelay then
			timesincelastupdate = 0
			local duration = (45-(GetTime()-BlueyAnnihilatorSV.timer))
			if duration >= 0 then
				BA.tf.text:SetText(floor(duration).." ("..BlueyAnnihilatorSV.stacks..")")
				BlueyAnnihilatorSV.delay = 0
			else 
				BlueyAnnihilatorSV.applied = false
				BlueyAnnihilatorSV.stacks = 1
				BA.tf.text:SetText("t (s)")
			end
		end

		if timesincelastscan > scandelay then
			timesincelastscan = 0
			BA.scanAuras()
		end
	end
end)

-- checking raiders for annihilators --
local str, users, raiding = "", {}, false
local delay, inspect_delay = 0, 1
local GetFramerate = GetFramerate
BA.anniWatcher = CreateFrame("Frame",nil)
local function checkAnnihilators(unit)
	if InCombatLockdown() then				
		if CanInspect(unit,false) then
			NotifyInspect(unit)
			local unitName = GetUnitName(unit)
			users[unitName] = 0
			local MH = (GetInventoryItemLink(unit,16))
			local OH = (GetInventoryItemLink(unit,17))
			ClearInspectPlayer()
				if select(1,GetItemInfo(MH)) == "Annihilator" then
					users[unitName] = users[unitName] + 1
				end
			if OH then
				if select(1,GetItemInfo(OH)) == "Annihilator" then
					users[unitName] = users[unitName] + 1
				end
			end

			local str = ""
			A_count = 0
			for player,count in pairs(users) do
				A_count = A_count + count
				if count == 0 then
					--str = str.. colors.red .. player .. " ("..count..")\n"
				elseif count == 1 then
					str = str.. "|cff"..colors.blue .. player .. " ("..count..")\n"
				elseif count == 2 then
					str = str.. "|cff"..colors.green .. player .. " ("..count..")\n"
				end
			end
			BA.tf.A_users:SetText("Total: "..A_count.."\n"..str)
		end
	end
end
BA.anniWatcher:SetScript("OnEvent", function(self,event,...)
	if event == ("RAID_ROSTER_UPDATE" or event == "VARIABLES_LOADED") then
		raiders_TOTAL = GetNumRaidMembers()
		if raiders_TOTAL > 0 then
			raiding = true
		else 
			raiding = false
			BA.tf.A_users:SetText("NOT\nRAIDING")
		end
	elseif event == ("UNIT_INVENTORY_CHANGED") then
		-- local unit = ...
		checkAnnihilators(...)
	elseif event == ("PLAYER_REGEN_ENABLED") then
		-- leave combat --
		
	elseif event == ("PLAYER_REGEN_DISABLED") then
		-- enter combat --
		BlueyAnnihilatorSV.duration = 0
	elseif event == ("PLAYER_TARGET_CHANGED") then
		BA.scanAuras()
	end
end)

-- autoswap functions --
swapFrame = CreateFrame("FRAME", "BA_swapFrame", BA.mf)
swapFrame.needsUpdate = true
swapFrame.annihs = {}
swapFrame:Hide()
swapFrame:SetPoint("BOTTOMLEFT", swapFrame:GetParent(), "TOPLEFT", 0,3)
swapFrame:SetWidth(150)
swapFrame:SetHeight(60)
swapFrame.background = swapFrame:CreateTexture("swapFrame_background", "ARTWORK")
swapFrame.background:SetAllPoints()
swapFrame.background:SetTexture(0,0,0,0.6)
BA.mf.activeText = BA.mf:CreateFontString("swapActiveStatus","OVERLAY", "GameFontNormalSmall")
BA.mf.activeText:SetPoint("BOTTOM", BA.mf, "TOP", 0, 3)
BA.mf.activeText.prefix = "Autoswap  "
swapFrame.setActive = function(active)
	if active then
		BlueyAnnihilatorSV.autoswap = true
		swapFrame:RegisterEvent("COMBAT_LOG_EVENT")
		BA.mf.activeText:SetText(BA.mf.activeText.prefix.."|cff"..colors.green.."on")
	else
		BlueyAnnihilatorSV.autoswap = false
		swapFrame:UnregisterEvent("COMBAT_LOG_EVENT")
		BA.mf.activeText:SetText(BA.mf.activeText.prefix.."off")
		if swapFrame.OLD_MH_itemLink then
			EquipItemByName(swapFrame.OLD_MH_itemLink,16)
			swapFrame.MH_anni = false
		end
		if swapFrame.OLD_OH_itemLink then
			EquipItemByName(swapFrame.OLD_OH_itemLink,17)
			swapFrame.OH_anni = false
		end
	end
end

swapFrame.mhSlider = CreateFrame("Slider", "mySlider", swapFrame, "OptionsSliderTemplate")
local sMH = swapFrame.mhSlider
sMH.prefix = "MH: "
sMH:SetOrientation('HORIZONTAL')
sMH:SetPoint("TOPLEFT", 2,-2)
sMH:SetPoint("TOPRIGHT", -2,-2)
sMH:SetMinMaxValues(0,45)
sMH:SetValueStep(1)
sMH.text = sMH:CreateFontString("mhslidervalue","OVERLAY","GameFontNormalSmall")
sMH.text:SetFont(BoldFont, 12, "OUTLINE")
sMH.text:SetPoint("CENTER", 0 -20)
sMH:SetScript("OnValueChanged", function(self,value)
	if value < 1 then
		swapFrame.MH_enabled = false
		sMH.text:SetText(sMH.prefix.."OFF")
		if BlueyAnnihilatorSV.ohSliderVal == 0 then
			if next(BlueyAnnihilatorSV) then -- only when not logging in
				swapFrame.setActive(false)
			end				
		end	
		if swapFrame.OLD_MH_itemLink then
			EquipItemByName(swapFrame.OLD_MH_itemLink,16)
			swapFrame.MH_anni = false
		end
	else
		swapFrame.MH_enabled = true
		sMH.text:SetText(sMH.prefix..value)
	end
	swapFrame.MH_threshold = value			
	BlueyAnnihilatorSV.mhSliderVal = value
end)

swapFrame.ohSlider = CreateFrame("Slider", "ohSlider", swapFrame, "OptionsSliderTemplate")
local sOH = swapFrame.ohSlider
sOH.prefix = "OH: "
sOH:SetOrientation('HORIZONTAL')
sOH:SetPoint("BOTTOMLEFT", 2,15)
sOH:SetPoint("BOTTOMRIGHT", -2,15)
sOH:SetMinMaxValues(0,45)
sOH:SetValueStep(1)
sOH.text = sOH:CreateFontString("ohslidervalue","OVERLAY","GameFontNormalSmall")
sOH.text:SetFont(BoldFont, 12, "OUTLINE")
sOH.text:SetPoint("CENTER", 0 -20)
sOH:SetScript("OnValueChanged", function(self,value)
	if value < 1 then
		swapFrame.OH_enabled = false
		sOH.text:SetText(sOH.prefix.."OFF")
		if BlueyAnnihilatorSV.mhSliderVal == 0 then
			if next(BlueyAnnihilatorSV) then -- only when not logging in
				swapFrame.setActive(false)
			end
		end
		if swapFrame.OLD_OH_itemLink then
			EquipItemByName(swapFrame.OLD_OH_itemLink,17)
			swapFrame.OH_anni = false
		end
	else
		swapFrame.OH_enabled = true
		sOH.text:SetText(sOH.prefix..value)
	end
	swapFrame.OH_threshold = value
	BlueyAnnihilatorSV.ohSliderVal = value
end)


function swapFrame.getA_buttons(itemLink) 
	if not sMH.A_buttons then
		sMH.A_buttons = {}
	end
	if not sOH.A_buttons then
		sOH.A_buttons = {}
	end
	local MHb = false
	local OHb = false
	for k,t in pairs(sMH.A_buttons) do
		if t.itemLink == itemLink then
			MHb = t
		end
	end
	for k,t in pairs(sOH.A_buttons) do
		if t.itemLink == itemLink then
			OHb = t
		end
	end
	return MHb, OHb
end

function swapFrame.update(...)
	if ... == "player" and swapFrame.needsUpdate then
		swapFrame.needsUpdate = false

		-- find annihilators in bags -- 
		for bagID = 0,4 do
			local numberOfSlots = GetContainerNumSlots(bagID)
			local itemLink
			for slot = 1,numberOfSlots do
				itemLink = GetContainerItemLink(bagID, slot)
				if itemLink then
					if select(1,GetItemInfo(itemLink) == "Annihilator") then
						if not tContains(swapFrame.annihs, itemLink) then
							tinsert(swapFrame.annihs, itemLink)
						end
					end
				end
			end
		end

		-- find equipped annihilators --
		for slot = 16,17 do
			local itemLink
			itemLink = GetInventoryItemLink("PLAYER", slot)
			if itemLink then
				if select(1,GetItemInfo(itemLink) == "Annihilator") then
					if slot == 16 then
						swapFrame.MH_anni = true
					else
						swapFrame.OH_anni = true
					end
					if not tContains(swapFrame.annihs, itemLink) then
						tinsert(swapFrame.annihs, itemLink)
					end
				else
					if slot == 16 then
						swapFrame.MH_anni = false
					else
						swapFrame.OH_anni = false
					end
				end
			end
		end

		-- create buttons for annihilators (based on weaponEnchants) -- 
		for k,itemLink in pairs(swapFrame.annihs) do
			local _, _, Color, Ltype, Id, Enchant, Gem1, Gem2, Gem3, Gem4,
				Suffix, Unique, LinkLvl, Name = string.find(itemLink,
				"|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*):?(%-?%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
			local enchantID, enchantName = getEnchantInfo(Enchant)
			local MHb, OHb = swapFrame.getA_buttons(itemLink)
			
			-- create frame for MH if it doesnt exist -- 
			if not MHb then
				swapFrame.newButton = true
				MHb = CreateFrame("FRAME", nil, swapFrame.mhSlider)
				
				MHb.itemLink = itemLink
				MHb.selected = false
				MHb.texture = MHb:CreateTexture(nil, "ARTWORK")
				local texture = select(3,GetSpellInfo(enchantID))
				if not texture or (strlen(texture)<5) then 
					MHb.texture:SetTexture(ANNIHILATOR_TEXTURE)
					enchantName = "No enchant"
				else
					MHb.texture:SetTexture(texture)
				end
				
				MHb.texture:SetAllPoints()

				MHb.overlay = MHb:CreateTexture(nil, "OVERLAY")
				MHb.overlay:SetAllPoints()
				if BlueyAnnihilatorSV.MH_anniLink == itemLink then
					MHb.selected = true
					MHb.overlay:SetTexture(unpack(colors.greenrgb))
					swapFrame.MH_anniLink = itemLink
				else
					MHb.selected = false
					MHb.overlay:SetTexture(unpack(colors.redrgb))
				end

				MHb.namehighlight = MHb:CreateFontString(nil, "HIGHLIGHT", "GameFontNormalSmall")
				MHb.namehighlight:SetFont(BoldFont, 14, "THINOUTLINE")
				MHb.namehighlight:SetPoint("BOTTOM", MHb, "TOP", 0, 3)
				MHb.namehighlight:SetText(enchantName)

				MHb:EnableMouse(true)
				MHb:SetScript("OnMouseDown", function(self, button, down)
					swapFrame.MH_anniLink = self.itemLink
					BlueyAnnihilatorSV.MH_anniLink = self.itemLink
					for i,sMHb in ipairs(swapFrame.mhSlider.A_buttons) do
						if sMHb.itemLink == self.itemLink then
							sMHb.selected = true
							sMHb.overlay:SetTexture(unpack(colors.greenrgb))
						else
							sMHb.selected = false
							sMHb.overlay:SetTexture(unpack(colors.redrgb))
						end
					end
				end)
				tinsert(swapFrame.mhSlider.A_buttons,MHb)
			end

			-- create frame for OH if it doesnt exist -- 
			if not OHb then
				swapFrame.newButton = true
				OHb = CreateFrame("FRAME", nil, swapFrame.ohSlider)
				
				OHb.itemLink = itemLink
				OHb.selected = false
				OHb.texture = OHb:CreateTexture(nil, "ARTWORK")
				local texture = select(3,GetSpellInfo(enchantID))
				if not texture or (strlen(texture)<5) then
					OHb.texture:SetTexture(ANNIHILATOR_TEXTURE)
					enchantName = "No enchant"
				else
					OHb.texture:SetTexture(texture)
				end
				OHb.texture:SetAllPoints()

				OHb.overlay = OHb:CreateTexture(nil, "OVERLAY")
				OHb.overlay:SetAllPoints()
				if BlueyAnnihilatorSV.OH_anniLink == itemLink then
					OHb.selected = true
					OHb.overlay:SetTexture(unpack(colors.greenrgb))
					swapFrame.OH_anniLink = itemLink
				else
					OHb.selected = false
					OHb.overlay:SetTexture(unpack(colors.redrgb))
				end

				OHb.namehighlight = OHb:CreateFontString(nil, "HIGHLIGHT", "GameFontNormalSmall")
				OHb.namehighlight:SetFont(BoldFont, 14, "THINOUTLINE")
				OHb.namehighlight:SetPoint("BOTTOM", OHb, "TOP", 0, 3)
				OHb.namehighlight:SetText(enchantName)
				
				OHb:EnableMouse(true)
				OHb:SetScript("OnMouseDown", function(self, button, down)
					swapFrame.OH_anniLink = self.itemLink
					BlueyAnnihilatorSV.OH_anniLink = self.itemLink
					for i,sOHb in ipairs(swapFrame.ohSlider.A_buttons) do
						
						if sOHb.itemLink == self.itemLink then
							sOHb.selected = true
							sOHb.overlay:SetTexture(unpack(colors.greenrgb))
						else
							sOHb.selected = false
							sOHb.overlay:SetTexture(unpack(colors.redrgb))
						end
					end
				end)
				tinsert(swapFrame.ohSlider.A_buttons,OHb)
			end
		end

		-- properly place the buttons -- 
		if swapFrame.newButton then
			swapFrame.newButton = false
			if swapFrame.mhSlider.A_buttons then
				for i,MHb in ipairs(swapFrame.mhSlider.A_buttons) do
					MHb:SetPoint("TOPLEFT",MHb:GetParent(), "TOPRIGHT", i*3+25*(i-1), 0)
					MHb:SetHeight(25)
					MHb:SetWidth(25)
					if swapFrame.MH_anniLink == MHb.itemLink then
						MHb.overlay:SetTexture(unpack(colors.greenrgb))
					else
						MHb.overlay:SetTexture(unpack(colors.redrgb))
					end
				end
			end
			if swapFrame.ohSlider.A_buttons then
				for i,OHb in ipairs(swapFrame.ohSlider.A_buttons) do
					OHb:SetPoint("TOPLEFT", OHb:GetParent(), "TOPRIGHT", i*3+25*(i-1), 0)
					OHb:SetHeight(25)
					OHb:SetWidth(25)
					if swapFrame.OH_anniLink == OHb.itemLink then
						OHb.overlay:SetTexture(unpack(colors.greenrgb))
					else
						OHb.overlay:SetTexture(unpack(colors.redrgb))
					end
				end
			end
		end
	end
end

swapFrame:SetScript("OnEvent", function(self,event, ...)
	if not BlueyAnnihilatorSV.active then return end
	if event == "COMBAT_LOG_EVENT" then
		-- autoswap --
		local timestamp,eventType,source,srcName,_,dstGUID,auraDest,_,spellID, spellName = ...
		if strmatch(eventType,"SWING") and srcName == PLAYERNAME then
			local duration = (45-(GetTime()-BlueyAnnihilatorSV.timer))
			local stacks = tonumber(BlueyAnnihilatorSV.stacks)
			if not stacks then stacks = 0 end
			-- MH --
			if swapFrame.MH_enabled and BlueyAnnihilatorSV.autoswap then
				if swapFrame.MH_threshold and swapFrame.MH_anniLink then
					if ( (duration < swapFrame.MH_threshold) or (stacks < 3) ) and not(swapFrame.MH_anni) then
						swapFrame.OLD_MH_itemLink = GetInventoryItemLink("PLAYER",16)
						EquipItemByName(swapFrame.MH_anniLink, 16)
						swapFrame.MH_anni = true
					elseif (duration > swapFrame.MH_threshold) and swapFrame.MH_anni then
						if tonumber(BlueyAnnihilatorSV.stacks) < 3 then return end
						if swapFrame.OLD_MH_itemLink then
							EquipItemByName(swapFrame.OLD_MH_itemLink,16)
							swapFrame.MH_anni = false
						end
					else
						--print(duration.. " / " ..swapFrame.MH_threshold)
					end
				end
			end

			-- OH --
			if swapFrame.OH_enabled and BlueyAnnihilatorSV.autoswap then
				if ( (duration < swapFrame.OH_threshold) or (stacks < 3) ) and swapFrame.OH_anniLink then
					if (duration < swapFrame.OH_threshold) and not(swapFrame.OH_anni) then
						swapFrame.OLD_OH_itemLink = GetInventoryItemLink("PLAYER",17)
						EquipItemByName(swapFrame.OH_anniLink, 17)
						swapFrame.OH_anni = true
					elseif (duration > swapFrame.OH_threshold) and swapFrame.OH_anni then
						if BlueyAnnihilatorSV.stacks < 3 then return end
						if swapFrame.OLD_OH_itemLink then
							EquipItemByName(swapFrame.OLD_OH_itemLink,17)
							swapFrame.OH_anni = false
						end
					else
						--print(duration.. " / " ..swapFrame.OH_threshold)
					end
				else
					--print("Threshold or itemLink not set for OH")
				end
			end
		end

	elseif event == "PLAYER_LOGIN" then
		swapFrame.needsUpdate = true
		swapFrame:UnregisterEvent("PLAYER_LOGIN")
	elseif event == "UNIT_INVENTORY_CHANGED" then
		if ... == "player" then
			swapFrame.needsUpdate = true
		end
	end
end)