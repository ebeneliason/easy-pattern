# EasyPattern for Playdate

[![MIT License](https://img.shields.io/github/license/ebeneliason/easy-pattern)](LICENSE) [![Toybox Compatible](https://img.shields.io/badge/toybox.py-compatible-brightgreen)](https://toyboxpy.io) [![Latest Version](https://img.shields.io/github/v/tag/ebeneliason/easy-pattern)](https://github.com/ebeneliason/easy-pattern/tags)

_Easy animated patterns for Playdate._

## What is EasyPattern?

EasyPattern is a utility for use with the [Playdate](https://play.date/) SDK that provides a
simple declarative syntax for creating animated patterns. Specify an 8x8 pattern sequence and
any of a variety of easing parameters, and let EasyPattern take care of the rest. Under the
hood it will automatically phase shift your pattern in the horizontal and/or vertical axes to
create a seamless looping pattern texture that can be used with any
[PlayDate drawing calls](https://sdk.play.date/1.13.2/Inside%20Playdate.html#_drawing).

_Playdate is a registered trademark of [Panic](https://panic.com)._

## Installation

### Installing Manually

1.  Download the [EasyPattern.lua](EasyPattern.lua) file.
2.  Place the file in your project directory (e.g. in the `source` directory next to `main.lua`).
3.  Import it in your project.

    ```lua
    import "EasyPattern"
    ```

### Using [`toybox.py`](https://toyboxpy.io/)

1.  If you haven't already, download and install [`toybox.py`](https://toyboxpy.io/).
2.  Navigate to your project folder in a Terminal window.

    ```console
    cd "/path/to/myProject"
    ```

3.  Add EasyPattern to your project

    ```console
    toybox add ebeneliason/easy-pattern
    toybox update
    ```

4.  Then, if your code is in the `source` directory, import it as follows:

    ```lua
    import '../toyboxes/toyboxes.lua'
    ```

## Usage

### The Basics

Define your pattern:

```lua
local checkerboard <const> = { 0xF0, 0xF0, 0xF0, 0xF0, 0x0F, 0x0F, 0x0F, 0x0F }
local easyCheckerboard = EasyPattern {
    pattern  = checkerboard,
    duration = 1.0,
    ease     = playdate.easingFunctions.inOutCubic,
    -- <additional animation params here>
}
```

Set the pattern for drawing (e.g. in your sprite's `draw` function):

```lua
playdate.graphics.setPattern(easyCheckerboard:apply())
-- draw using your pattern here
```

That's it! The pattern will automatically animate according to the parameters provided. The only
thing left to do is to make sure your sprite has a chance to draw in order to animate the pattern.
If it isn't naturally marked dirty (by e.g. moving each frame, etc.), you'll need to call
`markDirty()` yourself each frame.

Depending on the speed of your animation, chances are the pattern won't actually update every
frame. To improve performance, you can check to see whether the phase values for the pattern have
changed in order to know when to mark your sprite dirty. You can do this from your sprite's
`update` function:

```lua
if myEasyPattern:isDirty() then
    self:markDirty()
end

```

### Notes on Initialization

EasyPattern takes a single argument — a table of named parameters that define both the pattern and
animation properties. (This is also why no parentheses are required when defining a new instance,
instead enabling use of `{` and `}` by themselves.)

Most parameters come in pairs to enable setting independent values for the X and Y axes. For
example, `xDuration` and `yDuration`. However, when initializing a new `EasyPattern`, any
of the axis-specific values may be set for both axes at once by dropping the `x` or `y` prefix
from the parameter name, e.g. `..., scale = 2, reverses = true, ...` and so on. The usage example
above demonstrates this by setting the `duration` and `ease` for both axes at once.

### Notes on Animation Timing

EasyPatterns are designed to loop continuously. They do so with respect to an absolute clock that
starts the moment the program runs. _They do not depend on timers._ This approach means that two
instances of the same EasyPattern will run in sync with each other regardless of when they were
initialized or any other timing conditions. If you'd like two of the same EasyPatterns (or two
different patterns with the same duration) to animate out of phase with each other, adjust the
`xOffset` and `yOffset` for one of them.

## Supported Parameters

A full list of supported parameters follows below. Technically speaking, none of these are required.
In practice, you'll want to set either `pattern` or `ditherType`, and a `duration` for at least
one axis as shown in the example above.

The animation parameters may also be set directly on your EasyPattern instance at any time, e.g.

```lua
easyCheckerboard.xDuration = 0.5
```

### Pattern Parameters

#### `pattern`

The pattern to animate, specified as an array of 8 numbers describing the bitmap for each row, with
an optional additional 8 for a bitmap alpha channel, as would be supplied to
`playdate.graphics.setPattern()`. See [Defining Your Patterns](#defining-your-patterns) for details
on how to construct valid arguments for this parameter.

Default: `nil`

#### `ditherType`

A dither type as would be passed to `playdate.graphics.setDitherPattern()`, e.g.
`playdate.graphics.image.kDitherTypeVerticalLine`. This setting only applies when the `pattern`
parameter is omitted or `nil`.

Default: `nil`

#### `alpha`

An alpha value for a dither pattern, which can either be the default Playdate dither effect, or one
specified by `ditherType`. This setting only applies when the `pattern` parameter is omitted or `nil`.

Default `0.5`

#### `color`

The color in which to draw the provided dither pattern. This setting only applies when the `pattern`
parameter is omitted or `nil`.

Default: `playdate.graphics.kColorBlack`

#### `bgColor`

The color to use as a background when rendering a dither pattern (or a pattern with an alpha channel,
although in that case the background color could be baked into the pattern itself, without alpha).
Patterns are rendered with transparency by default, but this can be used to make them opaque.

Default: `playdate.graphics.kColorClear`

### Animation Parameters

#### `xEase`

An easing function that defines the animation pattern in the X axis. The function should follow the
signature of the [`playdate.easingFunctions`](https://sdk.play.date/1.13.2/Inside%20Playdate.html#M-easingFunctions):

-   **`t`**: elapsed time, in the range [0, `duration`]
-   **`b`**: the beginning value (always 0)
-   **`c`**: the change in value (always 8 — the size of the pattern)
-   **`d`**: the duration (`duration`)

Default: `playdate.easingFunctions.linear`

#### `yEase`

An easing function that defines the animation pattern in the Y axis. The function should follow the
signature of the `playdate.easingFunctions` as described just above.

Default: `playdate.easingFunctions.linear`

#### `xEaseArgs`

A list containing any additional arguments to the X axis easing function, e.g. to parameterize
amplitude, period, overshoot, etc.

Default: `{}`

#### `yEaseArgs`

A list containing any additional arguments to the Y axis easing function, e.g. to parameterize
amplitude, period, overshoot, etc.

Default: `{}`

#### `xDuration`

The duration of the animation in the X axis, in seconds. Omit this parameter or set it to 0 to
prevent animation in this axis.

Default: `0`

#### `yDuration`

The duration of the animation in the Y axis, in seconds. Omit this parameter or set it to 0 to
prevent animation in this axis.

Default: `0`

#### `xOffset`

An absolute time offset for the X axis animation (relative to Y), in seconds.

Default: `0`

#### `yOffset`

An absolute time offset for the Y axis animation (relative to X), in seconds.

Default: `0`

#### `xReverses`

A boolean indicating whether the X axis animation reverses at each end.

Default: `false`

#### `yReverses`

A boolean indicating whether the Y axis animation reverses at each end.

Default: `false`

#### `xReversed`

A boolean indicating whether the X axis animation is playing in reverse. This may be set manually,
and also updates automatically when `xReverses` is `true`.

Default: `false`

#### `yReversed`

A boolean indicating whether the Y axis animation is playing in reverse. This may be set manually,
and also updates automatically when `yReverses` is `true`.

Default: `false`

#### `xSpeed`

A multiplier for the overall speed of the animation in the X axis, relative to the timings
specified for its duration and offset.

Default: `1`

#### `ySpeed`

A multiplier for the overall speed of the animation in the Y axis, relative to the timings
specified for its duration and offset.

Default: `1`

#### `xScale`

A multiplier describing the number of 8px repetitions the pattern moves by per duration cycle in
the X axis. Non-integer values may result in discontinuity when looping.

Default: `1`

#### `yScale`

A multiplier describing the number of 8px repetitions the pattern moves by per duration cycle in
the Y axis. Non-integer values may result in discontinuity when looping.

Default: `1`

## Functions

### `apply()`

_This is where the magic happens._ `apply` takes no arguments and returns a 3-tuple matching the
signature of `playdate.graphics.setPattern()`. This enables you to pass the result of a call to
`apply` directly to the `setPattern` function without intermediate storage in a local variable.

#### Returns

-   **`patternImage`:** A `playdate.graphics.image` containing the 8x8 pattern to be drawn.
-   **`xPhase`:** The calculated phase offset for the X axis given the current time and other
    animation properties.
-   **`yPhase`:** The calculated phase offset for the Y axis given the current time and other
    animation properties.

### `isDirty()`

Indicates whether the pattern needs to be redrawn based on a change in the phase values since the
last time `apply` was called. Note that `isDirty` will only return true _once_ when new phase
values get computed. If you need to check it multiple times per frame, such as when applying the
same pattern to multiple sprites, you'd need to cache it so all sprites can know whether a redraw
is required.

#### Returns

-   **`dirty`**: A boolean indicating whether the pattern needs to be redrawn.

### `getPhases()`

Used to introspect the current X and Y phase offsets for the pattern. If the values are stale,
new values will be computed when calling this function; otherwise, the cached values will be
returned instead.

#### Returns

-   **`xPhase`**: A number representing the current phase offset for the X axis in the range 0..7.
-   **`yPhase`**: A number representing the current phase offset for the Y axis in the range 0..7.
-   **`recomputed`**: A boolean indicating whether the values were newly computed.

### `setPattern(pattern)`

Sets a new pattern, retaining all animation properties.

#### Params

-   **`pattern`:** An array of 8 numbers describing the bitmap for each row, with an optional
    additional 8 for a bitmap alpha channel, as would be supplied to
    `playdate.graphics.setPattern()`.

### `setDitherPattern(alpha, [ditherType])`

Sets a new dither pattern, retaining all animation properties.

#### Params

-   **`alpha`:** A value in the range [0, 1] describing the opacity of the dither effect.
-   **`ditherType`:** (_optional_) A constant as would be passed to `playdate.graphics.setDitherPattern()`, e.g.
    `playdate.graphics.image.kDitherTypeVerticalLine`.

### `setColor(color)`

Sets the color used for drawing the dither pattern.

#### Params

-   **`color`:** A `playdate.graphics` color value.

## Examples

These examples demonstrate the range of pattern animations possible with EasyPattern.

### Conveyor Belt

This example utilizes the built-in vertical line dither type to create a simple horizontally
scrolling conveyor belt effect. Because the dither effect naturally has transparency, a
`bgColor` is specified so that the resulting belt pattern is fully opaque.

```lua
EasyPattern {
    ditherType = playdate.graphics.image.kDitherTypeVerticalLine,
    xDuration  = 0.5,
    bgColor    = playdate.graphics.kColorWhite
}
```

### Marching Ants

This example creates a "marching ants" dotted outline effect, as is often used to indicate
rectangular selections. To achieve the effect, one would use this pattern in conjunction
with a call to `drawRect(r)`. Modulate the length of the dashes with the `alpha` parameter.

```lua
EasyPattern {
    ditherType = playdate.graphics.image.kDitherTypeDiagonalLine,
    xDuration  = 0.25,
    bgColor    = playdate.graphics.kColorWhite
}
```

### Vertical Bounce

In this example, the pattern appears to fall downward one block at a time, bouncing to a
settled state before the next row drops out.

```lua
EasyPattern {
    pattern   = checkerboard,
    yDuration = 1.0,
    yEase     = playdate.easingFunctions.outBounce,
    yReversed = true,
    scale     = 2
}
```

### Waves

This example uses a sinusoidal ease in the vertical axis to create a simple wave motion, paired
with a linear ease in the horizontal axis to illustrate directional flow. You can combine
different easing functions and even different timing values for each axis to acheive more nuanced
effects.

```lua
EasyPattern {
    pattern   = checkerboard,
    xDuration = 0.5,
    yDuration = 1.0,
    yEase     = playdate.easingFunctions.inOutSine,
    yReverses = true,
}
```

### Circular Pan

This example makes use of built-in sine functions and an `xOffset` to create a continuous
circular panning movement.

```lua
EasyPattern {
    pattern   = checkerboard,
    duration  = 0.5,
    ease      = playdate.easingFunctions.inOutSine,
    xOffset   = 0.25, -- half the duration
    reverses  = true,
    scale     = 2
}
```

### Perlin Noise

This example introduces a custom easing function for more complex behavior. Technically, it's
not an _easing_ function at all, as it uses Perlin noise generation to return values in the
desired range, causing the texture to appear to move about smoothly in a seemingly random way.

You could use this to create organic effects such as rustling leaves. You can create any
type of custom function you like to design behaviors unique to your application.

```lua
EasyPattern {
    pattern   = checkerboard,
    xDuration = 3,
    yDuration = 2,
    xEase     = function(t, b, c, d) return b + playdate.graphics.perlin(t / d, 2, 3, 4, d, 0.75) * c end,
    yEase     = function(t, b, c, d) return b + playdate.graphics.perlin(t / d, 5, 6, 7, d, 0.75) * c end,
    scale     = 10
    }
```

## Defining Your Patterns

A variety of tools exist to help you find or create patterns you could use with EasyPattern. For
instance, [GFXP](https://dev.playdate.store/tools/gfxp/) provides a library of patterns, a
visual pattern editor, and a tool for viewing patterns on Playdate hardware.

You can specify your patterns in hex as shown in the examples above. Or, for a more direct
visual representation in your code, you can use a binary encoding as shown below.

```lua
EasyPattern {
    pattern = BitPattern {
        '11110000',
        '11100001',
        '11000011',
        '10000111',
        '00001111',
        '00011110',
        '00111100',
        '01111000',
    },
    -- animation properties…
}
```

`BitPattern` is included when you import `EasyPattern` so you can use it at your convenience.
You can also include an alpha channel for your pattern. `BitPattern` automatically swizzles the
inputs, enabling you to place the pattern and its alpha channel side by side in a compact and legible
format, like so:

```lua
EasyPattern {
    pattern = BitPattern {
        -- PTTRN        ALPHA
        '10101010',  '00010000',
        '01010101',  '00111000',
        '10101010',  '01111100',
        '01010101',  '11111110',
        '10101010',  '01111100',
        '01010101',  '00111000',
        '10101010',  '00010000',
        '01010101',  '00000000',
    },
    -- animation properties…
}
```

## Troubleshooting

### What if my pattern doesn't appear?

Make sure you've specified either the `pattern` or the `ditherType` parameters properly. More info
on [defining your patterns](#defining-your-patterns) is provided in the previous section.

### What if my pattern doesn't animate?

1. First, make sure you've properly specified an `xDuration` and/or `yDuration`, without
   which your pattern will remain static.
2. Ensure that `draw` gets called as necessary to reflect the rendered pattern. If you're using a
   sprite, you can call `self:markDirty()` from your `update` function. See the
   [notes on performance](#what-about-performance) to optimize drawing. If you're not using sprites,
   just be sure to call your draw method as needed each frame.

## What About Performance?

Playdate is a very capable device, but even relatively simple Lua programs can suffer from
performance issues without adequate optimization. EasyPattern should work reliably in moderation
for most games, and does have some built-in optimizations. Most notably, you can ensure that
your sprite is only redrawn on frames when the pattern actually updates by checking whether it's
dirty first:

```lua
-- only redraw the sprite when the pattern updates
if myEasyPattern:isDirty() then
    self:markDirty()
end

```

When `isDirty` is called, `EasyPattern` will compute the phase offsets for the current time and
determine whether they have changed since the pattern was last applied. It also caches those
values so that they can be used when you do call `apply`, avoiding the need to compute them twice
in a single frame. The caching also ensures that there's no performance hit for calling
`apply` more than once in a given frame, so you can set the pattern multiple times in your draw
function as needed, or reuse the same pattern across several sprite instances with no penalty.

With all of that said, EasyPattern is certainly not the _best_ approach to animated patterns for
performance given the need to calculate phase offsets each frame. If you need maximal performance
you should consider encoding each frame of the animated pattern in an `imagetable` instead. If
you're using EasyPattern to draw sprites and need more performance, you can also use the
[Roto](https://github.com/ebeneliason/roto) utility to export the pattern or the final rendered
sprite(s) as matrix `imagetable` images.

## License

EasyPattern is distributed under the terms of the [MIT License](https://spdx.org/licenses/MIT.html).
