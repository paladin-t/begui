--[[
The MIT License

Copyright (C) 2021 Tony Wang

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
local beWidget = require 'libs/beGUI/beGUI_Widget'

--[[
Widgets.
]]

local Custom = beClass.class({
	_name = 'Custom',

	-- Constructs a Custom.
	ctor = function (self, name)
		beWidget.Widget.ctor(self)

		if name then
			self._name = name
		end
	end,

	__tostring = function (self)
		return self.name
	end,

	navigatable = function (self)
		return 'children'
	end,

	_update = function (self, theme, delta, dx, dy, event)
		if not self.visibility then
			return
		end

		local ox, oy = self:offset()
		local px, py = self:position()
		local x, y = dx + px + ox, dy + py + oy
		local w, h = self:size()
		self:_trigger('updated', self, x, y, w, h)

		beWidget.Widget._update(self, theme, delta, dx, dy, event)
	end
}, beWidget.Widget)

--[[
Exporting.
]]

return {
	Custom = Custom
}
