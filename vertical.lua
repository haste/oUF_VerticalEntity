-- From oUF_Classic
local colors = setmetatable({
	health = {.45, .73, .27},
	power = setmetatable({
		['MANA'] = {.27, .53, .73},
		['RAGE'] = {.73, .27, .27},
	}, {__index = oUF.colors.power}),
}, {__index = oUF.colors})

local menu = function(self)
	local unit = self.unit:sub(1, -2)
	local cunit = self.unit:gsub("(.)", string.upper, 1)

	if(unit == "party" or unit == "partypet") then
		ToggleDropDownMenu(1, nil, _G["PartyMemberFrame"..self.id.."DropDown"], "cursor", 0, 0)
	elseif(_G[cunit.."FrameDropDown"]) then
		ToggleDropDownMenu(1, nil, _G[cunit.."FrameDropDown"], "cursor", 0, 0)
	end
end

local backdrop = {
	bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tile = true, tileSize = 16,
	edgeFile = [[Interface\AddOns\oUF_VerticalEntity\textures\IshBorder]], edgeSize = 16,
	insets = {left = 4, right = 4, top = 4, bottom = 4},
}

-- Utility functions:
local createBackDrop = function(self, obj)
	local bg = CreateFrame("Frame", nil, self)
	bg:SetBackdrop(backdrop)
	bg:SetBackdropColor(0, 0, 0, .5)

	bg:SetPoint("LEFT", obj, "LEFT", -6, 0)
	bg:SetPoint("RIGHT", obj, "RIGHT", 6, 0)
	bg:SetPoint("TOP", obj, "TOP", 0, 6)
	bg:SetPoint("BOTTOM", obj, "BOTTOM", 0, -6)
end

-- Stuff that's shared between all frames.
local Shared = function(self, unit)
	self.menu = menu
	self.colors = colors

	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)

	self:RegisterForClicks"anyup"
	self:SetAttribute("*type2", "menu")

	local hp = CreateFrame("StatusBar", nil, self)
	hp:SetOrientation"VERTICAL"
	hp:SetStatusBarTexture"Interface\\AddOns\\oUF_VerticalEntity\\textures\\statusbar"

	hp.colorClass = true

	self.Health = hp
end

-- Used by player and target.
local Double = function(self, unit)
	-- Add the shared madness
	Shared(self)

	local hp = self.Health
	createBackDrop(self, hp)

	local pp = CreateFrame("StatusBar", nil, self)
	createBackDrop(self, pp)

	pp:SetOrientation"VERTICAL"
	pp:SetStatusBarTexture"Interface\\AddOns\\oUF_VerticalEntity\\textures\\statusbar"

	pp.colorPower = true

	self.Power = pp

	hp:SetWidth(45 - 10)
	hp:SetHeight(180 - 8)

	pp:SetWidth(45 - 10)
	pp:SetHeight(180 - 8)

	hp:SetPoint("LEFT", 5, 0)
	pp:SetPoint("RIGHT", -5, 0)

	self:SetAttribute('initial-height', 180)
	self:SetAttribute('initial-width', 45 + 45)
end

-- Used by party.
local Single = function(self, unit)
	-- Add the shared madness
	Shared(self)

	self:SetBackdrop(backdrop)
	self:SetBackdropColor(0, 0, 0, 1)

	local pp = CreateFrame("StatusBar", nil, self)
	pp:SetOrientation"VERTICAL"
	pp:SetStatusBarTexture"Interface\\AddOns\\oUF_VerticalEntity\\textures\\statusbar"

	pp.colorPower = true

	self.Power = pp
end

-- Used by target of target.
local Small = function(self, unit)
	-- Add the shared madness
	Shared(self)

	self:SetBackdrop(backdrop)
	self:SetBackdropColor(0, 0, 0, 1)
end

oUF:RegisterStyle("VerticalEntity - Double", Double)
oUF:RegisterStyle("VerticalEntity - Single", Single)
oUF:RegisterStyle("VerticalEntity - Small", Small)

-- Spawn the frames that should be double.
oUF:SetActiveStyle"VerticalEntity - Double"
oUF:Spawn"player":SetPoint("BOTTOM", -400, 20)
oUF:Spawn"target":SetPoint("BOTTOM", 400, 20)

oUF:SetActiveStyle"VerticalEntity - Single"
oUF:Spawn"targettarget":SetPoint("BOTTOM")
oUF:Spawn"pet":SetPoint("BOTTOM")
