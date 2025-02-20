-- Create the main frame for the UI
local mainFrame = CreateFrame("Frame", "WhosWinningMainFrame", UIParent, "BasicFrameTemplateWithInset")
mainFrame:SetSize(650, 400)
mainFrame:SetPoint("CENTER") -- Centered initially
mainFrame:Hide() -- Initially hidden

-- Title
mainFrame.title = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
mainFrame.title:SetPoint("TOP", mainFrame, "TOP", 0, -5)
mainFrame.title:SetText("Who's Winning: Kill Tracker")

-- Tab buttons
local currentTabButton = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
currentTabButton:SetSize(100, 25)
currentTabButton:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 10, -40)
currentTabButton:SetText("Current Data")

local oldTabButton = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
oldTabButton:SetSize(100, 25)
oldTabButton:SetPoint("LEFT", currentTabButton, "RIGHT", 10, 0)
oldTabButton:SetText("Old Data")

-- Scrollable frame for current data
local scrollFrame = CreateFrame("ScrollFrame", nil, mainFrame, "UIPanelScrollFrameTemplate")
scrollFrame:SetSize(500, 300)
scrollFrame:SetPoint("TOP", currentTabButton, "BOTTOM", 0, -10)

local contentFrame = CreateFrame("Frame", nil, scrollFrame)
contentFrame:SetSize(500, 400)
scrollFrame:SetScrollChild(contentFrame)

-- Function to update the main UI
WhosWinning_UpdateUI = function(playerKills, zoneKills)
    for _, child in ipairs({contentFrame:GetChildren()}) do
        child:Hide()
        child:SetParent(nil) -- Detach child elements
    end

    local offset = 0
    for zone, kills in pairs(zoneKills) do
        local line = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        line:SetPoint("TOPLEFT", 200, -offset)
        line:SetText(string.format("Zone: %s | Kills: %d", zone, kills))
        offset = offset + 20
        line:Show()
    end

    contentFrame:SetHeight(math.max(offset, 300))
    scrollFrame:UpdateScrollChildRect()
end

-- Old Data Frame
local oldDataFrame = CreateFrame("Frame", "WhosWinningOldDataFrame", UIParent, "BasicFrameTemplateWithInset")
oldDataFrame:SetSize(650, 400)
oldDataFrame:SetPoint("CENTER")
oldDataFrame:Hide()

-- Old Data Update Function
function UpdateOldDataUI(data)
    for _, child in ipairs({oldContentFrame:GetChildren()}) do
        child:Hide()
    end

    local offset = 0
    for zone, kills in pairs(data) do
        local line = oldContentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        line:SetPoint("TOPLEFT", 10, -offset)
        line:SetText(string.format("Zone: %s | Kills: %d", zone, kills))
        offset = offset + 20
    end

    oldContentFrame:SetHeight(math.max(offset, 300))
    oldScrollFrame:UpdateScrollChildRect()
end

-- Reset Button
local resetButton = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
resetButton:SetSize(100, 25)
resetButton:SetPoint("LEFT", oldTabButton, "RIGHT", 10, 0)
resetButton:SetText("Reset Data")

resetButton:SetScript("OnClick", function()
    StaticPopupDialogs["RESET_KILL_DATA_CONFIRM"] = {
        text = "Are you sure you want to reset all kill data?",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            ResetData()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    StaticPopup_Show("RESET_KILL_DATA_CONFIRM")
end)


-- Slash command to show the main UI
SLASH_WWSHOW1 = "/wwshow"
SlashCmdList["WWSHOW"] = function()
    mainFrame:Show()
    oldDataFrame:Hide()
    WhosWinning_UpdateUI(playerKills, zoneKills)
    currentTabButton:LockHighlight()
    oldTabButton:UnlockHighlight()
end