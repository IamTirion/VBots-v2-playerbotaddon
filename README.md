# VBots v2 playerbotaddon

A World of Warcraft 1.12.1 addon for vmangos bot commands with an improved user interface and enhanced functionality.

## Repository Information
- **Name:** VBots v2 playerbotaddon
- **Game Version:** WoW 1.12.1
- **Server:** vmangos
- **Status:** Beta

## Requirements
- GM Level 6 required for all commands
- VMaNGOS server with bot support

## Installation
1. Download the addon
2. Extract to your `World of Warcraft/Interface/AddOns` folder
3. Restart World of Warcraft if it's running

## Changelogs
# v2.2
- Added the "Use Object" button. It summons the bots to you first, before they try to use the object near you. It is buggy, but the commands themselves are buggy. It still works eventually.
- Added the "Load Bots" button, allowing you to save a list of bot names and load them. Requires the bots to have been created, and each bot has to be on its own account
- Changed how the Template panel works. Now you press Refresh Gear or Refresh Spec, then select a template, then click Apply Gear or Apply Spec to apply them
- Added Delete Gear and Delete Spec buttons to delete templates. Requires custom patch
- Added the Esc button to cancel typing in the Template Name box
- Added a Get Role button, to check the current role of a bot
- Added the "Add Paladin" and "Add Shaman" buttons for everyone. You won't be able to use the other faction's button normally. Requires custom patch
- Fixed the Spec Template options, which didn't work at all previously

  Custom patch
  https://github.com/IamTirion/core/tree/all-changes-classes-changes
  The patch contains a huge number of things that are not accepted into the official VMANGOS. 
  They are mainly changes to bots behaviour, more items on the GM Island vendors, and the World Buffs npc being able to buff the whole group.
  But if you just want the custom commands to use with this addon,
  you can pick out the custom commands from this patch and apply it to the official VMANGOS version if you know what you are doing.

## Features

### UI

![VBot 2 2 UI](https://github.com/user-attachments/assets/13a9fc5e-103a-4c14-bdfe-b88f357960d5)


### Temporary Bot Support
- Added support for temporary bots in battlegrounds
- New checkbox in the BG tab to toggle between permanent and temporary bots
- Temporary bots are automatically removed when they leave the battleground
- Uses the new server command: `.battlebot add [bg] [faction] [level] temp`


### GM Mode Improvements
- Added manual faction override for GM mode
- Improved faction detection for GM characters
- Fixed issues with faction-specific class buttons and battleground fills in GM mode

### Core Improvements
- Complete rewrite of the core system
 
### UI System
-  A new 'modern' take on the classic frame style, featuring well-defined borders that seamlessly integrate with the beloved legacy WoW UI.
- Movable main window with drag functionality
- Minimap button with right-click drag
- Improved tab system with 4 organized sections:
  * Party: Bot management and roles
  * Control: Combat controls
  * BG: Battleground and Battlebot features
  * Template: Gear/Spec management
- Working close button in all states

### Party Management
- Improved class button organization
- Added die/revive commands that work in all states
- Faction-specific class handling (Paladin/Shaman)

### Combat Control System
- Start/Stop combat buttons
- Pull target functionality
- CC marking system
- Focus mark controls
- AOE mode toggle
- Pause/Unpause functionality
- Come to me command

### Battleground System
- Added complete BG queue and fill system
- Implemented auto-fill functionality for all BGs (WSG, AB, AV)
- Queue command system with proper faction balance
- Leave space for player in their faction's team
- Dynamic bot level scaling: Battlebots are automatically created matching the player's current level
- Intelligent level-based BG queue system:
  * WSG: Level 10-60
  * AB: Level 20-60
  * AV: Level 51-60
- Proper level requirement checks before queueing
- Prevents queueing for BGs below minimum level requirement
- Start/Stop BG controls to skip waiting time or come back later

### Template System
- Interactive template management:
  * "Gear Template" and "Spec Template" buttons fetch all available templates
  * Dynamic dropdown menu automatically populates with server templates
  * Templates are displayed in format: "ID - Template Name"
  * Real-time dropdown updates when new templates are loaded
- Save functionality:
  * Save current gear setup as new template
  * Save current talent spec as new template
  * Custom template naming through input field
- User-friendly feedback:
  * Clear error messages if no template name is provided
  * Visual confirmation when templates are loaded
  * Proper input field placeholder text

### Command Queue System for BG fill
- Implemented command queuing for multiple bot additions
- Added delay between commands (0.5s)
- Added feedback messages for queue status
- Prevents command overflow

### Faction-Specific Features
- Dynamic faction class button (Paladin/Shaman)
- Automatic faction detection
- Proper initialization of faction-specific elements
- Improved error handling for faction-specific commands


## Credits
- This addon was first made by minzi90
- Original addon by coolzoom: https://github.com/coolzoom/vmangos-pbotaddon/tree/master
- Battleground fill system inspired by Digital Scriptorium: https://www.youtube.com/@Digital-Scriptorium
- Special thanks to Celguar for providing the chat message parsing code that enables template detection and auto-population of the dropdown menu: https://github.com/celguar/
