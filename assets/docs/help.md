## Getting Started

Welcome to Visualize IT, your go-to app for creating dynamic diagrams and adding animations through coded scripts. Whether you're a seasoned developer or a design enthusiast, this guide will help you unleash your creativity.

## Creating Your First Script

1. **Open new script page**: In the home page, tap on 'Create script' icon (outlined plus symbol)

![tutorial_1_1.png](assets/images/tutorial_1_1.png)

2. **Write your script**: By default a simple but functional script template is provided. Write your custom script using the Visualize IT syntax. 

> &#128712; From the script editor you can Save or Discard changes and even start Playing your script.

> &#128712; The code editor has code-autocompletion support and error detection features to improve your experience.

![tutorial_1_2.png](assets/images/tutorial_1_2.png)

3. **Play your first script**: Tap on the 'Play script' icon located at bottom right position.

> &#9888; Only saved valid scripts will be available to be played

4. **Start script visualization**: using the player button bar, tap on play button and enjoy your first visualization

![tutorial_1_3.png](assets/images/tutorial_1_3.png)

### Example script

```yaml
name: "New script 1"
description: "... complete the 'New script 1' description..." 
scenes:
  - name: "...scene name..."
    extensions: [ ]
    description: "...optional scene description"
    initial-state:
      - nop
    transitions:
      - show-banner: [ "**This is awesome!**", center, 2, true ]
```

## Script syntax

Visualize IT scripts must be written in YAML format using the specific structure shown below.

### Root keys

| Key         | Required | Type      | Description                                                    |
|-------------|----------|-----------|----------------------------------------------------------------|
| name        | Yes      | String    | Script display name                                            |
| description | Yes      | String    | Script long display description with Markdown language support |
| group       | No       | String    | Optional group name to use in script selector page (home)      |
| scenes      | Yes      | **Scene** | List of script scenes. At least one scene is required          |

### Scene keys
| Key                    | Required | Type              | Description                                                                                                    |
|------------------------|----------|-------------------|----------------------------------------------------------------------------------------------------------------|
| name                   | Yes      | String            | Scene display name                                                                                             |
| description            | No       | String            | Optional scene short description                                                                               |
| extensions             | Yes      | String array      | Array of extensions used in this scene (Only extension ids). The 'default' extension<br>is always included.    |
| title-duration         | No       | Int               | Amount of frames dedicated to show the scene title slide. Default value: *1*                                   |
| base-frame-duration-ms | No       | Int               | Duration in milliseconds for a player frame. Default value: *1000* ms (1 second per frame)                     |                                                       
| initial-state          | No       | **Command** array | Array of commands to setup the initial scene state. Only commands available in referenced modules can be used. |
| transitions            | No       | **Command** array | Array of commands to build the animation. Commands will be applied sequentially.                               |

#### Commands
A command can have
* No arguments
* A single argument
* An array of arguments
* A key-value map of arguments. Where the keys are the argument names.

Each command syntax depends on its own definition

**Example**
```yaml
initial-state:
    - no-arg-command
    - command-with-arg: "my-arg"
    - command-with-multi-arg: [arg1, arg2]
    - command-with-multi-arg: 
        arg_name_1: arg1
        arg_name_2: arg2
```

> **Commands namespacing**
> To avoid name conflicts a command can be prefixed with the extension id
> `extension_id`**.**`command_name`


## My Scripts
In this section, you will find all your scripts. From here, you can search, import, and export them. Furthermore, for the selected script, you will have the options to share, clone, export, edit, and play it.

### Search Scripts
Use the search bar to filter the shown scripts. It is available for "My Scripts" and "Public Scripts" tabs.

![tutorial_2_1.png](assets/images/tutorial_2_1.png)

### Import Scripts
Tap on 'Import Scripts' icon to import scripts. The script must be in YAML format. 

![tutorial_2_2_import_scripts.png](assets/images/tutorial_2_2_import_scripts.png)

After selecting and uploading the file, you will see the script accordingly to the group name chosen. In this sample, the group name was "My Imported Scripts"

![tutorial_2_3_import_scripts.png](assets/images/tutorial_2_3_import_scripts.png)

### Export Scripts
Tap on 'Export Scripts' icon to export all your scripts. You can use search bar to narrow the exportable script list.  

![tutorial_2_4_export_all.png](assets/images/tutorial_2_4_export_all.png)

![tutorial_2_4_export_confirm.png](assets/images/tutorial_2_4_export_confirm.png)

### Share this Script
At the bottom of the window, tap on the 'Share' icon to send the selected script to someone else. The application will send the script via email.

![tutorial_2_5_share.png](assets/images/tutorial_2_5_share.png)

### Export this Script
In order to export only the selected script, tap on the 'Export' option in the bottom of the window.

![tutorial_2_6_export.png](assets/images/tutorial_2_6_export.png)

### Delete this Script
Delete the selected script by tapping on 'Delete' in the bottom of the window.

![tutorial_2_7_delete.png](assets/images/tutorial_2_7_delete.png)

### Clone this Script
To get a copy of the selected script, tap on the 'Clone' functionality at the bottom of the window.

![tutorial_2_8_clone.png](assets/images/tutorial_2_8_clone.png)

After confirming you will see the copy of the script on 'Edit' mode. Here you can modify the script, and then discard, save or play the script. Please refer to 'Editor Mode' section or 'Edit this script'

![tutorial_2_8_clone_edit.png](assets/images/tutorial_2_8_clone_edit.png)

When you save the script, you will see it in the list

![tutorial_2_8_clone_list.png](assets/images/tutorial_2_8_clone_list.png)

### Edit this Script
Tap 'Edit' icon in the bottom of the window, to enter to 'Editor mode' and edit the selected script.

![tutorial_2_9_edit.png](assets/images/tutorial_2_9_edit.png)

After making modifications, you have the option to discard or save the changes. Once saved, the script can then be executed.

![tutorial_2_9_edit_options.png](assets/images/tutorial_2_9_edit_options.png)

### Play this Script
Finally, tap in 'Play' icon to start playing the script.

![tutorial_2_10_play.png](assets/images/tutorial_2_10_play.png)

Refer to 'Playing an script' section for more info about this mode.

## Public Scripts
In this section, you will find sample scripts and examples related to the onboarded extensions, such as External Sort, Extendible Hashing, and B# tree samples. Specifically, you will find detailed scripts that explain the evolution of various structures and algorithms.

When each script is selected, a brief explanation of the implemented model, along with the available commands, will be displayed on the right side of the screen.

![tutorial_3_1_public_scripts](assets/images/tutorial_3_1_public_scripts.png)

On this section, you can also search, create and import scripts in a similar way as it was instructed in 'My Scripts' section.

![tutorial_3_2_public_scripts_up_options](assets/images/tutorial_3_2_public_scripts_up_options.png)

Finally, at the bottom of the screen you will find the options for clone, view and play the selected script. 
All Public scripts are read-only, so in the view mode you won't be able edit the content of the script. If you want to made changes, just clone it to create a new script one based on it. The cloned script will be visible in 'My Scripts' tab.

![tutorial_3_3_public_scripts_options](assets/images/tutorial_3_3_public_scripts_options.png)

## Script Edition

The script editor has some helpful features to make script edition easier

### Code completion

When writing a script, the editor will try to suggest you 

* **Script section templates**
  ![tutorial_8_1_editor_template](assets/images/tutorial_8_1_editor_template.png)
* **Extension ids**
  ![tutorial_8_2_extension_ids](assets/images/tutorial_8_2_extension_ids.png) 
* **Commands**
  ![tutorial_8_3_commands](assets/images/tutorial_8_3_commands.png)
  > If you want to know the commands available in an extension just prefix the command with the extension id.
  ![tutorial_8_4_namespacing](assets/images/tutorial_8_4_namespacing.png)
  > If no suggestions appear, check if the extension was added in any script scene and if you applied that change.
* **Generators**
  ![tutorial_8_5_generators](assets/images/tutorial_8_5_generators.png)

### Generators

These pre-processor directives are utilities to generate sample data easily.

Currently only random integer array generation is supported. In order to use it, write the placeholder `_int_array_???_` replacing `???` with the desired amount of elements. The amount can be between 0 and 999. For example `_int_array_3_` will by replaced with an array of 3 random numbers during script play.

The effective array will be shown only when playing the script. In edition mode you will se the placeholder.

### Error detection

While you are editing a script, the editor is continuously checking the content and will display any error found at the bottom of the editor.

![tutorial_8_6_errors](assets/images/tutorial_8_6_errors.png)

## Playing a Script
In 'Player' mode you will find two options that can be changed from the selector in the upper-right side of the screen, this options are 'Presentation Mode' and 'Exploration Mode'

![tutorial_4_1_playing_a_script.png](assets/images/tutorial_4_1_playing_a_script.png)

### Presentation Mode
In this mode will you find the bottom bar with options to reproduce the script. It is not possible to see the script or modify it.

![tutorial_4_2_playing_a_script_options.png](assets/images/tutorial_4_2_playing_a_script_options.png)

The options presented are detailed below:

![tutorial_4_3_playing_a_script_detailed_options.png](assets/images/tutorial_4_3_playing_a_script_detailed_options.png)

1. Reset the script: The script is returned to the initial state. 
2. Player commands: You can play the script and also see each slide forward and backward.
3. Speed selector: Modify the speed of the presentation.
4. Scale selector: Modifies the scale of the view. It is possible to enlarge and reduce the view.
5. Maximize Window: Maximize the current window removing the upper section of the application. 

### Exploration Mode
Users may activate this mode by selecting the option located in the upper-right corner of the screen. In this mode, script content is accessible for viewing and modification. Users have the ability to discard or apply changes as required. Furthermore, during script execution, the currently executing line is visually highlighted.

![tutorial_5_1_playing_exploration_mode.png](assets/images/tutorial_5_1_playing_exploration_mode.png)

![tutorial_5_2_playing_exploration_mode_options.png](assets/images/tutorial_5_2_playing_exploration_mode_options.png)

> **Remember to apply the changes before playing script again.**

## Extensions
Tap on the 'Extensions' icon to see the available extensions:

![tutorial_6_1_extensions](assets/images/tutorial_6_1_extensions.png)

In this section, you will find a comprehensive list of all available extensions. You can search by name, and upon selection, detailed explanations of commands, arguments, and their limitations will be provided.

![tutorial_6_1_extensions_options](assets/images/tutorial_6_1_extensions_options.png)

## Help
When tap on 'Help' icon you will see this page.

![tutorial_7_1_help.png](assets/images/tutorial_7_1_help.png)





