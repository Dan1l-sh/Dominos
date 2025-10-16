--[[
	menuBar.lua
		A Dominos frame for micro menu buttons
--]]

--[[
	Copyright (c) 2008-2009 Jason Greer
	All rights reserved.

	Redistribution and use in source and binary forms, with or without 
	modification, are permitted provided that the following conditions are met:

		* Redistributions of source code must retain the above copyright notice, 
		  this list of conditions and the following disclaimer.
		* Redistributions in binary form must reproduce the above copyright
		  notice, this list of conditions and the following disclaimer in the 
		  documentation and/or other materials provided with the distribution.
		* Neither the name of the author nor the names of its contributors may 
		  be used to endorse or promote products derived from this software 
		  without specific prior written permission.

	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
	AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
	IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
	ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
	LIABLE FORANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
	SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
	INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
	CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
	ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
	POSSIBILITY OF SUCH DAMAGE.
--]]

--[[
local menuButtons = {
	CharacterMicroButton,
	SpellbookMicroButton,
	TalentMicroButton,
	AchievementMicroButton,
	QuestLogMicroButton,
	SocialsMicroButton,
	PVPMicroButton,
	LFDMicroButton,
	MainMenuMicroButton,
	HelpMicroButton
}
--]]

local menuButtons
do
    local loadButtons = function()
        local order = {
            "CharacterMicroButton",
            "SpellbookMicroButton",
            "TalentMicroButton",
            "AchievementMicroButton",
            "QuestLogMicroButton",
            "SocialsMicroButton",
            "PVPMicroButton",
            "LFDMicroButton",
            "EncounterJournalMicroButton",
            "StoreMicroButton",
            "MainMenuMicroButton",
        }
        menuButtons = {}
        for i = 1, #order do
            local b = _G[order[i]]
            if b then table.insert(menuButtons, b) end
        end
    end
    loadButtons()
end

do
	TalentMicroButton:SetScript('OnEvent', function(self, event)
		if (event == 'PLAYER_LEVEL_UP' or event == 'PLAYER_LOGIN') then
			if UnitCharacterPoints('player') > 0 and not CharacterFrame:IsShown() then
				SetButtonPulse(self, 60, 1)
			end
		elseif event == 'UPDATE_BINDINGS' then
			self.tooltipText =  MicroButtonTooltipText(TALENTS_BUTTON, 'TOGGLETALENTS')
		end
	end)
	TalentMicroButton:UnregisterAllEvents()
	TalentMicroButton:RegisterEvent('PLAYER_LEVEL_UP')
	TalentMicroButton:RegisterEvent('PLAYER_LOGIN')
	TalentMicroButton:RegisterEvent('UPDATE_BINDINGS')

	--simialr thing, but the achievement button
	AchievementMicroButton:UnregisterAllEvents()
end


-- Menu Bar

local MenuBar = Dominos:CreateClass('Frame', Dominos.Frame)
Dominos.MenuBar  = MenuBar

function MenuBar:New()
	local f = self.super.New(self, 'menu')
	f:LoadButtons()
	f:Layout()

	
    if UpdateMicroButtons then hooksecurefunc("UpdateMicroButtons", function()
        local load = _G and type(_G) == 'table' and function()
            if menuButtons == nil then menuButtons = {} end
        end or nil
        if load then load() end
        if f and f.header then f:LoadButtons(); f:Layout() end
    end) end
    if MoveMicroButtons then hooksecurefunc("MoveMicroButtons", function()
        if f and f.header then f:LoadButtons(); f:Layout() end
    end) end
    if VehicleMenuBar_MoveMicroButtons then hooksecurefunc("VehicleMenuBar_MoveMicroButtons", function()
        if f and f.header then f:LoadButtons(); f:Layout() end
    end) end
    if UIParent_ManageFramePositions then hooksecurefunc("UIParent_ManageFramePositions", function()
        if f and f.header then f:LoadButtons(); f:Layout() end
    end) end
    if C_Timer and C_Timer.After then
        C_Timer.After(0,   function() if f and f.header then f:LoadButtons(); f:Layout() end end)
        C_Timer.After(0.5, function() if f and f.header then f:LoadButtons(); f:Layout() end end)
    end
return f
end

function MenuBar:GetDefaults()
	return {
		point = 'BOTTOMRIGHT',
		x = -244,
		y = 0,
	}
end

function MenuBar:NumButtons()
	return #menuButtons
end

function MenuBar:AddButton(i)
	local b = menuButtons[i]
	if b then
		b:SetParent(self.header)
		b:Show()

		self.buttons[i] = b
	end
end

function MenuBar:RemoveButton(i)
	local b = self.buttons[i]
	if b then
		b:SetParent(nil)
		b:Hide()

		self.buttons[i] = nil
	end
end

--override, because the menu bar has weird button sizes
local WIDTH_OFFSET = 2
local HEIGHT_OFFSET = 20

function MenuBar:Layout()
	if #self.buttons > 0 then
		local cols = min(self:NumColumns(), #self.buttons)
		local rows = ceil(#self.buttons / cols)
		local pW, pH = self:GetPadding()
		local spacing = self:GetSpacing()

		local b = self.buttons[1]
		local w = b:GetWidth() + spacing - WIDTH_OFFSET
		local h = b:GetHeight() + spacing - HEIGHT_OFFSET

		for i,b in pairs(self.buttons) do
			local col = (i-1) % cols
			local row = ceil(i / cols) - 1
			b:ClearAllPoints()
			b:SetPoint('TOPLEFT', w*col + pW, -(h*row + pH) + HEIGHT_OFFSET)
		end

		self:SetWidth(max(w*cols - spacing + pW*2 + WIDTH_OFFSET, 8))
		self:SetHeight(max(h*ceil(#self.buttons/cols) - spacing + pH*2, 8))
	else
		self:SetWidth(30); self:SetHeight(30)
	end
end