# EIFE
EIFE (Eluna Interactive Fiction Engine) is an interactive fiction engine extension for [Eluna](https://elunaluaengine.github.io/index.html).

It allows you to create interactive stories which will be shown to the player as gossip menus.  
It will also give you the ability to store variables in your story, run code when you select a gossip entry and to script conditions which need to be met before the option will be available to the player.   
The code base is pretty slim so it should be very easy to extend, even if you're not familiar with it.

I built this so I can quickly give places in the world a little more depth and make them feel more alive. :)

## Example
You can find an example story which shows off all current features in the `example_story.lua` file.

## Installation
Just make sure that EIFE.lua is inside your extensions folder (e.g. `lua_scripts/extensions/EIFE/EIFE.lua`) and that your stories are outside of the extensions folder (e.g. `lua_scripts/stories/example_story.lua`).

## Documentation

### Text Placeholders
Player name: $N  
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
Story Variable: $clickCount (if clickCount is the name of your story variable)

### RegisterStory
`RegisterStory(entry, story);`

Registers the story object to the creature with the given entry id.

### UnregisterStory
`UnregisterStory(entry);`

Unregisters the currently registered story from the creature with the given entry id.

### SetStoryVariableValue
`function SetStoryVariableValue(entry, variableName, variableValue);`

Sets the given value to a story variable with the given variable name to the currently registered story from the creature with the given entry id.

## Need help?
You can visit either the [WoW Modding](https://discord.gg/mGfnwf9AJg) or the [Eluna](https://discord.gg/8MD98hGTfz) Discord servers and ask questions.
I'll try my best to answer them asap. :)
