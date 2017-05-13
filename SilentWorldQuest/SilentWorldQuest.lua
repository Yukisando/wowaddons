SilentWorldQuestMute = true
SilentWorldQuestSaidHello = false
local holdFunc = nil
local funcHeld = false

-- Event frame on login.
local SilentWorldQuestFirstLogin = CreateFrame("Frame", "SilentWorldQuestLogin")	
SilentWorldQuestFirstLogin:RegisterEvent("PLAYER_LOGIN")
SilentWorldQuestFirstLogin:SetScript("OnEvent",
	function(self, event, ...)
		if SilentWorldQuestSaidHello == false then
			SilentWorldQuestMessage("Silent World Quest loaded. Type /swq t to toggle.")
			SilentWorldQuestSaidHello = true
		end
		SilentWorldQuestFirstLogin:UnregisterEvent("PLAYER_LOGIN")
	end)


-- Clears the popup text frame --
-- If we try to close it before the UI has created it the client will crash.
local SilentWorldQuestTextHide = CreateFrame("Frame", "SilentWorldQuestText")
function SilentWorldQuestTextHide:onUpdate(sinceLastCheck)
	self.sinceLastCheck = (self.sinceLastCheck or 0) + sinceLastCheck;
	if ( self.sinceLastCheck >= 0 ) then
		local shown = TalkingHeadFrame:IsVisible()
		if shown == true then
			-- Done this way to allow toggling without requiring a UI reload.
			-- Disable this frames onUpdate script 
			SilentWorldQuestTextHide:SetScript("OnUpdate",nil);
			-- Save the center text frames onEvent function 
			holdFunc = TalkingHeadFrame:GetScript("onEvent");
			funcHeld = true
			-- Set the center texts frames new onEvent to nothing 
			TalkingHeadFrame:SetScript("OnEvent", function(self, event, ...) end)
			-- Close the current frame 
			TalkingHeadFrame.MainFrame.CloseButton:Click();
			-- Unregister AddOn Events 
			SilentWorldQuestSound:UnregisterAllEvents();
		end
	self.sinceLastCheck = 0;	
	end
end

local SilentWorldQuestSoundMute = CreateFrame("Frame", "SilentWorldQuestSound")	
SilentWorldQuestSoundMute:RegisterEvent("TALKINGHEAD_REQUESTED")
SilentWorldQuestSoundMute:SetScript("OnEvent",
function(self, event, ...)
	if SilentWorldQuestMute == true then
		-- Mute the Sound
		-- Play a dummy sound to get the clients current soundHandle count.
		local willPlay, soundHandle = PlaySoundKitID(2304, "Master", false);
		-- Nil error fix.
		if soundHandle then
			-- Mute the dummy sound
			StopSound(soundHandle, 1);
			-- Mute the previous sound (hopefully the initial voice acting) 
			soundHandle = soundHandle -1;
			StopSound(soundHandle, 1);
		end
		-- Close the text frame.
		SilentWorldQuestTextHide:SetScript("OnUpdate",SilentWorldQuestTextHide.onUpdate);
	end
end)

-- Message function
function SilentWorldQuestMessage(text, prefix)
	local tag = "SilentWorldQuest"
	local frame = DEFAULT_CHAT_FRAME
	if prefix ~= false then
		frame:AddMessage(("|cffffd480<|r|cffaaff80%s|r|cffffd480>|r %s"):format(tostring(tag), tostring(text)), 1, 0.46, 0.2)
	else
		frame:AddMessage(text, 1, 0.46, 0.2);
	end
end

-- SLASH COMMANDS REGISTER --
local SilentWorldQuestSlashCmds = {}
SilentWorldQuestSlashCmds = { ["t"]=true}

SLASH_K_SWQ_MAIN1 = "/swq"
function SlashCmdList.K_SWQ_MAIN(cmd)
	local s1, s2, s3 = strsplit(" ", cmd, 3)
		if s1 then
			s1 = string.lower(s1)
		end
		if s2 then
			s2 = string.lower(s2)
		end
		if s3 then
			s3 = string.lower(s3)
		end
		if not SilentWorldQuestSlashCmds[s1] == true then
			SilentWorldQuestMessage("Commands:")
			SilentWorldQuestMessage("/swq t : Toggles the talking head sounds and popups.")
		elseif s1 == "t" then
			if SilentWorldQuestMute == true then
				-- To disable --
				-- If we have the function saved (and thus have already created the frame).
				if funcHeld == true then
					TalkingHeadFrame:SetScript("OnEvent", holdFunc);
				end
				SilentWorldQuestMute = false
				SilentWorldQuestMessage("Talking head sounds and popups enabled.")
			else
				-- To enable --
				SilentWorldQuestMute = true
				-- Register AddOn Event.
				SilentWorldQuestSoundMute:RegisterEvent("TALKINGHEAD_REQUESTED")
				if funcHeld == true then
					-- If we already have the frames onEvent function saved 
					TalkingHeadFrame:SetScript("OnEvent", function(self, event, ...) end);
					-- Unregister AddOn event as it's not required if the above is true 
					SilentWorldQuestSound:UnregisterAllEvents();	
				end
				SilentWorldQuestMessage("Talking head sounds and popups disabled.")
			end
		end
end