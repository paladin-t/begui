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

local Clickable = beClass.class({
	_rule = 'inside',
	_enabled = true,
	_pressed = false,

	ctor = function (self)
		beWidget.Widget.ctor(self)
	end,

	__tostring = function (self)
		return 'Clickable'
	end,

	-- Gets the click detection rule.
	getRule = function (self)
		return self._rule
	end,
	-- Sets the click detection rule.
	setRule = function (self, val)
		self._rule = val

		return self
	end,

	enabled = function (self)
		return self._enabled
	end,
	setEnabled = function (self, val)
		self._enabled = val

		return self
	end,

	setVisible = function (self, val)
		beWidget.Widget.setVisible(self, val)

		if not val then
			self._pressed = false
		end

		return self
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
		if event.context.active and event.context.active ~= self then
			self._pressed = false
		elseif event.canceled or event.context.dragging then
			event.context.active = nil
			self._pressed = false
		elseif self._pressed then
			down = event.mouseDown
		else
			if self._rule == nil or self._rule == 'inside' then
				down = event.mouseDown and Math.intersects(event.mousePosition, Rect.byXYWH(x, y, w, h))
			else --[[ if self._rule == 'outside' then ]]
				down = event.mouseDown and not Math.intersects(event.mousePosition, Rect.byXYWH(x, y, w, h))
			end
		end
		if down and not self._pressed then
			event.context.active = self
			self._pressed = true
		elseif not down and self._pressed then
			event.context.active = nil
			self._pressed = false
			event.context.focus = self
			if self._enabled then
				self:_trigger('clicked', self)
			end
		elseif event.context.focus == self and event.context.navigated == 'press' then
			if self._enabled then
				self:_trigger('clicked', self)
			end
			event.context.navigated = false
		end

		beWidget.Widget._update(self, theme, delta, dx, dy, event)
	end
}, beWidget.Widget)

local ClickableText = beClass.class({
	_selected = false,
	_selectable = true,
	_theme = nil,
	_normalTheme = nil,
	_selectedTheme = nil,
	_disabledTheme = nil,
	_enabled = true,

	ctor = function (self, content)
		beWidget.Widget.ctor(self)

		self.content = content
	end,

	__tostring = function (self)
		return 'ClickableText'
	end,

	getValue = function (self)
		return self.content
	end,
	setValue = function (self, val)
		if type(val) ~= 'string' then
			val = tostring(val)
		end
		self.content = val

		return self
	end,

	selected = function (self)
		return self._selected
	end,
	setSelected = function (self, val)
		if not self._enabled then
			return self
		end
		if self._selected == val then
			return self
		end
		self._selected = val
		if val then
			self:_trigger('selected', self)
		else
			self:_trigger('deselected', self)
		end

		return self
	end,
	selectable = function (self)
		return self._selectable
	end,
	setSelectable = function (self, val)
		self._selectable = val

		return self
	end,

	setTheme = function (self, theme, normalTheme, selectedTheme, disabledTheme)
		self._theme = theme
		self._normalTheme = normalTheme
		self._selectedTheme = selectedTheme
		self._disabledTheme = disabledTheme

		return self
	end,

	enabled = function (self)
		return self._enabled
	end,
	setEnabled = function (self, val)
		if self._enabled and not val and self._selected then
			self:setSelected(false)
		end
		self._enabled = val

		return self
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
		if event.context.active and event.context.active ~= self then
			self._pressed = false
		elseif event.canceled or event.context.dragging then
			event.context.active = nil
			self._pressed = false
		elseif self._pressed then
			down = event.mouseDown
		else
			down = event.mouseDown and intersects
		end
		if down and not self._pressed then
			event.context.active = nil -- DO NOT USE `event.context.active = self`.
			self._pressed = true
		elseif not down and self._pressed then
			event.context.active = nil
			self._pressed = false
			event.context.focus = self
			if self._enabled then
				self:_trigger('clicked', self)
			end
		end
		if self._selectable then
			if not self._selected and intersects then
				self:setSelected(true)
			elseif self._selected and not intersects then
				self:setSelected(false)
			end
		end

		local elem = theme[self._theme or 'clickable_text']
		local normalTheme = self._normalTheme or 'font'
		local selectedTheme = self._selectedTheme or 'font_white'
		local disabledTheme = self._disabledTheme or 'font_placeholder'
		local font = self._selected and selectedTheme or normalTheme
		if self._selected then
			if self.transparency then
				local col = Color.new(elem.color.r, elem.color.g, elem.color.b, self.transparency)
				rect(x, y, x + w - 1, y + h - 1, true, col)
			else
				rect(x, y, x + w - 1, y + h - 1, true, elem.color)
			end
		end
		local offX, offY = 0, 0
		if elem.content_offset then
			offX, offY = elem.content_offset[1], elem.content_offset[2]
		end
		if self._selectable then
			beUtils.textLeft(self.content, theme[font], x + 4 + offX, y + offY, w - 8, h, elem.content_offset, self.transparency)
		else
			beUtils.textLeft(self.content, theme[disabledTheme], x + 4 + offX, y + offY, w - 8, h, elem.content_offset, self.transparency)
		end

		beWidget.Widget._update(self, theme, delta, dx, dy, event)
	end
}, beWidget.Widget)

local Draggable = beClass.class({
	_draggedTimestamp = nil,
	_draggedPosition = nil,
	_draggingPosition = nil,
	_dragging = false,
	_dragOffset = nil,
	_draggingX = 0, _draggingY = 0,
	_draggingEvent = nil,
	_draggingTimeout = false,
	_dropping = false,

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

	updateDragging = function (self, theme, delta, event)
		beWidget.Widget._update(self, theme, delta, self._draggingX, self._draggingY, self._draggingEvent or event)
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
		local picking = false
		local dropping = false
		if self._draggingTimeout then
			if not down then
				self._draggingTimeout = false
			end
		elseif down and not event.context.dragging then -- Picked the current widget.
			event.context.dragging = self
			self._draggedTimestamp = DateTime.ticks()
			self._draggedPosition = event.mousePosition
			self._draggingPosition = event.mousePosition
			self._dragging = false
			picking = true
			self._draggingEvent = {
				mousePosition = event.mousePosition,
				mouseDown = false,
				mouseWheel = 0,
				canceled = false,
				context = {
					navigated = nil,
					focus = nil,
					active = nil,
					dragging = nil,
					popup = nil,
					clippingStack = event.clippingStack
				}
			}
		elseif not down and event.context.dragging == self then -- Dropped the current widget.
			event.context.dragging = nil
			self._draggedTimestamp = nil
			self._draggedPosition = nil
			self._draggingPosition = nil
			self._dragging = false
			self._dragOffset = Vec2.new(0, 0)
			dropping = true
			self._draggingEvent = nil
			self._draggingTimeout = false
			self._dropping = true
		elseif down and event.context.dragging == self then -- Is dragging the current widget.
			if self._draggedTimestamp ~= nil then
				local diff = DateTime.toSeconds(DateTime.ticks() - self._draggedTimestamp)
				if diff < 0.3 and self._draggedPosition ~= self._draggingPosition then
					self._dragging = true
					self._draggedTimestamp = nil
				elseif diff >= 0.3 and self._draggedPosition ~= self._draggingPosition then
					event.context.dragging = nil
					self._draggedTimestamp = nil
					self._draggedPosition = nil
					self._draggingPosition = nil
					self._dragging = false
					self._dragOffset = Vec2.new(0, 0)
					self._draggingEvent = nil
					self._draggingTimeout = true
				end
			end
		end

		if self._draggingPosition then
			if self._dragging then
				self._dragOffset = self._dragOffset + (event.mousePosition - self._draggingPosition)
			end
			self._draggingPosition = event.mousePosition
		end
		if self._draggingEvent then
			if self._dragging then
				self._draggingEvent.mousePosition = nil
				self._draggingEvent.mouseDown = false
				self._draggingEvent.mouseWheel = 0
				self._draggingEvent.canceled = true
			else
				self._draggingEvent.mousePosition = event.mousePosition
				self._draggingEvent.mouseDown = event.mouseDown
				self._draggingEvent.mouseWheel = event.mouseWheel
				self._draggingEvent.canceled = event.canceled
			end
		end

		self._draggingX, self._draggingY = dx + self._dragOffset.x, dy + self._dragOffset.y
		if not picking and not dropping and not self._dragging then
			if self._dropping then
				self._dropping = false
			else
				beWidget.Widget._update(self, theme, delta, self._draggingX, self._draggingY, self._draggingEvent or event)
			end
		end
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
					if self._dropping.parent then
						self._dropping.parent:removeChild(self._dropping)
						self:addChild(self._dropping)
					end
					self:_trigger('dropped', self, self._dropping)
				else
					self:_trigger('left', self, self._dropping)
				end
			end
			self._dropping = nil
		end
		if dropped then
			self._pressed = false
			event.context.focus = self
			self._dropped = nil
		elseif down and not self._pressed then
			self._pressed = true
		elseif not event.mouseDown and self._pressed then
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

--[[
Exporting.
]]

return {
	Clickable = Clickable,
	ClickableText = ClickableText,
	Draggable = Draggable,
	Droppable = Droppable
}
