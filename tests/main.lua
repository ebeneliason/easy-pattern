import 'luaunit/playdate_luaunit_fix'
import 'luaunit/luaunit'
import 'tests'

local gfx = playdate.graphics
local cnt = kTextAlignment.center

-- turns off updating
playdate.stop()
gfx.drawTextAligned("*RUNNING…*", 200, 110, cnt)
gfx.drawTextAligned("Open console for details", 200, 140, cnt)

-- when outputting a table, include a table address
luaunit.PRINT_TABLE_REF_IN_ERROR_MSG = true

-- process the command line args (if any)
local testOutputFilename = "test_output"
local outputType = "text"
local luaunit_args = {'--output', 'text', '--verbose', '-r',}

-- limit tests to run (specify as `TestSuite` or `TestSuite.testName`)
local testsToRun = {
	-- "TestSuite.testName"
}
for _, test in ipairs(testsToRun) do
	table.insert(luaunit_args, test)
end

-- run the tests
local runner = luaunit.LuaUnit.new()
local returnValue = runner:runSuite(table.unpack(luaunit_args))

gfx.fillRect(0, 106, 400, 24)
gfx.setImageDrawMode(playdate.graphics.kDrawModeInverted)
gfx.drawTextAligned(returnValue == 0 and "*SUCCESS*" or "*FAIL*", 200, 110, cnt)

local s = "*" .. runner.result.passedCount .. " tests passed*"
if returnValue > 0 then
	s = s .. ", *" .. runner.result.notPassedCount .. " failed*"
end
s = s .. "\nOpen console for details"

gfx.setColor(gfx.kColorWhite)
gfx.fillRect(0, 140, 400, 50)
gfx.setImageDrawMode(playdate.graphics.kDrawModeCopy)
gfx.drawTextAligned(s, 200, 140, cnt)
