local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local KeyBinding = vUI:NewModule("Key Binding")

local GetMouseFocus = GetMouseFocus
local match = string.match

KeyBinding.ValidBindings = {
	["ACTIONBUTTON"] = true,
	["BONUSACTIONBUTTON"] = true,
	["MULTIACTIONBAR1BUTTON"] = true,
	["MULTIACTIONBAR2BUTTON"] = true,
	["MULTIACTIONBAR3BUTTON"] = true,
	["MULTIACTIONBAR4BUTTON"] = true,
	["SHAPESHIFTBUTTON"] = true,
}

KeyBinding.Translate = {
	["MultiBarBottomLeftButton"] = "MULTIACTIONBAR1BUTTON",
	["MultiBarBottomRightButton"] = "MULTIACTIONBAR2BUTTON",
	["MultiBarRightButton"] = "MULTIACTIONBAR3BUTTON",
	["MultiBarLeftButton"] = "MULTIACTIONBAR4BUTTON",
}

KeyBinding.Filter = {
	["BACKSPACE"] = true,
	["LALT"] = true,
	["RALT"] = true,
	["LCTRL"] = true,
	["RCTRL"] = true,
	["LSHIFT"] = true,
	["RSHIFT"] = true,
	["ENTER"] = true,
	["ESCAPE"] = true,
}

function KeyBinding:OnKeyUp(key)
	if (not IsKeyPressIgnoredForBinding(key) and not self.Filter[key] and self.TargetBindingName) then
		local Alt = IsAltKeyDown() and "ALT-" or ""
		local Ctrl = IsControlKeyDown() and "CTRL-" or ""
		local Shift = IsShiftKeyDown() and "SHIFT-" or ""
		
		if (Alt or Ctrl or Shift) then
			key = Alt .. Ctrl .. Shift .. key
		end
		
		local OldAction = GetBindingAction(key, true)
		
		if OldAction then
			local OldName = GetBindingName(OldAction)
			
			vUI:print(format(Language['Unbound "%s" from %s'], key, OldName))
		end
		
		SetBinding(key, self.TargetBindingName, 1)
		
		local NewAction = GetBindingAction(key, true)
		local NewName = GetBindingName(NewAction)
		
		vUI:print(format(Language['Bound "%s" to %s'], key, NewName))
		
		GUI:GetWidgetByWindow(Language["Action Bars"], "save"):Enable()
		GUI:GetWidgetByWindow(Language["Action Bars"], "discard"):Enable()
	end
end

function KeyBinding:OnKeyDown(key)
	local MouseFocus = GetMouseFocus()
	
	if (MouseFocus and MouseFocus.GetName) then
		local Name = MouseFocus:GetName()
		local ButtonName = match(Name, "%D+")
		
		if self.Translate[ButtonName] then
			if self.ValidBindings[self.Translate[ButtonName]] then
				self.TargetBindingName = self.Translate[ButtonName] .. match(Name, "(%d+)$")
				self.TargetName = Name
			end
		end
	end
end

function KeyBinding:OnUpdate(elapsed)
	self.Elapsed = self.Elapsed + elapsed
	
	if (self.Elapsed > 0.05) then
		local MouseFocus = GetMouseFocus()
		
		if (MouseFocus and MouseFocus.action) then
			self.Hover:SetScaledPoint("TOPLEFT", MouseFocus, 1, -1)
			self.Hover:SetScaledPoint("BOTTOMRIGHT", MouseFocus, -1, 1)
			self.Hover:Show()
		elseif self.Hover:IsShown() then
			self.Hover:Hide()
		end
		
		self.Elapsed = 0
	end
end

local DisableKeyBindingMode = function()
	KeyBinding:Disable()
end

function KeyBinding:Enable()
	self:EnableKeyboard(true)
	self:SetScript("OnUpdate", self.OnUpdate)
	self:SetScript("OnKeyDown", self.OnKeyDown)
	self:SetScript("OnKeyUp", self.OnKeyUp)
	self.Active = true
	
	vUI:print("Binding mode enabled.")
	
	vUI:DisplayPopup(Language["Attention"], Language["Key binding mode is currently active. Would you like to exit key binding mode?"], Language["Accept"], DisableKeyBindingMode, Language["Cancel"])
end

function KeyBinding:Disable()
	self:EnableKeyboard(false)
	self:SetScript("OnUpdate", nil)
	self:SetScript("OnKeyDown", nil)
	self:SetScript("OnKeyUp", nil)
	self.Active = false
	self.TargetBindingName = nil
	
	vUI:print("Binding mode is disabled.")
	vUI:ClearPopup()
end

function KeyBinding:Toggle()
	if self.Active then
		self:Disable()
	else
		self:Enable()
	end
end

function KeyBinding:Load()
	self.Elapsed = 0
	
	self.Hover = CreateFrame("Frame", nil, self)
	self.Hover:SetFrameLevel(50)
	self.Hover:SetFrameStrata("DIALOG")
	self.Hover:SetBackdrop(vUI.Outline)
	self.Hover:SetBackdropBorderColorHex("388E3C")
	self.Hover:Hide()
end

local ToggleBindingMode = function()
	KeyBinding:Toggle()
end

local OnAccept = function()
	AttemptToSaveBindings(GetCurrentBindingSet())
	
	GUI:GetWidgetByWindow(Language["Action Bars"], "discard"):Disable()
	GUI:GetWidgetByWindow(Language["Action Bars"], "save"):Disable()
	
	KeyBinding:Disable()
end

local SaveChanges = function()
	vUI:DisplayPopup(Language["Attention"], Language["Are you sure you would like to save these key binding changes?"], Language["Accept"], OnAccept, Language["Cancel"])
end

local DiscardChanges = function()
	vUI:DisplayPopup(Language["Attention"], Language["Are you sure you would like to discard these key binding changes?"], Language["Accept"], ReloadUI, Language["Cancel"])
end

GUI:AddOptions(function(self)
	local Left, Right = self:GetWindow(Language["Action Bars"])
	
	Right:CreateHeader(Language["Key Binding"])
	Right:CreateButton(Language["Toggle"], Language["Key Bind Mode"], Language["While toggled, you can hover over action buttons|nand press a key combination to rebind that action"], ToggleBindingMode)
	Right:CreateButton(Language["Save"], Language["Save Changes"], Language["Save key binding changes"], SaveChanges)
	Right:CreateButton(Language["Discard"], Language["Discard Changes"], Language["Discard key binding changes"], DiscardChanges)
	
	self:GetWidgetByWindow(Language["Action Bars"], "save"):Disable()
	self:GetWidgetByWindow(Language["Action Bars"], "discard"):Disable()
end)