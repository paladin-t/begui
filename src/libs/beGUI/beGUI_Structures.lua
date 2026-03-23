--[[
The MIT License

Copyright (C) 2021 - 2026 Tony Wang

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

local beClass = require 'libs/beGUI/beClass'

--[[
Helper structures.
]]

local Percent = beClass.class({
	amount = 0,

	-- Constructs a Percent structure.
	-- `amount`: typically [0, 100]
	ctor = function (self, amount)
		self.amount = amount / 100
	end,

	__mul = function (self, num)
		return self.amount * num
	end
})

local function percent(amount)
	return Percent.new(amount)
end

local Calc = beClass.class({
	expr = 0,
	percent = 0,
	offset = 0,

	-- Constructs a Calc structure.
	-- `expr`: the layout expression
	ctor = function (self, expr)
		-- Prepare.
		local y = type(expr)
		if y == 'number' then
			self.offset = expr

			return
		end
		if y ~= 'string' then
			-- Do nothing.

			return
		end
		expr = expr:gsub('^%s*(.-)%s*$', '%1') -- Trim spaces.

		-- Named values.
		if
			expr == 'left' or expr == 'top' or expr == 'begin' or expr == 'head' or expr == 'front' or
			expr == 'empty' or expr == 'none'
		then
			-- Do nothing.

			return
		elseif
			expr == 'right' or expr == 'bottom' or expr == 'end' or expr == 'tail' or expr == 'back' or
			expr == 'full' or expr == 'all'
		then
			self.percent = 1

			return
		elseif
			expr == 'middle' or expr == 'center' or expr == 'centre' or
			expr == 'half'
		then
			self.percent = 0.5

			return
		end

		-- Percent strings, i.e. '2%'.
		local percentStr = string.match(expr, '^(-?%d+%.?%d*)%%$')
		if percentStr then
			self.percent = tonumber(percentStr) / 100

			return
		end

		-- Pixel strings, i.e. '20px'.
		local pxStr = string.match(expr, '^(-?%d+%.?%d*)px$')
		if pxStr then
			self.offset = tonumber(pxStr)

			return
		end

		-- Numeric strings, i.e. '0.02'.
		local numStr = string.match(expr, '^(-?%d+%.?%d*)$')
		if numStr then
			local num = tonumber(numStr)
			self.percent = num

			return
		end

		-- Construct a `Calc` object.
		local percentStr, opStr, pxStr = string.match(expr, '^(-?%d+%.?%d*)%%%s*([+-]?)%s*(-?%d+%.?%d*)px$')
		if percentStr and pxStr then
			self.percent = tonumber(percentStr) / 100
			local sign = opStr or '+'
			self.offset = tonumber(sign .. pxStr)
		else
			self.percent = 0
			self.offset = 0
		end
	end,

	__mul = function (self, num)
		return self.percent * num + self.offset
	end
})

local function calc(expr)
	-- Prepare.
	local y = type(expr)
	if y == 'number' then
		return expr
	end
	if y ~= 'string' then
		return 0
	end
	expr = expr:gsub('^%s*(.-)%s*$', '%1') -- Trim spaces.

	-- Named values.
	if
		expr == 'left' or expr == 'top' or expr == 'begin' or expr == 'head' or expr == 'front' or
		expr == 'empty' or expr == 'none'
	then
		return Percent.new(0)
	elseif
		expr == 'right' or expr == 'bottom' or expr == 'end' or expr == 'tail' or expr == 'back' or
		expr == 'full' or expr == 'all'
	then
		return Percent.new(100)
	elseif
		expr == 'middle' or expr == 'center' or expr == 'centre' or
		expr == 'half'
	then
		return Percent.new(50)
	end

	-- Percent strings, i.e. '2%'.
	local percentStr = string.match(expr, '^(-?%d+%.?%d*)%%$')
	if percentStr then
		return Percent.new(tonumber(percentStr))
	end

	-- Pixel strings, i.e. '20px'.
	local pxStr = string.match(expr, '^(-?%d+%.?%d*)px$')
	if pxStr then
		return tonumber(pxStr)
	end

	-- Numeric strings, i.e. '0.02'.
	local numStr = string.match(expr, '^(-?%d+%.?%d*)$')
	if numStr then
		local num = tonumber(numStr)

		return Percent.new(num * 100)
	end

	-- Fall to construct a `Calc` object.
	return Calc.new(expr)
end

--[[
Exporting.
]]

return {
	Percent = Percent,
	percent = percent,
	Calc = Calc,
	calc = calc
}
