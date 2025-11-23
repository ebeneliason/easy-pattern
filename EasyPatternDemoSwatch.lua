import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"

import "EasyPattern"

local gfx <const> = playdate.graphics

local WIDTH <const> = 80
local HEIGHT <const> = WIDTH

local patterns


--! USAGE
--
-- Create an instance of this class to view `EasyPattern` examples. Place this file next to `EasyPattern.lua`
-- in your project and include it in `main.lua`. Create an instance and specify a pattern ID (see the list of
-- example patterns below).
--
-- local swatch = EasyPatternDemoSwatch("waves")
--
-- Alternatively, call `EasyPatternDemoSwatch.tile()` to tile all of the example patterns randomly on screen.
-- As an interesting experiment, try turning on `Highlight Screen Updates` in the Simulator's `View` menu while
-- tiling. Assuming you aren't using other sprites or drawing APIs underneath, this will illustrate how each
-- swatch redraws only on frames when the pattern changes.
--
-- NOTE: This demo uses sprites: make sure to call `playdate.graphics.sprite.update()` each frame.


--! SWATCH CLASS
--
-- This is the demo sprite class itself. As you can see, it's quite small. You can use this as a template for
-- creating your own sprites that perform drawing with `EasyPattern`. Just check to see if a redraw is needed in
-- `update`, and then use any drawing APIs after calling `setPattern(myPattern:apply())` within `draw`
class('EasyPatternDemoSwatch').extends(gfx.sprite)

function EasyPatternDemoSwatch:init(id)
    EasyPatternDemoSwatch.super.init(self)

    self.pattern = patterns[id] or patterns.checker
    self.id = id

    self:setSize(WIDTH, HEIGHT)
    self:moveTo(200, 120) -- centered
    self:setZIndex(32767) -- topmost
    self:add() -- auto-add for convenience
end

function EasyPatternDemoSwatch:update()
    -- check to see if the pattern requires a redraw this frame
    if self.pattern:isDirty() then
        self:markDirty()
    end
end

function EasyPatternDemoSwatch:draw(x, y, w, h)
    gfx.pushContext()
        -- apply the pattern
        gfx.setPattern(self.pattern:apply())

        -- do some drawing with it
        if self.id == "ants" then
            gfx.drawRect(0, 0, self.width, self.height)
        else
            gfx.fillRect(x, y, w, h)
        end

        -- special cases for a couple of multi-pattern swatches
        if self.id == "reflected" then
            self.pattern:setReflected(false, false)
            gfx.setPattern(self.pattern:apply())
            gfx.fillRect(x, y, w/2, h)
            self.pattern:setReflected(true, false)
        elseif self.id == "oozeOverlay" then
            gfx.setPattern(patterns.ooze:apply())
            gfx.fillRect(x, y, w, h)
            gfx.setPattern(self.pattern:apply())
            gfx.fillRect(x, y, w, h)
        end
    gfx.popContext()
end


--! PATTERNS
--
-- This is the list of example patterns, which may be passed by ID to `init`. Extend this list with
-- patterns of your own for quick and easy experimentation.

patterns = {
    checker = EasyPattern {
        pattern = BitPattern {
            ' X X X X . . . . ',
            ' X X X X . . . . ',
            ' X X X X . . . . ',
            ' X X X X . . . . ',
            ' . . . . X X X X ',
            ' . . . . X X X X ',
            ' . . . . X X X X ',
            ' . . . . X X X X ',
        },
        duration = 0.25,
    },

    conveyor = EasyPattern {
        ditherType = playdate.graphics.image.kDitherTypeVerticalLine,
        xDuration  = 0.5,
        bgColor    = playdate.graphics.kColorWhite,
    },

    scanline = EasyPattern {
        ditherType = playdate.graphics.image.kDitherTypeHorizontalLine,
        color = gfx.kColorWhite,
        alpha = 0.8,
        duration = 0.4,
        yReversed = true,
    },

    ooze = EasyPattern {
        pattern = BitPattern {
            ' X X X X X X X X ',
            ' X X X X X X X X ',
            ' X X X X X X X X ',
            ' . . X X X X X . ',
            ' X . . X X X . . ',
            ' X X . . . . . X ',
            ' X X X X X X X X ',
            ' X X X X X X X X ',
        },
        yDuration = 1,
        yReversed = true,
    },

    -- try drawing this pattern atop ooze!
    oozeOverlay = EasyPattern {
        pattern = BitPattern {
            -- pattern --------     -- alpha ----------
            ' X X X X X X X X ',    ' . . . . . . . . ',
            ' X X X X X X X X ',    ' . . . . . . . . ',
            ' X X X X X X X X ',    ' . . . . . . . . ',
            ' . . X X X X X . ',    ' . . . . . . . . ',
            ' X . . X X X . . ',    ' . X . . . . . X ',
            ' X X . . . . . X ',    ' . . X . X . X . ',
            ' X X X X X X X X ',    ' . . . . . . . . ',
            ' X X X X X X X X ',    ' . . . . . . . . ',
        },
        yEase     = playdate.easingFunctions.inOutSine,
        yDuration = 0.5,
        yReversed = true,
        xDuration = 1,
        shift     = 3,
    },

    -- use this pattern with `drawRect` instead of a fill!
    ants = EasyPattern {
        ditherType = playdate.graphics.image.kDitherTypeDiagonalLine,
        xDuration  = 0.25,
        bgColor    = playdate.graphics.kColorWhite,
    },

    bounce = EasyPattern {
        pattern = BitPattern {
            ' . . . . . . . . ',
            ' X X X . X X X X ',
            ' X X X . X X X X ',
            ' X X X . X X X X ',
            ' . . . . . . . . ',
            ' X X X X X X X . ',
            ' X X X X X X X . ',
            ' X X X X X X X . ',
        },
        yDuration = 1,
        yEase     = playdate.easingFunctions.outBounce,
        yReversed = true,
        scale     = 2,
    },

    waves = EasyPattern {
        pattern = BitPattern {
            ' . . . . . . . . ',
            ' . X . . . . . X ',
            ' . . . X . X . . ',
            ' . . . . . . . . ',
            ' . . . . . . . . ',
            ' X X X X . . . . ',
            ' . . . . X X X X ',
            ' . . . . . . . . ',
        },
        xDuration = 0.5,
        yDuration = 1.0,
        yEase     = playdate.easingFunctions.inOutSine,
        yReverses = true,
    },

    circle = EasyPattern {
        pattern = BitPattern {
            ' X X X X X X X X ',
            ' X X . . . X X X ',
            ' X . X X X . X X ',
            ' X . X X X . X X ',
            ' X . X X X . X X ',
            ' X X . . . X X X ',
            ' X X X X X X X X ',
            ' X X X X X X X X ',
        },
        duration  = 1,
        ease      = playdate.easingFunctions.inOutSine,
        xOffset   = 0.5, -- half the duration
        reverses  = true,
        scale     = 3,
    },

    sway = EasyPattern {
        pattern = BitPattern {
            ' X X X X X X X X ',
            ' X X X X X X X X ',
            ' X X X X . X X X ',
            ' . X X X X X X X ',
            ' . . X X X X X . ',
            ' . X . X X X . X ',
            ' X . X . . . X . ',
            ' X X . X . X . X ',
        },
        xDuration = 2,
        yDuration = 1, -- half the x duration
        ease      = playdate.easingFunctions.inOutSine,
        reverses  = true,
        yReversed = true,
        xScale    = 3,
    },

    steam = EasyPattern {
        pattern = BitPattern {
            -- pattern --------     -- alpha ----------
            ' . . X . . X . . ',    ' . . X . X X . . ',
            ' . X . . . . . . ',    ' . X X . . . . . ',
            ' . X . . . . . . ',    ' . X X . . . . . ',
            ' . . X . . . . . ',    ' . . X X . . . . ',
            ' . . . . . . . . ',    ' . . . . . . . . ',
            ' . . . . . X . . ',    ' . . . . . X . . ',
            ' . . . . . . X . ',    ' . . . . . X X . ',
            ' . . . . . . X . ',    ' . . . . . X X . ',
        },
        duration  = 1,
        ease      = playdate.easingFunctions.inOutSine,
        yOffset   = 0.5, -- half the duration
        xReverses = true,
    },

    perlin = EasyPattern {
        pattern = BitPattern {
            ' . . . . . . . . ',
            ' . X . . . X . . ',
            ' . . . X . . . . ',
            ' . . . . . . . X ',
            ' . . . . . X . . ',
            ' . X . . . . . . ',
            ' . . . . . . . . ',
            ' . . . X . . . X ',
        },
        xDuration = 3,
        yDuration = 2,
        xEase     = function(t, b, c, d) return b + playdate.graphics.perlin(t / d, 2, 6, 8, d, 0.75) * c end,
        yEase     = function(t, b, c, d) return b + playdate.graphics.perlin(t / d, 5, 9, 9, d, 0.75) * c end,
        scale     = 10,
    },

    vibrate = EasyPattern {
        pattern = BitPattern {
            ' . . . . . . . . ',
            ' . . . . . . . . ',
            ' . . . X . . . . ',
            ' . . . X X . . . ',
            ' . X X X X X . . ',
            ' . . X X . . . . ',
            ' . . . X . . . . ',
            ' . . . . . . . . ',
        },
        duration = 1,
        scale    = 2,
        ease     = function() return math.random(0,5)/5 end,
    },

    dotmatrix = EasyPattern {
        pattern = BitPattern {
            ' X X X X X X X X ',
            ' X X X X X X X X ',
            ' X X X X X X X X ',
            ' X X X . . X X X ',
            ' X X X . . X X X ',
            ' X X X X X X X X ',
            ' X X X X X X X X ',
            ' X X X X X X X X ',
        },
        yDuration = 1,
        yEase     = function(t, b, c, d) return playdate.easingFunctions.linear(math.floor(t*4)/4, b, c, d) end,
    },

    -- try drawing this pattern next to an unreflected version
    reflected = EasyPattern {
        ditherType = playdate.graphics.image.kDitherTypeDiagonalLine,
        alpha      = 0.2,
        xDuration  = 1,
        xReflected = true,
        bgColor    = gfx.kColorWhite,
    },
}

--! TILING
-- A handy function to tile the patterns on screen

function EasyPatternDemoSwatch.tile()
    local i = 0
    for id in pairs(patterns) do
        local x = WIDTH/2 + i*WIDTH
        EasyPatternDemoSwatch(id):moveTo(x%400, HEIGHT/2 + x//400*HEIGHT)
        i += 1
    end
end
