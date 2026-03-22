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
	local y = type(expr)
	if y == 'number' then
		return expr
	end
	if y ~= 'string' then
		return 0
	end

	if expr == 'left' or expr == 'top' or expr == 'begin' or expr == 'head' or expr == 'front' then
		return Percent.new(0)
	elseif expr == 'right' or expr == 'bottom' or expr == 'end' or expr == 'tail' or expr == 'back' then
		return Percent.new(100)
	elseif expr == 'middle' or expr == 'center' or expr == 'centre' then
		return Percent.new(50)
	end

	expr = expr:gsub('^%s*(.-)%s*$', '%1')

	local percentStr = string.match(expr, '^(-?%d+%.?%d*)%%$')
	if percentStr then
		return Percent.new(tonumber(percentStr))
	end

	local pxStr = string.match(expr, '^(-?%d+%.?%d*)px$')
	if pxStr then
		return tonumber(pxStr)
	end

	local numStr = string.match(expr, '^(-?%d+%.?%d*)$')
	if numStr then
		local num = tonumber(numStr)

		return Percent.new(num * 100)
	end

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
