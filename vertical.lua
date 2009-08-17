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
	bg:SetBackdropColor(0, 0, 0, .6)
	bg:SetBackdropBorderColor(1, 1, 1, .6)

	bg:SetPoint("LEFT", obj, "LEFT", -6, 0)
	bg:SetPoint("RIGHT", obj, "RIGHT", 6, 0)
	bg:SetPoint("TOP", obj, "TOP", 0, 6)
	bg:SetPoint("BOTTOM", obj, "BOTTOM", 0, -6)
end

local siValue = function(val)
	if(val >= 1e6) then
		return ('%.1f'):format(val / 1e6):gsub('%.', 'm')
	elseif(val >= 1e4) then
		return ("%.1f"):format(val / 1e3):gsub('%.', 'k')
	else
		return val
	end
end

local function Hex(r, g, b)
	if type(r) == "table" then
		if r.r then r, g, b = r.r, r.g, r.b else r, g, b = unpack(r) end
	end
	return string.format("|cff%02x%02x%02x", r*255, g*255, b*255)
end

local UnitSpecific = {
	player = function(self)
		-- We create it on the health bar, as statusbar like to stay high...
		local combat = self.Health:CreateTexture(nil, "OVERLAY")
		combat:SetHeight(32)
		combat:SetWidth(32)
		combat:SetPoint("BOTTOM", self, 0, -14)

		self.Combat = combat

		local resting = self.Health:CreateTexture(nil, "OVERLAY")
		resting:SetHeight(24)
		resting:SetWidth(24)
		resting:SetPoint("BOTTOMLEFT", self, -6, -8)

		self.Resting = resting

		local hp = self:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		hp:SetPoint("LEFT", self, "RIGHT", 24, -16)
		hp:SetFont(GameFontNormal:GetFont(), 16)
		hp:SetTextColor(1, 1, 1)
		self:Tag(hp, '[VE-Double:HP]')

		local pp = self:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		pp:SetPoint("TOP", hp, "BOTTOM")
		pp:SetFont(GameFontNormal:GetFont(), 16)
		self:Tag(pp, '[raidcolor][VE-Double:PP]|r')
	end,

	target = function(self)
		local hp = self:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		hp:SetPoint("RIGHT", self, "LEFT", -24, -16)
		hp:SetFont(GameFontNormal:GetFont(), 16)
		hp:SetTextColor(1, 1, 1)
		self:Tag(hp, '[VE-Double:HP]')

		local pp = self:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		pp:SetPoint("TOP", hp, "BOTTOM")
		pp:SetFont(GameFontNormal:GetFont(), 16)
		self:Tag(pp, '[raidcolor][VE-Double:PP]|r')
	end,
}

-- Custom tags:
oUF.Tags['[VE-Double:HP]'] = function(unit)
	local min = UnitHealth(unit)
	if(min > 0) then
		return siValue(min)
	end
end

oUF.Tags['[VE-Double:PP]'] = function(unit)
	local min = UnitPower(unit)
	if(min > 0) then
		return siValue(min)
	end
end

oUF.Tags['[VE-Single:HPColor]'] = function(unit)
	local max = UnitHealthMax(unit)
	if(max ~= 0) then
		return Hex(oUF.ColorGradient(UnitHealth(unit) / max, unpack(oUF.colors.smooth)))
	end
end

oUF.TagEvents['[VE-Double:HP]'] = 'UNIT_HEALTH'
oUF.TagEvents['[VE-Double:PP]'] = 'UNIT_ENERGY UNIT_FOCUS UNIT_MANA UNIT_RAGE UNIT_RUNIC_POWER'

oUF.TagEvents['[VE-Single:HPColor]'] = 'UNIT_HEALTH'

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

	if(UnitSpecific[unit]) then
		return UnitSpecific[unit](self)
	end
end

-- Used by player and target.
local Double = function(self, unit)
	-- Add the shared madness
	Shared(self, unit)

	local hp = self.Health
	createBackDrop(self, hp)

	local pp = CreateFrame("StatusBar", nil, self)
	createBackDrop(self, pp)

	pp:SetOrientation"VERTICAL"
	pp:SetStatusBarTexture"Interface\\AddOns\\oUF_VerticalEntity\\textures\\statusbar"

	pp.colorPower = true

	self.Power = pp

	hp:SetWidth(40 - 12)
	hp:SetHeight(160 - 8)

	pp:SetWidth(40 - 12)
	pp:SetHeight(160 - 8)

	hp:SetPoint("LEFT", 5, 0)
	pp:SetPoint("RIGHT", -5, 0)

	self:SetAttribute('initial-height', 160)
	self:SetAttribute('initial-width', 40 + 40)
end

-- Used by party.
local Single = function(self, unit)
	-- Add the shared madness
	Shared(self, unit)

	self:SetBackdrop(backdrop)
	self:SetBackdropColor(0, 0, 0, .6)
	self:SetBackdropBorderColor(1, 1, 1, .6)

	local hp = self.Health

	local hpbg = hp:CreateTexture(nil, "BORDER")
	hpbg:SetAllPoints(hp)
	hpbg:SetAlpha(.8)
	hpbg:SetTexture(1, 1, 1)

	hpbg.multiplier = .3
	hp.bg = hpbg

	local hptag = hp:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	hptag:SetPoint("BOTTOM", hp, 0, 5)
	hptag:SetPoint"LEFT"
	hptag:SetPoint"RIGHT"
	hptag:SetJustifyH"CENTER"
	hptag:SetFont(GameFontNormal:GetFont(), 16)
	hptag:SetTextColor(1, 1, 1)
	self:Tag(hptag, '[VE-Single:HPColor][VE-Double:HP]|r')

	local pp = CreateFrame("StatusBar", nil, self)
	pp:SetOrientation"VERTICAL"
	pp:SetStatusBarTexture"Interface\\AddOns\\oUF_VerticalEntity\\textures\\statusbar"

	local ppbg = pp:CreateTexture(nil, "BORDER")
	ppbg:SetAllPoints(pp)
	ppbg:SetAlpha(.8)
	ppbg:SetTexture(1, 1, 1)

	ppbg.multiplier = .3

	pp.bg = ppbg
	pp.colorPower = true

	self.Power = pp

	hp:SetWidth(60 - 11)
	hp:SetHeight(135 - 12)

	pp:SetWidth(8 - 2)
	pp:SetHeight(135 - 12)

	hp:SetPoint("LEFT", 6, 0)
	pp:SetPoint("RIGHT", -6, 0)

	self:SetAttribute('initial-height', 135)
	self:SetAttribute('initial-width', 60 + 8)
end

-- Used by target of target.
local Small = function(self, unit)
	-- Add the shared madness
	Shared(self, unit)

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
local party = oUF:Spawn("header", "oUF_VEParty")
party:SetPoint("BOTTOM", 0, 45)
party:SetManyAttributes(
	"showParty", true,
	"xOffset", 35,
	"point", "LEFT"
)
party:Show()
