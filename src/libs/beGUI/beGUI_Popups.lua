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
local beStructures = require 'libs/beGUI/beGUI_Structures'
local beWidget = require 'libs/beGUI/beGUI_Widget'

--[[
Widgets.
]]

local Popup = beClass.class({
	_scheduled = nil,

	-- Constructs a Popup.
	ctor = function (self)
		beWidget.Widget.ctor(self)
	end,

	__tostring = function (self)
		return 'Popup'
	end,

	navigatable = function (self)
		return 'children'
	end,

	schedule = function (self, func)
		self._scheduled = func
	end,

	_update = function (self, theme, delta, dx, dy, event)
		if not self.visibility then
			return
		end

		local ox, oy = self:offset()
		local px, py = self:position()
		local x, y = dx + px + ox, dy + py + oy
		local w, h = self:size()

		if self.transparency then
			local col = Color.new(80, 80, 80, 120 * (self.transparency / 255))
			rect(x, y, x + w, y + h, true, col)
		else
			rect(x, y, x + w, y + h, true, Color.new(80, 80, 80, 120))
		end

		beWidget.Widget._update(self, theme, delta, dx, dy, event)

		if self._scheduled then
			self._scheduled()
			self._scheduled = nil
		end
	end
}, beWidget.Widget)

local MessageBox = beClass.class({
	_closable = true,
	_title = nil,
	_message = nil,
	_confirm = 'OK',
	_initialized = false,

	-- Constructs a MessageBox.
	ctor = function (self, closable, title, message, confirm)
		Popup.ctor(self)

		self._closable = closable
		self._title = title or 'Bitty Engine'
		self._message = message
		if confirm then
			self._confirm = confirm
		end

		local P = beStructures.percent
		self
			:setId('popup')
			:anchor(0, 0)
			:put(0, 0)
			:resize(P(100), P(100))
	end,

	__tostring = function (self)
		return 'MessageBox'
	end,

	_update = function (self, theme, delta, dx, dy, event)
		if not self._initialized then
			self._initialized = true

			local width = 256
			local P = beStructures.percent
			local child = beGUI.Picture.new(theme['window'], true)
				:setId('picture')
				:anchor(0.5, 0.5)
				:put(P(50), P(50))
				:resize(width, 128)
				:addChild(
					beGUI.Label.new(self._title, 'center', true, 'font_title')
						:setId('label_title')
						:anchor(0.5, 0)
						:put(P(50), 3)
						:resize(P(100), 23)
				)
				:addChild(
					beGUI.Label.new(self._message, 'center', true)
						:setId('label_message')
						:anchor(0.5, 1)
						:put(P(50), P(50))
						:resize(P(100), 23)
				)
				:addChild(
					beGUI.Button.new(self._confirm)
						:setId('button_confirm')
						:anchor(0.5, 1)
						:put(P(50), P(90))
						:resize(P(24), 23)
						:on('clicked', function (sender)
							self:_trigger('confirmed', self)
						end)
				)
			if self._closable then
				child
					:addChild(
						beGUI.PictureButton.new('', false, { normal = 'button_close', pressed = 'button_close_down' })
							:setId('button_close')
							:anchor(1, 0)
							:put(width - 6, 5)
							:resize(19, 19)
							:on('clicked', function (sender)
								self:_trigger('canceled', self)
							end)
					)
			end
			self:addChild(child)

			local w, h = self:size()
			child:_updateLayout(w, h)
		end

		Popup._update(self, theme, delta, dx, dy, event)
	end,

	_cancelNavigation = function (self)
		if self._closable then
			self:_trigger('canceled', self)
		end

		self.context.focus = nil
		self.context.navigated = false
	end
}, Popup)

local QuestionBox = beClass.class({
	_closable = true,
	_title = nil,
	_message = nil,
	_confirm = 'Yes',
	_deny = 'No',
	_initialized = false,

	-- Constructs a QuestionBox.
	ctor = function (self, closable, title, message, confirm, deny)
		Popup.ctor(self)

		self._closable = closable
		self._title = title or 'Bitty Engine'
		self._message = message
		if confirm then
			self._confirm = confirm
		end
		if deny then
			self._deny = deny
		end

		local P = beStructures.percent
		self
			:setId('popup')
			:anchor(0, 0)
			:put(0, 0)
			:resize(P(100), P(100))
	end,

	__tostring = function (self)
		return 'QuestionBox'
	end,

	_update = function (self, theme, delta, dx, dy, event)
		if not self._initialized then
			self._initialized = true

			local width = 256
			local P = beStructures.percent
			local child = beGUI.Picture.new(theme['window'], true)
				:setId('picture')
				:anchor(0.5, 0.5)
				:put(P(50), P(50))
				:resize(width, 128)
				:addChild(
					beGUI.Label.new(self._title, 'center', true, 'font_title')
						:setId('label_title')
						:anchor(0.5, 0)
						:put(P(50), 3)
						:resize(P(100), 23)
				)
				:addChild(
					beGUI.Label.new(self._message, 'center', true)
						:setId('label_message')
						:anchor(0.5, 1)
						:put(P(50), P(50))
						:resize(P(100), 23)
				)
				:addChild(
					beGUI.Button.new(self._confirm)
						:setId('button_confirm')
						:anchor(1.1, 1)
						:put(P(50), P(90))
						:resize(P(24), 23)
						:on('clicked', function (sender)
							self:_trigger('confirmed', self)
						end)
				)
				:addChild(
					beGUI.Button.new(self._deny)
						:setId('button_deny')
						:anchor(-0.1, 1)
						:put(P(50), P(90))
						:resize(P(24), 23)
						:on('clicked', function (sender)
							self:_trigger('denied', self)
						end)
				)
			if self._closable then
				child
					:addChild(
						beGUI.PictureButton.new('', false, { normal = 'button_close', pressed = 'button_close_down' })
							:setId('button_close')
							:anchor(1, 0)
							:put(width - 6, 5)
							:resize(19, 19)
							:on('clicked', function (sender)
								self:_trigger('canceled', self)
							end)
					)
			end
			self:addChild(child)

			local w, h = self:size()
			child:_updateLayout(w, h)
		end

		Popup._update(self, theme, delta, dx, dy, event)
	end,

	_cancelNavigation = function (self)
		if self._closable then
			self:_trigger('canceled', self)
		end

		self.context.focus = nil
		self.context.navigated = false
	end
}, Popup)

--[[
Exporting.
]]

return {
	Popup = Popup,
	MessageBox = MessageBox,
	QuestionBox = QuestionBox
}
