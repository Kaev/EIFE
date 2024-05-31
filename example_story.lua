local story = {
    variables = {
        clickCount = {
            startValue = 0,
            temporary = true -- resets on Gossip Hello
        },
        clickCountWithoutReset = {
            startValue = 0 -- Will stay as long as the story is loaded
        },
        randomChoice = {
            startValue = 0, -- We randomize this in our story
            temporary = true
        },
        setFromScript = {
            startValue = 0 -- Temporary would not make sense here, we set it from outside of the story declaration
        }
    },
    [1] = {
        text = [[Player name: $N
Player Level: $L
Player Race: $R
Player Class: $C
Player Gender based: $G(Male:Female)
Player Target Name: $T
Player Guild name: $H
Player Guild rank: $I
Player Zone: $Z
Player Area: $A
Creature name: $CN
SetFromScript: $setFromScript]],  -- These are all available placeholders except setFromScript, it's an example of a story variable
        options = {
            {
                text = [[Option 1]],
                next = 2,
                icon = 1 -- You can set the icon for each option - See GossipDef.h for all available icons (0-20)
            },
            {
                text = [[Option 2]],
                next = 3,
                icon = 8
            },
            {
                text = [[This will not progress the story]],
                next = 4,
                onSelect = function(story, player, creature)
                    return false; -- returning false in onSelect will stop story progress. We don't need to return true for the opposite case but you can if you want to
                end
            },
            {
                text = [[Go to Clickcounter]],
                next = 5
            },
            {
                text = [[Give NPC Item]],
                next = 4,
                onSelect = function(story, player, creature)
                    if player:HasItem(12345, 1) then -- Always recheck, player can e.g. trade the item while Gossip is open
                        player:RemoveItem(12345, 1);
                    else
                        return false;
                    end
                end,
                condition = function(story, player, creature) -- condition that needs to be met to make this option available
                    return player:HasItem(12345, 1);
                end
            },
            {
                text = [[Get a random choice]],
                next = 6,
                onSelect = function(story, player, creature)
                    story.variables.randomChoice.value = math.random(0, 1); -- Set a story variable value
                end
            },
            {
                text = [[Unregister Story]],
                onSelect = function(story, player, creature)
                    UnregisterStory(creature:GetEntry()); -- This will remove this story from the creature. Either reregister via code or reload Eluna to register it again
                end
            },
        },
    },
    [2] = {
        text = [[You picked option 1.]],
        options = {
            {
                text = [[Jump to option 2 anyway]],
                next = 3
            }
        }
    },
    [3] = {
        text = [[You picked option 2.]],
        options = {
            {
                text = [[Go to id 4]],
                next = 4
            }
        }
    },
    [4] = {
        text = [[You reached the end]],
        options = {
            {
                text = [[Go back to start]],
                next = 1
            }
        }
    },
    [5] = {
        text = [[Clickcount: $clickCount
Clickcount without reset: $clickCountWithoutReset]], -- Example for writing out story variables, basically same as the placeholders
        options = {
            {
                text = [[Increase Clickcount]],
                next = 5,
                onSelect = function(story, player, creature)
                    story.variables.clickCount.value = story.variables.clickCount.value + 1;
                    story.variables.clickCountWithoutReset.value = story.variables.clickCountWithoutReset.value + 1;
                end
            },
            {
                text = [[Clickcounter reached 5!]],
                next = 5,
                onSelect = function(story, player, creature)
                    player:SendUnitSay("Clickcounter reached 5!", 0);
                end,
                condition = function(story, player, creature)
                    return story.variables.clickCount.value >= 5;
                end
            },
            {
                text = [[Reset All Temporary Story Variables]],
                next = 5,
                onSelect = function(story, player, creature)
                    story:ResetTemporary(); -- ResetTemporary will reset all temporary story variables
                end,
                condition = function(story, player, creature)
                    return story.variables.clickCount.value >= 5;
                end
            },
            {
                text = [[Reset All Story Variables]],
                next = 5,
                onSelect = function(story, player, creature)
                    story:Reset(); -- Reset() will reset ALL story variables (temporary and permanent ones)
                end,
                condition = function(story, player, creature)
                    return story.variables.clickCount.value >= 5;
                end
            },
            {
                text = [[Go Back]],
                next = 1
            }
        }
    },
    [6] = {
        text = [[Here's your random choice!]],
        options = {
            {
                text = [[Random Choice 1]],
                next = 1,
                condition  = function(story, player, creature)
                    return story.variables.randomChoice.value == 0; -- We set the random choice via onSelect function of the option that leads to this story path
                end
            },
            {
                text = [[Random Choice 2]],
                next = 1,
                condition  = function(story, player, creature)
                    return story.variables.randomChoice.value == 1; -- We set the random choice via onSelect function of the option that leads to this story path
                end
            }
        }
    }
};

RegisterStory(3431, story); -- Don't forget to give that creature the gossip npcflag (1) in the database or via script
SetStoryVariableValue(3431, "setFromScript", 1234); -- We set a variable value from outside the story declaration