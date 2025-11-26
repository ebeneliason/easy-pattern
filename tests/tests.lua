import "../EasyPattern.lua"


local gfx <const> = playdate.graphics
local ease <const> = playdate.easingFunctions
local lu <const> = luaunit

-- a list of random numbers
local rnd = {}
for i = 1, 9 do
    rnd[i] = math.random()
end

-- a simple pattern
local checkerboard <const> = { 0xF0, 0xF0, 0xF0, 0xF0, 0x0F, 0x0F, 0x0F, 0x0F }

-- the same pattern using BitPattern
local bitCheckerboard <const> = BitPattern {
    "11110000",
    "11110000",
    "11110000",
    "11110000",
    "00001111",
    "00001111",
    "00001111",
    "00001111",
}

-- a bit pattern
local zigzag <const> = BitPattern {
    "10001000",
    "11011101",
    "01110111",
    "00100010",
    "10001000",
    "11011101",
    "01110111",
    "00100010",
}

-- a bit pattern with alpha
local stripestripe <const> = BitPattern {
    "10101010",  "11111111",
    "10101010",  "00000000",
    "10101010",  "11111111",
    "10101010",  "00000000",
    "10101010",  "11111111",
    "10101010",  "00000000",
    "10101010",  "11111111",
    "10101010",  "00000000",
}

-- shorthand color references
local B <const> = gfx.kColorBlack
local W <const> = gfx.kColorWhite
local C <const> = gfx.kColorClear

-- return an array with pixel values from the top left size^2 area
local function sampleImage(img, size)
    local samples = {}
    for i = 0, size-1 do
        for j = 0, size-1 do
            samples[ 1 + i * size + j] = img:sample(j, i)
        end
    end
    return samples
end

TestInit = {}

function TestInit:testDefaults()
    local p = EasyPattern {}
    lu.assertEquals(p.pattern, nil)
    lu.assertEquals(p.alpha, 0.5)
    lu.assertEquals(p.ditherType, nil)
    lu.assertEquals(p.color, gfx.kColorBlack)
    lu.assertEquals(p.bgColor, gfx.kColorClear)
    lu.assertEquals(p.xDuration, 0)
    lu.assertEquals(p.yDuration, 0)
    lu.assertEquals(p.xOffset, 0)
    lu.assertEquals(p.yOffset, 0)
    lu.assertEquals(p.xEase, ease.linear)
    lu.assertEquals(p.yEase, ease.linear)
    lu.assertEquals(p.xEaseArgs, {})
    lu.assertEquals(p.yEaseArgs, {})
    lu.assertEquals(p.xReverses, false)
    lu.assertEquals(p.yReverses, false)
    lu.assertEquals(p.xReversed, false)
    lu.assertEquals(p.yReversed, false)
    lu.assertEquals(p.xSpeed, 1)
    lu.assertEquals(p.ySpeed, 1)
    lu.assertEquals(p.xScale, 1)
    lu.assertEquals(p.yScale, 1)
    lu.assertEquals(p.xShift, 0)
    lu.assertEquals(p.yShift, 0)
    lu.assertEquals(p.xReflected, false)
    lu.assertEquals(p.yReflected, false)
    lu.assertEquals(p.rotated, false)
    lu.assertEquals(p.inverted, false)
    lu.assertEquals(p._pt, 0)
    lu.assertEquals(p._xPhase, 0)
    lu.assertEquals(p._yPhase, 0)
    lu.assertEquals(p._ptx, 0)
    lu.assertEquals(p._pty, 0)
    lu.assertNotNil(p.patternImage)
end

function TestInit:testFallbacks()
    local p = EasyPattern {
        duration = rnd[1],
        offset = rnd[2],
        ease = ease.inOutCubic,
        easeArgs = { rnd[3], rnd[4] },
        reverses = true,
        reversed = true,
        speed = rnd[5],
        scale = rnd[6],
        shift = rnd[7],
        reflected = true,
    }
    lu.assertEquals(p.xDuration, rnd[1])
    lu.assertEquals(p.yDuration, rnd[1])
    lu.assertEquals(p.xOffset, rnd[2])
    lu.assertEquals(p.yOffset, rnd[2])
    lu.assertEquals(p.xEase, ease.inOutCubic)
    lu.assertEquals(p.yEase, ease.inOutCubic)
    lu.assertEquals(p.xEaseArgs, { rnd[3], rnd[4] })
    lu.assertEquals(p.yEaseArgs, { rnd[3], rnd[4] })
    lu.assertEquals(p.xReverses, true)
    lu.assertEquals(p.yReverses, true)
    lu.assertEquals(p.xReversed, true)
    lu.assertEquals(p.yReversed, true)
    lu.assertEquals(p.xSpeed, rnd[5])
    lu.assertEquals(p.ySpeed, rnd[5])
    lu.assertEquals(p.xScale, rnd[6])
    lu.assertEquals(p.yScale, rnd[6])
    lu.assertEquals(p.xShift, rnd[7])
    lu.assertEquals(p.yShift, rnd[7])
    lu.assertEquals(p.xReflected, true)
    lu.assertEquals(p.yReflected, true)
end

function TestInit:testLegacyParams()
    local p = EasyPattern {
        xPhaseDuration = rnd[1],
        yPhaseDuration = rnd[2],
        xPhaseOffset = rnd[3],
        yPhaseOffset = rnd[4],
        xPhaseFunction = ease.inOutCubic,
        yPhaseFunction = ease.inOutSine,
        xPhaseArgs = { rnd[5], rnd[6] },
        yPhaseArgs = { rnd[7], rnd[8] },
    }
    lu.assertEquals(p.xDuration, rnd[1])
    lu.assertEquals(p.yDuration, rnd[2])
    lu.assertEquals(p.xOffset, rnd[3])
    lu.assertEquals(p.yOffset, rnd[4])
    lu.assertEquals(p.xEase, ease.inOutCubic)
    lu.assertEquals(p.yEase, ease.inOutSine)
    lu.assertEquals(p.xEaseArgs, { rnd[5], rnd[6] })
    lu.assertEquals(p.yEaseArgs, { rnd[7], rnd[8] })
end

function TestInit:testXParams()
    local p = EasyPattern {
        xDuration = rnd[1],
        xOffset = rnd[2],
        xEase = ease.inOutCubic,
        xEaseArgs = { rnd[3], rnd[4] },
        xReverses = true,
        xReversed = true,
        xSpeed = rnd[5],
        xScale = rnd[6],
        xShift = rnd[7],
        xReflected = true,
    }
    lu.assertEquals(p.xDuration, rnd[1])
    lu.assertEquals(p.yDuration, 0)
    lu.assertEquals(p.xOffset, rnd[2])
    lu.assertEquals(p.yOffset, 0)
    lu.assertEquals(p.xEase, ease.inOutCubic)
    lu.assertEquals(p.yEase, ease.linear)
    lu.assertEquals(p.xEaseArgs, { rnd[3], rnd[4] })
    lu.assertEquals(p.yEaseArgs, {})
    lu.assertEquals(p.xReverses, true)
    lu.assertEquals(p.yReverses, false)
    lu.assertEquals(p.xReversed, true)
    lu.assertEquals(p.yReversed, false)
    lu.assertEquals(p.xSpeed, rnd[5])
    lu.assertEquals(p.ySpeed, 1)
    lu.assertEquals(p.xScale, rnd[6])
    lu.assertEquals(p.yScale, 1)
    lu.assertEquals(p.xShift, rnd[7])
    lu.assertEquals(p.yShift, 0)
    lu.assertEquals(p.xReflected, true)
    lu.assertEquals(p.yReflected, false)
end

function TestInit:testYParams()
    local p = EasyPattern {
        yDuration = rnd[1],
        yOffset = rnd[2],
        yEase = ease.inOutCubic,
        yEaseArgs = { rnd[3], rnd[4] },
        yReverses = true,
        yReversed = true,
        ySpeed = rnd[5],
        yScale = rnd[6],
        yShift = rnd[7],
        yReflected = true,
    }
    lu.assertEquals(p.yDuration, rnd[1])
    lu.assertEquals(p.xDuration, 0)
    lu.assertEquals(p.yOffset, rnd[2])
    lu.assertEquals(p.xOffset, 0)
    lu.assertEquals(p.yEase, ease.inOutCubic)
    lu.assertEquals(p.xEase, ease.linear)
    lu.assertEquals(p.yEaseArgs, { rnd[3], rnd[4] })
    lu.assertEquals(p.xEaseArgs, {})
    lu.assertEquals(p.yReverses, true)
    lu.assertEquals(p.xReverses, false)
    lu.assertEquals(p.yReversed, true)
    lu.assertEquals(p.xReversed, false)
    lu.assertEquals(p.ySpeed, rnd[5])
    lu.assertEquals(p.xSpeed, 1)
    lu.assertEquals(p.yScale, rnd[6])
    lu.assertEquals(p.xScale, 1)
    lu.assertEquals(p.yShift, rnd[7])
    lu.assertEquals(p.xShift, 0)
    lu.assertEquals(p.xReflected, false)
    lu.assertEquals(p.yReflected, true)
end

function TestInit:testPatternParams()
    local p = EasyPattern {
        pattern = checkerboard
    }
    lu.assertEquals(p.pattern, checkerboard)
end

function TestInit:testDitherPatternParams()
    local p = EasyPattern {
        ditherType = gfx.image.kDitherTypeDiagonalLine,
        alpha = rnd[1],
        color = gfx.kColorWhite,
        bgColor = gfx.kColorBlack
    }
    lu.assertEquals(p.ditherType, gfx.image.kDitherTypeDiagonalLine)
    lu.assertEquals(p.alpha, rnd[1])
    lu.assertEquals(p.color, gfx.kColorWhite)
    lu.assertEquals(p.bgColor, gfx.kColorBlack)
end

function TestInit:testInvertedParam()
    local p = EasyPattern {
        inverted = true
    }

    lu.assertEquals(p.inverted, true)
end

function TestInit:testRotatedParam()
    local p = EasyPattern {
        rotated = true
    }

    lu.assertEquals(p.rotated, true)
end


TestPatterns = {}

function TestPatterns:testSetColor()
    local p = EasyPattern {
        ditherType = gfx.image.kDitherTypeVerticalLine
    }

    local before = sampleImage(p.patternImage, 8)
    p:setColor(gfx.kColorWhite)
    local after = sampleImage(p.patternImage, 8)
    for i = 1, #before do
        -- black areas should now be white
        if before[i] == gfx.kColorBlack then
            lu.assertEquals(after[i], gfx.kColorWhite)
        -- clear areas should remain clear
        elseif before[i] == gfx.kColorClear then
            lu.assertEquals(after[i], gfx.kColorClear)
        end
    end
end

function TestPatterns:testSetBackgroundColor()
    local p = EasyPattern {
        ditherType = gfx.image.kDitherTypeVerticalLine
    }

    local before = sampleImage(p.patternImage, 8)
    p:setBackgroundColor(gfx.kColorWhite)
    local after = sampleImage(p.patternImage, 8)
    for i = 1, #before do
        -- black areas should remain black
        if before[i] == gfx.kColorBlack then
            lu.assertEquals(after[i], gfx.kColorBlack)
        -- clear areas should now be white
        elseif before[i] == gfx.kColorClear then
            lu.assertEquals(after[i], gfx.kColorWhite)
        end
    end
end

function TestPatterns:testSetDitherAlpha()
    local p = EasyPattern {
        alpha = 1
    }

    local before = sampleImage(p.patternImage, 8)
    p:setDitherPattern(0)
    local after = sampleImage(p.patternImage, 8)
    -- all pixels should have changed
    for i = 1, #before do
        lu.assertNotEquals(before[i], after[i])
    end
end

function TestPatterns:testSetDitherType()
    local p = EasyPattern {
        ditherType = gfx.image.kDitherTypeVerticalLine
    }

    local expectedBefore = {
        B, B, C, C, B, B,
        B, B, C, C, B, B,
        B, B, C, C, B, B,
        B, B, C, C, B, B,
        B, B, C, C, B, B,
        B, B, C, C, B, B,
    }

    local expectedAfter = {
        B, B, B, B, B, B,
        B, B, B, B, B, B,
        C, C, C, C, C, C,
        C, C, C, C, C, C,
        B, B, B, B, B, B,
        B, B, B, B, B, B,
    }

    local before = sampleImage(p.patternImage, 6)
    lu.assertEquals(before, expectedBefore)

    p:setDitherPattern(0.5, gfx.image.kDitherTypeHorizontalLine)

    local after = sampleImage(p.patternImage, 6)
    lu.assertEquals(after, expectedAfter)
end

function TestPatterns:testReflectionHorizontal()
    local p = EasyPattern {
        pattern = zigzag
    }

    local expectedBefore = {
        W, B, B, B,
        W, W, B, W,
        B, W, W, W,
        B, B, W, B,
    }

    local expectedAfter = {
        B, B, B, W,
        W, B, W, W,
        W, W, W, B,
        B, W, B, B,
    }

    local before = sampleImage(p.patternImage, 4)
    lu.assertEquals(before, expectedBefore)

    p:setReflected(true, false)

    local after = sampleImage(p.patternImage, 4)
    lu.assertEquals(after, expectedAfter)
end

function TestPatterns:testReflectionVertical()
    local p = EasyPattern {
        pattern = zigzag
    }

    local expectedBefore = {
        W, B, B, B,
        W, W, B, W,
        B, W, W, W,
        B, B, W, B,
    }

    local expectedAfter = {
        B, B, W, B,
        B, W, W, W,
        W, W, B, W,
        W, B, B, B,
    }

    local before = sampleImage(p.patternImage, 4)
    lu.assertEquals(before, expectedBefore)

    p:setReflected(false, true)

    local after = sampleImage(p.patternImage, 4)
    lu.assertEquals(after, expectedAfter)
end

function TestPatterns:testRotation()
    local p = EasyPattern {
        pattern = zigzag
    }

    local expectedBefore = {
        W, B, B, B,
        W, W, B, W,
        B, W, W, W,
        B, B, W, B,
    }

    local expectedAfter = {
        B, B, W, W,
        B, W, W, B,
        W, W, B, B,
        B, W, W, B,
    }

    local before = sampleImage(p.patternImage, 4)
    lu.assertEquals(before, expectedBefore)

    p:setRotated(true)

    local after = sampleImage(p.patternImage, 4)
    lu.assertEquals(after, expectedAfter)
end

function TestPatterns:testSetPattern()
    local p = EasyPattern {
        pattern = checkerboard
    }

    local expectedBefore = {
        W, W, W, W, B, B,
        W, W, W, W, B, B,
        W, W, W, W, B, B,
        W, W, W, W, B, B,
        B, B, B, B, W, W,
        B, B, B, B, W, W,
    }

    local expectedAfter = {
        W, B, B, B, W, B,
        W, W, B, W, W, W,
        B, W, W, W, B, W,
        B, B, W, B, B, B,
        W, B, B, B, W, B,
        W, W, B, W, W, W,
    }

    local before = sampleImage(p.patternImage, 6)
    lu.assertEquals(before, expectedBefore)

    p:setPattern(zigzag)

    local after = sampleImage(p.patternImage, 6)
    lu.assertEquals(after, expectedAfter)
end

function TestPatterns:testSetPatternWithAlpha()
    local p = EasyPattern {
        pattern = checkerboard
    }

    local expectedBefore = {
        W, W, W, W, B, B,
        W, W, W, W, B, B,
        W, W, W, W, B, B,
        W, W, W, W, B, B,
        B, B, B, B, W, W,
        B, B, B, B, W, W,
    }

    local expectedAfter = {
        W, B, W, B, W, B,
        C, C, C, C, C, C,
        W, B, W, B, W, B,
        C, C, C, C, C, C,
        W, B, W, B, W, B,
        C, C, C, C, C, C,
    }

    local before = sampleImage(p.patternImage, 6)
    lu.assertEquals(before, expectedBefore)

    p:setPattern(stripestripe)

    local after = sampleImage(p.patternImage, 6)
    lu.assertEquals(after, expectedAfter)
end

function TestPatterns:testInverted()
    local p = EasyPattern {
        pattern = checkerboard,
        inverted = true,
    }

    local default = {
        W, W, W, W, B, B,
        W, W, W, W, B, B,
        W, W, W, W, B, B,
        W, W, W, W, B, B,
        B, B, B, B, W, W,
        B, B, B, B, W, W,
    }

    local inverted = {
        B, B, B, B, W, W,
        B, B, B, B, W, W,
        B, B, B, B, W, W,
        B, B, B, B, W, W,
        W, W, W, W, B, B,
        W, W, W, W, B, B,
    }

    local sample = sampleImage(p.patternImage, 6)
    lu.assertEquals(sample, inverted)

    p:setInverted(false)

    sample = sampleImage(p.patternImage, 6)
    lu.assertEquals(sample, default)

    p:setInverted(true)
    sample = sampleImage(p.patternImage, 6)
    lu.assertEquals(sample, inverted)
end


TestPhases = {}

function TestPhases:setUp()
    -- animate in both axes
    self.CACHE_EXP = 1/60
    self.p = EasyPattern {
        duration = 1
    }

    -- mock our timer
    self.p._getTime = function() return self.p.mockTime end
    self.p.mockTime = 0.5
end

function TestPhases:testGetPhases()
    local p = self.p
    p.mockTime = 0

    for i = 0, 16 do
        p.mockTime = i/8
        local x, y = p:getPhases()
        lu.assertEquals(x, i % 8)
        lu.assertEquals(y, i % 8)
    end
end

function TestPhases:testDirty()
    local p = self.p
    p.mockTime = 1/8

    local x, y, dirty = p:getPhases()
    lu.assertEquals(x, 1)
    lu.assertEquals(y, 1)
    -- should be dirty after calculating phases
    lu.assertEquals(dirty, true)
    dirty = p:isDirty()
    -- should remain dirty on subsequent checks
    lu.assertEquals(dirty, true)
    dirty = p:isDirty()
    lu.assertEquals(dirty, true)
    -- should not be dirty following apply
    p:apply()
    dirty = p:isDirty()
    -- should be dirty again as time advances
    p.mockTime = 2/8
    dirty = p:isDirty()
    lu.assertEquals(dirty, true)
end

function TestPhases:testSetPhaseShifts()
    local p = self.p

    local x, y
    -- initial condition
    x, y = p:getPhases()
    lu.assertEquals(x, 4 + 0)
    lu.assertEquals(y, 4 + 0)

    -- shift distinct amounts
    p:setPhaseShifts(2, 3)
    lu.assertEquals(p.xShift, 2)
    lu.assertEquals(p.yShift, 3)
    x, y = p:getPhases()
    lu.assertEquals(x, 4 + 2)
    lu.assertEquals(y, 4 + 3)

    -- shift same amount
    p:setPhaseShifts(7)
    x, y = p:getPhases()
    lu.assertEquals(x, (4 + 7) % 8)
    lu.assertEquals(y, (4 + 7) % 8)

    -- overflow in both directions
    p:setPhaseShifts(12, -2)
    x, y = p:getPhases()
    lu.assertEquals(x, (4 + 12) % 8)
    lu.assertEquals(y, 4 - 2)
end

function TestPhases:testShiftPhasesBy()
    local p = self.p

    local x, y
    -- initial condition
    x, y = p:getPhases()
    lu.assertEquals(x, 4 + 0)
    lu.assertEquals(y, 4 + 0)

    -- shift distinct amounts
    p:setPhaseShifts(1, 2)
    lu.assertEquals(p.xShift, 1)
    lu.assertEquals(p.yShift, 2)
    x, y = p:getPhases()
    lu.assertEquals(x, 4 + 1)
    lu.assertEquals(y, 4 + 2)

    -- shift same amount
    p:shiftPhasesBy(1)
    lu.assertEquals(p.xShift, 2)
    lu.assertEquals(p.yShift, 3)
    x, y = p:getPhases()
    lu.assertEquals(x, 4 + 2)
    lu.assertEquals(y, 4 + 3)

    -- shift negative
    p:shiftPhasesBy(-2)
    lu.assertEquals(p.xShift, 0)
    lu.assertEquals(p.yShift, 1)
    x, y = p:getPhases()
    lu.assertEquals(x, 4 + 0)
    lu.assertEquals(y, 4 + 1)


    -- shift to boundary
    p:shiftPhasesBy(3)
    x, y = p:getPhases()
    lu.assertEquals(x, 4 + 3)
    lu.assertEquals(y, 0) -- wrap

end

function TestPhases:testCachedValues()
    local p = self.p

    -- compute the values once
    local x1, y1, dirty = p:getPhases()
    lu.assertEquals(dirty, true)

    -- repeat and confirm the same values are returned from the cache
    local x2, y2, dirty2 = p:getPhases()
    lu.assertEquals(x1, x2)
    lu.assertEquals(y1, y2)
    lu.assertEquals(dirty2, false)
end

function TestPhases:testCacheExpiration()
    local p = self.p

    -- compute the values once
    local x1, y1, dirty
    x1, y1, dirty = p:getPhases()
    lu.assertEquals(dirty, true)

    --advance a small amount and ensure cache is still used
    p.mockTime += self.CACHE_EXP * 0.9
    local x2, y2
    x2, y2, dirty = p:getPhases()
    lu.assertEquals(x1, x2)
    lu.assertEquals(y1, y2)
    lu.assertEquals(dirty, false)

    --advance time past the cache expiration and ensure values get recomputed
    p.mockTime += 1/8 -- based on 8 phase units per second
    local x3, y3
    x3, y3, dirty = p:getPhases()
    lu.assertNotEquals(x2, x3)
    lu.assertNotEquals(y2, y3)
    lu.assertEquals(dirty, true)
end

function TestPhases:testIsDirty()
    local p = self.p
    local dirty

    p.mockTime = 1/8
    dirty = p:isDirty()
    lu.assertEquals(dirty, true)
    p:apply()
    dirty = p:isDirty()
    lu.assertEquals(dirty, false)

    p.mockTime = 2/8
    dirty = p:isDirty()
    lu.assertEquals(dirty, true)
    p:apply()
    dirty = p:isDirty()
    lu.assertEquals(dirty, false)
end

function TestPhases:testApply()
    local p = self.p
    local x, y, dirty

    p.mockTime = 1/8
    _, x, y = p:apply()
    lu.assertEquals(x, 1)
    lu.assertEquals(y, 1)

    p.mockTime = 2/8
    _, x, y = p:apply()
    lu.assertEquals(x, 2)
    lu.assertEquals(y, 2)
end

function TestPhases:testReverses()
    local p = self.p
    p.xReverses = true
    local x, y

    p.mockTime = 7/8
    x, y = p:getPhases()
    lu.assertEquals(x, 7)
    lu.assertEquals(y, 7)
    lu.assertEquals(p.xReversed, false)

    p.mockTime = 8/8
    x, y = p:getPhases()
    lu.assertEquals(x, 7)
    lu.assertEquals(y, 0)
    lu.assertEquals(p.xReversed, true)

    p.mockTime = 9/8
    x, y = p:getPhases()
    lu.assertEquals(x, 6)
    lu.assertEquals(y, 1)
    lu.assertEquals(p.xReversed, true)

    p.mockTime = 16/8
    x, y = p:getPhases()
    lu.assertEquals(x, 0)
    lu.assertEquals(y, 0)
    lu.assertEquals(p.xReversed, false)
end

function TestPhases:testOffset()
    local p = self.p
    p.xOffset = 0.5
    p.yOffset = 0.5
    local x, y

    p.mockTime = 4/8
    x, y, dirty = p:getPhases()
    lu.assertEquals(x, 0)
    lu.assertEquals(y, 0)

    p.mockTime = 5/8
    x, y, dirty = p:getPhases()
    lu.assertEquals(x, 1)
    lu.assertEquals(y, 1)

    p.mockTime = 6/8
    x, y = p:getPhases()
    lu.assertEquals(x, 2)
    lu.assertEquals(y, 2)

    p.mockTime = 7/8
    x, y = p:getPhases()
    lu.assertEquals(x, 3)
    lu.assertEquals(y, 3)
end

function TestPhases:testSpeed()
    local p = self.p
    p.xSpeed = 2
    p.ySpeed = 2
    local x, y

    p.mockTime = 1/8
    _, x, y = p:apply()
    lu.assertEquals(x, 2)
    lu.assertEquals(y, 2)

    p.mockTime = 2/8
    _, x, y = p:apply()
    lu.assertEquals(x, 4)
    lu.assertEquals(y, 4)
end

function TestPhases:testScale()
    local p = self.p
    p.xScale = 2
    p.yScale = 2
    local x, y

    p.mockTime = 1/8
    _, x, y = p:apply()
    lu.assertEquals(x, 2)
    lu.assertEquals(y, 2)

    p.mockTime = 2/8
    _, x, y = p:apply()
    lu.assertEquals(x, 4)
    lu.assertEquals(y, 4)
end

function TestPhases:testReflection()
    local p = self.p
    p.mockTime = 1/8
    p:setReflected(true)

    local x, y
    _, x, y = p:apply()
    lu.assertEquals(x, 7 - 1)
    lu.assertEquals(y, 7 - 1)

    p:setReflected(true, false)
    _, x, y = p:apply()
    lu.assertEquals(x, 7 - 1)
    lu.assertEquals(y, 1)

    p:setReflected(false, true)
    p._pt = 0 -- invalidate cache
    _, x, y = p:apply()
    lu.assertEquals(x, 1)
    lu.assertEquals(y, 7 - 1)
end

function TestPhases:testRotation()
    local p = self.p
    p.xDuration = 0
    p.mockTime = 1/8

    -- base case, animating in Y axis only
    local x, y
    _, x, y = p:apply()
    lu.assertEquals(x, 0)
    lu.assertEquals(y, 1)

    -- animating in X axis only after rotation
    p:setRotated(true)
    _, x, y = p:apply()
    lu.assertEquals(x, 1)
    lu.assertEquals(y, 0)

    -- animation continues in new axis
    p.mockTime = 2/8
    _, x, y = p:apply()
    lu.assertEquals(x, 2)
    lu.assertEquals(y, 0)
end


TestLoops = {}

function TestLoops:setUp()
    -- animate in both axes
    self.CACHE_EXP = 1/60
    self.p = EasyPattern {
        duration = 1
    }

    -- track loop callbacks
    self.loops  = 0
    self.xLoops = 0
    self.yLoops = 0

    self.loopCBs  = 0
    self.xLoopCBs = 0
    self.yLoopCBs = 0

    self.p.loopCallback  = function(_, n) self.loopCBs += 1  self.loops  = n end
    self.p.xLoopCallback = function(_, n) self.xLoopCBs += 1 self.xLoops = n end
    self.p.yLoopCallback = function(_, n) self.yLoopCBs += 1 self.yLoops = n end

    -- mock our timer
    self.p._getTime = function() return self.p.mockTime end
    self.p.mockTime = 0
end

function TestLoops:testXLoopDuration()
    local p = self.p
    p.mockTime = 0
    p.xDuration = 2
    p.yDuration = 3
    lu.assertEquals(p:getXLoopDuration(), 2)

    -- double speed
    p.xSpeed = 2
    lu.assertEquals(p:getXLoopDuration(), 1)

    -- half speed
    p.xSpeed = 0.5
    lu.assertEquals(p:getXLoopDuration(), 4)

    -- reverses
    p.xReverses = true
    lu.assertEquals(p:getXLoopDuration(), 8)
end

function TestLoops:testYLoopDuration()
    local p = self.p
    p.mockTime = 0
    p.xDuration = 2
    p.yDuration = 3
    lu.assertEquals(p:getYLoopDuration(), 3)

    -- double speed
    p.ySpeed = 2
    lu.assertEquals(p:getYLoopDuration(), 1.5)

    -- half speed
    p.ySpeed = 0.5
    lu.assertEquals(p:getYLoopDuration(), 6)

    -- reverses
    p.yReverses = true
    lu.assertEquals(p:getYLoopDuration(), 12)
end

function TestLoops:testLoopDuration()
    local p = self.p
    p.mockTime = 0
    p.xDuration = 2
    p.yDuration = 2
    lu.assertEquals(p:getLoopDuration(), 2)

    p.xDuration = 2
    p.yDuration = 3
    lu.assertEquals(p:getLoopDuration(), 6)

    p.xDuration = 0.25
    p.yDuration = 3
    lu.assertEquals(p:getLoopDuration(), 3)
end

function TestLoops:testBasicLoopCallback()
    local p = self.p
    p.xDuration = 2
    p.yDuration = 3

    -- no loops yet
    for i = 0, 5 do
        p.mockTime = i
        p:apply()
        lu.assertEquals(self.loops, 0)
        lu.assertEquals(self.loopCBs, 0)
    end

    -- just before first loop
    p.mockTime = 5.95
    p:apply()
    lu.assertEquals(self.loops, 0)
    lu.assertEquals(self.loopCBs, 0)

    -- at first loop
    p.mockTime = 6.00
    p:apply()
    lu.assertEquals(self.loops, 1)
    lu.assertEquals(self.loopCBs, 1)

    -- applied a second time, still just one callback
    p.mockTime = 6.00
    p:apply()
    lu.assertEquals(self.loops, 1)
    lu.assertEquals(self.loopCBs, 1)

    -- just after first loop
    p.mockTime = 6.05
    p:apply()
    lu.assertEquals(self.loops, 1)
    lu.assertEquals(self.loopCBs, 1)

    -- after several loops
    p.mockTime = 19
    p:apply()
    lu.assertEquals(self.loops, 3)
    lu.assertEquals(self.loopCBs, 2) -- skipped ahead in time, missed second call
end

function TestLoops:testXYLoopCallbacks()
    local p = self.p
    p.xDuration = 2
    p.yDuration = 3

    lu.assertEquals(self.xLoops, 0)
    lu.assertEquals(self.xLoopCBs, 0)
    lu.assertEquals(self.yLoops, 0)
    lu.assertEquals(self.yLoopCBs, 0)
    lu.assertEquals(self.loops, 0)
    lu.assertEquals(self.loopCBs, 0)

    p.mockTime = 1
    p:apply()
    lu.assertEquals(self.xLoops, 0)
    lu.assertEquals(self.xLoopCBs, 0)
    lu.assertEquals(self.yLoops, 0)
    lu.assertEquals(self.yLoopCBs, 0)
    lu.assertEquals(self.loops, 0)
    lu.assertEquals(self.loopCBs, 0)

    p.mockTime = 2
    p:apply()
    lu.assertEquals(self.xLoops, 1)
    lu.assertEquals(self.xLoopCBs, 1)
    lu.assertEquals(self.yLoops, 0)
    lu.assertEquals(self.yLoopCBs, 0)
    lu.assertEquals(self.loops, 0)
    lu.assertEquals(self.loopCBs, 0)

    p.mockTime = 3
    p:apply()
    lu.assertEquals(self.xLoops, 1)
    lu.assertEquals(self.xLoopCBs, 1)
    lu.assertEquals(self.yLoops, 1)
    lu.assertEquals(self.yLoopCBs, 1)
    lu.assertEquals(self.loops, 0)
    lu.assertEquals(self.loopCBs, 0)

    p.mockTime = 4
    p:apply()
    lu.assertEquals(self.xLoops, 2)
    lu.assertEquals(self.xLoopCBs, 2)
    lu.assertEquals(self.yLoops, 1)
    lu.assertEquals(self.yLoopCBs, 1)
    lu.assertEquals(self.loops, 0)
    lu.assertEquals(self.loopCBs, 0)

    p.mockTime = 5
    p:apply()
    lu.assertEquals(self.xLoops, 2)
    lu.assertEquals(self.xLoopCBs, 2)
    lu.assertEquals(self.yLoops, 1)
    lu.assertEquals(self.yLoopCBs, 1)
    lu.assertEquals(self.loops, 0)
    lu.assertEquals(self.loopCBs, 0)

    p.mockTime = 6
    p:apply()
    lu.assertEquals(self.xLoops, 3)
    lu.assertEquals(self.xLoopCBs, 3)
    lu.assertEquals(self.yLoops, 2)
    lu.assertEquals(self.yLoopCBs, 2)
    lu.assertEquals(self.loops, 1)
    lu.assertEquals(self.loopCBs, 1)
end


TestBitPattern = {}

function TestBitPattern:testWithoutAlpha()
    lu.assertEquals(bitCheckerboard, checkerboard)
end

function TestBitPattern:testWithAlpha()
    local bitCheckerboardHorizontalDither = BitPattern {
        -- pttrn --  -- alpha --
        "11110000",  "11111111",
        "11110000",  "00000000",
        "11110000",  "11111111",
        "11110000",  "00000000",
        "00001111",  "11111111",
        "00001111",  "00000000",
        "00001111",  "11111111",
        "00001111",  "00000000",
    }

    local expected <const> = {
        0xF0, 0xF0, 0xF0, 0xF0, 0x0F, 0x0F, 0x0F, 0x0F, -- pttrn
        0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00  -- alpha
    }
    lu.assertEquals(bitCheckerboardHorizontalDither, expected)
end

function TestBitPattern:testWithASCII()
    local bitCheckerboardHorizontalDither = BitPattern {
        -- pttrn ----------   -- alpha ----------
        " X X X X . . . . ",  " X X X X X X X X ",
        " X X X X . . . . ",  " . . . . . . . . ",
        " X X X X . . . . ",  " X X X X X X X X ",
        " X X X X . . . . ",  " . . . . . . . . ",
        " . . . . X X X X ",  " X X X X X X X X ",
        " . . . . X X X X ",  " . . . . . . . . ",
        " . . . . X X X X ",  " X X X X X X X X ",
        " . . . . X X X X ",  " . . . . . . . . ",
    }

    local expected <const> = {
        0xF0, 0xF0, 0xF0, 0xF0, 0x0F, 0x0F, 0x0F, 0x0F, -- pttrn
        0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00  -- alpha
    }
    lu.assertEquals(bitCheckerboardHorizontalDither, expected)
end
