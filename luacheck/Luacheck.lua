-- EasyPattern globals
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
                setPattern = {},
                setDitherPattern = {},
                updatePatternImage = {},
                getPhases = {},
                isDirty = {},
                apply = {}
            }
        },
    }
}
