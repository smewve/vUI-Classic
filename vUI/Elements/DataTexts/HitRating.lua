local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local DT = vUI:GetModule("DataText")

local GetHitModifier = GetHitModifier
local GetSpellHitModifier = GetSpellHitModifier
local Label = Language["Hit"]

local OnMouseUp = function()
	ToggleCharacter("PaperDollFrame")
end

local Update = function(self, event, unit)
	if (unit and unit ~= "player") then
		return
	end
	
	local Rating
	local Hit = GetHitModifier()
	local Spell = GetSpellHitModifier()
	
	if (Spell > Hit) then
		Rating = Spell
	else
		Rating = Hit
	end
	
	self.Text:SetFormattedText("|cff%s%s:|r |cff%s%s%%|r", Settings["data-text-label-color"], Label, Settings["data-text-value-color"], Rating)
end

local OnEnable = function(self)
	self:RegisterEvent("UNIT_STATS")
	self:SetScript("OnEvent", Update)
	self:SetScript("OnMouseUp", OnMouseUp)
	
	self:Update("player")
end

local OnDisable = function(self)
	self:UnregisterEvent("UNIT_STATS")
	self:SetScript("OnEvent", nil)
	self:SetScript("OnMouseUp", nil)
	
	self.Text:SetText("")
end

DT:SetType("Hit", OnEnable, OnDisable, Update)