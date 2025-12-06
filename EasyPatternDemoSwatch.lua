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

        -- special case for a reflected example
        if self.id == "reflected" then
            self.pattern:setReflected(false, false)
            gfx.setPattern(self.pattern:apply())
            gfx.fillRect(x, y, w/2, h)
            self.pattern:setReflected(true, false)
        end
    gfx.popContext()
end


--! PATTERNS
--
-- This is the list of example patterns, which may be passed by ID to `init`. Extend this list with
-- patterns of your own for quick and easy experimentation.

patterns = {
    checker = EasyPattern {
        pattern = { 0xF0, 0xF0, 0xF0, 0xF0, 0x0F, 0x0F, 0x0F, 0x0F },
        duration = 0.25,
    },

    conveyor = EasyPattern {
        pattern    = playdate.graphics.image.kDitherTypeVerticalLine,
        bgColor    = playdate.graphics.kColorWhite,
        xDuration  = 1,
        -- un-comment the line below (and comment out the line above) to operate with the crank!
        -- update     = function(p) p.xShift = playdate.getCrankPosition()//15 end,
    },

    scanline = EasyPattern {
        pattern = {
            ditherType = playdate.graphics.image.kDitherTypeHorizontalLine,
            color      = gfx.kColorWhite,
            alpha      = 0.8,
        },
        duration  = 0.4,
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
        duration = 1, -- must be non-zero to trigger easing function, but value doesn't matter
        scale    = 2, -- adjust to change the amplitude of vibration
        ease     = function(_, _, _, _) return math.random(0, 5) / 5 end, -- note that all args are ignored
        -- more ways than one…try commenting out the three lines above and uncommenting
        -- this update function to achieve the same result. The last constant represents scale.
        -- update = function(p)
        --   p.xShift = math.random(0,8)/8 * 2
        --   p.yShift = math.random(0,8)/8 * 2
        -- end,
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

    blink = EasyPattern {
        pattern = BitPattern {
            ' X X X X X X X X ',
            ' X X X X X X . X ',
            ' X X X X X . . X ',
            ' X X X X . . . X ',
            ' X X X . . . . X ',
            ' X X . . . . . X ',
            ' X . . . . . . X ',
            ' X X X X X X X X ',
        },
        -- the divisor is the blink speed in milliseconds; decrease it to strobe faster!
        update = function(p, t) p:setInverted(t*1000//1000 % 2 == 0) end
        -- more ways than one…try commenting out the line above and uncommenting those below
        -- duration = 1,
        -- loopCallback = function(p) p:setInverted(not p.inverted) end,
        -- ease = function() return 0 end, -- don't actually ease, just let `duration` trigger `loopCallback`
    },

    -- try drawing this pattern next to an unreflected version
    reflected = EasyPattern {
        ditherType = playdate.graphics.image.kDitherTypeDiagonalLine,
        alpha      = 0.2,
        xDuration  = 1,
        xReflected = true,
        bgColor    = gfx.kColorWhite,
    },

    waterfall = EasyPattern {
        pattern = BitPattern {
            -- pattern --------     -- alpha ----------
            ' . . . . . . . . ',    ' . . . . . . . . ',
            ' . . . . . . . . ',    ' . . . . . . . . ',
            ' . . . . . . . . ',    ' . . . . . . . . ',
            ' . . . . . . . . ',    ' . X . . . . . . ',
            ' . . . . . . . . ',    ' . . X . . . . X ',
            ' . . . . . . . . ',    ' . . . . X . X . ',
            ' . . . . . . . . ',    ' . . . . . . . . ',
            ' . . . . . . . . ',    ' . . . . . . . . ',
        },
        bgPattern = EasyPattern {
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
        duration = 1.25,
        yReversed = true,
        yEase     = playdate.easingFunctions.inOutSine,
        yScale    = 2,
        xShift    = 2,
        alpha     = 1,
    },

    dashing = EasyPattern {
        pattern = gfx.imagetable.new("images/hdashes"),
        xDuration = 2,
        ease = playdate.easingFunctions.outExpo,
        reverses = true,
        tickDuration = 1/8,
        scale = 6,
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
