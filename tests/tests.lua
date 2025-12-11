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
-- fully transparent
local transparent <const> = { 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 }
-- opaque white
local white <const> = { 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF }
-- opaque black
local black <const> = { 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 }


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

-- reusable expected sample results

local checker6 <const> = {
    W, W, W, W, B, B,
    W, W, W, W, B, B,
    W, W, W, W, B, B,
    W, W, W, W, B, B,
    B, B, B, B, W, W,
    B, B, B, B, W, W,
}

local hstripe6 <const> = {
    W, W, W, W, W, W,
    B, B, B, B, B, B,
    W, W, W, W, W, W,
    B, B, B, B, B, B,
    W, W, W, W, W, W,
    B, B, B, B, B, B,
}

local transparent6 <const> = {
    C, C, C, C, C, C,
    C, C, C, C, C, C,
    C, C, C, C, C, C,
    C, C, C, C, C, C,
    C, C, C, C, C, C,
    C, C, C, C, C, C,
}

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
    lu.assertEquals(p.pattern, checkerboard)
    lu.assertEquals(p.bgPattern, nil)
    lu.assertEquals(p.alpha, 1.0)
    lu.assertEquals(p.ditherType, gfx.image.kDitherTypeBayer8x8)
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
    lu.assertNotNil(p.compositePatternImage)
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
    lu.assertNotNil(p._patternImage)
    lu.assertNil(p._bgPatternImage)

    local sample = sampleImage(p._patternImage, 6)
    lu.assertEquals(sample, checker6)
    sample = sampleImage(p.compositePatternImage, 6)
    lu.assertEquals(sample, checker6)
end

function TestInit:testBackgroundParams()
    local p = EasyPattern {
        pattern = transparent,
        bgColor = gfx.kColorBlack,
        bgPattern = checkerboard,
    }
    lu.assertEquals(p.bgColor, gfx.kColorBlack)
    lu.assertNotNil(p._bgPatternImage)

    local sample = sampleImage(p._bgPatternImage, 6)
    lu.assertEquals(sample, checker6)
    sample = sampleImage(p.compositePatternImage, 6)
    lu.assertEquals(sample, checker6)
end

function TestInit:testAlphaParams()
    local p = EasyPattern {
        alpha = 0.123,
        ditherType = gfx.image.kDitherTypeDiagonalLine,
    }
    lu.assertEquals(p.alpha, 0.123)
    lu.assertEquals(p.ditherType, gfx.image.kDitherTypeDiagonalLine)
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

function TestInit:testCallbackParams()
    local l, x, y
    local f1 = function() l = true end
    local f2 = function() x = true end
    local f3 = function() y = true end
    local p = EasyPattern {
        loopCallback = f1,
        xLoopCallback = f2,
        yLoopCallback = f3
    }

    lu.assertEquals(p.loopCallback, f1)
    lu.assertEquals(p.xLoopCallback, f2)
    lu.assertEquals(p.yLoopCallback, f3)
end

function TestInit:testImageObjectPersistence()
    local p = EasyPattern {
        pattern = zigzag,
        bgPattern = checkerboard,
        alpha = 0.5,
        yReflected = true,
    }

    -- these image objects should persist indefinitely, even as new patterns are set,
    -- transformations are applied, and compositing is performed.
    local pImage = p._patternImage
    local bgImage = p._bgPatternImage
    local cImage = p.compositePatternImage
    local _cImage = p._compositePatternImage

    p:_resetPatternProperties()
    p:_resetBackgroundProperties()
    p:_updateCompositePatternImage()
    p:apply()

    lu.assertEquals(pImage, p._patternImage)
    lu.assertEquals(bgImage, p._bgPatternImage)
    lu.assertEquals(cImage, p.compositePatternImage)
    lu.assertEquals(_cImage, p._compositePatternImage)

    p:setPatternImage(gfx.image.new("images/checker"))
    p:setBackgroundPatternImage(gfx.image.new("images/hstripe"))
    p:apply()

    lu.assertEquals(pImage, p._patternImage)
    lu.assertEquals(bgImage, p._bgPatternImage)
    lu.assertEquals(cImage, p.compositePatternImage)
    lu.assertEquals(_cImage, p._compositePatternImage)

    p:setPatternImageTable(gfx.imagetable.new("images/hdashes"))
    p:setBackgroundPatternImageTable(gfx.imagetable.new("images/hdashes"))
    p:apply()

    lu.assertEquals(pImage, p._patternImage)
    lu.assertEquals(bgImage, p._bgPatternImage)
    lu.assertEquals(cImage, p.compositePatternImage)
    lu.assertEquals(_cImage, p._compositePatternImage)
end


TestPatterns = {}

function TestPatterns:testSetBackgroundColor()
    local p = EasyPattern {
        ditherType = gfx.image.kDitherTypeVerticalLine
    }

    local before = sampleImage(p.compositePatternImage, 8)
    p:setBackgroundColor(gfx.kColorWhite)
    local after = sampleImage(p.compositePatternImage, 8)
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

function TestPatterns:testSetDitherPattern()
    local p = EasyPattern {
        pattern = {
            alpha = 0.5,
            ditherType = gfx.image.kDitherTypeVerticalLine,
        }
    }

    local vertical50 = {
        B, B, C, C,
        B, B, C, C,
        B, B, C, C,
        B, B, C, C,
    }

    local horizontal25 = {
        B, B, B, B,
        B, B, B, B,
        B, B, B, B,
        C, C, C, C,
    }

    local before = sampleImage(p.compositePatternImage, 4)
    lu.assertEquals(before, vertical50)

    p:setPattern({
        alpha = 0.5,
        ditherType = gfx.image.kDitherTypeVerticalLine,
        color = gfx.kColorWhite,
    })

    local after = sampleImage(p.compositePatternImage, 4)
    for i = 1, #before do
        -- black areas should now be white
        if before[i] == gfx.kColorBlack then
            lu.assertEquals(after[i], gfx.kColorWhite)
        -- clear areas should remain clear
        elseif before[i] == gfx.kColorClear then
            lu.assertEquals(after[i], gfx.kColorClear)
        end
    end

    p:setDitherPattern(0.5, gfx.image.kDitherTypeVerticalLine, gfx.kColorWhite)

    local after2 = sampleImage(p.compositePatternImage, 4)
    lu.assertEquals(after, after2)

    p:setPattern({
        alpha = 0.25,
        ditherType = gfx.image.kDitherTypeHorizontalLine,
    })

    local sample = sampleImage(p.compositePatternImage, 4)
    lu.assertEquals(sample, horizontal25)

    p:setDitherPattern(0.25, gfx.image.kDitherTypeHorizontalLine)

    local sample2 = sampleImage(p.compositePatternImage, 4)
    lu.assertEquals(sample, sample2)
end

function TestPatterns:testSetPatternImage()
    local p = EasyPattern {
        pattern = gfx.image.new("./images/checker")
    }

    local sample = sampleImage(p._patternImage, 6)
    lu.assertEquals(sample, checker6)
    sample = sampleImage(p.compositePatternImage, 6)
    lu.assertEquals(sample, checker6)
    lu.assertNil(p._bgPatternImage)

    p:setPatternImage(gfx.image.new("./images/hstripe"))
    sample = sampleImage(p._patternImage, 6)
    lu.assertEquals(sample, hstripe6)
    sample = sampleImage(p.compositePatternImage, 6)
    lu.assertEquals(sample, hstripe6)
end

function TestPatterns:testSetPatternImageTable()
    self.p = EasyPattern {
        pattern = gfx.imagetable.new("./images/hdashes"),
        tickDuration = 1,
    }
    local p = self.p

    local expected = {
        B, B, B, B,
        B, B, B, B,
        W, B, B, B,
        W, B, B, B,
    }

    lu.assertNotNil(p._patternTable)
    local sample = sampleImage(p._patternImage, 4)
    lu.assertEquals(sample, expected)
    sample = sampleImage(p.compositePatternImage, 4)
    lu.assertEquals(sample, expected)

    -- mock our timer
    p._getTime = function() return p.mockTime end

    local expected1 = {
        B, B, B, B,
        B, B, B, B,
        W, W, B, B,
        W, W, B, B,
    }

    p.mockTime = 1
    p:apply()
    sample = sampleImage(p._patternImage, 4)
    lu.assertEquals(sample, expected1)
    sample = sampleImage(p.compositePatternImage, 4)
    lu.assertEquals(sample, expected1)

    local expected6 = {
        B, B, B, B,
        B, B, B, B,
        B, B, B, W,
        B, B, B, W,
    }

    p.mockTime = 6
    p:apply()
    sample = sampleImage(p._patternImage, 4)
    lu.assertEquals(sample, expected6)
    sample = sampleImage(p.compositePatternImage, 4)
    lu.assertEquals(sample, expected6)

    p.mockTime = p._patternTable:getLength() + 1
    p:apply()
    sample = sampleImage(p._patternImage, 4)
    lu.assertEquals(sample, expected1)
    sample = sampleImage(p.compositePatternImage, 4)
    lu.assertEquals(sample, expected1)

    p.mockTime = p._patternTable:getLength() + 6
    p:apply()
    sample = sampleImage(p._patternImage, 4)
    lu.assertEquals(sample, expected6)
    sample = sampleImage(p.compositePatternImage, 4)
    lu.assertEquals(sample, expected6)
end

function TestPatterns:testSetEasyPatternOnlyOnBackground()
    local p = EasyPattern { pattern = transparent }

    p:setPattern(EasyPattern { pattern = stripestripe })

    lu.assertNil(p._bgEasyPattern)
    lu.assertNil(p._bgPatternImage)
    local sample = sampleImage(p.compositePatternImage, 6)
    lu.assertEquals(sample, transparent6)
end

function TestPatterns:testBackgroundPatternRemoval()
    local p = EasyPattern { pattern = transparent }

    -- confirm starting conditions
    lu.assertNil(p.bgPattern)
    lu.assertNil(p._bgPatternImage)
    lu.assertEquals(p.pattern, transparent)
    local sample = sampleImage(p.compositePatternImage, 6)
    lu.assertEquals(sample, transparent6)

    -- set a checkerboard pattern as a background
    p:setBackgroundPattern(checkerboard)
    lu.assertEquals(p.pattern, transparent)
    lu.assertNotNil(p.bgPattern)
    lu.assertNotNil(p._bgPatternImage)
    lu.assertEquals(p.bgPattern, checkerboard)
    sample = sampleImage(p._patternImage, 6)
    lu.assertEquals(sample, transparent6)
    sample = sampleImage(p.compositePatternImage, 6)
    lu.assertEquals(sample, checker6)

    -- then remove it
    p:setBackgroundPattern(nil)
    lu.assertNil(p.bgPattern)
    lu.assertNil(p._bgPatternImage)
    lu.assertEquals(p.pattern, transparent)
    sample = sampleImage(p._patternImage, 6)
    lu.assertEquals(sample, transparent6)
    p:_updateCompositePatternImage()
    sample = sampleImage(p.compositePatternImage, 6)
    lu.assertEquals(sample, transparent6)
end

function TestPatterns:testPatternValuesReset()
    local p = EasyPattern { pattern = checkerboard }

    lu.assertEquals(p.pattern, checkerboard)
    lu.assertNil(p.patternTable)

    p:setDitherPattern(0.5)
    lu.assertNil(p.pattern)

    p:setBitPattern(checkerboard)
    lu.assertEquals(p.pattern, checkerboard)

    p:setPatternImage(gfx.image.new("./images/checker"))
    lu.assertNil(p.pattern)

    p:setBitPattern(checkerboard)
    lu.assertEquals(p.pattern, checkerboard)

    p:setPatternImageTable(gfx.imagetable.new("./images/hdashes"))
    lu.assertNil(p.pattern)
    lu.assertNotNil(p._patternTable)

    p:setBitPattern(stripestripe)
    lu.assertEquals(p.pattern, stripestripe)
    lu.assertNil(p._patternTable)

    p:setPatternImageTable(gfx.imagetable.new("./images/hdashes"))
    lu.assertNil(p.pattern)
    lu.assertNotNil(p._patternTable)

    p:setPattern(nil) -- restore default
    lu.assertEquals(p.pattern, checkerboard)
    lu.assertNil(p._patternTable)
end

function TestPatterns:testBackgroundPatternValuesReset()
    local p = EasyPattern {
        pattern = transparent,
        bgPattern = checkerboard,
    }

    lu.assertEquals(p.bgPattern, checkerboard)
    lu.assertNotNil(p._bgPatternImage)
    lu.assertNil(p._bgPatternTable)
    lu.assertNil(p._bgEasyPattern)

    p:setBackgroundDitherPattern(0.5)
    lu.assertNil(p.bgPattern)
    lu.assertNotNil(p._bgPatternImage)
    lu.assertNil(p._bgPatternTable)
    lu.assertNil(p._bgEasyPattern)

    p:setBackgroundBitPattern(checkerboard)
    lu.assertEquals(p.bgPattern, checkerboard)
    lu.assertNotNil(p._bgPatternImage)
    lu.assertNil(p._bgPatternTable)
    lu.assertNil(p._bgEasyPattern)

    p:setBackgroundEasyPattern(EasyPattern {})
    lu.assertNil(p.bgPattern)
    lu.assertNotNil(p._bgPatternImage)
    lu.assertNil(p._bgPatternTable)
    lu.assertNotNil(p._bgEasyPattern)

    p:setBackgroundBitPattern(checkerboard)
    lu.assertEquals(p.bgPattern, checkerboard)
    lu.assertNotNil(p._bgPatternImage)
    lu.assertNil(p._bgPatternTable)
    lu.assertNil(p._bgEasyPattern)

    p:setBackgroundPatternImage(gfx.image.new("./images/checker"))
    lu.assertNil(p.bgPattern)
    lu.assertNotNil(p._bgPatternImage)
    lu.assertNil(p._bgPatternTable)
    lu.assertNil(p._bgEasyPattern)

    p:setBackgroundBitPattern(checkerboard)
    lu.assertEquals(p.bgPattern, checkerboard)
    lu.assertNotNil(p._bgPatternImage)
    lu.assertNil(p._bgPatternTable)
    lu.assertNil(p._bgEasyPattern)

    p:setBackgroundPatternImageTable(gfx.imagetable.new("./images/hdashes"))
    lu.assertNil(p.bgPattern)
    lu.assertNotNil(p._bgPatternImage)
    lu.assertNotNil(p._bgPatternTable)
    lu.assertNil(p._bgEasyPattern)

    p:setBackgroundPattern(checkerboard)
    lu.assertEquals(p.bgPattern, checkerboard)
    lu.assertNotNil(p._bgPatternImage)
    lu.assertNil(p._bgPatternTable)
    lu.assertNil(p._bgEasyPattern)
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

    local before = sampleImage(p.compositePatternImage, 4)
    lu.assertEquals(before, expectedBefore)

    p:setReflected(true, false)

    local after = sampleImage(p.compositePatternImage, 4)
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

    local before = sampleImage(p.compositePatternImage, 4)
    lu.assertEquals(before, expectedBefore)

    p:setReflected(false, true)

    local after = sampleImage(p.compositePatternImage, 4)
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

    local before = sampleImage(p.compositePatternImage, 4)
    lu.assertEquals(before, expectedBefore)

    p:setRotated(true)

    local after = sampleImage(p.compositePatternImage, 4)
    lu.assertEquals(after, expectedAfter)
end

function TestPatterns:testSetPattern()
    local p = EasyPattern {
        pattern = checkerboard
    }

    local expectedAfter = {
        W, B, B, B, W, B,
        W, W, B, W, W, W,
        B, W, W, W, B, W,
        B, B, W, B, B, B,
        W, B, B, B, W, B,
        W, W, B, W, W, W,
    }

    local before = sampleImage(p.compositePatternImage, 6)
    lu.assertEquals(before, checker6)

    p:setPattern(zigzag)

    local after = sampleImage(p.compositePatternImage, 6)
    lu.assertEquals(after, expectedAfter)
end

function TestPatterns:testSetPatternWithAlpha()
    local p = EasyPattern {
        pattern = checkerboard
    }

    local expectedAfter = {
        W, B, W, B, W, B,
        C, C, C, C, C, C,
        W, B, W, B, W, B,
        C, C, C, C, C, C,
        W, B, W, B, W, B,
        C, C, C, C, C, C,
    }

    local before = sampleImage(p.compositePatternImage, 6)
    lu.assertEquals(before, checker6)

    p:setPattern(stripestripe)

    local after = sampleImage(p._patternImage, 6)
    lu.assertEquals(after, expectedAfter)

    local after = sampleImage(p.compositePatternImage, 6)
    lu.assertEquals(after, expectedAfter)
end

function TestPatterns:testSetBackgroundPattern()
    local p = EasyPattern {
        pattern = stripestripe
    }

    local expectedBefore = {
        W, B, W, B, W, B,
        C, C, C, C, C, C,
        W, B, W, B, W, B,
        C, C, C, C, C, C,
        W, B, W, B, W, B,
        C, C, C, C, C, C,
    }

    local expectedAfter = {
        W, B, W, B, W, B,
        W, W, W, W, B, B,
        W, B, W, B, W, B,
        W, W, W, W, B, B,
        W, B, W, B, W, B,
        B, B, B, B, W, W,
    }

    local before = sampleImage(p.compositePatternImage, 6)
    lu.assertEquals(before, expectedBefore)

    lu.assertNil(p._bgPatternImage)
    p:setBackgroundPattern(checkerboard)
    lu.assertNotNil(p._bgPatternImage)
    lu.assertNil(p._bgEasyPattern)

    local after = sampleImage(p.compositePatternImage, 6)
    lu.assertEquals(after, expectedAfter)
end

function TestPatterns:testSetBackgroundPatternImage()
    local p = EasyPattern {
        pattern = transparent,
        bgPattern = gfx.image.new("./images/checker"),
    }

    local sample = sampleImage(p._patternImage, 6)
    lu.assertEquals(sample, transparent6)
    sample = sampleImage(p._bgPatternImage, 6)
    lu.assertEquals(sample, checker6)
    sample = sampleImage(p.compositePatternImage, 6)
    lu.assertEquals(sample, checker6)

    p:setBackgroundPatternImage(gfx.image.new("./images/hstripe"))
    sample = sampleImage(p._patternImage, 6)
    lu.assertEquals(sample, transparent6)
    sample = sampleImage(p._bgPatternImage, 6)
    lu.assertEquals(sample, hstripe6)
    sample = sampleImage(p.compositePatternImage, 6)
    lu.assertEquals(sample, hstripe6)
end

function TestPatterns:SKIP_testSetBackgroundPatternImageTable()
    -- TODO
end

function TestPatterns:testSetBackgroundEasyPattern()
    local p = EasyPattern {
        pattern = stripestripe
    }

    local expectedBefore = {
        W, B, W, B, W, B,
        C, C, C, C, C, C,
        W, B, W, B, W, B,
        C, C, C, C, C, C,
        W, B, W, B, W, B,
        C, C, C, C, C, C,
    }

    local expectedAfter = {
        W, B, W, B, W, B,
        W, W, W, W, B, B,
        W, B, W, B, W, B,
        W, W, W, W, B, B,
        W, B, W, B, W, B,
        B, B, B, B, W, W,
    }

    local before = sampleImage(p.compositePatternImage, 6)
    lu.assertEquals(before, expectedBefore)

    lu.assertNil(p._bgPatternImage)
    p:setBackgroundPattern(EasyPattern { pattern = checkerboard })
    lu.assertNotNil(p._bgPatternImage)
    lu.assertNotNil(p._bgEasyPattern)

    local after = sampleImage(p.compositePatternImage, 6)
    lu.assertEquals(after, expectedAfter)
end

function TestPatterns:testInverted()
    local p = EasyPattern {
        pattern = checkerboard,
        inverted = true,
    }

    local inverted = {
        B, B, B, B, W, W,
        B, B, B, B, W, W,
        B, B, B, B, W, W,
        B, B, B, B, W, W,
        W, W, W, W, B, B,
        W, W, W, W, B, B,
    }

    local sample = sampleImage(p.compositePatternImage, 6)
    lu.assertEquals(sample, inverted)

    p:setInverted(false)

    sample = sampleImage(p.compositePatternImage, 6)
    lu.assertEquals(sample, checker6)

    p:setInverted(true)
    sample = sampleImage(p.compositePatternImage, 6)
    lu.assertEquals(sample, inverted)
end


function TestPatterns:testAvoidUnnecessaryPatternUpdates()
    local p = EasyPattern {}

    -- inverted
    p:apply()
    p:setInverted(false)
    lu.assertIsFalse(p:isDirty())
    p:apply()
    p:setInverted(true)
    lu.assertIsTrue(p:isDirty())
    p:apply()
    p:setInverted(true)
    lu.assertIsFalse(p:isDirty())

    -- bgColor
    p:apply()
    p:setBackgroundColor(gfx.kColorClear)
    lu.assertIsFalse(p:isDirty())
    p:apply()
    p:setBackgroundColor(gfx.kColorWhite)
    lu.assertIsTrue(p:isDirty())
    p:apply()
    p:setBackgroundColor(gfx.kColorWhite)
    lu.assertIsFalse(p:isDirty())

    -- alpha
    p:apply()
    p:setAlpha(1)
    lu.assertIsFalse(p:isDirty())
    p:apply()
    p:setAlpha(0.5)
    lu.assertIsTrue(p:isDirty())
    p:apply()
    p:setAlpha(0.5)
    lu.assertIsFalse(p:isDirty())

    -- dither
    p:apply()
    p:setAlpha(0.5, gfx.image.kDitherTypeBayer8x8)
    lu.assertIsFalse(p:isDirty())
    p:apply()
    p:setAlpha(0.5, gfx.image.kDitherTypeDiagonalLine)
    lu.assertIsTrue(p:isDirty())
    p:apply()
    p:setAlpha(0.5, gfx.image.kDitherTypeDiagonalLine)
    lu.assertIsFalse(p:isDirty())

    -- rotated
    p:apply()
    p:setRotated(false)
    lu.assertIsFalse(p:isDirty())
    p:apply()
    p:setRotated(true)
    lu.assertIsTrue(p:isDirty())
    p:apply()
    p:setRotated(true)
    lu.assertIsFalse(p:isDirty())

    -- reflected
    p:apply()
    p:setReflected(false, false)
    lu.assertIsFalse(p:isDirty())
    p:apply()
    p:setReflected(true, false)
    lu.assertIsTrue(p:isDirty())
    p:apply()
    p:setReflected(true, false)
    lu.assertIsFalse(p:isDirty())
    p:apply()
    p:setReflected(true, true)
    lu.assertIsTrue(p:isDirty())
    p:apply()
    p:setReflected(true, true)
    lu.assertIsFalse(p:isDirty())
    p:apply()
    p:setReflected(false)
    lu.assertIsTrue(p:isDirty())
    p:apply()
    p:setReflected(false)
    lu.assertIsFalse(p:isDirty())
end

function TestPatterns:testMinimizePatternUpdatesDuringPhaseComputation()
    local p = EasyPattern {
        duration = 1,
        alpha = 0.5,
        bgPattern = EasyPattern {
            duration = 1
        }
    }

    -- mock timer
    p._getTime = function() return p.mockTime end
    p.mockTime = 0

    -- wrap the pattern update function to count the number of times it's called
    local updates = 0
    p.__updateCompositePatternImage = p._updateCompositePatternImage
    p._updateCompositePatternImage = function()
        updates += 1
        p:__updateCompositePatternImage()
    end

    p.mockTime = 1 -- advance time
    updates = 0 -- reset counter
    p:apply()
    lu.assertEquals(updates, 1)

    p:setPattern(gfx.imagetable.new("./images/hdashes"), 1) -- tick every frame
    p.mockTime = 2 -- advance time
    updates = 0 -- reset counter
    p:apply()
    lu.assertEquals(updates, 1)

    p:setBackgroundPattern(gfx.imagetable.new("./images/hdashes"), 1) -- tick every frame
    p.mockTime = 3 -- advance time
    updates = 0 -- reset counter
    p:apply()
    lu.assertEquals(updates, 2) -- we haven't yet optimized independent background and pattern ticks in the same frame

    p:setPattern(checkerboard) -- static pattern, should no longer update composite image
    p.mockTime = 4 -- advance time
    updates = 0 -- reset counter
    p:apply()
    lu.assertEquals(updates, 1)
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

function TestPhases:testAnimatedBackgroundPattern()
    local p = self.p
    p.xDuration = 0
    p.yDuration = 0
    p:setPattern(stripestripe)

    local bg = EasyPattern {
        pattern = checkerboard,
        xDuration = 1
    }
    p:setBackgroundPattern(bg)

    -- mock bg timer
    bg._getTime = function() return p.mockTime end

    local unshifted = {
        W, B, W, B, W, B,
        W, W, W, W, B, B,
        W, B, W, B, W, B,
        W, W, W, W, B, B,
        W, B, W, B, W, B,
        B, B, B, B, W, W,
    }

    local shiftedOne = {
        W, B, W, B, W, B,
        W, W, W, B, B, B,
        W, B, W, B, W, B,
        W, W, W, B, B, B,
        W, B, W, B, W, B,
        B, B, B, W, W, W
    }

    p.mockTime = 0
    p:apply()
    sample = sampleImage(p.compositePatternImage, 6)
    lu.assertEquals(sample, unshifted)

    p.mockTime = 1/8
    p:apply()
    sample = sampleImage(p.compositePatternImage, 6)
    lu.assertEquals(sample, shiftedOne)
end

function TestPhases:testAnimatedForegroundPattern()
    local p = self.p
    p:setPattern(stripestripe)
    p.xDuration = 0
    p.yDuration = 1

    local bg = EasyPattern {
        pattern = checkerboard
    }
    p:setBackgroundPattern(bg)

    -- mock bg timer
    bg._getTime = function() return p.mockTime end

    local unshifted = {
        W, B, W, B, W, B,
        W, W, W, W, B, B,
        W, B, W, B, W, B,
        W, W, W, W, B, B,
        W, B, W, B, W, B,
        B, B, B, B, W, W,
    }

    -- This is subtle. We expect the visual result to have a fixed bgPattern, while the pattern itself
    -- moves in the Y axis. However, because pattern image will have any phase shifts applied to it, the
    -- net result here is that the background image appears to shift in the Y axis in the opposite direction,
    -- while the pattern itself remains fixed.
    local shiftedTwo = {
        W, B, W, B, W, B, --B, B, B, B, W, W,
        B, B, B, B, W, W,
        W, B, W, B, W, B, --W, W, W, W, B, B,
        W, W, W, W, B, B,
        W, B, W, B, W, B, --W, W, W, W, B, B,
        W, W, W, W, B, B,
    }

    p.mockTime = 0
    p:apply()
    sample = sampleImage(p.compositePatternImage, 6)
    lu.assertEquals(sample, unshifted)

    p.mockTime = 2/8
    p:apply()
    sample = sampleImage(p.compositePatternImage, 6)
    lu.assertEquals(sample, shiftedTwo)
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

    -- bgPattern in opposite axis has no effect
    p:setBackgroundPattern(EasyPattern { yDuration = 12 })
    lu.assertEquals(p:getXLoopDuration(), 8)

    -- bgPattern in same axis
    p:setBackgroundPattern(EasyPattern { xDuration = 12 })
    lu.assertEquals(p:getXLoopDuration(), 24)
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

    -- bgPattern in opposite axis has no effect
    p:setBackgroundPattern(EasyPattern { xDuration = 18 })
    lu.assertEquals(p:getYLoopDuration(), 12)

    -- bgPattern in same axis
    p:setBackgroundPattern(EasyPattern { yDuration = 18 })
    lu.assertEquals(p:getYLoopDuration(), 36)
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

    -- bgPattern with no duration
    p:setBackgroundPattern(EasyPattern {})
    lu.assertEquals(p:getLoopDuration(), 3)

    -- bgPattern in same axis
    p:setBackgroundPattern(EasyPattern { xDuration = 5, yDuration = 2 })
    lu.assertEquals(p:getLoopDuration(), 30)
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

function TestLoops:testUpdateCallback()
    local p = self.p
    local updated = false
    local time = 0
    local pattern = nil

    p.update = function(p, t)
        updated = true
        pattern = p
        time = t
        p.xShift = t -- trigger dirty bit
    end

    p.mockTime = 2
    p:apply()
    lu.assertIsFalse(p:isDirty())
    p.mockTime = 3
    _, _, dirty = p:getPhases()
    lu.assertIsTrue(dirty)
    lu.assertIsTrue(updated)
    lu.assertEquals(pattern, p)
    lu.assertEquals(time, 3)
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
