local GOSSIP_EVENT_ON_HELLO = 1;
local GOSSIP_EVENT_ON_SELECT = 2;

-- Local table to store all stories
local stories = {};

-- Function to replace placeholders in the text
local function ReplacePlaceholders(story, player, text, creature)
    local genderStr = function(male, female)
        return player:GetGender() == 0 and male or female;
    end

    -- Replace story variables with exact matches
    text = text:gsub("%$(%w+)", function(variableName)
        local variable = story.variables[variableName]
        if variable then
            return tostring(variable.value) -- Replace placerholder with variable value
        else
            return "$" .. variableName  -- If variable not found, keep the placeholder as is
        end
    end)

    text = text:gsub("%$CN", creature:GetName())
               :gsub("%$N", player:GetName())
               :gsub("%$R", player:GetRaceAsString())
               :gsub("%$C", player:GetClassAsString())
               :gsub("%$G%((.-):(.-)%)", function(male, female) return genderStr(male, female) end)
               :gsub("%$T", player:GetSelection() and player:GetSelection():GetName() or "")
               :gsub("%$L", player:GetLevel())
               :gsub("%$H", player:GetGuildName() or "")
               :gsub("%$I", player:GetGuildRank() or "")
               :gsub("%$Z", GetAreaName(player:GetZoneId()))
               :gsub("%$A", GetAreaName(player:GetAreaId()));

    return text;
end

-- Function to display the story part to the player
local function ShowStory(player, creature, story, storyPartId)
    local part = story[storyPartId];
    if not part then
        player:GossipComplete();
        return;
    end

    -- Replace all placeholders in the story text
    local text = ReplacePlaceholders(story, player, part.text, creature);
    player:GossipSetText(text);

    -- Add all options to the gossip menu
    if part.options then
        for optionId, option in ipairs(part.options) do
            if option.condition == nil or option.condition(story, player, creature)  then
                print(option.icon);
                player:GossipMenuAddItem(option.icon or 0, option.text, storyPartId, optionId);
            end
            
        end
    end

    player:GossipSendMenu(0x7FFFFFFF, creature);
end

local function ResetVariables(story)
    for _, variable in pairs(story.variables) do
            variable.value = variable.startValue;
    end
end

local function ResetTemporaryVariables(story)
    for _, variable in pairs(story.variables) do
        if variable.value == nil or variable.temporary then
            variable.value = variable.startValue;
        end
    end
end

-- Function to handle initial interaction
local function StartStory(event, player, creature)
    local entry = creature:GetEntry();
    local story = stories[entry];
    if story then
        ResetTemporaryVariables(story);
        ShowStory(player, creature, story, 1);
    else
        PrintError(player:GetName().." tried to open non existing story for creature "..entry);
        player:GossipComplete();
    end
end

-- Function to handle option selection
local function ContinueStory(event, player, creature, senderPartId, senderOptionId, code)
    local entry = creature:GetEntry();
    local story = stories[entry];
    if story then
        local storyPart = story[senderPartId];
        if storyPart and storyPart.options and storyPart.options[senderOptionId] then
            local option = storyPart.options[senderOptionId];
            if option.onSelect then
                local cancel = option.onSelect(story, player, creature);
                if cancel == nil or cancel then
                    ShowStory(player, creature, story, option.next);
                else 
                    ShowStory(player, creature, story, senderPartId);
                end
            else
                ShowStory(player, creature, story, option.next);
            end
        else
            PrintError(player:GetName().." picked non existing option "..senderOptionId.." in story part "..senderPartId.. "for creature "..entry);
            player:GossipComplete();
        end
    else
        PrintError(player:GetName().." tried to open non existing story for creature "..entry);
        player:GossipComplete();
    end
end

function SetStoryVariableValue(entry, variableName, variableValue)
    stories[entry].variables[variableName].value = variableValue;
end

function RegisterStory(entry, story)
    stories[entry] = story;
    stories[entry].Reset = function()
        ResetVariables(story);
    end
    stories[entry].ResetTemporary = function()
        ResetTemporaryVariables(story);
    end
    RegisterCreatureGossipEvent(entry, GOSSIP_EVENT_ON_HELLO, StartStory);
    RegisterCreatureGossipEvent(entry, GOSSIP_EVENT_ON_SELECT, ContinueStory);
end

function UnregisterStory(entry)
    stories[entry] = {};
    ClearCreatureGossipEvents(entry);
end