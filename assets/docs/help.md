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







