# The `leporello` class

A simple LaTeX document class to create folding flyers with two key features:

1) Columns are created first and then placed on a page of the folding flyer. This way, columns can be used multiple times on pages with varying widths.
2) Boxes with padding and background (including bleed) can be typeset easily and positioned in a column.

---

# Documentation

## Loading the class

Use `\documentclass{leporello}` to load the document class. The document class loads the `geometry`, the `graphicx` and the `l3draw` package.

Use `\leporelloset` or use the optional argument of the document class to globally set the document layout. The following options are available:

- `columns`: Expects a comma-separated list of dimensions that describe the width of the columns in the layout. A few layouts are predefined: `two columns`, `three columns`, `four columns`, `four columns wrap`, `five columns` and `six columns`. These do not expect a value. The default value is `97mm, 100mm, 100mm`.
- `layout height`: Expects a dimension that sets the height of the final layout. The width is automatically calculated from the list given to `columns`. The default value is `210mm`.
- `show frames`: When set, frames around the single pages (columns) are shown. Does not expect a value. 
- `prepress`: When set, the paper size is increased at all four pages by the width of the info area and crop marks are shown. Does not expect a value.
- `info area`: Expects a dimension for the width of the info area that is shown when `preoress` is set. The default value is `10mm`.
- `bleed`: Expects a dimension for the width of the bleed. The default value is `3mm`.

## Defining columns

Columns are grouped material to be typeset on a specific page of the folding flyer. A column can contain anything that can be placed in a TeX box in general, but the typical use of a column is to only serve as a frame to which boxes are attached. The package has currently no text overflow detection. Thus, if a column contains more that fits, the relevant parts just spill over the frame edges.

A column is defined by the `leporellocolumn` environment which takes one mandatory argument taking the name (or ID) of the column.

## Defining boxes

Boxes can be defined inside of columns. They also can contain anything that can be placed in a TeX box in general and they have no text overflow detection.

A box is defined by the `leporellobox` environment which takes one optional argument to set bxx-specific options. These are:

- `align parent`: Expects a comma-separated list of two items which denote the horizontal and vertical pole of whcih the intersection defines the coordinate of the column box that serves as anchor to align the current box. The default value is `l, t` denoting the top left corner. Available poles are:
    - `l`: The left edge of the box.
    - `hc`: The horizontal center of the box.
    - `r`: The right edge of the box.
    - `t`: The top edge of the box.
    - `vc`: The vertical center of the box.
    - `B`: The baseline of the box.
    - `b`: The bottom edge of the box.
- `align self`: Expects a comma-separated list of two items which denote the horizontal and vertical pole of whcih the intersection defines the coordinate of the current box that serves as anchor to align the current box to the column box. The default value is `l, t` denoting the top left corner.
- `offset`: Expects a comma-separated list of two dimensions which set the offset of the anchor set via `align parent` and `align self`. The first dimension is the offset to the right, the second dimension the offset downwards. The default value is `0mm, 0mm`.
- `width`: Expects a dimension to explicitly set the width of the current box. The default value is `0mm` which means that the box is as wide as the parent column box.
- `height`: Expects a dimension to explicitly set the height of the current box. The default value is `0mm` which means that the box is as high as necessary to fit the contents.
- `stretch height`: When set, the box is stretched until its relevant edge meets the edge of the parent column box. Does not expect a value.
- `padding left`: Expects a dimension to describe the padding of the contents from the left edge of the box. The default value is `7.5mm`.
- `padding right`: Expects a dimension to describe the padding of the contents from the right edge of the box. The default value is `7.5mm`.
- `padding top`: Expects a dimension to describe the padding of the contents from the top edge of the box. The default value is `7.5mm`.
- `padding bottom`: Expects a dimension to describe the padding of the contents from the bottom edge of the box. The default value is `7.5mm`. All four padding settings can also be stated using the syntax `padding={left=7.5mm,top=7.5mm}` or similar.
- `no padding`: When set, sets all padding to zero. Does not expect a value.
- `pre`: Expects a token list that is placed before the actual contents of the box. Should not contain typeset material.
- `background`: Expects a color name as defined via `l3color` or `none` which will not fill the background. The default value is `none`.
- `bleed`: Expects a comma-separated list consisting of up to four items with the values `t`, `b`, `l` and `r` that describe the edges (top, bottom, left and right) where bleed should be added to the box. Note that bleed is not added to the inner edges where the column boxes meet.
- `store width`: Expects a single control sequence (macro) to store the width of the current box.
- `store height`: Expects a single control sequence (macro) to store the height of the current box.
- `flow into`: Expects the ID of the box into which typeset material will flow into if it does not fit into the current box. See section "flow mechanism" below.

## Typesetting boxes to columns

Using the command `\printleporellocolumns` which takes one mandatory argument, previously defined columns can be placed onto a page of the document. The command expects as argument a comma-separated list of names of previously defined columns. These are then placed onto a document page from left to right while the width is taken from the setting via the `columns` key and the height is taken from the setting via the `layout height` key.

The command takes one optional argument that can take the option `reverse layout`. When set, the widths of the columns are reversed, but the placement of the columns is still from left to right. The option should be used to typeset the verso of a folding flyer that naturally has the widths of the columns reversed.

Currently, boxes can only be attached to columns. A future version of the document class may allow to attach boxes to each other.

## Flow mechanism

It is possible to let typeset material flow from one box to another box. To this end, the key `flow into` can be set to the relevant box and assigned the ID of the box to flow into as value. The IDs of the boxes are integers starting from 1 and increasing in the order of the defintion of the boxes. 

The flow mechanism works across multiple boxes. But due to the way the typesetting mechanism of TeX works, it needs some manual adjustment if the typeset material flows across boxes of different width. In this case, the command `\leporelloboxbreak` should be inserted at the point where the break should take place.

## Other settings

### Defining colors

The package uses the color model of the `l3color` module. The `xcolor` package is not supported. To provide a user interface to define and select colors, the commands `\leporellocolordefine` and `\leporellocolorselect` are defined. 

The command `\leporellocolordefine` takes three arguments, the first being the name of the color to be defined. The second argument takes the color model (for example `rgb` or `cmyk`) and the third argument takes the color values. For more information about which color models are supported, please refer to the documentation of the `l3color` module.

The command `\leporellocolorselect` takes the name of the previously defined color as argument. All following objects are affected by this color setting. To colorize only a few letters, use curly braces for grouping.

### Restoring justified typesetting

In order to restore justified typesetting after having set `\raggedright`, `\raggedleft` or `\centering`, the packages defines the command `\leporellojustified` which restores the default justified typesetting style of TeX.

### Defining styles

In order to simplify the setting of recurring options to the `leporellobox` environment, it is possible to group several of these options as style via the `\leporellosetstyle` command which takes as first argument the name of the newly defined style and as second argument the releevant options (key-value pairs). The style can then be used like an option to any `leporellobox` environment.

### Inserting images

With the command `\leporelloimage` images that cover full boxes can be inserted. This command can be placed in a `leporellobox` with zero padding. The command has one mandatory argument that takes a relative path and file name to select the image to be inserted. It also has one optional argument to take the following options:

- `clip width`: Expects a dimension depicting the width of the boxed image.
- `clip height`: Expects a dimension depicting the height of the boxed image.
- `scale`: Expects a floating point number depicting the scaling factor of the image. This factor will not affect the size of the box.
- `width`: Expects a dimension to explicitly set the width of the image. This will override a `scale` value.
- `height`: Expects a dimension to explicitly set the width of the image. This will override a `scale` or a `width` value. The aspect ratio of the original image will always be kept.
- `offset`: Expects a comma-separated list consisting of two values that describe the offset of the image that will be positioned per default so that the upper left corner sits at the upper left corner of the box. A positive offset will shift the image in upper left direction.
- `ignore padding`: Expects a comma-separated list consisting of up to four items with the values `t`, `b`, `l` and `r` that describe the edges (top, bottom, left and right) where the image should ignore the padding of the current box.
- `fill bleed`: When set, the image will spread into the bleed. This will result in a shift of the image by the size of the bleed which needs to be accounted for using `offset`. Does not expect a value.
