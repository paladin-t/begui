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
local beUtils = require 'libs/beGUI/beGUI_Utils'
local beWidget = require 'libs/beGUI/beGUI_Widget'

--[[
Widgets.
]]

local Group = beClass.class({
	_enabled = true,

	ctor = function (self, content)
		beWidget.Widget.ctor(self)

		self.content = content
	end,

	__tostring = function (self)
		return 'Group'
	end,

	-- Gets the group name.
	getValue = function (self)
		return self.content
	end,
	-- Sets the group name.
	setValue = function (self, val)
		self.content = val

		return self
	end,

	enabled = function (self)
		return self._enabled
	end,
	setEnabled = function (self, val)
		self._enabled = val
		if self.children then
			for i, c in ipairs(self.children) do
				if type(c.setEnabled) == 'function' then
					c:setEnabled(self._enabled)
				end
			end
		end

		return self
	end,

	navigatable = function (self)
		if not self._enabled then
			return nil
		end

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

		local font_ = theme['font']
		local elem = theme['group']
		local x_ = x + elem.content_offset[1]
		local w_, h_ = measure(self.content, font_.resource, font_.margin or 1, font_.scale or 1)
		local col = Color.new(elem.color.r, elem.color.g, elem.color.b, self.transparency or 255)
		line(x, y + h_ * 0.5, x, y + h - 1, col)
		line(x, y + h - 1, x + w - 1, y + h - 1, col)
		line(x + w - 1, y + h_ * 0.5, x + w - 1, y + h - 1, col)
		line(x, y + h_ * 0.5, x_ - 2, y + h_ * 0.5, col)
		line(x_ + w_ + 2, y + h_ * 0.5, x + w - 1, y + h_ * 0.5, col)
		local elem_ = theme['group_title']
		beUtils.textCenter(self.content, font_, x_, y, w_, h_, elem_.content_offset, self.transparency)

		beWidget.Widget._update(self, theme, delta, dx, dy, event)
	end
}, beWidget.Widget)

local List = beClass.class({
	_scrollableVertically = true,
	_scrollableHorizontally = false,
	_childrenCount = 0,
	_theme = nil,
	_scrollable = true,
	_enabled = true,
	_inertance = nil,
	_inertanceSpeed = nil,
	_inertancePosition = nil,
	_inertanceDirection = nil,
	_withScrollBar = false,
	_scrolledTimestamp = nil,
	_pressed = false,
	_pressedPosition = nil,
	_pressingPosition = nil,
	_scrolling = nil,
	_scrollX = 0, _scrollY = 0,
	_scrollSpeed = 16,
	_maxX = 0, _maxY = 0,
	_scrollDirectionalTimestamp = nil,
	_doNotInteract = false,

	-- Constructs a List.
	-- `withScrollBar`: whether to draw scroll bar(s)
	ctor = function (self, withScrollBar)
		beWidget.Widget.ctor(self)

		self._withScrollBar = withScrollBar
	end,

	__tostring = function (self)
		return 'List'
	end,

	-- Gets whether to allow scrolling vertically.
	scrollableVertically = function (self)
		return self._scrollableVertically
	end,
	-- Sets whether to allow scrolling vertically.
	setScrollableVertically = function (self, val)
		self._scrollableVertically = val

		return self
	end,
	-- Gets whether to allow scrolling horizontally.
	scrollableHorizontally = function (self)
		return self._scrollableHorizontally
	end,
	-- Sets whether to allow scrolling horizontally.
	setScrollableHorizontally = function (self, val)
		self._scrollableHorizontally = val

		return self
	end,

	-- Gets the scroll speed.
	scrollSpeed = function (self)
		return self._scrollSpeed
	end,
	-- Sets the scroll speed.
	setScrollSpeed = function (self, val)
		self._scrollSpeed = val

		return self
	end,

	setTheme = function (self, theme)
		self._theme = theme

		return self
	end,

	-- Gets whether can scroll the widget by mouse wheel.
	scrollable = function (self)
		return self._scrollable
	end,
	-- Sets whether can scroll the widget by mouse wheel.
	setScrollable = function (self, val)
		self._scrollable = val

		return self
	end,

	enabled = function (self)
		return self._enabled
	end,
	setEnabled = function (self, val)
		self._enabled = val
		if self.children then
			for i, c in ipairs(self.children) do
				if type(c.setEnabled) == 'function' then
					c:setEnabled(self._enabled)
				end
			end
		end

		return self
	end,

	navigatable = function (self)
		if not self._enabled then
			return nil
		end

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
			if self._enabled then
				if not self._doNotInteract then
					down = event.mouseDown
				end
			end
		else
			if self._enabled then
				if not self._doNotInteract then
					if event.mouseDown then
						down = intersects
						if not down and not self._doNotInteract then
							self._doNotInteract = true
						end
					end
				end
			end
		end
		local now = DateTime.ticks()
		if down and not self._pressed then
			if self._withScrollBar then
				self._scrolledTimestamp = now
			end
			self._pressed = true
			self._pressedPosition = event.mousePosition
			self._pressingPosition = event.mousePosition
			self._scrolling = nil
			self._scrollDirectionalTimestamp = now
			self._inertancePosition = event.mousePosition
			self._inertanceSpeed = 0
		elseif not down and self._pressed then
			if self._inertanceSpeed ~= nil then
				local speed = self._inertanceSpeed
				if speed > 5 then
					local force = beUtils.clamp(1 - speed / 40, 0, 6) * 20 + 4
					local dist = self._pressingPosition - self._pressedPosition
					if self._scrollableHorizontally and w < self._maxX then
						if math.abs(dist.x) < math.abs(dist.y) then
							self._inertance = dist.y * force
							self._inertanceDirection = 'y'
						else
							self._inertance = dist.x * force
							self._inertanceDirection = 'x'
						end
					elseif self._scrollableVertically then
						self._inertance = dist.y * force
						self._inertanceDirection = 'y'
					end
				end
			end
			self._pressed = false
			self._pressedPosition = nil
			self._pressingPosition = nil
			self._scrolling = nil
			self._scrollDirectionalTimestamp = nil
			self._inertancePosition = nil
			self._inertanceSpeed = nil
		elseif down and self._pressed then
			if self._withScrollBar then
				self._scrolledTimestamp = now
			end
			if self._scrollDirectionalTimestamp ~= nil then
				local diff = DateTime.toSeconds(now - self._scrollDirectionalTimestamp)
				if diff < 0.3 and self._pressedPosition ~= self._pressingPosition then
					local diff = self._pressedPosition - self._pressingPosition
					if self._scrollableHorizontally and w < self._maxX then
						if math.abs(diff.x) < math.abs(diff.y) then
							self._scrolling = 'y'
						else
							self._scrolling = 'x'
						end
					elseif self._scrollableVertically then
						if math.abs(diff.x) < math.abs(diff.y) then
							self._scrolling = 'y'
						end
					end
					self._scrollDirectionalTimestamp = nil
				end
			end
			if self._inertancePosition ~= event.mousePosition then
				if self._inertancePosition then
					local diff = event.mousePosition - self._inertancePosition
					self._inertanceSpeed = diff.length
				end
				self._inertancePosition = event.mousePosition
			end
		end
		if self._doNotInteract and not event.mouseDown then
			self._doNotInteract = false
		end

		local elem = theme[self._theme or 'list']
		beUtils.tex9Grid(elem, x, y, w, h, nil, self.transparency, nil)

		local scrollBarTransparency = nil
		if self._scrolledTimestamp then
			local SCROLL_BAR_TIMEOUT_SECONDS = 1
			local diff = DateTime.toSeconds(now - self._scrolledTimestamp)
			local factor = diff / SCROLL_BAR_TIMEOUT_SECONDS
			scrollBarTransparency = factor < 0.7 and 1 or beUtils.clamp(1 - (factor - 0.7) / 0.3, 0, 1)
			if factor >= 1 then
				self._scrolledTimestamp = nil
			end
		end
		if self._maxX < w then
			self._maxX = w
		end
		if self._maxY < h then
			self._maxY = h
		end
		if self._pressingPosition then
			if self._scrolling == 'x' and event.mousePosition then
				local diff = event.mousePosition.x - self._pressingPosition.x
				if not beUtils.isNaN(diff) then
					self._scrollX = self._scrollX + diff
					self._scrollX = beUtils.clamp(self._scrollX, w - self._maxX, 0)
				end
			elseif self._scrolling == 'y' and event.mousePosition then
				local diff = event.mousePosition.y - self._pressingPosition.y
				if not beUtils.isNaN(diff) then
					self._scrollY = self._scrollY + diff
					self._scrollY = beUtils.clamp(self._scrollY, h - self._maxY, 0)
				end
			end
			self._pressingPosition = event.mousePosition
		elseif intersects and event.mouseWheel < 0 and self._scrollable then
			if self._enabled then
				if self._withScrollBar then
					self._scrolledTimestamp = now
				end
				if self._scrollableVertically and not key(beUtils.KeyCodeLShift) and not key(beUtils.KeyCodeRShift) then
					self._scrollY = beUtils.clamp(self._scrollY - self._scrollSpeed, h - self._maxY, 0)
				elseif self._scrollableHorizontally then
					self._scrollX = beUtils.clamp(self._scrollX - self._scrollSpeed, w - self._maxX, 0)
				end
			end
		elseif intersects and event.mouseWheel > 0 and self._scrollable then
			if self._enabled then
				if self._withScrollBar then
					self._scrolledTimestamp = now
				end
				if self._scrollableVertically and not key(beUtils.KeyCodeLShift) and not key(beUtils.KeyCodeRShift) then
					self._scrollY = beUtils.clamp(self._scrollY + self._scrollSpeed, h - self._maxY, 0)
				elseif self._scrollableHorizontally then
					self._scrollX = beUtils.clamp(self._scrollX + self._scrollSpeed, w - self._maxX, 0)
				end
			end
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
		if self._inertance then
			if self._withScrollBar then
				self._scrolledTimestamp = now
			end
			if self._inertanceDirection == 'y' then
				self._scrollY = beUtils.clamp(self._scrollY + self._inertance * delta, h - self._maxY, 0)
			else
				self._scrollX = beUtils.clamp(self._scrollX + self._inertance * delta, w - self._maxX, 0)
			end
			self._inertance = self._inertance * 0.9
			if math.abs(self._inertance) < 0.1 then
				self._inertance = nil
				self._inertanceSpeed = nil
				self._inertancePosition = nil
				self._inertanceDirection = nil
			end
		end
		if self._scrollX < 0 then
			self._scrollX = beUtils.clamp(self._scrollX, w - self._maxX, 0)
		end
		if self._scrollY < 0 then
			self._scrollY = beUtils.clamp(self._scrollY, h - self._maxY, 0)
		end

		local clipped = self:_beginClip(event, x + 1, y + 1, w - 2, h - 2)
		beWidget.Widget._update(self, theme, delta, dx + self._scrollX, dy + self._scrollY, event)
		local count = self:getChildrenCount()
		if count ~= self._childrenCount then
			self._childrenCount = count
		end
		if clipped then
			if elem.color and scrollBarTransparency then
				local col = Color.new(elem.color.r, elem.color.g, elem.color.b, elem.color.a * scrollBarTransparency)
				if self._scrollableVertically then
					local widgetPos = y + 1
					local widgetSize = h - 2
					local clientSize = widgetSize
					if self._scrollableHorizontally then
						clientSize = clientSize - 4
					end
					local contentSize = self._maxY
					local barSize = math.ceil(math.max(math.min((widgetSize / contentSize) * widgetSize, clientSize), 8))
					local percent = beUtils.clamp(-self._scrollY / (contentSize - widgetSize), 0, 1)
					local slide = clientSize - barSize
					local offset = slide * percent
					local x_, y_, w_, h_ =
						math.floor(x + w - 4), beUtils.round(widgetPos + offset),
						math.floor(x + w - 1), math.min(beUtils.round(widgetPos + offset + barSize + 1), widgetPos + clientSize)
					rect(x_, y_, w_, h_, true, col)
				end
				if self._scrollableHorizontally then
					local widgetPos = x + 1
					local widgetSize = w - 2
					local clientSize = widgetSize
					if self._scrollableVertically then
						clientSize = clientSize - 4
					end
					local contentSize = self._maxX
					local barSize = math.ceil(math.max(math.min((widgetSize / contentSize) * widgetSize, clientSize), 8))
					local percent = beUtils.clamp(-self._scrollX / (contentSize - widgetSize), 0, 1)
					local slide = clientSize - barSize
					local offset = slide * percent
					local x_, y_, w_, h_ =
						beUtils.round(widgetPos + offset), math.floor(y + h - 4),
						math.min(beUtils.round(widgetPos + offset + barSize + 1), widgetPos + clientSize), math.floor(y + h - 1)
					rect(x_, y_, w_, h_, true, col)
				end
			end
		end
		if clipped then
			self:_endClip(event)
		end
	end,
	_updateChildren = function (self, theme, delta, dx, dy, event)
		if self.children == nil then
			return
		end
		self._maxX, self._maxY = 0, 0
		for i, c in ipairs(self.children) do
			c:_update(theme, delta, dx, dy, event)
			local px, py = c:position()
			local w, h = c:size()
			local x, y = px + w, py + h
			if x > self._maxX then
				self._maxX = x
			end
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
		rect(x - self._scrollX + 1, y - self._scrollY + 1, x + w - 1 - self._scrollX - 2, y + h - 1 - self._scrollY - 1, false, col)
	end,

	_scroll = function (self, dirX, dirY)
		local w, h = self:size()
		if dirX then
			if dirX < 0 then
				if self._scrollX < 0 then
					self._scrollX = beUtils.clamp(self._scrollX + self._scrollSpeed, w - self._maxX, 0)

					return true
				end
			elseif dirX > 0 then
				if self._scrollX > w - self._maxX then
					self._scrollX = beUtils.clamp(self._scrollX - self._scrollSpeed, w - self._maxX, 0)

					return true
				end
			end
		end
		if dirY then
			if dirY < 0 then
				if self._scrollY < 0 then
					self._scrollY = beUtils.clamp(self._scrollY + self._scrollSpeed, h - self._maxY, 0)

					return true
				end
			elseif dirY > 0 then
				if self._scrollY > h - self._maxY then
					self._scrollY = beUtils.clamp(self._scrollY - self._scrollSpeed, h - self._maxY, 0)

					return true
				end
			end
		end

		return false
	end
}, beWidget.Widget)

local Tab = beClass.class({
	_pages = nil,
	_pagesInitialized = false,
	_tabSize = nil,
	_focusArea = nil,
	_value = 1,
	_headHeight = nil,
	_pressed = false,
	_scrollable = true,
	_enabled = true,
	_doNotInteract = false,

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

	-- Adds a Tab page with the specific title.
	-- `title`: the Tab page title to add
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
	-- Gets the page count of the Tab Widget.
	count = function (self)
		return #self.content
	end,

	-- Gets the active page index.
	getValue = function (self)
		return self._value
	end,
	-- Sets the active page index.
	setValue = function (self, val)
		if self._value == val then
			return self
		end
		if val < 1 or val > #self.content then
			return self
		end
		self._value = val
		self:_trigger('changed', self, self._value)

		return self
	end,

	-- Gets the specified Tab size.
	tabSize = function (self)
		return self._tabSize
	end,
	-- Sets the specified Tab size.
	setTabSize = function (self, val)
		self._tabSize = val

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

	-- Gets whether can scroll the widget by mouse wheel.
	scrollable = function (self)
		return self._scrollable
	end,
	-- Sets whether can scroll the widget by mouse wheel.
	setScrollable = function (self, val)
		self._scrollable = val

		return self
	end,

	enabled = function (self)
		return self._enabled
	end,
	setEnabled = function (self, val)
		self._enabled = val
		if self.children then
			for i, c in ipairs(self.children) do
				if type(c.setEnabled) == 'function' then
					c:setEnabled(self._enabled)
				end
			end
		end

		return self
	end,

	navigatable = function (self)
		if not self._enabled then
			return nil
		end

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
			if self._enabled then
				if not self._doNotInteract then
					down = event.mouseDown
				end
			end
		else
			if self._enabled then
				if not self._doNotInteract then
					if event.mouseDown then
						down = Math.intersects(event.mousePosition, Rect.byXYWH(x, y, w, h))
						if not down and not self._doNotInteract then
							self._doNotInteract = true
						end
					end
				end
			end
		end
		local pressed = false
		if down and not self._pressed then
			self._pressed = true
		elseif not down and self._pressed then
			self._pressed = false
			event.context.focus = self
			pressed = true
		elseif intersectsHead and event.mouseWheel < 0 and self._scrollable then
			if #self.content ~= 0 then
				if self._enabled then
					local val = self._value - 1
					if val < 1 then
						val = 1
					end
					self:setValue(val)
				end
			end
		elseif intersectsHead and event.mouseWheel > 0 and self._scrollable then
			if #self.content ~= 0 then
				if self._enabled then
					local val = self._value + 1
					if val > #self.content then
						val = #self.content
					end
					self:setValue(val)
				end
			end
		elseif event.context.focus == self and event.context.navigated == 'inc' then
			if self._enabled then
				local val = self._value + 1
				self:setValue(val)
			end
			event.context.navigated = false
		elseif event.context.focus == self and event.context.navigated == 'dec' then
			if self._enabled then
				local val = self._value - 1
				self:setValue(val)
			end
			event.context.navigated = false
		end
		if self._doNotInteract and not event.mouseDown then
			self._doNotInteract = false
		end

		local font_ = theme['font']
		local elem = theme['tab']
		local paddingX, paddingY = elem.content_offset[1] or 2, elem.content_offset[2] or 2
		local x_ = x
		local n = #self.content
		for i = 1, n, 1 do
			local v = self.content[i]
			local w_, h_ = nil, nil
			if self._tabSize == nil then
				if type(v) == 'string' then
					w_, h_ = measure(v, font_.resource, font_.margin or 1, font_.scale or 1)
				else
					w_, h_ = v.area[3], v.area[4]
				end
				w_ = w_ + paddingX * 2
				h_ = h_ + paddingY * 2
			else
				w_, h_ = self._tabSize.x, self._tabSize.y
			end
			if self._headHeight == nil then
				self._headHeight = h_
			end
			if pressed then
				if self._enabled then
					if Math.intersects(event.mousePosition, Rect.byXYWH(x_, y, w_, h_)) then
						local val = i
						self:setValue(val)
					end
				end
			end
			local col = Color.new(elem.color.r, elem.color.g, elem.color.b, self.transparency or 255)
			if i == self._value then
				self._focusArea[1], self._focusArea[2], self._focusArea[3], self._focusArea[4] =
					x_ + 1, y + 1, x_ + w_ - 2, y + h_ - 1
				-- Tab itself.
				line(x_, y, x_ + w_ - 1, y, col)
				line(x_ + w_ - 1, y, x_ + w_ - 1, y + h_, col)
				-- Border.
				line(x, y + h - 1, x + w - 1, y + h - 1, col)
				line(x, y, x, y + h - 1, col)
				line(x + w - 1, y + h_, x + w - 1, y + h - 1, col)
				line(x_ + w_ - 1, y + h_, x + w - 1, y + h_, col)
				line(x, y + h_, x_, y + h_, col)
			else
				line(x_, y, x_ + w_ - 1, y, col)
				line(x_ + w_ - 1, y, x_ + w_ - 1, y + h_, col)
			end
			if type(v) == 'string' then
				local elem_ = theme['tab_title']
				beUtils.textCenter(v, font_, x_, y, w_, h_, elem_.content_offset, self.transparency)
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
	_updateChildren = function (self, theme, delta, dx, dy, event)
		if self.children == nil then
			return
		end
		local page = self._pages[self._value]
		if not page then
			return
		end
		for i, c in ipairs(page) do
			if not self.popup or self.popup == c then
				c:_update(theme, delta, dx, dy, event)
			else
				c:_update(
					theme, delta, dx, dy,
					{
						mousePosition = nil,
						mouseDown = false,
						mouseWheel = 0,
						canceled = false,
						context = event.context
					}
				)
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
	Group = Group,
	List = List,
	Tab = Tab
}
