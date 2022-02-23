--[[
The MIT License

Copyright (C) 2021 - 2022 Tony Wang

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
Stack.
]]

local NonShrinkStack = beClass.class({
	_threshold = nil,
	_stack = nil,
	_count = 0,

	ctor = function (self, threshold)
		self._threshold = threshold or 5
		self._stack = { }
		self._count = 0
	end,

	__tostring = function (self)
		return 'NonShrinkStack'
	end,

	__len = function (self)
		return self._count
	end,

	push = function (self, arg1, arg2)
		if self._count >= self._threshold then
			error('Stack overflow.')
		end
		if self._count >= #self._stack then
			table.insert(self._stack, { arg1, arg2 })
			self._count = self._count + 1
		else
			self._count = self._count + 1
			local obj = self._stack[self._count]
			obj[1], obj[2] = arg1, arg2
		end

		return self
	end,
	pop = function (self)
		if self._count == 0 then
			error('Pop from empty stack.')
		end
		local result = self._stack[self._count]
		self._count = self._count - 1
		local ret1, ret2 = result[1], result[2]
		result[1], result[2] = false, false

		return ret1, ret2
	end,
	top = function (self)
		if self._count == 0 then
			return nil
		end
		local result = self._stack[self._count]

		return result[1], result[2]
	end,
	count = function (self)
		return self._count
	end,
	empty = function (self)
		return self._count == 0
	end,
	clear = function (self)
		while not self:empty() do
			self:pop()
		end

		return self
	end,
	get = function (self, index)
		if index < 1 or index > self._count then
			return nil
		end

		return self._stack[index]
	end,
	set = function (self, index, data)
		if index < 1 or index > self._count then
			return self
		end

		self._stack[index] = data

		return self
	end
})

--[[
Exporting.
]]

return {
	NonShrinkStack = NonShrinkStack
}
