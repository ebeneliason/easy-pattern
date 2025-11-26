-- EasyPattern globals
--
-- To validate, install luacheck and then run it from the root of this repo:
-- $ luacheck *.lua
--
-- This file can also be used with toyboxpy (https://toyboxpy.io):
--
-- 1. Add this to your project's .luacheckrc:
--    require "toyboxes/luacheck" (stds, files)
--
-- 2. Add 'toyboxes' to your std:
--    std = "lua54+playdate+toyboxes"

return {
    globals = {
        EasyPattern = {
            fields = {
                super = {
                    fields = {
                        className = {},
                        init = {}
                    },
                },
                className = {},
                init = {},
                setColor = {},
                setBackgroundColor = {},
                setBackgroundPattern = {},
                setPattern = {},
                setDitherPattern = {},
                setRotated = {},
                setReflected = {},
                setInverted = {},
                _updatePatternImage = {},
                _getTime = {},
                getPhases = {},
                setPhaseShifts = {},
                shiftPhasesBy = {},
                getLoopDuration = {},
                getXLoopDuration = {},
                getYLoopDuration = {},
                isDirty = {},
                apply = {}
            }
        },
        BitPattern = {},
        EasyPatternDemoSwatch = {
            fields = {
                super = {
                    fields = {
                        className = {},
                        init = {}
                    }
                },
                className = {},
                init = {},
                draw = {},
                update = {},
                tile = {},
            }
        }
    }
}
