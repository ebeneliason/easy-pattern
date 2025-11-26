import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/easing"

local gfx <const> = playdate.graphics
local geom <const> = playdate.geometry

local PTTRN_SIZE <const> = 8
local CACHE_EXP <const> = 1 / 60 -- max FPS

-- luacheck: ignore 214 (ignore use of variables beginning with underscore)

-- Animated patterns with easing, made easy.
--
--! SAMPLE USAGE
--
--     local checkerboard <const> = { 0xF0, 0xF0, 0xF0, 0xF0, 0x0F, 0x0F, 0x0F, 0x0F }
--     local easyCheckerboard = EasyPattern {
--         pattern  = checkerboard,
--         duration = 1.0,
--         ease     = playdate.easingFunctions.inOutCubic,
--         -- <list any additional animation params here>
--     }
--
--     playdate.graphics.setPattern(easyCheckerboard:apply()) -- in `draw`
--     -- <perform drawing using pattern here>

class('EasyPattern').extends(Object)

--! PARAMETERS

-- Create a new animated EasyPattern.
-- @param params            A table containing one or more of the elements listed below.
--
--                          With the exception of `pattern`, `ditherType`, `alpha`, and `color`
--                          any of these properties may also be set directly on the object at any
--                          time, e.g. `myEasyPattern.xPhaseDuration = 0.5`. (Use `:setPattern()` or
--                          `:setDitherPattern()` to change the pattern itself.)
--
--                          Additionally, when initializing an `EasyPattern`, any of the axis-specific
--                          values may be set for both axes at once by dropping the `x` or `y` prefix,
--                          from the parameter name, e.g. `..., scale = 2, reverses = true, ...`
--
--  PATTERN PROPERTIES
--
--        pattern           The pattern to animate, specified as an array of 8 numbers describing the
--                          bitmap for each row, with an optional additional 8 for a bitmap alpha
--                          channel, as would be supplied to `playdate.graphics.setPattern()`.
--
--        ditherType        A dither type as would be passed to `playdate.graphics.setDitherPattern()`,
--                          e.g. `playdate.graphics.image.kDitherTypeVerticalLine`. This setting only
--                          applies when the `pattern` parameter is omitted or `nil`.
--                          Default: nil.
--
--        alpha             An alpha value for a dither pattern, which can either be the default
--                          Playdate dither effect, or one specified by `ditherType`. This setting only
--                          applies when the `pattern` parameter is omitted or `nil`.
--                          Default 0.5.
--
--        color             The color to use when rendering the dither pattern. This setting only
--                          applies when the `pattern` parameter is omitted or `nil`.
--                          Default: `playdate.graphics.kColorBlack`
--
--        bgColor           The color to use as a background when rendering a dither pattern or a
--                          pattern with an alpha channel.
--                          Default: `playdate.graphics.kColorClear`
--
--        bgPattern         A pattern to render behind the this one. This may be a static pattern as may be
--                          passed for the `pattern` parameter, or another EasyPattern instance.
--
--        inverted          A boolean indicating whether the pattern is inverted, with white pixels appearing
--                          as black and black pixels appearing as white. The alpha channel is not affected.
--
--  ANIMATION PROPERTIES
--
--        xEase             An easing function that defines the animation pattern in the X axis,
--                          following the signature of the `playdate.easingFunctions`.
--                          Default: `playdate.easingFunctions.linear`
--
--        yEase             An easing function that defines the animation pattern in the Y axis,
--                          following the signature of the `playdate.easingFunctions`.
--                          Default: `playdate.easingFunctions.linear`
--
--        xEaseArgs         A list containing any additional args to the X axis easing function, e.g.
--                          to parameterize amplitude, period, overshoot, etc.
--                          Default: {}
--
--        yEaseArgs         A list containing any additional args to the Y axis easing function, e.g.
--                          to parameterize amplitude, period, overshoot, etc.
--                          Default: {}
--
--        xDuration         The duration of the animation in the X axis, in seconds. Omit this param
--                          or set it to 0 to prevent animation in this axis.
--                          Default: 0.
--
--        yDuration         The duration of the animation in the Y axis, in seconds. Omit this param
--                          or set it to 0 to prevent animation in this axis.
--                          Default: 0.
--
--        xOffset           An absolute time offset for the X axis animation, in seconds.
--                          Default: 0.
--
--        xOffset           An absolute time offset for the Y axis animation, in seconds.
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
--  TRANSFORMATIONS
--
--        xShift            The number of pixels to shift the final pattern phase by in the X axis.
--                          Default: 0.
--
--        yShift            The number of pixels to shift the final pattern phase by in the Y axis.
--                          Default: 0.
--
--        xReflected        A boolean indicating whether the entire pattern should be reflected across the
--                          vertical (Y) axis.
--                          Default: false.
--
--        yReflected        A boolean indicating whether the entire pattern should be reflected across the
--                          horizontal (X) axis.
--                          Default: false.
--
--        rotated           A boolean indicating whether the entire pattern should be rotated 90º, producing an
--                          orthogonal result. Rotation is applied following any reflections.
--                          Default: false.
--
--  CALLBACKS
--
--        loopCallback      A function to be called when the pattern loops, taking into account the effective
--                          duration of the animation in each axis including speed and reversal, as well as any
--                          background pattern animations. The `EasyPattern` and total loop count are passed as
--                          parameters to the function.
--                          Default: nil.
--
--        xLoopCallback     A function to be called when the pattern loops in the X axis, taking into account all
--                          considerations noted above. The `EasyPattern` and X loop count are passed as
--                          parameters to the function.
--                          Default: nil.
--
--        yLoopCallback     A function to be called when the pattern loops in the Y axis, taking into account all
--                          considerations noted above. The `EasyPattern` and Y loop count are passed as
--                          parameters to the function.
--                          Default: nil.
--! INIT

function EasyPattern:init(params)
    EasyPattern.super.init(self)

    -- the pattern to be animated
    self.pattern = params.pattern or nil

    -- the alpha value to use when animating a dither pattern (and `pattern` itself is `nil`)
    self.alpha = params.alpha or 0.5

    -- the dither type to use when `pattern` is `nil`
    self.ditherType = params.ditherType or nil

    -- the color to use for the dither pattern when `pattern` is `nil`
    self.color = params.color or gfx.kColorBlack

    -- the color to use for a background for a dither pattern or a pattern with an alpha channel
    self.bgColor = params.bgColor or gfx.kColorClear

    -- a pattern to draw behind this one, which can be static or an EasyPattern instance
    self.bgPattern = params.bgPattern or nil

    -- a boolean indicating whether the pattern is drawn with black and white pixels inverted
    self.inverted = params.inverted or false

    -- OBJECT PROPERTY  | SINGLE AXIS SET        | DUAL AXIS FALLBACK    | DEFAULT VALUE

    -- governs animation duration in both x and y axes in seconds (1 second yields 8FPS, negative numbers reverse)
    self.xDuration      = params.xDuration      or params.duration      or 0
    self.yDuration      = params.yDuration      or params.duration      or 0

    -- legacy duration params
    self.xDuration      = params.xPhaseDuration or params.phaseDuration or self.xDuration
    self.yDuration      = params.yPhaseDuration or params.phaseDuration or self.yDuration

    -- offsets that adjust the relative x and y phases, in seconds; when omitted, both run in the same phase
    self.xOffset        = params.xOffset        or params.offset        or 0
    self.yOffset        = params.yOffset        or params.offset        or 0

    -- legacy offset params
    self.xOffset        = params.xPhaseOffset   or params.phaseOffset   or self.xOffset
    self.yOffset        = params.yPhaseOffset   or params.phaseOffset   or self.yOffset

    -- by default, a linear animation is used; any playdate easing (or API-compatible) function is supported
    self.xEase          = params.xEase          or params.ease          or playdate.easingFunctions.linear
    self.yEase          = params.yEase          or params.ease          or playdate.easingFunctions.linear

    self.xEaseArgs      = params.xEaseArgs      or params.easeArgs      or {}
    self.yEaseArgs      = params.yEaseArgs      or params.easeArgs      or {}

    -- legacy function params
    self.xEase          = params.xPhaseFunction or params.phaseFunction or self.xEase
    self.yEase          = params.yPhaseFunction or params.phaseFunction or self.yEase

    self.xEaseArgs      = params.xPhaseArgs     or params.phaseArgs     or self.xEaseArgs
    self.yEaseArgs      = params.yPhaseArgs     or params.phaseArgs     or self.yEaseArgs

    -- indicates whether the animation reverses when reaching either end
    self.xReverses      = params.xReverses      or params.reverses      or false
    self.yReverses      = params.yReverses      or params.reverses      or false

    -- indicates whether the animation is actively playing in reverse
    self.xReversed      = params.xReversed      or params.reversed      or false
    self.yReversed      = params.yReversed      or params.reversed      or false

    -- a speed multiplier which affects overall speed relative to the specified phase durations
    self.xSpeed         = params.xSpeed         or params.speed         or 1
    self.ySpeed         = params.ySpeed         or params.speed         or 1

    -- a scale multiplier which affects how many 8px texture repetitions are moved by per animation cycle
    self.xScale         = params.xScale         or params.scale         or 1
    self.yScale         = params.yScale         or params.scale         or 1

    -- the number of pixels to shift the final pattern phases by
    self.xShift         = params.xShift         or params.shift         or 0
    self.yShift         = params.yShift         or params.shift         or 0

    -- indicates whether the entire pattern is reflected across the vertical or horizontal axis
    self.xReflected     = params.xReflected     or params.reflected     or false
    self.yReflected     = params.yReflected     or params.reflected     or false

    -- indicates whether the entire pattern is rotated by 90º producing an orthogonal result
    self.rotated        = params.rotated                                or false

    -- registers callback that fire when the pattern loops; loopCallback is distinct, not shorthand for both x and y
    self.loopCallback   = params.loopCallback                           or nil
    self.xLoopCallback  = params.xLoopCallback                          or nil
    self.yLoopCallback  = params.yLoopCallback                          or nil

    -- the previously computed time values for each axis, used to determine when to reverse animations
    self._ptx = 0
    self._pty = 0

    -- the previous phase calculation timestamp, used for caching computed phase offsets
    self._pt = 0

    -- the number of loops run in each axis and overall
    self._xLoops = 0
    self._yLoops = 0
    self._loops  = 0

    -- a flag indicating whether the pattern is dirty and needs to be redrawn
    self._dirty = false

    -- cached phase offset values for each axis
    self._xPhase = 0
    self._yPhase = 0


    -- the pattern image to use for drawing, at twice the pattern size to support looping animation
    self.patternImage = gfx.image.new(PTTRN_SIZE * 2, PTTRN_SIZE * 2)

    -- pre-render the pattern image
    self:_updatePatternImage()
end

--! SETTERS

function EasyPattern:setColor(color)
    self.color = color
    self:_updatePatternImage()
end

function EasyPattern:setBackgroundColor(color)
    self.bgColor = color
    self:_updatePatternImage()
end

function EasyPattern:setBackgroundPattern(pattern)
    self.bgPattern = pattern
    self:_updatePatternImage()
end

function EasyPattern:setPattern(pattern)
    self.pattern = pattern
    self:_updatePatternImage()
end

function EasyPattern:setDitherPattern(alpha, ditherType)
    self.alpha = alpha
    self.ditherType = ditherType
    self.pattern = nil
    self:_updatePatternImage()
end

function EasyPattern:setInverted(inverted)
    self.inverted = inverted
    self:_updatePatternImage()
end

function EasyPattern:setRotated(flag)
    self.rotated = flag
    self._pt = 0 -- invalidate cache
    self:_updatePatternImage()
    self:getPhases()
end

function EasyPattern:setReflected(horizontal, vertical)
    if vertical == nil then vertical = horizontal end
    self.xReflected = horizontal
    self.yReflected = vertical
    self._pt = 0 -- invalidate cache
    self:_updatePatternImage()
    self:getPhases()
end

function EasyPattern:_updatePatternImage()
    self.patternImage:clear(self.bgColor)

    -- draw the pattern image
    gfx.pushContext(self.patternImage)
        -- draw the background pattern first
        if self.bgPattern then
            if self.bgPattern.apply then
                self.bgPattern:setPhaseShifts(-self._xPhase, -self._yPhase) -- must subtract our own phase!
                gfx.setPattern(self.bgPattern:apply())
            else
                gfx.setPattern(self.bgPattern, -self.xPhase, -self.yPhase)
            end
            gfx.fillRect(0, 0, PTTRN_SIZE * 2, PTTRN_SIZE * 2)
        end
        -- draw our own pattern second
        gfx.setColor(self.color)
        if self.pattern then
            gfx.setPattern(self.pattern)
        elseif self.ditherType then
            gfx.setDitherPattern(self.alpha, self.ditherType)
        else
            gfx.setDitherPattern(self.alpha)
        end
        gfx.fillRect(0, 0, PTTRN_SIZE * 2, PTTRN_SIZE * 2)
    gfx.popContext()

    -- invert as needed
    if self.inverted then
        gfx.pushContext(self.patternImage)
            gfx.setImageDrawMode(gfx.kDrawModeInverted)
            self.patternImage:draw(0, 0)
        gfx.popContext()
    end

    -- apply any transformations to our pattern image
    if self.rotated or self.xReflected or self.yReflected then
        local xform = geom.affineTransform.new()
        if self.xReflected then xform:scale(-1, 1) end
        if self.yReflected then xform:scale(1, -1) end
        if self.rotated then xform:rotate(90) end
        self.patternImage = self.patternImage:transformedImage(xform)
    end
end

-- set phase shifts which offset the pattern
function EasyPattern:setPhaseShifts(xShift, _yShift)
    self.xShift = xShift
    self.yShift = _yShift or xShift
    self._pt = 0 -- invalidate cache
    local _, _, dirty = self:getPhases()
    return dirty
end

-- a convenience function for adjusting the phases by the specified offset from current values
function EasyPattern:shiftPhasesBy(xShift, _yShift)
    self.xShift += xShift
    self.yShift += _yShift or xShift
    self._pt = 0 -- invalidate cache
    local _, _, dirty = self:getPhases()
    return dirty
end

-- this exists primarily to enable mocking in tests
function EasyPattern:_getTime() -- luacheck: ignore
    return playdate.getCurrentTimeMilliseconds() / 1000
end

local function gcd(a, b)
    while b ~= 0 do a, b = b, a % b end
    return a
end

local function lcm(a, b)
    if a == 0 or b == 0 then
        return math.max(a, b) -- technically 0, but for our purposes we want the non-zero value if there is one
    end
    return math.abs(a * b) / gcd(a, b)
end

--! GETTERS

function EasyPattern:getLoopDuration()
    -- compute our own total duration
    local duration = lcm(self:getXLoopDuration(), self:getYLoopDuration())
    -- consider any background pattern duration
    local bgDuration = (self.bgPattern and self.bgPattern.getLoopDuration) and self.bgPattern:getLoopDuration() or 0
    return lcm(duration, bgDuration)
end

function EasyPattern:getXLoopDuration()
    -- compute our own X duration
    local duration = self.xDuration * (self.xReverses and 2 or 1) / self.xSpeed
    -- consider any background pattern X duration
    local bgDuration = (self.bgPattern and self.bgPattern.getXLoopDuration) and self.bgPattern:getXLoopDuration() or 0
    return lcm(duration, bgDuration)
end

function EasyPattern:getYLoopDuration()
    -- compute our own total duration
    local duration = self.yDuration * (self.yReverses and 2 or 1) / self.ySpeed
    -- consider any background pattern Y duration
    local bgDuration = (self.bgPattern and self.bgPattern.getYLoopDuration) and self.bgPattern:getYLoopDuration() or 0
    return lcm(duration, bgDuration)
end

--! PHASE COMPUTATION

function EasyPattern:getPhases()
    -- all patterns animate with respect to absolute time
    local t = self:_getTime()

    -- use the cached values if they were computed recently enough
    if t - self._pt < CACHE_EXP then
        return self._xPhase, self._yPhase, false
    end

    -- calculate the effective time param for each axis accounting for offsets, speed scaling, and looping
    local tx = (t * self.xSpeed + self.xOffset) % self.xDuration
    local ty = (t * self.ySpeed + self.yOffset) % self.yDuration

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
    local xPhase = (self.xDuration > 0 and self.xEase)
        and self.xEase(tx, 0, PTTRN_SIZE, self.xDuration, table.unpack(self.xEaseArgs))
                * self.xScale % PTTRN_SIZE // 1
        or 0

    local yPhase = (self.yDuration > 0 and self.yEase)
        and self.yEase(ty, 0, PTTRN_SIZE, self.yDuration, table.unpack(self.yEaseArgs))
                * self.yScale % PTTRN_SIZE // 1
        or 0

    -- flip the output values when in reverse animation mode
    if self.xReversed then xPhase = PTTRN_SIZE - xPhase - 1 end
    if self.yReversed then yPhase = PTTRN_SIZE - yPhase - 1 end

    -- apply any phase shifts
    if self.xShift ~= 0 then
        xPhase = (xPhase + self.xShift) % PTTRN_SIZE
    end
    if self.yShift ~= 0 then
        yPhase = (yPhase + self.yShift) % PTTRN_SIZE
    end

    -- apply any transformations
    if self.xReflected then
        xPhase = PTTRN_SIZE - xPhase - 1
    end
    if self.yReflected then
        yPhase = PTTRN_SIZE - yPhase - 1
    end
    if self.rotated then
        xPhase, yPhase = yPhase, xPhase
    end

    -- determine if we're dirty and cache the computed phase values along with a timestamp
    self._isDirty = xPhase ~= self._xPhase or yPhase ~= self._yPhase
    self._xPhase = xPhase
    self._yPhase = yPhase
    self._pt = t

    -- update background if either we or it changed
    if self.bgPattern then
        if self._isDirty or (self.bgPattern.isDirty ~= nil and self.bgPattern:isDirty()) then
            self:_updatePatternImage()
            self._isDirty = true
        end
    end

    -- call loop callbacks if defined
    if self.xLoopCallback then
        local xld = self:getXLoopDuration()
        local xLoops = (t + self.xOffset%xld) / xld // 1
        if xLoops > self._xLoops then
            self.xLoopCallback(self, xLoops)
            self._xLoops = xLoops
        end
    end
    if self.yLoopCallback then
        local yld = self:getYLoopDuration()
        local yLoops = (t + self.yOffset%yld) / yld // 1
        if yLoops > self._yLoops then
            self.yLoopCallback(self, yLoops)
            self._yLoops = yLoops
        end
    end
    if self.loopCallback then
        local loops = (t / self:getLoopDuration()) // 1
        if loops > self._loops then
            self.loopCallback(self, loops)
            self._loops = loops
        end
    end

    -- return the newly computed phase offsets and indicate whether they have changed
    return xPhase, yPhase, self._isDirty
end

function EasyPattern:isDirty()
    local _, _, dirty = self:getPhases()
    self._isDirty = self._isDirty or dirty
    return self._isDirty
end

function EasyPattern:apply()
    local xPhase, yPhase = self:getPhases()
    self._isDirty = false
    -- return a 3-tuple to be used as arguments to `playdate.graphics.setPattern()`
    return self.patternImage, xPhase, yPhase
end

--! BIT PATTERN

-- This masquerades as a companion class to EasyPattern, but in reality it's just a convenience
-- function which returns a table of numbers converted from their binary string representations.
-- Use it to craft patterns to pass to EasyPattern or to `playdate.graphics.setPattern`.
-- Represent black pixels with a 0, a period (.), or an underscore (_); represent white pixels
-- with any other character, such as a 1 or an X. Any spaces within the string are ignored.
--
-- For example, here's how to define an opaque BitPattern in binary:

-- local checker = BitPattern {
--     '11110000',
--     '11110000',
--     '11110000',
--     '11110000',
--     '00001111',
--     '00001111',
--     '00001111',
--     '00001111',
-- }

-- And here's that same pattern in ASCII:
--
-- local checker = BitPattern {
--     ' X X X X . . . . ',
--     ' X X X X . . . . ',
--     ' X X X X . . . . ',
--     ' X X X X . . . . ',
--     ' . . . . X X X X ',
--     ' . . . . X X X X ',
--     ' . . . . X X X X ',
--     ' . . . . X X X X ',
-- }
--
-- When including an alpha channel, interleave its rows with the pattern rows such that the
-- pattern and alpha channel representations appear side-by-side in the file, like so:
--
-- local ditheredDiamond = BitPattern {
--     -- PTTRN ----------   -- ALPHA ---------
--     ' X . X . X . X . ',  ' . . . X . . . . ',
--     ' . X . X . X . X ',  ' . . X X X . . . ',
--     ' X . X . X . X . ',  ' . X X X X X . . ',
--     ' . X . X . X . X ',  ' X X X X X X X . ',
--     ' X . X . X . X . ',  ' . X X X X X . . ',
--     ' . X . X . X . X ',  ' . . X X X . . . ',
--     ' X . X . X . X . ',  ' . . . X . . . . ',
--     ' . X . X . X . X ',  ' . . . . . . . . ',
-- }

function BitPattern(binaryRows)
    local hasAlpha = #binaryRows == 16
    local pattern = {}
    for i, binaryRow in ipairs(binaryRows) do
        binaryRow = binaryRow:gsub(".", function(c)
            if c == " " then return ""                               -- strip spaces
            elseif c == "0" or c == "." or c == "_" then return "0"  -- black pixels
            else return "1"                                          -- white pixels (any other char)
            end
        end)
        if hasAlpha then
            pattern[i//2 + (i % 2 == 0 and 8 or 1)] = tonumber(binaryRow, 2) -- de-interlace alpha
        else
            pattern[i] = tonumber(binaryRow, 2)
        end
    end
    return pattern
end
