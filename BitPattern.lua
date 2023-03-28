
-- This masquerades as a companion class to EasyPattern, but in reality it's just a convenience
-- function which returns a table of numbers converted from their binary string representations.
-- Use it to craft a patterns to pass to e.g. `playdate.graphics.setPattern`.
--
-- When including an alpha channel, its rows should be interleaved with the pattern rows, such
-- that the pattern and alpha channel representations appear side-by-side in the file.

function BitPattern(binaryRows)
    local hasAlpha = #binaryRows == 16
    local pattern = {}
    for i, binaryRow in ipairs(binaryRows) do
        if hasAlpha then
            pattern[i//2 + (i % 2 == 0 and 8 or 1)] = tonumber(binaryRow, 2)
        else
            pattern[i] = tonumber(binaryRow, 2)
        end
    end
    return pattern
end
