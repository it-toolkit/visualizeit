# Default extension

This is the default extension usage doc. 

This extension is implicitly included in all scripts.

Extension id: `default`

## Available commands

### show-popup

This command shows a pop up that temporarily stops the script playback until it is closed.

#### Arguments

| Name    | Type   | Position | Required | Default value | Description |
|---------|--------|----------|----------|---------------|-------------|
| message | string | 0        | true     | -             | -           |

### background

This command setups the current visualization background.

#### Arguments

| Name     | Type   | Position | Required | Default value | Description |
|----------|--------|----------|----------|---------------|-------------|
| imageUrl | string | 0        | true     | -             | -           |
| scaling  | string | 1        | true     | -             | -           |

### show-banner

This command shows a banner in top of current visualization state.

#### Arguments

| Name     | Type   | Position | Required | Default value | Description                                            |
|----------|--------|----------|----------|---------------|--------------------------------------------------------|
| message  | string | 0        | true     | -             | -                                                      |
| position | string | 1        | true     | -             | -                                                      |
| duration | int    | 2        | true     | -             | Amount of frames to show the banner before removing it |

### nop

This is a NO-Operation command. It could be used to add some dummy frames.
