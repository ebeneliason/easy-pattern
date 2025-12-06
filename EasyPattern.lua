import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/easing"

local gfx <const> = playdate.graphics
local geom <const> = playdate.geometry

local PTTRN_SIZE <const> = 8
local CACHE_EXP <const> = 1 / 60 -- max FPS

local checkerboard <const> = { 0xF0, 0xF0, 0xF0, 0xF0, 0x0F, 0x0F, 0x0F, 0x0F }

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
--                          With the exception of `pattern` and `bgPattern`, these properties may also be
--                          set directly on an `EasyPattern` instance at any time, e.g.
--                          `myEasyPattern.xDuration = 0.5`. (Use `:setPattern()` or `:setBackgroundPattern()`
--                          to change the pattern itself.)
--
--                          Additionally, when initializing an `EasyPattern`, any of the axis-specific
--                          values may be set for both axes at once by dropping the `x` or `y` prefix,
--                          from the parameter name, e.g. `..., scale = 2, reverses = true, ...`
--
--  PATTERN PROPERTIES
--
--        pattern           The pattern to animate, specified in one of the following formats:
--                           1. An array of 8 numbers describing the bitmap for each row, with an optional
--                              additional 8 for a bitmap alpha channel, as would be supplied to
--                              `playdate.graphics.setPattern()`
--                           2. A table containing an `alpha` value, `ditherType` (as would be passed to
--                              `playdate.graphics.setDitherPattern()`, e.g.
--                              `playdate.graphics.image.kDitherTypeVerticalLine`), and an optional `color`
--                              value in which to render the dither (e.g. `playdate.graphics.kColorWhite`)
--                           3. An 8x8 pixel `playdate.graphics.image`
--                           4. An 8x8 pixel `playdate.graphics.imagetable` (see also: `tickDuration`)
--                          Default: checkerboard.
--
--        bgPattern         A pattern to render behind the this one. This may be a any static pattern as may be
--                          passed for the `pattern` parameter, or another `EasyPattern` instance.
--
--        bgColor           The color to use as a background. This is especially useful when specifying a
--                          pattern using `alpha` and `ditherType`, but may be used with any transparent pattern.
--                          Default: `playdate.graphics.kColorClear`
--
--        alpha             An alpha value representing the opacity at which to render the pattern.
--                          Default 1.0.
--
--        ditherType        A dither type as would be passed to `playdate.graphics.setDitherPattern()`,
--                          e.g. `playdate.graphics.image.kDitherTypeVerticalLine`, to use when the pattern
--                          is rendered at partial opacity with an alpha value less than 1.
--                          Default: `playdate.graphics.image.kDitherTypeBayer8x8`.
--
--        inverted          A boolean indicating whether the pattern is inverted, with white pixels appearing
--                          as black and black pixels appearing as white. The alpha channel is not affected.
--
--        tickDuration      The duration of each tick, in seconds, used to dictate advancement when the pattern
--                          and/or background pattern is specified as an `imagetable`.
--                          Default: The target FPS, i.e. `1 / playdate.display.getRefreshRate()`
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
--  TRANSFORMATION PROPERTIES
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
--
--        update            A function to be called immediately before new phases are calculated. The `EasyPattern`
--                          and the current time are passed as parameters to the function. This can be used to
--                          dynamically update the pattern in response to inputs or game state.
--                          Default: nil.

--! INIT

function EasyPattern:init(params)
    EasyPattern.super.init(self)

    -- CORE PATTERN PROPERTIES

    -- the overall opacity value
    self.alpha = params.alpha or 1

    -- the dither type used when opacity is less than 1
    self.ditherType = params.ditherType or gfx.image.kDitherTypeBayer8x8

    -- the color to use as a background behind the provided pattern
    self.bgColor = params.bgColor or gfx.kColorClear

    -- a boolean indicating whether the pattern is drawn with black and white pixels inverted
    self.inverted = params.inverted or false

    -- tick duration used when pattern and/or background pattern is an `imagetable`
    self.tickDuration = params.tickDuration or 1 / playdate.display.getRefreshRate()

    -- custom update function
    self.update = params.update or nil


    -- OBJECT PROPERTY  | SINGLE AXIS SET        | DUAL AXIS FALLBACK    | DEFAULT VALUE

    -- governs animation duration in both x and y axes in seconds (1 second yields 8FPS, negative numbers reverse)
    self.xDuration      = params.xDuration      or params.duration      or 0
    self.yDuration      = params.yDuration      or params.duration      or 0

    -- offsets that adjust the relative x and y phases, in seconds; when omitted, both run in the same phase
    self.xOffset        = params.xOffset        or params.offset        or 0
    self.yOffset        = params.yOffset        or params.offset        or 0

    -- by default, a linear animation is used; any playdate easing (or API-compatible) function is supported
    self.xEase          = params.xEase          or params.ease          or playdate.easingFunctions.linear
    self.yEase          = params.yEase          or params.ease          or playdate.easingFunctions.linear

    self.xEaseArgs      = params.xEaseArgs      or params.easeArgs      or {}
    self.yEaseArgs      = params.yEaseArgs      or params.easeArgs      or {}

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

    -- previously recorded tick value
    self._ptick = 0

    -- the pattern image to use for drawing, at twice the pattern size to support looping animation
    self._patternImage = gfx.image.new(PTTRN_SIZE * 2, PTTRN_SIZE * 2) -- the raw, non-composited pattern image
    self.compositePatternImage = gfx.image.new(PTTRN_SIZE * 2, PTTRN_SIZE * 2) -- scratch for rendering alpha
    self._compositePatternImage = gfx.image.new(PTTRN_SIZE * 2, PTTRN_SIZE * 2) -- final composited pattern

    -- lastly, initialize the provided pattern(s)
    self:setPattern(params.pattern or checkerboard)
    self:setBackgroundPattern(params.bgPattern)
end

--! SETTERS

function EasyPattern:setPattern(a, b, c)
    if not a then a = checkerboard end -- restore default if set to `nil`
    self:_resetPatternProperties()
    self:_setPattern(self._patternImage, a, b, c)
end

function EasyPattern:setBackgroundPattern(a, b, c)
    self:_resetBackgroundProperties()
    -- allow removal of the background pattern
    if not a then
        self._bgPatternImage = nil
        self:_updateCompositePatternImage()
        return
    end
    self:_setPattern(self._bgPatternImage, a, b, c)
end

function EasyPattern:_setPattern(img, a, b, c)
    if type(a) == "number" then
        self:_setDitherPattern(img, b or 0.5, a, c)
    elseif getmetatable(a) == gfx.imagetable then
        self:_setPatternImageTable(img, a, b or self.tickDuration)
    elseif getmetatable(a) == gfx.image then
        self:_setPatternImage(img, a)
    elseif getmetatable(a) == EasyPattern then
        if img == self._bgPatternImage then
            self:setBackgroundEasyPattern(a)
        else
            print("ERROR: EasyPatterns may only be set as a background pattern")
        end
    elseif #a == 8 or #a == 16 then
        self:_setBitPattern(img, a)
    elseif a.alpha or a.ditherType then
        self:_setPattern(img, a.ditherType, a.alpha or 0.5, a.color)
    else
        print("ERROR: Invalid pattern definition")
    end
end

function EasyPattern:setBitPattern(pattern)
    self:_resetPatternProperties()
    self:_setBitPattern(self._patternImage, pattern)
end

function EasyPattern:setBackgroundBitPattern(pattern)
    self:_resetBackgroundProperties()
    self:_setBitPattern(self._bgPatternImage, pattern)
end

function EasyPattern:_setBitPattern(img, pattern)
    if img == self._patternImage then
        self.pattern = pattern
    else
        self.bgPattern = pattern
    end
    img:clear(gfx.kColorClear)
    gfx.pushContext(img)
        gfx.setPattern(pattern)
        gfx.fillRect(0, 0, PTTRN_SIZE * 2, PTTRN_SIZE * 2)
    gfx.popContext()
    self:_updateCompositePatternImage()
end

function EasyPattern:setDitherPattern(alpha, ditherType, color)
    self:_resetPatternProperties()
    self:_setDitherPattern(self._patternImage, alpha, ditherType, color)
end

function EasyPattern:setBackgroundDitherPattern(alpha, ditherType, color)
    self:_resetBackgroundProperties()
    self:_setDitherPattern(self._bgPatternImage, alpha, ditherType, color)
end

function EasyPattern:_setDitherPattern(img, alpha, ditherType, color)
    img:clear(gfx.kColorClear)
    gfx.pushContext(img)
        gfx.setColor(color or gfx.kColorBlack)
        gfx.setDitherPattern(alpha, ditherType or gfx.image.kDitherTypeBayer8x8)
        gfx.fillRect(0, 0, PTTRN_SIZE * 2, PTTRN_SIZE * 2)
    gfx.popContext()
    self:_updateCompositePatternImage()
end

function EasyPattern:setPatternImage(img)
    self:_resetPatternProperties()
    self:_setPatternImage(self._patternImage, img)
end

function EasyPattern:setBackgroundPatternImage(img)
    self:_resetBackgroundProperties()
    self:_setPatternImage(self._bgPatternImage, img)
end

function EasyPattern:_setPatternImage(img, patternImg)
    img:clear(gfx.kColorClear)
    gfx.pushContext(img)
        patternImg:draw(0, 0)
        patternImg:draw(0, PTTRN_SIZE)
        patternImg:draw(PTTRN_SIZE, 0)
        patternImg:draw(PTTRN_SIZE, PTTRN_SIZE)
    gfx.popContext()
    self:_updateCompositePatternImage()
end

function EasyPattern:setPatternImageTable(imageTable, tickDuration)
    self:_resetPatternProperties()
    self:_setPatternImageTable(self._patternImage, imageTable, tickDuration or self.tickDuration)
end

function EasyPattern:setBackgroundPatternImageTable(imageTable, tickDuration)
    self:_resetBackgroundProperties()
    self:_setPatternImageTable(self._bgPatternImage, imageTable, tickDuration or self.tickDuration)
end

function EasyPattern:_setPatternImageTable(img, imageTable, tickDuration)
    if img == self._patternImage then
        self._patternTable = imageTable
    else
        self._bgPatternTable = imageTable
    end
    self.tickDuration = tickDuration
    local frame = (self:_getTime() // tickDuration) % imageTable:getLength() + 1
    self:_setPatternImage(img, imageTable:getImage(frame))
end

function EasyPattern:setBackgroundEasyPattern(pattern)
    self:_resetBackgroundProperties()
    self._bgEasyPattern = pattern
    self:_updateCompositePatternImage()
end

function EasyPattern:_resetPatternProperties()
    self.pattern = nil
    self._patternTable = nil
end

function EasyPattern:_resetBackgroundProperties()
    self.bgPattern = nil
    self._bgPatternTable = nil
    self._bgPatternImage = nil
    self._bgEasyPattern = nil
    if not self._bgPatternImage then
        self._bgPatternImage = gfx.image.new(PTTRN_SIZE * 2, PTTRN_SIZE * 2)
    end
end

function EasyPattern:_updateCompositePatternImage()
    -- clear to background color
    self.compositePatternImage:clear(self.bgColor)

    -- draw the pattern
    gfx.pushContext(self.compositePatternImage)
        -- draw the background pattern first, negating our own phase shift
        if self._bgEasyPattern then
            self._bgEasyPattern:setPhaseShifts(-self._xPhase, -self._yPhase)
            gfx.setPattern(self._bgEasyPattern:apply())
            gfx.fillRect(0, 0, PTTRN_SIZE * 2, PTTRN_SIZE * 2)
        elseif self._bgPatternImage then
            gfx.setPattern(self._bgPatternImage, -self._xPhase % PTTRN_SIZE, -self._yPhase % PTTRN_SIZE)
            gfx.fillRect(0, 0, PTTRN_SIZE * 2, PTTRN_SIZE * 2)
        end
        -- draw our own pattern next
        self._patternImage:draw(0, 0)
    gfx.popContext()

    -- invert as needed
    if self.inverted then
        gfx.pushContext(self.compositePatternImage)
            gfx.setImageDrawMode(gfx.kDrawModeInverted)
            self.compositePatternImage:draw(0, 0)
        gfx.popContext()
    end

    -- apply any transformations to our pattern image
    if self.rotated or self.xReflected or self.yReflected then
        local xform = geom.affineTransform.new()
        if self.xReflected then xform:scale(-1, 1) end
        if self.yReflected then xform:scale(1, -1) end
        if self.rotated then xform:rotate(90) end
        self.compositePatternImage = self.compositePatternImage:transformedImage(xform)
    end

    -- apply transparency
    if self.alpha < 1 then
        gfx.pushContext(self.compositePatternImage)
            gfx.setPattern(self.compositePatternImage, self._xPhase, self._yPhase)
            gfx.fillRect(0, 0, PTTRN_SIZE * 2, PTTRN_SIZE * 2)
        gfx.popContext()
        self._compositePatternImage:clear(gfx.kColorClear)
        gfx.pushContext(self._compositePatternImage)
            self.compositePatternImage:drawFaded(0, 0, self.alpha, self.ditherType)
        gfx.popContext()
        self.compositePatternImage:clear(gfx.kColorClear)
        gfx.pushContext(self.compositePatternImage)
            gfx.setPattern(self._compositePatternImage, -self._xPhase%8, -self._yPhase%8)
            gfx.fillRect(0, 0, PTTRN_SIZE * 2, PTTRN_SIZE * 2)
        gfx.popContext()
    end

    -- clear the flag to indicate we're up-to-date
    self._needsCompositePatternUpdate = false
    -- we need to redraw any time our pattern updates
    self._isDirty = true
end

function EasyPattern:setBackgroundColor(color)
    if self.bgColor == color then return end
    self.bgColor = color
    self:_updateCompositePatternImage()
end

function EasyPattern:setAlpha(alpha, ditherType)
    if self.alpha == alpha and (ditherType == nil or self.ditherType == ditherType) then return end
    self.alpha = alpha
    self.ditherType = ditherType or self.ditherType or gfx.image.kDitherTypeBayer8x8
    self:_updateCompositePatternImage()
end

function EasyPattern:setInverted(inverted)
    if self.inverted == inverted then return end
    self.inverted = inverted
    self:_updateCompositePatternImage()
end

function EasyPattern:setRotated(flag)
    if self.rotated == flag then return end
    self.rotated = flag
    self._pt = 0 -- invalidate cache
    self:_updateCompositePatternImage()
    self:getPhases()
end

function EasyPattern:setReflected(horizontal, vertical)
    if vertical == nil then vertical = horizontal end
    if self.xReflected == horizontal and self.yReflected == vertical then return end
    self.xReflected = horizontal
    self.yReflected = vertical
    self._pt = 0 -- invalidate cache
    self:_updateCompositePatternImage()
    self:getPhases()
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


--! GETTERS

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

function EasyPattern:getLoopDuration()
    -- compute our own total duration
    local duration = lcm(self:getXLoopDuration(), self:getYLoopDuration())
    -- consider any background pattern duration
    local bgDuration = self._bgEasyPattern and self._bgEasyPattern:getLoopDuration() or 0
    return lcm(duration, bgDuration)
end

function EasyPattern:getXLoopDuration()
    -- compute our own X duration
    local duration = self.xDuration * (self.xReverses and 2 or 1) / self.xSpeed
    -- consider any background pattern X duration
    local bgDuration = self._bgEasyPattern and self._bgEasyPattern:getXLoopDuration() or 0
    return lcm(duration, bgDuration)
end

function EasyPattern:getYLoopDuration()
    -- compute our own total duration
    local duration = self.yDuration * (self.yReverses and 2 or 1) / self.ySpeed
    -- consider any background pattern Y duration
    local bgDuration = self._bgEasyPattern and self._bgEasyPattern:getYLoopDuration() or 0
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

    -- give our update function a chance to make any changes
    if self.update then self:update(t) end

    -- calculate the effective time param for each axis accounting for offsets, speed scaling, and looping
    local tx = self.xDuration > 0 and (t * self.xSpeed + self.xOffset) % self.xDuration or 0
    local ty = self.yDuration > 0 and (t * self.ySpeed + self.yOffset) % self.yDuration or 0

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

    -- determine if we're dirty and cache the computed phase values along with a timestamp, while
    -- preserving an already-dirty state that may have resulted from an external change to the pattern itself
    self._isDirty = self._isDirty or (xPhase ~= self._xPhase or yPhase ~= self._yPhase)
    self._xPhase = xPhase
    self._yPhase = yPhase
    self._pt = t

    self._needsCompositePatternUpdate = false

    -- update background if either we or it changed
    if self._bgEasyPattern or self._bgPatternImage then
        if self._isDirty or (self._bgEasyPattern and self._bgEasyPattern:isDirty()) then
            self._needsCompositePatternUpdate = true
            self._isDirty = true
        end
    end

    -- update the pattern if we're semi-transparent to ensure the transparency mask remains fixed
    if self._isDirty and (self.xDuration > 0 or self.yDuration > 0) and self.alpha < 1 then
        self._needsCompositePatternUpdate = true
    end

    -- update pattern and background pattern image tables every tick
    if self._patternTable or self._bgPatternTable then
        local tick = self:_getTime() // self.tickDuration
        if tick ~= self._ptick then
            self._ptick = tick
            self._isDirty = true
            if self._patternTable then
                local n = tick % self._patternTable:getLength() + 1
                self:_setPatternImage(self._patternImage, self._patternTable:getImage(n))
            end
            if self._bgPatternTable then
                local n = tick % self._bgPatternTable:getLength() + 1
                self:_setPatternImage(self._bgPatternImage, self._bgPatternTable:getImage(n))
            end
        end
    end

    if self._needsCompositePatternUpdate then
        self:_updateCompositePatternImage()
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
    return self.compositePatternImage, xPhase, yPhase
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
