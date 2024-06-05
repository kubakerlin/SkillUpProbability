local SkillUpProbability, core = ...

-- Initiate basic slash commands and add-on elements
function core:init(event)
	-- Allows usage of arrow keys in edit box without rotating character
	for i = 1, NUM_CHAT_WINDOWS do
		_G["ChatFrame"..i.."EditBox"]:SetAltArrowKeyMode(false)
	end

	---------------------------------
	-- BLIZZARD ADDON DEPENDENCIES --
	---------------------------------
	
	LoadAddOn('Blizzard_TradeSkillUI')
	LoadAddOn('Blizzard_CraftUI')
	LoadAddOn('Blizzard_DebugTools')
	
	--------------------
	-- SLASH COMMANDS --
	--------------------
	
	-- Reload shortcut
	SLASH_RELOAD1 = "/rl" 
	SlashCmdList["RELOAD"] = ReloadUI

	-- Frame stack shortcut
	SLASH_FRAMESTK1 = "/fs"
	SlashCmdList["FRAMESTK"] = function()
		FrameStackTooltip_Toggle()
	end

	-- Clear chat
	SLASH_CLEARCHAT1 = "/clear"
	SlashCmdList["CLEARCHAT"] = function()
		SELECTED_CHAT_FRAME:Clear()
	end

	-- Get build version (For UI number)	
	SLASH_BUILDINFO1 = "/buildinfo"
	SlashCmdList["BUILDINFO"] = function()
		core:Print((select(4, GetBuildInfo())))
	end

	-----------
	-- HOOKS --
	-----------

	-- Hook onto TradeSkillFrame_Update and append percentages to the end of spells
	hooksecurefunc('TradeSkillFrame_Update', function()
		if TradeSkillFrame:IsShown() then
			local profName = core:GetProfessionName()
			local tradeLevel = core:GetProfessionLevel()
			local maxLevel = select(3, GetTradeSkillLine())
			if maxLevel ~= tradeLevel then
				for i=1, TRADE_SKILLS_DISPLAYED do
					core:UpdateTradeSkill(i, profName)
				end
			end
		end
	end)

	--[[ Account for Enchanting and Poisons, because they use the Craft API and not the TradeSkill API. May or may not become
	-- deprecated in WOTLK Classic ]]--
	if _G.CraftFrame_Update then
		hooksecurefunc('CraftFrame_Update', function()
			if CraftFrame:IsShown() then
				local profName, craftLevel, maxLevel = GetCraftDisplaySkillLine()
				if maxLevel ~= craftLevel then
					for i=1, CRAFTS_DISPLAYED do
						core:UpdateCraftSkill(i, profName)
					end
				end
			end
		end)
	end

	--[[ Questie in WOTLK has a function in its file QuestieProfessions.lua called "Update" which is called on the event
	-- SKILL_LINES_CHANGED. This overwrites the changes made by this addon's hook on TradeSkillFrame_Update and creates an unpleasant
	-- bug that makes the percentages flicker on and off. ]]--
	numAddons = GetNumAddOns()
	questieName = ""
	questieInstalled = false
	for i = 1, numAddons
	do
		name, title, _, enabled, _, _, _ = GetAddOnInfo(i)
		if string.match(title, "Questie") or string.match(title, "questie") then
			questieName = name
			questieInstalled = true
			break
		end
	end

	if questieInstalled == true then 
		ret, res = LoadAddOn(questieName)
		if not ret then
			-- Do nothing
		else
			print(WrapTextInColorCode("SkillUpProbability: ", "FFFF0000").." If you are using "..WrapTextInColorCode("Questie", "FF00FF00").." there is currently a bug caused by conflicting code with that addOn that causes the percentage text to 'flicker' when you level up. Unfortunately a fix for this hasn't been found yet, although it's but a minor inconvenience.")
		end
	end

	--local githubLink = "https://github.com/Zsargul/SkillUpProbability"
	--core:Print("Please report any bugs to: "..githubLink)
end
