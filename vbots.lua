-- Create Date : 2020/5/12 10:00:00 by coolzoom https://github.com/coolzoom/vmangos-pbotaddon/tree/master
-- Remaster Date : 2026/3/29 15:31:24 by IamTirion https://github.com/IamTirion/VBots-v2-playerbotaddon
-- Constants moved to top and grouped logically
local ADDON_NAME = "VBots"


VBotsDB = VBotsDB or {
    minimapButtonPosition = 268 
}

local isLookingForTemplates = false

local templateScanTimer = 0
local TEMPLATE_SCAN_TIMEOUT = 5


CMD_PARTYBOT_CLONE = ".partybot clone"
CMD_PARTYBOT_REMOVE = ".partybot remove"
CMD_PARTYBOT_ADD = ".partybot add "
CMD_PARTYBOT_SETROLE = ".partybot setrole "
CMD_PARTYBOT_GETROLE = ".partybot getrole"
CMD_PARTYBOT_GEAR = ".character premade gear "
CMD_PARTYBOT_SPEC = ".character premade spec "


CMD_BATTLEGROUND_GO = ".go "
CMD_BATTLEBOT_ADD = ".battlebot add "


local BG_INFO = {
    warsong = {
        size = 10,
        minLevel = 10,
        maxLevel = 60
    },
    arathi = {
        size = 15,
        minLevel = 20,
        maxLevel = 60
    },
    alterac = {
        size = 40,
        minLevel = 51,
        maxLevel = 60
    }
}


local useTempBots = false

-- Command queue system
local CommandQueue = {
    commands = {},
    timer = 0,
    processing = false
}


local MinimapButton = {
    shown = false,
    position = VBotsDB.minimapButtonPosition or 268,
    radius = 78,
    cos = math.cos,
    sin = math.sin,
    deg = math.deg,
    atan2 = math.atan2
}


local playerFaction = nil  
local manualFactionOverride = nil 


function GetPlayerFaction()
    
    if manualFactionOverride then
        return manualFactionOverride
    end
    
    
    local _, race = UnitRace("player")
    if race then
        if race == "Human" or race == "Dwarf" or race == "NightElf" or race == "Gnome" then
            return "alliance"
        elseif race == "Orc" or race == "Troll" or race == "Tauren" or race == "Undead" or race == "Scourge" then
            return "horde"
        end
    end
    
   
    if not playerFaction then
        local faction = UnitFactionGroup("player")
        if faction then
            playerFaction = string.lower(faction)
        else
            
            DEFAULT_CHAT_FRAME:AddMessage("Faction detection failed. Using Alliance as default. Use /vbots faction alliance|horde to set manually.")
            playerFaction = "alliance"
        end
    end
    
    return playerFaction
end


function SetPlayerFaction(faction)
    if faction == "alliance" or faction == "horde" then
        manualFactionOverride = faction
        DEFAULT_CHAT_FRAME:AddMessage("Faction manually set to: " .. faction)
        
        InitializeFactionClassButton()
    else
        DEFAULT_CHAT_FRAME:AddMessage("Invalid faction. Use 'alliance' or 'horde'.")
    end
end

SLASH_VBOTS1 = "/vbots"
SlashCmdList["VBOTS"] = function(msg)    
    vbotsFrame:Show()
    MinimapButton.shown = true
    DEFAULT_CHAT_FRAME:AddMessage("VBots window opened")
end

function MinimapButton:UpdatePosition()
    local radian = self.position * (math.pi/180)
    vbotsButtonFrame:SetPoint(
        "TOPLEFT",
        "Minimap",
        "TOPLEFT",
        54 - (self.radius * self.cos(radian)),
        (self.radius * self.sin(radian)) - 55
    )
    self:Init()
end

function MinimapButton:CalculatePosition(xpos, ypos)
    local xmin, ymin = Minimap:GetLeft(), Minimap:GetBottom()
    xpos = xmin - xpos/UIParent:GetScale() + 70
    ypos = ypos/UIParent:GetScale() - ymin - 70
    
    local angle = self.deg(self.atan2(ypos, xpos))
    if angle < 0 then
        angle = angle + 360
    end
    
    self.position = angle
    VBotsDB.minimapButtonPosition = angle 
    self:UpdatePosition()
end

function MinimapButton:Init()
    
    self.position = VBotsDB.minimapButtonPosition or self.position
    
    if self.shown then
        vbotsFrame:Show()
    else
        vbotsFrame:Hide()
    end
end

function MinimapButton:Toggle()
    self.shown = not self.shown
    self:Init()
end


function SubPartyBotClone(self)
    SendChatMessage(CMD_PARTYBOT_CLONE)
end

function SubPartyBotRemove(self)
    SendChatMessage(CMD_PARTYBOT_REMOVE)
end

function SubPartyBotSetRole(self, arg)
    SendChatMessage(CMD_PARTYBOT_SETROLE .. arg)
end

function SubPartyBotGetRole()
    SendChatMessage(CMD_PARTYBOT_GETROLE)
end

function SubPartyBotAdd(self, arg)
    SendChatMessage(CMD_PARTYBOT_ADD .. arg)
    DEFAULT_CHAT_FRAME:AddMessage("bot added. please search available gear and spec set.")
end

-- BattleGround function
function SubBattleGo(self, arg)
    SendChatMessage(CMD_BATTLEGROUND_GO .. arg)
end


function SubSendGuildMessage(self, arg)
    SendChatMessage(arg, "GUILD", GetDefaultLanguage("player"));
end

function CloseFrame()
    vbotsFrame:Hide()
    MinimapButton.shown = false
end

local VBOTS_NUM_TABS = 4


function vbotsFrame_ShowTab(tabID)
    
    for i=1, VBOTS_NUM_TABS do
        local content = getglobal(vbotsFrame:GetName().."Tab"..i.."Content")
        if content then
            content:Hide()
        end
    end
    
   
    local selectedContent = getglobal(vbotsFrame:GetName().."Tab"..tabID.."Content")
    if selectedContent then
        selectedContent:Show()
    end
end


function OpenFrame()
    DEFAULT_CHAT_FRAME:AddMessage("Loading " .. ADDON_NAME)
    vbotsFrame:Show()
    MinimapButton.shown = true
end


function vbotsFrame_OnLoad()
    
    this.numTabs = VBOTS_NUM_TABS
    
   
    this.selectedTab = 1
    PanelTemplates_SetNumTabs(this, VBOTS_NUM_TABS)
    PanelTemplates_SetTab(this, 1)
    
   
    vbotsFrame_ShowTab(1)
    
    
    this:RegisterEvent("VARIABLES_LOADED")
    DEFAULT_CHAT_FRAME:RegisterEvent('CHAT_MSG_SYSTEM')
end


function vbotsButtonFrame_OnClick()
    vbotsButtonFrame_Toggle()
end

function vbotsButtonFrame_Init()
    MinimapButton:Init()
end

function vbotsButtonFrame_Toggle()
    MinimapButton:Toggle()
end

function vbotsButtonFrame_UpdatePosition()
    MinimapButton:UpdatePosition()
end

function vbotsButtonFrame_BeingDragged()
    local x, y = GetCursorPosition()
    MinimapButton:CalculatePosition(x, y)
end

function vbotsButtonFrame_OnEnter()
    GameTooltip:SetOwner(this, "ANCHOR_LEFT")
    GameTooltip:SetText("vmangos bot command, \n click to open/close, \n right mouse to drag me")
    GameTooltip:Show()
end


local gearTemplates = {}
local specTemplates = {}
selectedGearTemplateId = nil
selectedSpecTemplateId = nil
local currentTemplateType = nil  -- "gear" or "spec" during scan


function InitializeFactionClassButton()
    local button = getglobal("PartyBotAddFactionClass")
    if button then
        local faction = GetPlayerFaction()
        if faction == "alliance" then
            button:SetText("Add Paladin")
        else
            button:SetText("Add Shaman")
        end
        DEFAULT_CHAT_FRAME:AddMessage("Faction detected as: " .. faction)
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("CHAT_MSG_SYSTEM")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_LOGIN")

f:SetScript("OnEvent", function()
    local event = event
    local message = arg1

    if event == "CHAT_MSG_SYSTEM" and message then    
        if isLookingForTemplates then
            if string.find(message, "^%d+%s*-%s*") then
                local _, _, id, name = string.find(message, "^(%d+)%s*-%s*([^%(]+)")
                if id and name then
                    if currentTemplateType == "gear" then
                        gearTemplates[id] = name
                        -- Refresh gear dropdown
                        local dropdown = getglobal("vbotsGearDropDown")
                        if dropdown then
                            UIDropDownMenu_Initialize(dropdown, GearDropDown_Initialize)
                        end
                    elseif currentTemplateType == "spec" then
                        specTemplates[id] = name
                        -- Refresh spec dropdown
                        local dropdown = getglobal("vbotsSpecDropDown")
                        if dropdown then
                            UIDropDownMenu_Initialize(dropdown, SpecDropDown_Initialize)
                        end
                    end
                end
            end
            -- Optional: detect end of listing if server sends a message
        end
    end

    if event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_LOGIN" then
      
        local faction = GetPlayerFaction()
        DEFAULT_CHAT_FRAME:AddMessage("VBots: Detected faction as " .. faction)
        InitializeFactionClassButton()
    end
end)


function GearDropDown_Initialize()
    local info = {}
    info.text = "Gear Templates"
    info.notClickable = 1
    info.isTitle = 1
    UIDropDownMenu_AddButton(info)
    
    for id, name in pairs(gearTemplates) do
        info = {}
        info.text = id .. " - " .. name
        info.func = GearDropDown_OnClick
        info.value = id
        UIDropDownMenu_AddButton(info)
    end
end

function SpecDropDown_Initialize()
    local info = {}
    info.text = "Spec Templates"
    info.notClickable = 1
    info.isTitle = 1
    UIDropDownMenu_AddButton(info)
    
    for id, name in pairs(specTemplates) do
        info = {}
        info.text = id .. " - " .. name
        info.func = SpecDropDown_OnClick
        info.value = id
        UIDropDownMenu_AddButton(info)
    end
end


function GearDropDown_OnClick()
    local id = this.value
    local name = gearTemplates[id]
    if id and name then
        selectedGearTemplateId = id
        -- Update dropdown display text
        local dropdown = getglobal("vbotsGearDropDown")
        if dropdown then
            local textField = getglobal(dropdown:GetName() .. "Text")
            if textField then
                textField:SetText(id .. " - " .. name)
            end
        end
        DEFAULT_CHAT_FRAME:AddMessage("Gear template selected: " .. id .. " - " .. name .. " (click Apply Gear to equip)")
    end
end

function SpecDropDown_OnClick()
    local id = this.value
    local name = specTemplates[id]
    if id and name then
        selectedSpecTemplateId = id
        -- Update dropdown display text
        local dropdown = getglobal("vbotsSpecDropDown")
        if dropdown then
            local textField = getglobal(dropdown:GetName() .. "Text")
            if textField then
                textField:SetText(id .. " - " .. name)
            end
        end
        DEFAULT_CHAT_FRAME:AddMessage("Spec template selected: " .. id .. " - " .. name .. " (click Apply Spec to learn talents)")
    end
end


local function QueueCommand(command)
    table.insert(CommandQueue.commands, command)
    if not CommandQueue.processing then
        CommandQueue.processing = true
        CommandQueue.timer = 0
        CommandQueue.frame:Show()
    end
end


CommandQueue.frame = CreateFrame("Frame")
CommandQueue.frame:Hide()
CommandQueue.frame:SetScript("OnUpdate", function()
    if table.getn(CommandQueue.commands) == 0 then
        CommandQueue.processing = false
        CommandQueue.frame:Hide()
        return
    end

    CommandQueue.timer = CommandQueue.timer + arg1
    if CommandQueue.timer >= 0.5 then 
        local command = table.remove(CommandQueue.commands, 1)
        SendChatMessage(command)
        CommandQueue.timer = 0
        
        if table.getn(CommandQueue.commands) == 0 then
            DEFAULT_CHAT_FRAME:AddMessage("All bots have been added!")
        end
    end
end)

-- Function to fill a battleground -- THANK YOU DIGITAL SCRIPTORIUM FOR THE IDEA - https://www.youtube.com/@Digital-Scriptorium
function SubBattleFill(self, bgType)
    local playerFaction = GetPlayerFaction() 
    local playerLevel = UnitLevel("player")
    local bgData = BG_INFO[bgType]
    
    if not bgData then
        DEFAULT_CHAT_FRAME:AddMessage("Invalid battleground type: " .. bgType)
        return
    end
    
   
    if playerLevel < bgData.minLevel then
        DEFAULT_CHAT_FRAME:AddMessage("You must be at least level " .. bgData.minLevel .. " to queue for " .. bgType)
        return
    end
    
   
    CommandQueue.commands = {}
    CommandQueue.timer = 0
    
    DEFAULT_CHAT_FRAME:AddMessage("Using faction: " .. playerFaction .. " for BG fill")
    
   
    local allianceCount = bgData.size
    if playerFaction == "alliance" then
        allianceCount = bgData.size - 1 
    end
    for i = 1, allianceCount do
        local command = CMD_BATTLEBOT_ADD .. bgType .. " alliance " .. playerLevel
        if useTempBots then
            command = command .. " temp"
        end
        QueueCommand(command)
    end
    
    -- Add Horde bots
    local hordeCount = bgData.size
    if playerFaction == "horde" then
        hordeCount = bgData.size - 1 
    end
    for i = 1, hordeCount do
        local command = CMD_BATTLEBOT_ADD .. bgType .. " horde " .. playerLevel
        if useTempBots then
            command = command .. " temp"
        end
        QueueCommand(command)
    end
    
  
    QueueCommand(CMD_BATTLEGROUND_GO .. bgType)
    
   
    local totalBots = allianceCount + hordeCount
    local botType = useTempBots and "temporary" or "permanent"
    DEFAULT_CHAT_FRAME:AddMessage("Queueing " .. totalBots .. " level " .. playerLevel .. " " .. botType .. " bots for " .. bgType .. " (leaving space for you in " .. playerFaction .. " team)")
end 

function ToggleTempBots()
    useTempBots = not useTempBots
    local status = useTempBots and "enabled" or "disabled"
    DEFAULT_CHAT_FRAME:AddMessage("Temporary bots " .. status)
    
   
    local checkbox = getglobal("TempBotsCheckbox")
    if checkbox then
        checkbox:SetChecked(useTempBots)
    end
end 


local templateScanFrame = CreateFrame("Frame")
templateScanFrame:Hide()
templateScanFrame:SetScript("OnUpdate", function()
    if not isLookingForTemplates then
        templateScanFrame:Hide()
        return
    end
    
    templateScanTimer = templateScanTimer + arg1
    if templateScanTimer >= TEMPLATE_SCAN_TIMEOUT then
        isLookingForTemplates = false
        templateScanTimer = 0
        templateScanFrame:Hide()
        DEFAULT_CHAT_FRAME:AddMessage("Template scanning completed.")
    end
end)


function StartTemplateScan()
    isLookingForTemplates = true
    templateScanTimer = 0
    templateScanFrame:Show()
    DEFAULT_CHAT_FRAME:AddMessage("Looking for templates...")
end


function GearTemplateButtonClick()
    currentTemplateType = "gear"
    gearTemplates = {}
    StartTemplateScan()
    SendChatMessage(CMD_PARTYBOT_GEAR)
end

function SpecTemplateButtonClick()
    currentTemplateType = "spec"
    specTemplates = {}
    StartTemplateScan()
    SendChatMessage(CMD_PARTYBOT_SPEC)
end

--- Gear delete popup
VBots_GearToDelete = nil

StaticPopupDialogs["CONFIRM_DELETE_GEAR_TEMPLATE"] = {
    text = "Are you sure you want to delete gear template \"%s\"?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        if VBots_GearToDelete then
            SendChatMessage(".character premade deletegear " .. VBots_GearToDelete)
            VBots_GearToDelete = nil
            selectedGearTemplateId = nil
            local dropdown = getglobal("vbotsGearDropDown")
            if dropdown then
                local textField = getglobal(dropdown:GetName() .. "Text")
                if textField then
                    textField:SetText("Select Gear Template")
                end
            end
            GearTemplateButtonClick()
        end
    end,
    OnCancel = function()
        VBots_GearToDelete = nil
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

function DeleteGearTemplate()
    if not selectedGearTemplateId then
        DEFAULT_CHAT_FRAME:AddMessage("No gear template selected. Please select one from the Gear dropdown.")
        return
    end
    local name = gearTemplates[selectedGearTemplateId]
    if not name then
        DEFAULT_CHAT_FRAME:AddMessage("Error: Could not find template name.")
        return
    end
    VBots_GearToDelete = name
    StaticPopup_Show("CONFIRM_DELETE_GEAR_TEMPLATE", name)
end

-- Preset storage (global saved variable)
VBotsDB.botPresets = VBotsDB.botPresets or {}
local selectedPresetName = nil

-- Helper: get text from the popup edit box and split into lines
function GetBotNamesFromEditBox()
    local editBox = getglobal("BotNamesEdit")
    if not editBox then return {} end
    local text = editBox:GetText()
    if type(text) ~= "string" then return {} end

    local names = {}
    local from = 1
    local len = string.len(text)

    while from <= len do
        -- Find next newline (Unix \n or Windows \r\n)
        local s, e = string.find(text, "[\r\n]", from)
        if not s then
            -- Last line
            local line = string.sub(text, from)
            local trimmed = string.gsub(line, "^%s*(.-)%s*$", "%1")
            if trimmed ~= "" then
                table.insert(names, trimmed)
            end
            break
        end
        -- Extract line between 'from' and the newline
        local line = string.sub(text, from, s - 1)
        local trimmed = string.gsub(line, "^%s*(.-)%s*$", "%1")
        if trimmed ~= "" then
            table.insert(names, trimmed)
        end
        from = e + 1
    end
    return names
end

-- Load the current edit box content as bot commands
function LoadBotNamesFromEditBox()
    local names = GetBotNamesFromEditBox()
    if table.getn(names) == 0 then
        DEFAULT_CHAT_FRAME:AddMessage("No bot names entered.")
        return
    end
    -- Use command queue to send .partybot load for each name
    CommandQueue.commands = {}
    CommandQueue.timer = 0
    for _, botName in ipairs(names) do
        QueueCommand(".partybot load " .. botName)
    end
    DEFAULT_CHAT_FRAME:AddMessage("Queued " .. table.getn(names) .. " bot(s) for loading.")
end

-- Save current edit box content as a preset
function SaveCurrentListAsPreset()
    local presetNameEdit = getglobal("PresetNameEdit")
    if not presetNameEdit then return end
    local presetName = presetNameEdit:GetText()
    if not presetName or presetName == "" or presetName == "Preset name" then
        DEFAULT_CHAT_FRAME:AddMessage("Please enter a preset name.")
        return
    end
    local names = GetBotNamesFromEditBox()
    if table.getn(names) == 0 then
        DEFAULT_CHAT_FRAME:AddMessage("No bot names to save.")
        return
    end

    -- Ensure VBotsDB and botPresets exist
    if not VBotsDB then
        VBotsDB = {}
    end
    if not VBotsDB.botPresets then
        VBotsDB.botPresets = {}
    end

    VBotsDB.botPresets[presetName] = names
    DEFAULT_CHAT_FRAME:AddMessage("Preset '" .. presetName .. "' saved with " .. table.getn(names) .. " bot(s).")

    -- Refresh the dropdown
    local dropdown = getglobal("PresetDropDown")
    if dropdown then
        UIDropDownMenu_Initialize(dropdown, PresetDropDown_Initialize)
        UIDropDownMenu_SetText("Select Preset", dropdown)
    end
end

-- Populate the preset dropdown
function PresetDropDown_Initialize()
    local info = {}
    info.text = "Presets"
    info.notClickable = 1
    info.isTitle = 1
    UIDropDownMenu_AddButton(info)

    if not VBotsDB or not VBotsDB.botPresets then
        info = {}
        info.text = "No presets"
        info.disabled = 1
        UIDropDownMenu_AddButton(info)
        return
    end

    for name, _ in pairs(VBotsDB.botPresets) do
        info = {}
        info.text = name
        info.func = SelectPreset   -- function name, not closure
        info.arg1 = name           -- pass preset name as argument
        UIDropDownMenu_AddButton(info)
    end
end

-- Called when a preset is selected from dropdown
function SelectPreset(name)
    if not name then return end
    selectedPresetName = name
    local dropdown = getglobal("PresetDropDown")
    if dropdown then
        UIDropDownMenu_SetText(name, dropdown)
    end
    -- Automatically load the preset's bot names
    LoadSelectedPreset()
end

-- Load the selected preset into the edit box
function LoadSelectedPreset()
    if not VBotsDB or not VBotsDB.botPresets then
        DEFAULT_CHAT_FRAME:AddMessage("No presets saved yet.")
        return
    end
    if not selectedPresetName then
        DEFAULT_CHAT_FRAME:AddMessage("No preset selected. Choose one from the dropdown.")
        return
    end
    local names = VBotsDB.botPresets[selectedPresetName]
    if not names then
        DEFAULT_CHAT_FRAME:AddMessage("Preset not found.")
        return
    end
    local editBox = getglobal("BotNamesEdit")
    if editBox then
        editBox:SetText(table.concat(names, "\n"))
        editBox:SetTextColor(1, 1, 1)
        DEFAULT_CHAT_FRAME:AddMessage("Loaded preset '" .. selectedPresetName .. "' into editor.")
    end
end

function DeleteSelectedPreset()
    if not selectedPresetName then
        DEFAULT_CHAT_FRAME:AddMessage("No preset selected. Choose one from the dropdown first.")
        return
    end
    
    if not VBotsDB or not VBotsDB.botPresets then
        DEFAULT_CHAT_FRAME:AddMessage("No presets to delete.")
        return
    end
    
    if not VBotsDB.botPresets[selectedPresetName] then
        DEFAULT_CHAT_FRAME:AddMessage("Preset '" .. selectedPresetName .. "' not found.")
        return
    end
    
    VBotsDB.botPresets[selectedPresetName] = nil
    DEFAULT_CHAT_FRAME:AddMessage("Preset '" .. selectedPresetName .. "' deleted.")
    
    selectedPresetName = nil
    
    -- Optional: clear the edit box
    local editBox = getglobal("BotNamesEdit")
    if editBox then
        editBox:SetText("")
        editBox:SetTextColor(0.6, 0.6, 0.6)
    end
    
    local dropdown = getglobal("PresetDropDown")
    if dropdown then
        UIDropDownMenu_SetText("Select Preset", dropdown)
        UIDropDownMenu_Initialize(dropdown, PresetDropDown_Initialize)
    end
end

function UseObjectCommand()
    -- Queue the three commands in order
    QueueCommand(".partybot cometome")
    QueueCommand(".gobject select")
    QueueCommand(".partybot usegobject")
    DEFAULT_CHAT_FRAME:AddMessage("Queued: cometome -> select object -> use object")
end