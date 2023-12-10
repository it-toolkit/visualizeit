## Getting Started

Welcome to Visualize IT, your go-to app for creating dynamic diagrams and adding animations through coded scripts. Whether you're a seasoned developer or a design enthusiast, this guide will help you unleash your creativity.

## Creating Your First Diagram

1. **Launch Visualize IT**: Open the app, go to 'My Scripts' and tap on 'Create' icon (outlined plus symbol)

2. **Choose a script name**: Write it in the toolbar. You can also define a script "Description".

3. **Create a new scene**: Tap on the 'Create' icon (outlined plus symbol) next to the Scenes list title.

4. **Write your scene script**: Write your script in the editor using the Visualize IT syntax.

## Example script

```
    description: B+ Tree values manipulation
    tags: data-structure, tree
    fixture
        btree TD
          # nodeId(/parentNodeId)? : level : (value(->childNodeId)?)(,value(->childNodeId)?)+
          P1 : 2 : 1 -> P1.1, 7 -> P1.2
          P1.1/P1 : 1 : 1 -> P1.1.1, 3 -> P1.1.2, 5 -> P1.1.3
          P1.2/P1 : 1 : 7 -> P1.2.1, 9 -> P1.2.2
          P1.1.1/P1.1 : 0 : 1,2
          P1.1.2/P1.1 : 0 : 3,4
          P1.1.3/P1.2 : 0 : 5,6
          P1.2.1/P1.2 : 0 : 7,8
          P1.2.2/P1.3 : 0 : 9,10,11,12
    transitions
        Add node value 13 (1s)
        Add node value 14 (1s)
        Delete node value 13
```

## Visualize IT syntax

### Script Metadata

### Scene