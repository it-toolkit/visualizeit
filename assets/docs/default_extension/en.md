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

Allowed scaling values:

| Value     | Description                                                                                                                                                                                                                                                           |
|-----------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| fill      | Fill the target box by distorting the source's aspect ratio.                                                                                                                                                                                                          |
| contain   | As large as possible while still containing the source entirely<br> within the target box.                                                                                                                                                                            |
| cover     | As small as possible while still covering the entire target box.                                                                                                                                                                                                      |
| fitWidth  | Make sure the full width of the source is shown, regardless <br>of whether this means the source overflows the target box vertically.                                                                                                                                 |
| fitHeight | Make sure the full height of the source is shown, regardless <br>of whether this means the source overflows the target box horizontally.                                                                                                                              |
| none      | Align the source within the target box (by default, centering)<br>and discard any portions of the source that lie outside the box. <br>The source image is not resized.                                                                                               |
| scaleDown | Align the source within the target box (by default, centering)<br>and, if necessary, scale the source down to ensure that the source<br>fits within the box. <br>This is the same as `contain` if that would shrink the image,<br>otherwise it is the same as `none`. |

### show-banner

This command shows a banner in top of current visualization state.

#### Arguments

| Name       | Type    | Position | Required | Default value | Description                                                   |
|------------|---------|----------|----------|---------------|---------------------------------------------------------------|
| message    | string  | 0        | true     | -             | -                                                             |
| position   | string  | 1        | false    | center        | -                                                             |
| duration   | int     | 2        | false    | 1             | Amount of frames to show the banner before removing it (>= 1) |
| adjustSize | boolean | 3        | false    | false         | If 'true' the banner size will be adjusted to its content     |

Allowed position values:

| Value        | 
|--------------|
| topLeft      |
| topCenter    |
| topRight     |
| centerLeft   |
| center       |
| centerRight  |
| bottomLeft   |
| bottomCenter |
| bottomRight  |

### nop

This is a NO-Operation command. It could be used to add some dummy frames.
