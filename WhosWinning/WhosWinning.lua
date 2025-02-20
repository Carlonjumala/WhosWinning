-- Initialize kill counters
local playerKills = 0
local zoneKills = {} -- Table to store kills per zone
local resetTime = 24 * 60 * 60 -- 24 hours in seconds (for stats reset)
local oldZoneKills = oldZoneKills or {} -- For storing old data

-- Frame for event handling
local frame = CreateFrame("Frame")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_LOGOUT")

-- Function to update the kill counters and save data
function UpdateWhosWinningUI()
    -- Update the total kills and zone kills in the UI
    if WhosWinning_UpdateUI then
        WhosWinning_UpdateUI(playerKills, zoneKills)
    end
end

-- Load saved data on login or zone change
local function LoadSavedData()
    local currentZone = GetZoneText()
    if WhosWinningData and WhosWinningData[currentZone] then
        zoneKills = WhosWinningData
    else
        zoneKills[currentZone] = 0
    end
    UpdateWhosWinningUI()
end

-- Save current data into old data at reset
local function ResetData()
    -- Save old data before resetting
    oldZoneKills = {}
    for zone, kills in pairs(zoneKills) do
        oldZoneKills[zone] = kills
    end

    -- Clear the current data
    zoneKills = {}
    playerKills = 0

    -- Notify the player and refresh the UI
    print("|cff00ff00Who's Winning:|r Data reset and old data archived.")
    UpdateWhosWinningUI()
    UpdateOldDataUI(oldZoneKills)
end

-- Save data on logout
frame:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGOUT" then
        local currentZone = GetZoneText()
        WhosWinningData = WhosWinningData or {}
        WhosWinningData[currentZone] = zoneKills[currentZone] or 0
    elseif event == "PLAYER_ENTERING_WORLD" then
        LoadSavedData()
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        -- Handle combat events
        local _, subEvent, _, sourceGUID, _, _, _, destGUID, destName, destFlags = CombatLogGetCurrentEventInfo()
        if subEvent == "PARTY_KILL" and sourceGUID == UnitGUID("player") then
            -- Check if the killed entity is a player
            if bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 then
                -- Player killed another player
                playerKills = playerKills + 1

                -- Track kills in the current zone
                local currentZone = GetZoneText() or "Unknown Zone"
                zoneKills[currentZone] = (zoneKills[currentZone] or 0) + 1

                -- Update the UI
                UpdateWhosWinningUI()

                -- Debug messages
                print("[DEBUG] You killed: " .. (destName or "Unknown"))
                print("[DEBUG] Total Kills: " .. playerKills)
                print("[DEBUG] Kills in " .. currentZone .. ": " .. zoneKills[currentZone])
            end
        end
    end
end)

-- Slash command to reset data manually
SLASH_WWRESET1 = "/wwreset"
SlashCmdList["WWRESET"] = function()
    ResetData()
end

-- Login message
local loginFrame = CreateFrame("Frame")
loginFrame:RegisterEvent("PLAYER_LOGIN")

loginFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        local addonName = "|cff00ff00Who's Winning|r"
        local currentTime = date("%H:%M:%S") -- Current time in HH:MM:SS format
        local resetIn = resetTime - (time() % resetTime) -- Time until stats reset
        local hoursLeft = math.floor(resetIn / 3600)
        local minutesLeft = math.floor((resetIn % 3600) / 60)
        local secondsLeft = resetIn % 60

        print(addonName .. ": Loading...") -- Loading message
        print("Current Time: " .. currentTime)
        print(string.format("Time until stats reset: %02d:%02d:%02d", hoursLeft, minutesLeft, secondsLeft))
        print("Use /wwshow to open the UI.")
    end
end)
