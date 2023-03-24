import "CoreLibs/object"
import "CoreLibs/graphics"

local gfx <const> = playdate.graphics

local PTTRN_SIZE <const> = 8

-- Animated patterns with easing, made easy.
--
-- SAMPLE USAGE: 
--
--     local checkerboard = {0xF0F0, 0xF0F0, 0xF0F0, 0xF0F0, 0x0F0F, 0x0F0F, 0x0F0F, 0x0F0F}
--     local easyCheckerboard = EasyPattern {
--         pattern       = checkerboard,
--         phaseDuration = 1.0,
--         phaseFunction = playdate.easingFunctions.inOutCubic,
--         -- <list any additional animation params here>
--     }
--
--     playdate.graphics.setPattern(easyCheckerboard:apply()) -- in `draw`

class('EasyPattern').extends(object)

-- Create a new animated EasyPattern.
-- @param params            A table containing one or more of the elements listed below.
--
--                          With the exception of `pattern`, `alpha`, and `ditherType`, any
--                          of these properties may also be set directly on the object at any
--                          time, e.g. `myEasyPattern.xPhaseDuration = 0.5`. (Use `:setPattern()` or
--                          `:setDitherPattern()` to change the pattern itself.)
--
--                          Additionally, when initilizing an `EasyPattern`, any of the axis-specific
--                          values may be set for both axes at once by dropping the `x` or `y` prefix,
--                          from the parameter name, e.g. `..., scale = 2, reverses = true, ...`
--
--        pattern           The pattern to animate, specified as an array of 8 numbers describing the
--                          bitmap for each row, with an optional additional 8 for a bitmap alpha
--                          channel, as would be supplied to `playdate.graphics.setPattern()`.
--
--        alpha             An alpha value for a dither pattern, which can either be the default
--                          Playdate dither effect, or one specified by `ditherType`. This setting only
--                          applies when the `pattern` parameter is omitted or `nil`.
--                          Default 0.5.
--
--        ditherType        A dither type as would be passed to `playdate.graphics.setDitherPattern()`,
--                          e.g. `playdate.graphics.image.kDitherTypeVerticalLine`. This setting only
--                          applies when the `pattern` parameter is omitted or `nil`.
--                          Default: nil.
--
--        xPhaseFunction    An easing function that defines the animation pattern in the X axis,
--                          following the signature of the `playdate.easingFunctions`.
--                          Default: `playdate.easingFunctions.linear`
--
--        yPhaseFunction    An easing function that defines the animation pattern in the Y axis,
--                          following the signature of the `playdate.easingFunctions`.
--                          Default: `playdate.easingFunctions.linear`
--
--        xPhaseArgs        A list containing any additional args to the X axis easing function, e.g.
--                          to parameterize amplitude, period, overshoot, etc.
--                          Default: {}
--
--        yPhaseArgs        A list containing any additional args to the Y axis easing function, e.g.
--                          to parameterize amplitude, period, overshoot, etc.
--                          Default: {}
--
--        xPhaseDuration    The duration of the animation in the X axis, in seconds. Omit this param
--                          or set it to 0 to prevent animation in this axis.
--                          Default: 0.
--
--        yPhaseDuration    The duration of the animation in the Y axis, in seconds. Omit this param
--                          or set it to 0 to prevent animation in this axis.
--                          Default: 0.
--
--        xPhaseOffset      An asbolute time offset for the X axis animation (relative to Y), in seconds.
--                          Default: 0.
--
--        xPhaseOffset      An asbolute time offset for the Y axis animation (relative to X), in seconds.
--                          Default: 0.
--
--        xReverses         A boolean indicating whether the X axis animation reverses at each end.
--                          Default: false.
--
--        yReverses         A boolean indicating whether the Y axis animation reverses at each end.
--                          Default: false.
--
--        xReversed         A boolean indicating whether the X axis animation is playing in reverse.
--                          May be set manually, and also updates automatically when `xReverses` is `true`.
--                          Default: false.
--
--        yReversed         A boolean indicating whether the Y axis animation is playing in reverse.
--                          May be set manually, and also updates automatically when `yReverses` is `true`.
--                          Default: false.
--
--        xSpeed            A multiplier for the overall speed of the animation in the X axis, relative
--                          to the timings specified for its duration and offset.
--                          Default: 1.
--
--        ySpeed            A multiplier for the overall speed of the animation in the Y axis, relative
--                          to the timings specified for its duration and offset.
--                          Default: 1.
--
--        xScale            A multiplier describing the number of 8px repetitions the pattern moves by
--                          per cycle in the X axis. Non-integer values result in discontinuity when looping.
--                          Default: 1.
--
--        yScale            A multiplier describing the number of 8px repetitions the pattern moves by
--                          per cycle in the Y axis. Non-integer values result in discontinuity when looping.
--                          Default: 1.
--


function EasyPattern:init(params)
    EasyPattern.super.init(self)

    -- the pattern to be animated
    self.pattern = params.pattern or nil

    -- the alpha value to use when animating a dither pattern (and `pattern` itself is `nil`)
    self.alpha = params.alpha or 0.5

    -- the dither type to use when `pattern` is `nil`
    self.ditherType = params.ditherType or nil


    -- OBJECT PROPERTY  | SINGLE AXIS SET        | DUAL AXIS FALLBACK    | DEFAULT VALUE

    -- governs animation duration in both x nd y axes in sseconds (1 second yields 8FPS, negative numbers reverse)
    self.xPhaseDuration = params.xPhaseDuration or params.phaseDuration or 0
    self.yPhaseDuration = params.yPhaseDuration or params.phaseDuration or 0

    -- offsets that adjust the relative x and y phases, in seconds; when omitted, both run in the same phase
    self.xPhaseOffset   = params.xPhaseOffset   or params.phaseOffset   or 0
    self.yPhaseOffset   = params.yPhaseOffset   or params.phaseOffset   or 0

    -- by default, a linear animation is used; any playdate easing (or API-compatible) function is supported
    self.xPhaseFunction = params.xPhaseFunction or params.phaseFunction or playdate.easingFunctions.linear
    self.yPhaseFunction = params.yPhaseFunction or params.phaseFunction or playdate.easingFunctions.linear

    self.xPhaseArgs     = params.xPhaseArgs     or params.phaseArgs     or {}
    self.yPhaseArgs     = params.yPhaseArgs     or params.phaseArgs     or {}

    -- indicates whether the animation reverses when reaching either end
    self.xReverses      = params.xReverses      or params.reverses      or false
    self.yReverses      = params.yReverses      or params.reverses      or false

    -- indicates whether the animation is actively playing in reverse
    self.xReversed      = params.xReversed      or params.reversed      or false
    self.yReversed      = params.yReversed      or params.reversed      or false

    -- a speed mutlipler which affects overall speed relative to the specified phase durations
    self.xSpeed         = params.xSpeed         or params.speed         or 1
    self.ySpeed         = params.ySpeed         or params.speed         or 1

    -- a scale mutlipler which affects how many 8px texture repetitions are moved by per animation cycle
    self.xScale         = params.xScale         or params.scale         or 1
    self.yScale         = params.yScale         or params.scale         or 1

    -- the previously computed time values for each axis, used to determine when to reverse animations
    self._ptx = 0
    self._pty = 0

    -- the pattern image to use for drawing, at twice the pattern size to support looping animation
    self.patternImage = gfx.image.new(PTTRN_SIZE * 2, PTTRN_SIZE * 2)

    -- pre-render the pattern image
    self:updatePatternImage()
end

function EasyPattern:setPattern(pattern)
    self.pattern = pattern
    self:updatePatternImage()
end

function EasyPattern:setDitherPattern(alpha, ditherType)
    self.alpha = alpha
    self.ditherType = ditherType
    self.pattern = nil
    self:updatePatternImage()
end

function EasyPattern:updatePatternImage()
    self.patternImage:clear(gfx.kColorWhite)
    gfx.pushContext(self.patternImage)
        gfx.setColor(gfx.kColorBlack)
        if self.pattern then
            gfx.setPattern(self.pattern)
        else
            gfx.setDitherPattern(self.alpha, self.ditherType)
        end
        gfx.fillRect(0, 0, PTTRN_SIZE * 2, PTTRN_SIZE * 2)
    gfx.popContext()
end

function EasyPattern:apply()
    -- all patterns animate with respect to absolute time
    local t = playdate.getCurrentTimeMilliseconds() / 1000

    -- calculate the effective time param for each axis accounting for offsets, speed scaling, and looping
    tx = (t * self.xSpeed + self.xPhaseOffset) % self.xPhaseDuration
    ty = (t * self.ySpeed + self.yPhaseOffset) % self.yPhaseDuration

    -- handle animation reversal when crossing the animation duration bounds
    if self.xReverses and self._ptx > tx then
        self.xReversed = not self.xReversed
    end
    self._ptx = tx

    if self.yReverses and self._pty > ty then
        self.yReversed = not self.yReversed
    end
    self._pty = ty

    -- compute the resulting phase offsets, mod 8 to fit within our pattern texture
    local xPhase = (self.xPhaseDuration > 0 and self.xPhaseFunction)
        and self.xPhaseFunction(tx, 0, PTTRN_SIZE, self.xPhaseDuration, table.unpack(self.xPhaseArgs)) * self.xScale % PTTRN_SIZE // 1
        or 0

    local yPhase = (self.yPhaseDuration > 0 and self.yPhaseFunction)
        and self.yPhaseFunction(ty, 0, PTTRN_SIZE, self.yPhaseDuration, table.unpack(self.yPhaseArgs)) * self.yScale % PTTRN_SIZE // 1
        or 0

    -- flip the output values when in reverse animation mode
    if self.xReversed then xPhase = PTTRN_SIZE - xPhase end
    if self.yReversed then yPhase = PTTRN_SIZE - yPhase end

    -- return a 3-tuple to be used as arguments to `playdate.graphics.setPattern()`
    return self.patternImage, xPhase, yPhase
end
