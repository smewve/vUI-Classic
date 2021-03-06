local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local DT = vUI:GetModule("DataText")
local Gold = vUI:GetModule("Gold")

local GetMoney = GetMoney
local GetCoinTextureString = GetCoinTextureString

local OnEnter = function(self)
	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	
	local TrashValue = select(2, vUI:GetTrashValue())
	local ServerInfo, ServerTotalGold = Gold:GetServerInfo()
	local Change = Gold:GetSessionStats()
	
	GameTooltip:AddLine(vUI.UserRealm)
	GameTooltip:AddLine(" ")
	
	if (#ServerInfo > 1) then
		GameTooltip:AddDoubleLine(Language["Total"], GetCoinTextureString(ServerTotalGold), 1, 0.82, 0, 1, 1, 1)
	end
	
	for i = 1, #ServerInfo do
		GameTooltip:AddDoubleLine(ServerInfo[i][1], GetCoinTextureString(ServerInfo[i][2]), 1, 1, 1, 1, 1, 1)
	end
	
	if (Change ~= 0) then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(Language["Session"])
		
		if (Change > 0) then
			GameTooltip:AddDoubleLine(Language["|cFF66FF66Profit|r"], GetCoinTextureString(Change), 1, 1, 1, 1, 1, 1)
		else
			GameTooltip:AddDoubleLine(Language["|cFFFF6666Loss|r"], GetCoinTextureString(Change * -1), 1, 1, 1, 1, 1, 1)
		end
	end
	
	if (TrashValue > 0) then
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(Language["Trash item vendor value:"], GetCoinTextureString(TrashValue), 1, 1, 1, 1, 1, 1)
	end
	
	GameTooltip:Show()
end

local OnLeave = function()
	GameTooltip:Hide()
end

local Update = function(self)
	self.Text:SetText(format("|cff%s%s|r", Settings["data-text-value-color"], GetCoinTextureString(GetMoney())))
end

local OnEnable = function(self)
	self:RegisterEvent("PLAYER_MONEY")
	self:SetScript("OnEvent", self.Update)
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", OnLeave)
	
	self:Update()
end

local OnDisable = function(self)
	self:UnregisterEvent("PLAYER_MONEY")
	self:SetScript("OnEvent", nil)
	self:SetScript("OnEnter", nil)
	self:SetScript("OnLeave", nil)
	
	self.Text:SetText("")
end

DT:SetType("Gold", OnEnable, OnDisable, Update)