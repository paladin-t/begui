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
local beUtils = require 'libs/beGUI/beGUI_Utils'
local beWidget = require 'libs/beGUI/beGUI_Widget'

--[[
Widgets.
]]

local List = beClass.class({
	_pressed = false,
	_pressedTimestamp = nil,
	_pressedPosition = nil,
	_pressingPosition = nil,
	_scrolling = false,
	_scrollY = 0,
	_maxY = 0,

	-- Constructs a List.
	ctor = function (self)
		beWidget.Widget.ctor(self)
	end,

	__tostring = function (self)
		return 'List'
	end,

	navigatable = function (self)
		return 'content'
	end,

	_update = function (self, theme, delta, dx, dy, event)
		if not self.visibility then
			return
		end

		local ox, oy = self:offset()
		local px, py = self:position()
		local x, y = dx + px + ox, dy + py + oy
		local w, h = self:size()
		local down = false
		local intersects = Math.intersects(event.mousePosition, Rect.byXYWH(x, y, w, h))
		if event.canceled or event.context.dragging then
			self._pressed = false
		elseif self._pressed then
			down = event.mouseDown
		else
			down = event.mouseDown and intersects
		end
		if down and not self._pressed then
			self._pressed = true
			self._pressedTimestamp = DateTime.ticks()
			self._pressedPosition = event.mousePosition
			self._pressingPosition = event.mousePosition
			self._scrolling = false
		elseif not down and self._pressed then
			self._pressed = false
			self._pressedTimestamp = nil
			self._pressedPosition = nil
			self._pressingPosition = nil
			self._scrolling = false
		elseif down and self._pressed then
			if self._pressedTimestamp ~= nil then
				local diff = DateTime.toSeconds(DateTime.ticks() - self._pressedTimestamp)
				if diff < 0.3 and self._pressedPosition ~= self._pressingPosition then
					self._scrolling = true
					self._pressedTimestamp = nil
				end
			end
		end

		local elem = theme['list']
		beUtils.tex9Grid(elem, x, y, w, h, nil, self.transparency)

		if self._maxY < h then
			self._maxY = h
		end
		if self._pressingPosition then
			if self._scrolling then
				self._scrollY = self._scrollY + (event.mousePosition.y - self._pressingPosition.y)
				self._scrollY = beUtils.clamp(self._scrollY, h - self._maxY, 0)
			end
			self._pressingPosition = event.mousePosition
		elseif intersects and event.mouseWheel < 0 then
			self._scrollY = beUtils.clamp(self._scrollY - 16, h - self._maxY, 0)
		elseif intersects and event.mouseWheel > 0 then
			self._scrollY = beUtils.clamp(self._scrollY + 16, h - self._maxY, 0)
		end
		if not intersects then
			event = {
				mousePosition = event.mousePosition,
				mouseDown = false,
				mouseWheel = 0,
				canceled = false,
				context = event.context
			}
		elseif self._scrolling then
			event = {
				mousePosition = event.mousePosition,
				mouseDown = false,
				mouseWheel = 0,
				canceled = true,
				context = event.context
			}
		end

		local x_, y_, w_, h_ = clip(x + 1, y + 1, w - 1, h - 2)
		beWidget.Widget._update(self, theme, delta, dx, dy + self._scrollY, event)
		if x_ then
			clip(x_, y_, w_, h_)
		else
			clip()
		end
	end,
	_updateChildren = function (self, theme, delta, dx, dy, event)
		if self.children == nil then
			return
		end
		self._maxY = 0
		for _, c in ipairs(self.children) do
			c:_update(theme, delta, dx, dy, event)
			local _, py = c:position()
			local _, h = c:size()
			local y = py + h
			if y > self._maxY then
				self._maxY = y
			end
		end
	end,
	_updateFocus = function (self, delta, x, y)
		local HALF_DURATION = 1
		self.focusTicks = self.focusTicks + delta
		if self.focusTicks >= HALF_DURATION * 2 then
			self.focusTicks = self.focusTicks - HALF_DURATION * 2
		end
		local f = 0
		if self.focusTicks < HALF_DURATION then
			f = beUtils.clamp(self.focusTicks / HALF_DURATION, 0, 1)
		else
			f = beUtils.clamp(1 - (self.focusTicks - HALF_DURATION) / HALF_DURATION, 0, 1)
		end

		local w, h = self:size()
		local col = Color.new(55 + 200 * f, 55 + 200 * f, 55 + 200 * (1 - f))
		rect(x, y - self._scrollY, x + w - 1, y + h - 1 - self._scrollY, false, col)
	end,

	_scroll = function (self, dir)
		local _, h = self:size()
		if dir < 0 then
			if self._scrollY < 0 then
				self._scrollY = beUtils.clamp(self._scrollY + 16, h - self._maxY, 0)

				return true
			end
		elseif dir > 0 then
			if self._scrollY > h - self._maxY then
				self._scrollY = beUtils.clamp(self._scrollY - 16, h - self._maxY, 0)

				return true
			end
		end

		return false
	end
}, beWidget.Widget)

local Draggable = beClass.class({
	_draggedTimestamp = nil,
	_draggedPosition = nil,
	_draggingPosition = nil,
	_dragging = false,
	_dragOffset = nil,

	-- Constructs a Draggable.
	ctor = function (self)
		beWidget.Widget.ctor(self)

		self._dragOffset = Vec2.new(0, 0)
	end,

	__tostring = function (self)
		return 'Draggable'
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
		local down = false
		local intersects = Math.intersects(event.mousePosition, Rect.byXYWH(x, y, w, h))
		if event.context.dragging then
			down = event.mouseDown
		else
			down = event.mouseDown and intersects
		end
		if down and not event.context.dragging then
			event.context.dragging = self
			self._draggedTimestamp = DateTime.ticks()
			self._draggedPosition = event.mousePosition
			self._draggingPosition = event.mousePosition
			self._dragging = false
		elseif not down and event.context.dragging == self then
			event.context.dragging = nil
			self._draggedTimestamp = nil
			self._draggedPosition = nil
			self._draggingPosition = nil
			self._dragging = false
			self._dragOffset = Vec2.new(0, 0)
		elseif down and event.context.dragging == self then
			if self._draggedTimestamp ~= nil then
				local diff = DateTime.toSeconds(DateTime.ticks() - self._draggedTimestamp)
				if diff < 0.3 and self._draggedPosition ~= self._draggingPosition then
					self._dragging = true
					self._draggedTimestamp = nil
				end
			end
		end

		if self._draggingPosition then
			if self._dragging then
				self._dragOffset = self._dragOffset + (event.mousePosition - self._draggingPosition)
			end
			self._draggingPosition = event.mousePosition
		end
		if not intersects then
			event = {
				mousePosition = event.mousePosition,
				mouseDown = false,
				mouseWheel = 0,
				canceled = false,
				context = event.context
			}
		elseif self._dragging then
			event = {
				mousePosition = event.mousePosition,
				mouseDown = false,
				mouseWheel = 0,
				canceled = event.canceled,
				context = event.context
			}
		end

		beWidget.Widget._update(self, theme, delta, dx + self._dragOffset.x, dy + self._dragOffset.y, event)
	end
}, beWidget.Widget)

local Droppable = beClass.class({
	_pressed = false,
	_dropping = nil,
	_dropped = false,

	-- Constructs a Droppable.
	ctor = function (self)
		beWidget.Widget.ctor(self)
	end,

	__tostring = function (self)
		return 'Droppable'
	end,

	navigatable = function (self)
		return 'all'
	end,

	_update = function (self, theme, delta, dx, dy, event)
		if not self.visibility then
			return
		end

		local ox, oy = self:offset()
		local px, py = self:position()
		local x, y = dx + px + ox, dy + py + oy
		local w, h = self:size()
		local down = false
		local intersects = Math.intersects(event.mousePosition, Rect.byXYWH(x, y, w, h))
		local dropped = nil
		if event.canceled then
			self._dropping = nil
		else
			down = event.mouseDown and intersects
		end
		if down and not self._dropping then
			if event.context.dragging then
				self._dropping = event.context.dragging
				self._dropped = true
				self:_trigger('entered', self, self._dropping)
			end
		elseif not down and self._dropping then
			if event.mouseDown then
				self:_trigger('left', self, self._dropping)
			else
				local droppable = self:_trigger('dropping', self, self._dropping)
				if droppable then
					dropped = droppable -- Doesn't trigger 'clicked' when has droppable.
					self:_trigger('dropped', self, self._dropping)
					if self._dropping.parent then
						self._dropping.parent:removeChild(self._dropping)
						self:addChild(self._dropping)
					end
				else
					self:_trigger('left', self, self._dropping)
				end
			end
			self._dropping = nil
		end
		if dropped then
			event.context.active = nil
			self._pressed = false
			event.context.focus = self
			self._dropped = nil
		elseif down and not self._pressed then
			event.context.active = self
			self._pressed = true
		elseif not event.mouseDown and self._pressed then
			event.context.active = nil
			self._pressed = false
			event.context.focus = self
			if not self._dropped then
				self:_trigger('clicked', self)
			end
			self._dropped = nil
		elseif event.context.focus == self and event.context.navigated == 'press' then
			self:_trigger('clicked', self)
			event.context.navigated = false
		end

		beWidget.Widget._update(self, theme, delta, dx, dy, event)
	end
}, beWidget.Widget)

local Tab = beClass.class({
	_pages = nil,
	_pagesInitialized = false,
	_value = 1,
	_focusArea = nil,
	_headHeight = nil,
	_pressed = false,

	-- Constructs a Tab.
	ctor = function (self)
		beWidget.Widget.ctor(self)

		self.content = { 'Noname' }

		self._pages = { { } }
		self._focusArea = { 0, 0, 0, 0 }
	end,

	__tostring = function (self)
		return 'Tab'
	end,

	add = function (self, title)
		if self._pagesInitialized then
			table.insert(self.content, title)
			table.insert(self._pages, { })
		else
			self.content = { title }
			self._pagesInitialized = true
		end

		return self
	end,
	count = function (self)
		return #self.content
	end,

	-- Gets the active index.
	getValue = function (self)
		return self._value
	end,
	-- Sets the active index.
	setValue = function (self, val)
		if self._value == val then
			return self
		end
		if val < 1 or val > #self.content then
			return self
		end
		self._value = val
		self:_trigger('changed', self, self._value)

		for index, page in ipairs(self._pages) do
			local visible = self._value == index
			for _, c in ipairs(page) do
				c:setVisible(visible)
			end
		end

		return self
	end,

	addChild = function (self, child)
		local result = beWidget.Widget.addChild(self, child)
		table.insert(self._pages[self._value], child)

		return result
	end,
	removeChild = function (self, child)
		local result = beWidget.Widget.removeChild(self, child)
		self._pages[self._value] = beUtils.filter(self._pages[self._value], function (val)
			return val ~= child
		end)

		return result
	end,

	navigatable = function (self)
		return 'all'
	end,

	_update = function (self, theme, delta, dx, dy, event)
		if not self.visibility then
			return
		end

		local ox, oy = self:offset()
		local px, py = self:position()
		local x, y = dx + px + ox, dy + py + oy
		local w, h = self:size()
		local down = false
		local intersectsHead = Math.intersects(event.mousePosition, Rect.byXYWH(x, y, w, self._headHeight))
		if event.context.active and event.context.active ~= self then
			self._pressed = false
		elseif event.canceled or event.context.dragging then
			self._pressed = false
		elseif self._pressed then
			down = event.mouseDown
		else
			down = event.mouseDown and Math.intersects(event.mousePosition, Rect.byXYWH(x, y, w, h))
		end
		local pressed = false
		if down and not self._pressed then
			self._pressed = true
		elseif not down and self._pressed then
			self._pressed = false
			event.context.focus = self
			pressed = true
		elseif intersectsHead and event.mouseWheel < 0 then
			if #self.content ~= 0 then
				local val = self._value - 1
				if val < 1 then
					val = 1
				end
				self:setValue(val)
			end
		elseif intersectsHead and event.mouseWheel > 0 then
			if #self.content ~= 0 then
				local val = self._value + 1
				if val > #self.content then
					val = #self.content
				end
				self:setValue(val)
			end
		elseif event.context.focus == self and event.context.navigated == 'inc' then
			local val = self._value + 1
			self:setValue(val)
			event.context.navigated = false
		elseif event.context.focus == self and event.context.navigated == 'dec' then
			local val = self._value - 1
			self:setValue(val)
			event.context.navigated = false
		end

		local elem = theme['tab']
		local paddingX, paddingY = elem.content_offset[1] or 2, elem.content_offset[2] or 2
		local x_ = x
		for i, v in ipairs(self.content) do
			local w_, h_ = nil, nil
			if type(v) == 'string' then
				w_, h_ = measure(v, theme['font'].resource)
			else
				w_, h_ = v.area[3], v.area[4]
			end
			w_ = w_ + paddingX * 2
			h_ = h_ + paddingY * 2
			if self._headHeight == nil then
				self._headHeight = h_
			end
			if pressed then
				if Math.intersects(event.mousePosition, Rect.byXYWH(x_, y, w_, h_)) then
					local val = i
					self:setValue(val)
				end
			end
			local black = Color.new(0, 0, 0, self.transparency or 255)
			if i == self._value then
				self._focusArea[1], self._focusArea[2], self._focusArea[3], self._focusArea[4] =
					x_ + 1, y + 1, x_ + w_ - 2, y + h_ - 1
				-- Tab itself.
				line(x_, y, x_ + w_ - 1, y, black)
				line(x_ + w_ - 1, y, x_ + w_ - 1, y + h_, black)
				-- Border.
				line(x, y + h - 1, x + w - 1, y + h - 1, black)
				line(x, y, x, y + h - 1, black)
				line(x + w - 1, y + h_, x + w - 1, y + h - 1, black)
				line(x_ + w_ - 1, y + h_, x + w - 1, y + h_, black)
				line(x, y + h_, x_, y + h_, black)
			else
				line(x_, y, x_ + w_ - 1, y, black)
				line(x_ + w_ - 1, y, x_ + w_ - 1, y + h_, black)
			end
			if type(v) == 'string' then
				local elem_ = theme['tab_title']
				beUtils.textCenter(v, theme['font'], x_, y, w_, h_, elem_.content_offset, self.transparency)
			else
				local sx, sy, sw, sh = nil, nil, nil, nil
				if v.area then
					sx, sy, sw, sh = v.area[1], v.area[2], v.area[3], v.area[4]
				end
				if self.transparency then
					local col = Color.new(255, 255, 255, self.transparency)
					tex(v.resource, x_ + paddingX, y + paddingY, sw, sh, sx, sy, sw, sh, 0, Vec2.new(0.5, 0.5), false, false, col)
				else
					tex(v.resource, x_ + paddingX, y + paddingY, sw, sh, sx, sy, sw, sh)
				end
			end
			x_ = x_ + w_ - 1
		end

		beWidget.Widget._update(self, theme, delta, dx, dy, event)
	end,
	_updateFocus = function (self, delta, x, y)
		local HALF_DURATION = 1
		self.focusTicks = self.focusTicks + delta
		if self.focusTicks >= HALF_DURATION * 2 then
			self.focusTicks = self.focusTicks - HALF_DURATION * 2
		end
		local f = 0
		if self.focusTicks < HALF_DURATION then
			f = beUtils.clamp(self.focusTicks / HALF_DURATION, 0, 1)
		else
			f = beUtils.clamp(1 - (self.focusTicks - HALF_DURATION) / HALF_DURATION, 0, 1)
		end

		local w, h = self:size()
		local col = Color.new(55 + 200 * f, 55 + 200 * f, 55 + 200 * (1 - f))
		rect(self._focusArea[1], self._focusArea[2], self._focusArea[3], self._focusArea[4], false, col)
	end,

	_fillNavigation = function (self, lst)
		local nav = self:navigatable()
		if not nav then
			return
		end
		if not self:visible() then
			return
		end
		if nav == 'all' or nav == 'content' then
			table.insert(lst, self)
		end
		if (nav == 'all' or nav == 'children') and self.children then
			for _, c in ipairs(self.children) do
				c:_fillNavigation(lst)
			end
		end
	end
}, beWidget.Widget)

--[[
Exporting.
]]

return {
	List = List,
	Draggable = Draggable,
	Droppable = Droppable,
	Tab = Tab
}
