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
local beStructures = require 'libs/beGUI/beGUI_Structures'

--[[
Widgets.
]]

local Widget = beClass.class({
	DEBUG = false,

	id = nil,                              -- String.
	visibility = true,                     -- Boolean.
	capturability = false,
	queriablility = false,
	anchorX = 0, anchorY = 0,              -- Number, typically [0.0, 1.0].
	x = 0, y = 0,                          -- Number or Percent.
	worldX = 0, worldY = 0,                -- Auto calculated.
	width = 0, height = 0,                 -- Number or Percent.
	parentWidth = nil, parentHeight = nil, -- Auto calculated.
	content = nil,
	transparency = nil,
	parent = nil,
	children = nil,

	popup = nil,
	hovering = false,
	focused = nil,                         -- Used to reserve focused widget before popup.
	focusIfHovering = false,
	focusTicks = 0,
	context = nil,
	tweens = nil,
	events = nil,

	ctor = function (self)
	end,

	__tostring = function (self)
		return 'Widget'
	end,

	-- Sets the ID of the Widget.
	-- `id`: ID string
	setId = function (self, id)
		if id ~= nil and type(id) ~= 'string' then
			error('String or nil expected.')
		end

		self.id = id

		return self
	end,
	-- Gets a leaf node with the specific ID sequence.
	get = function (self, ...)
		local full = { ... }
		if #full == 0 then
			return self
		end
		local car_ = beUtils.car(full)
		local cdr_ = beUtils.cdr(full)
		local c = self:getChild(car_)
		if not c then
			return nil
		end

		return c:get(table.unpack(cdr_))
	end,
	-- Finds a Widget with the specific ID.
	-- `id`: ID string
	find = function (self, id)
		local find_ = nil
		find_ = function (widget, id)
			if widget.id == id then
				return widget
			end
			if widget.children then
				for _, c in ipairs(widget.children) do
					local ret = find_(c, id)
					if ret then
						return ret
					end
				end
			end

			return nil
		end

		return find_(self, id)
	end,

	-- Gets the visibility of the Widget.
	visible = function (self)
		return self.visibility
	end,
	-- Sets the visibility of the Widget.
	-- `val`: boolean
	setVisible = function (self, val)
		self.visibility = val

		return self
	end,

	-- Gets the capturability of the Widget.
	capturable = function (self)
		return self.capturability
	end,
	-- Sets the capturability of the Widget.
	-- `val`: `true, `false` or 'children'
	setCapturable = function (self, val)
		self.capturability = val

		return self
	end,

	-- Sets the anchor of the Widget; anchor is used to calculate the offset when placing widget.
	-- `x`: x position of the anchor in local space as number, typically [0.0, 1.0] for [left, right]
	-- `y`: y position of the anchor in local space as number, typically [0.0, 1.0] for [top, bottom]
	anchor = function (self, x, y)
		self.anchorX = x
		self.anchorY = y

		return self
	end,
	-- Gets the offset of the Widget.
	-- returns offset width, height in world space
	offset = function (self)
		local w, h = self:size()

		return -w * self.anchorX, -h * self.anchorY
	end,
	-- Sets the position of the Widget.
	-- `x`: number for absolute position, or Percent for relative position
	-- `y`: number for absolute position, or Percent for relative position
	put = function (self, x, y)
		self.x = x
		self.y = y

		return self
	end,
	-- Gets the position of the Widget.
	position = function (self)
		local canvasWidth, canvasHeight = Canvas.main:size()
		local x, y = self.x, self.y
		if beClass.is(x, beStructures.Percent) then
			if self.parent then
				x = x * self.parentWidth
			else
				x = x * canvasWidth
			end
		end
		if beClass.is(y, beStructures.Percent) then
			if self.parent then
				y = y * self.parentHeight
			else
				y = y * canvasHeight
			end
		end

		return x, y
	end,
	-- Sets the size of the Widget.
	-- `width`: number for absolute size, or Percent for relative size
	-- `height`: number for absolute size, or Percent for relative size
	resize = function (self, width, height)
		self.width = width
		self.height = height

		return self
	end,
	-- Gets the size of the Widget.
	size = function (self)
		local w, h = self.width, self.height
		if beClass.is(w, beStructures.Percent) then
			w = w * self.parentWidth
		end
		if beClass.is(h, beStructures.Percent) then
			h = h * self.parentHeight
		end

		return w, h
	end,

	-- Gets the alpha value of the Widget.
	alpha = function (self)
		if not self.transparency then
			return 255
		end

		return self.transparency
	end,
	-- Sets the alpha value of the Widget.
	setAlpha = function (self, val)
		if val == 255 then
			val = nil
		end

		self.transparency = val

		if self.children ~= nil then
			for _, c in ipairs(self.children) do
				c:setAlpha(val)
			end
		end

		return self
	end,

	-- Gets the child with the specific ID or index.
	-- `id`: ID string, or index number
	-- returns the found child or nil
	getChild = function (self, id)
		if self.children == nil then
			return nil
		end
		if not id then
			return nil
		end
		if type(id) == 'string' then
			for _, v in ipairs(self.children) do
				if v.id == id then
					return v
				end
			end
		elseif type(id) == 'number' then
			if id >= 1 and id <= #self.children then
				return self.children[id]
			end
		end

		return nil
	end,
	-- Insert a child.
	-- `child`: child widget
	insertChild = function (self, child, index)
		if not child then
			return self
		end
		if child.parent then
			error('This widget is already a child of another one.')
		end
		if self.children == nil then
			self.children = { }
		end
		for _, v in ipairs(self.children) do
			if v == child then
				return self
			end
		end
		table.insert(self.children, index, child)
		child.parent = self

		return self
	end,
	-- Adds a child.
	-- `child`: child widget
	addChild = function (self, child)
		return self:insertChild(child, self.children and #self.children + 1 or 1)
	end,
	-- Removes a child with the specific child, or its ID or index.
	-- `child`: child object, or its ID string, or index number
	removeChild = function (self, child)
		if self.children == nil then
			return self
		end
		if not child then
			return self
		end
		if not child.parent then
			error('This widget is not a child of any other one.')
		end
		if type(child) == 'string' then
			for i, v in ipairs(self.children) do
				if v.id == child then
					local c = self.children[i]
					table.remove(self.children, i)
					c.parent = nil

					return self
				end
			end
		elseif type(child) == 'number' then
			if child >= 1 and child <= #self.children then
				local c = self.children[child]
				table.remove(self.children, child)
				c.parent = nil
			end
		else
			for i, v in ipairs(self.children) do
				if v == child then
					local c = self.children[i]
					table.remove(self.children, i)
					c.parent = nil

					return self
				end
			end
		end

		return self
	end,
	-- Iterates all children, and calls the specific handler.
	foreachChild = function (self, handler)
		if self.children == nil then
			return self
		end
		for i, c in ipairs(self.children) do
			handler(c, i)
		end

		return self
	end,
	-- Sorts all children.
	sortChildren = function (self, comp)
		table.sort(self.children, comp)

		return self
	end,
	-- Gets the count of all children.
	getChildrenCount = function (self)
		if self.children == nil then
			return 0
		end

		return #self.children
	end,
	-- Clears all children.
	clearChildren = function (self)
		self.children = nil

		return self
	end,

	-- Opens a popup.
	-- `content`: the popup to open
	openPopup = function (self, content)
		if self.popup then
			return self
		end
		if not content then
			error('Widget expected.')
		end

		local focused = self.context.navigated ~= nil
		self.focused = self.context.focus
		self.context.focus = nil

		self.popup = content
		self:addChild(self.popup)

		local w, h = self:size()
		self.popup:_updateLayout(w, h)

		if focused then
			self.popup:schedule(function ()
				if self.popup.context == nil then
					self.popup.context = self.context
				end
				self.popup:navigate('next')
			end)
		end

		return self
	end,
	-- Closes any popup.
	closePopup = function (self)
		if not self.popup then
			return self
		end
		self:removeChild(self.popup)
		self.popup = nil

		self.context.focus = self.focused
		self.focused = nil

		return self
	end,

	-- Updates the Widget and its children recursively.
	-- `theme`: the theme to draw with
	-- `delta`: elapsed time since previous update
	update = function (self, theme, delta, event)
		return self:_update(theme, delta, 0, 0, event)
	end,

	-- Registers the handler of the specific event.
	-- `event`: event name string
	-- `handler`: callback function
	on = function (self, event, handler)
		if not event then
			return self
		end
		if self.events == nil then
			self.events = { }
		end
		if self.events[event] == nil then
			self.events[event] = { }
		end
		if beUtils.exists(self.events[event], handler) then
			error('Event handler already exists.')
		end
		table.insert(self.events[event], handler)

		return self
	end,
	-- Unregisters the handlers of the specific event.
	-- `event`: event name string
	off = function (self, event)
		if not event then
			return self
		end
		if self.events == nil then
			return self
		end
		if self.events[event] == nil then
			return self
		end
		self.events[event] = nil
		if not next(self.events) then
			self.events = nil
		end

		return self
	end,

	-- Gets whether this widget is navigatable.
	-- returns 'all' for fully navigatable,
	--   `nil` for non-navigatable,
	--   'children' for children only,
	--   'content' for content only
	navigatable = function (self)
		return 'children'
	end,
	-- Navigates.
	-- `dir`: can be one in 'prev', 'next', 'press', 'cancel'
	navigate = function (self, dir)
		if dir ~= 'prev' and dir ~= 'next' and dir ~= 'dec' and dir ~= 'inc' and dir ~= 'press' and dir ~= 'cancel' then
			error('Unknown navigation: ' .. dir .. '.')
		end

		if self.context then
			self.context.navigated = dir
		end
	end,

	-- Gets whether this widget is queriable.
	-- returns `true` for queriable, otherwise `false`
	queriable = function (self)
		return self.queriablility
	end,
	-- Sets whether this widget is queriable.
	setQueriable = function (self, val)
		self.queriablility = val

		return self
	end,
	-- Queries a widget at the specific position.
	query = function (self, x, y)
		if not x or not y or beUtils.isNaN(x) or beUtils.isNaN(y) then
			return nil
		end
		if not self:visible() then
			return nil
		end
		if not self:queriable() then
			return nil
		end
		if self.children ~= nil then
			for i = #self.children, 1, -1 do
				local c = self.children[i]
				local ret = c:query(x, y)
				if ret ~= nil then
					return ret
				end
			end
		end
		local x_, y_ = self.worldX, self.worldY
		local w_, h_ = self:size()
		if Math.intersects(Vec2.new(x, y), Rect.byXYWH(x_, y_, w_, h_)) then
			return self
		end

		return nil
	end,

	-- Gets whether this widget has captured mouse event.
	captured = function (self)
		if not self.visibility then
			return false
		end
		if not self.capturability then
			return false
		end
		if self.popup then
			return true
		end
		if self.hovering then
			return true
		end
		if self.children ~= nil then
			for _, c in ipairs(self.children) do
				if c:captured() then
					return true
				end
			end
		end

		return false
	end,

	-- Schedules a tweening procedure.
	tween = function (self, t)
		if self.tweens == nil then
			self.tweens = { }
		end
		table.insert(self.tweens, t)

		return self
	end,
	-- Clears all tweening procedures.
	clearTweenings = function (self)
		self.tweens = nil

		return self
	end,

	_updateLayout = function (self, parentWidth, parentHeight)
		if self.parentWidth == parentWidth and self.parentHeight == parentHeight then
			return
		end
		self.parentWidth, self.parentHeight = parentWidth, parentHeight
		local w, h = self:size()

		if self.children == nil then
			return
		end
		for _, c in ipairs(self.children) do
			c:_updateLayout(w, h)
		end
	end,
	_update = function (self, theme, delta, dx, dy, event)
		if not self.visibility then
			return
		end

		local once = not event
		if once then
			if self.context == nil then
				self.context = {
					navigated = nil,
					focus = nil,
					active = nil,
					dragging = nil,
					popup = nil
				}
			end

			local canvasWidth, canvasHeight = Canvas.main:size()
			self:_updateLayout(canvasWidth, canvasHeight)

			local x, y, lmb, _4, _5, wheel = mouse()
			event = {
				mousePosition = Vec2.new(x, y),
				mouseDown = lmb,
				mouseWheel = wheel,
				canceled = false,
				context = self.context,
			}

			if lmb or wheel ~= 0 then
				self.context.navigated = nil
			end

			if self.popup ~= nil then
				if self.popup.context == nil then
					self.popup.context = self.context
				end
				self.popup:_navigate()
			else
				self:_navigate()
			end
		else
			self.context = nil
		end

		if self.tweens then
			local dead = nil
			for _, t in ipairs(self.tweens) do
				if t:update(delta) then
					if dead == nil then
						dead = { }
					end
					table.insert(dead, t)
				end
			end
			if dead then
				self.tweens = beUtils.filter(self.tweens, function (t)
					return not beUtils.exists(dead, t)
				end)
				if #self.tweens == 0 then
					self.tweens = nil
				end
			end
		end

		local ox, oy = self:offset()
		local px, py = self:position()
		local x, y = dx + px + ox, dy + py + oy
		if beGUI.Widget.DEBUG then
			local w, h = self:size()
			rect(x, y, x + w - 1, y + h - 1, false, Color.new(255, 0, 0, 128))
		end
		if self.capturability == true then
			local w, h = self:size()
			self.hovering = Math.intersects(event.mousePosition, Rect.byXYWH(x, y, w, h))
		end
		self.worldX, self.worldY = x, y
		self:_updateChildren(theme, delta, x, y, event)

		if self.focusIfHovering then
			local w, h = self:size()
			if self.hovering or Math.intersects(event.mousePosition, Rect.byXYWH(x, y, w, h)) then
				if event.context then
					event.context.focus = self
				end
			end
		end
		if event.context and event.context.focus == self and (event.context.navigated ~= nil or self.focusIfHovering) then
			self:_updateFocus(delta, x, y)
		end
	end,
	_updateChildren = function (self, theme, delta, dx, dy, event)
		if self.children == nil then
			return
		end
		for _, c in ipairs(self.children) do
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
		rect(x, y, x + w - 1, y + h - 1, false, col)
	end,

	_trigger = function (self, event, ...)
		if not event then
			return nil
		end
		if self.events == nil then
			return nil
		end
		if self.events[event] == nil then
			return nil
		end
		if #self.events[event] == 1 then
			local ret = self.events[event][1](...)

			return ret
		else
			local ret = { }
			for i, h in ipairs(self.events[event]) do
				table.insert(ret, h(...) or false)
			end

			return table.unpack(ret)
		end
	end,

	_navigate = function (self)
		if not self.context or not self.context.navigated then
			return
		end

		if self.context.navigated == 'cancel' then
			self:_cancelNavigation()
		end

		local lst = { }
		self:_fillNavigation(lst)

		local first = #lst > 0 and lst[1] or nil
		local last = #lst > 0 and lst[#lst] or nil
		local prev = nil
		for i, c in ipairs(lst) do
			local next = i < #lst and lst[i + 1] or nil
			local nav = c:navigatable()
			if self.context.navigated == 'prev' then
				if self.context.focus == c then
					local scrolled = false
					if nav == 'content' then
						if c:_scroll(-1) then
							scrolled = true
						end
					end
					if not scrolled then
						self.context.focus = prev or last
					end
					self.context.navigated = false
				end
			elseif self.context.navigated == 'next' then
				if self.context.focus == c then
					local scrolled = false
					if nav == 'content' then
						if c:_scroll(1) then
							scrolled = true
						end
					end
					if not scrolled then
						self.context.focus = next or first
					end
					self.context.navigated = false
				end
			end
			prev = c
		end
		if self.context.navigated == 'prev' then
			self.context.focus = last
			self.context.navigated = false
		elseif self.context.navigated == 'next' then
			self.context.focus = first
			self.context.navigated = false
		end
	end,
	_fillNavigation = function (self, lst)
		local nav = self:navigatable()
		if not nav then
			return
		end
		if not self:visible() then
			return
		end
		if (nav == 'all' or nav == 'children') and self.children then
			for _, c in ipairs(self.children) do
				c:_fillNavigation(lst)
			end
		end
		if nav == 'all' or nav == 'content' then
			table.insert(lst, self)
		end
	end,
	_cancelNavigation = function (self)
		self.context.focus = nil
		self.context.navigated = false
	end
})

--[[
Exporting.
]]

return {
	Widget = Widget
}
