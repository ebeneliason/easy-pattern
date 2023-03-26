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
local checkerboard = { 0xF0F0, 0xF0F0, 0xF0F0, 0xF0F0, 0x0F0F, 0x0F0F, 0x0F0F, 0x0F0F }
local easyCheckerboard = EasyPattern {
    pattern       = checkerboard,
    phaseDuration = 1.0,
    phaseFunction = playdate.easingFunctions.inOutCubic,
    -- <additional animation params here>
}
```

Set the pattern for drawing (e.g. in your sprite's `draw` function):

```lua
playdate.graphics.setPattern(easyCheckerboard:apply())
-- draw using your pattern here
```

That's it! The pattern will automatically animate according to the parameters provided.

### Notes on Initialization

EasyPattern takes a single argument — a table of named parameters that define both the pattern and
animation properties. (This is also why no parentheses are required when defining a new instance,
instead enabling use of `{` and `}` by themselves.)

Most parameters come in pairs to enable setting independent values for the X and Y axes. For
example, `xPhaseDuration` and `yPhaseDuration`. However, when initializing a new `EasyPattern`, any
of the axis-specific values may be set for both axes at once by dropping the `x` or `y` prefix
from the parameter name, e.g. `..., scale = 2, reverses = true, ...` and so on. The usage example
above demonstrates this by setting the `phaseDuration` and `phaseFunction` for both axes at once.

### Notes on Animation Timing

EasyPatterns are designed to loop continuously. They do so with respect to an absolute clock that
starts the moment the program runs. _They do not depend on timers._ This approach means that two
instances of the same EasyPattern will run in sync with each other regardless of when they were
initialized or any other timing conditions. If you'd like two of the same EasyPatterns (or two
different patterns with the same duration) to animate out of phase with each other, adjust the
`xPhaseOffset` and `yPhaseOffset` for one of them.

## Supported Parameters

A full list of supported parameters follows below. Technically speaking, none of these are required.
In practice, you'll want to set either `pattern` or `ditherType`, and a `phaseDuration` for at least
one axis as shown in the example above.

With the exception of `pattern`, `alpha`, and `ditherType`, any listed properties may also be set
directly on your EasyPattern instance at any time, e.g.

```lua
easyCheckerboard.xPhaseDuration = 0.5
```

### `pattern`

The pattern to animate, specified as an array of 8 numbers describing the bitmap for each row, with
an optional additional 8 for a bitmap alpha channel, as would be supplied to
`playdate.graphics.setPattern()`.

Default: `nil`

### `alpha`

An alpha value for a dither pattern, which can either be the default Playdate dither effect, or one
specified by `ditherType`. This setting only applies when the `pattern` parameter is omitted or `nil`.

Default `0.5`

### `ditherType`

A dither type as would be passed to `playdate.graphics.setDitherPattern()`, e.g.
`playdate.graphics.image.kDitherTypeVerticalLine`. This setting only applies when the `pattern`
parameter is omitted or `nil`.

Default: `nil`

### `xPhaseFunction`

An easing function that defines the animation pattern in the X axis. The function should follow the
signature of the [`playdate.easingFunctions`](https://sdk.play.date/1.13.2/Inside%20Playdate.html#M-easingFunctions):

-   **`t`**: elapsed time, in the range [0, `phaseDuration`]
-   **`b`**: the beginning value (always 0)
-   **`c`**: the change in value (always 8 — the size of the pattern)
-   **`d`**: the duration (`phaseDuration`)

Default: `playdate.easingFunctions.linear`

### `yPhaseFunction`

An easing function that defines the animation pattern in the Y axis. The function should follow the
signature of the `playdate.easingFunctions` as described just above.

Default: `playdate.easingFunctions.linear`

### `xPhaseArgs`

A list containing any additional arguments to the X axis easing function, e.g. to parameterize
amplitude, period, overshoot, etc.

Default: `{}`

### `yPhaseArgs`

A list containing any additional arguments to the Y axis easing function, e.g. to parameterize
amplitude, period, overshoot, etc.

Default: `{}`

### `xPhaseDuration`

The duration of the animation in the X axis, in seconds. Omit this parameter or set it to 0 to
prevent animation in this axis.

Default: `0`

### `yPhaseDuration`

The duration of the animation in the Y axis, in seconds. Omit this parameter or set it to 0 to
prevent animation in this axis.

Default: `0`

### `xPhaseOffset`

An absolute time offset for the X axis animation (relative to Y), in seconds.

Default: `0`

### `yPhaseOffset`

An absolute time offset for the Y axis animation (relative to X), in seconds.

Default: `0`

### `xReverses`

A boolean indicating whether the X axis animation reverses at each end.

Default: `false`

### `yReverses`

A boolean indicating whether the Y axis animation reverses at each end.

Default: `false`

### `xReversed`

A boolean indicating whether the X axis animation is playing in reverse. This may be set manually,
and also updates automatically when `xReverses` is `true`.

Default: `false`

### `yReversed`

A boolean indicating whether the Y axis animation is playing in reverse. This may be set manually,
and also updates automatically when `yReverses` is `true`.

Default: `false`

### `xSpeed`

A multiplier for the overall speed of the animation in the X axis, relative to the timings
specified for its duration and offset.

Default: `1`

### `ySpeed`

A multiplier for the overall speed of the animation in the Y axis, relative to the timings
specified for its duration and offset.

Default: `1`

### `xScale`

A multiplier describing the number of 8px repetitions the pattern moves by per duration cycle in
the X axis. Non-integer values may result in discontinuity when looping.

Default: `1`

### `yScale`

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

### `setPattern(pattern)`

Sets a new pattern, retaining all animation properties.

#### Params

-   **`pattern`:** An array of 8 numbers describing the bitmap for each row, with an optional
    additional 8 for a bitmap alpha channel, as would be supplied to
    `playdate.graphics.setPattern()`.

#### Returns

`nil`

### `setDitherPattern(alpha, ditherType)`

Sets a new dither pattern, retaining all animation properties.

#### Params

-   **`alpha`:**: A value in the range [0, 1] describing the opacity of the dither effect.
-   **`ditherType`:**: A constant as would be passed to `playdate.graphics.setDitherPattern()`, e.g.
    `playdate.graphics.image.kDitherTypeVerticalLine`.

### Returns

`nil`

## Examples

These examples demonstrate the range of pattern animations possible with EasyPattern

### Conveyor Belt

This example utilizes the built-in vertical line dither type to create a simple horizontally
scrolling conveyor belt effect.

```lua
EasyPattern {
    ditherType     = playdate.graphics.image.kDitherTypeVerticalLine,
    xPhaseDuration = 0.5
}
```

### Vertical Bounce

In this example, the pattern appears to fall downward one block at a time, bouncing to a
settled state before the next row drops out.

```lua
EasyPattern {
    pattern        = checkerboard,
    yPhaseDuration = 1.0,
    yPhaseFunction = playdate.easingFunctions.outBounce,
    yReversed      = true,
    scale          = 2
}
```

### Circular Pan

This example makes use of built-in sine functions and an `xPhaseOffset` to create a continuous
circular panning movement.

```lua
EasyPattern {
    pattern        = checkerboard,
    phaseDuration  = 0.5,
    phaseFunction  = playdate.easingFunctions.inOutSine,
    xPhaseOffset   = 0.25, -- half the duration
    reverses       = true,
    scale          = 2
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
    pattern        = checkerboard,
    xPhaseDuration = 3,
    yPhaseDuration = 2,
    xPhaseFunction = function(t, b, c, d) return b + playdate.graphics.perlin(t / d, 2, 3, 4, d, 0.75) * c end,
    yPhaseFunction = function(t, b, c, d) return b + playdate.graphics.perlin(t / d, 5, 6, 7, d, 0.75) * c end,
    scale          = 10
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

## What About Performance?

Playdate is a very capable device, but even relatively simple Lua programs can suffer from
performance issues without adequate optimization. EasyPattern is certainly not the best approach
to animated patterns for performance given the need to calculate phase offsets each frame.
EasyPattern is fantastically useful for quick prototyping, and should work reliably in moderation
for most games. However, if you need additional performance you should consider encoding each
frame of the animated pattern in an `imagetable`.

If you're using EasyPattern to draw sprites and need more performance, you can also use the
[Roto](https://github.com/ebeneliason/roto) utility to export the pattern or the final rendered
sprite(s) as matrix `imagetable` images.

## License

EasyPattern is distributed under the terms of the [MIT License](https://spdx.org/licenses/MIT.html).
