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

require 'libs/beGUI/beGUI'
require 'keycode'

local DEBUG = false

local widgets = nil
local theme = nil

function setup()
	print('beGUI v' .. beGUI.version)

	Canvas.main:resize(0, 320)

	local P = beGUI.percent -- Alias of percent.
	local left = beGUI.Widget.new()
		:put(P(27), 15)     -- X: 27%, Y: 15.
		:resize(P(45), 290) -- W: 45%, H: 290.
		:addChild(
			beGUI.Button.new('Button')
				:setId('button')
				:anchor(0, 0)      -- X: left, Y: top.
				:put(P(-50), 0)    -- X: -50%, Y: 0.
				:resize(P(48), 23) -- W: 48%, H: 23.
				:on('clicked', function (sender)
					local lbl = widgets:get(1, 'label')
					lbl:setValue('Clicked ' .. tostring(sender))
				end)
		)
		:addChild(
			beGUI.Button.new('Popup')
				:setId('button')
				:anchor(1, 0)      -- X: right, Y: top.
				:put(P(50), 0)     -- X: 50%, Y: 0.
				:resize(P(48), 23) -- W: 48%, H: 23.
				:on('clicked', function (sender)
					widgets:openPopup( -- Open popup.
						beGUI.QuestionBox.new(true, 'Message', 'Hi there!')
							:on('canceled', function (sender)
								widgets:closePopup()

								local lbl = widgets:get(1, 'label')
								lbl:setValue('Popup canceled')
							end)
							:on('confirmed', function (sender)
								widgets:closePopup()

								local lbl = widgets:get(1, 'label')
								lbl:setValue('Popup confirmed')
							end)
							:on('denied', function (sender)
								widgets:closePopup()

								local lbl = widgets:get(1, 'label')
								lbl:setValue('Popup denied')
							end)
					)

					local lbl = widgets:get(1, 'label')
					lbl:setValue('Popup opened')
				end)
		)
		:addChild(
			beGUI.Label.new('beGUI demo', 'left', true)
				:setId('label')
				:anchor(0.5, 0)
				:put(0, 20)
				:resize(P(100), 23)
		)
		:addChild(
			beGUI.CheckBox.new('CheckBox')
				:setId('checkbox')
				:anchor(0.5, 0)
				:put(0, 40)
				:resize(P(100), 23)
				:on('changed', function (sender, value)
					local lbl = widgets:get(1, 'label')
					lbl:setValue('Changed ' .. tostring(sender) .. ', ' ..  tostring(value))
				end)
		)
		:addChild(
			beGUI.RadioBox.new('RadioBox 1', true)
				:setId('radiobox1')
				:anchor(0.5, 0)
				:put(0, 60)
				:resize(P(100), 23)
				:on('changed', function (sender, value)
					if value then
						local lbl = widgets:get(1, 'label')
						lbl:setValue('Changed ' .. tostring(sender) .. '1, ' ..  tostring(value))
					end
				end)
		)
		:addChild(
			beGUI.RadioBox.new('RadioBox 2')
				:setId('radiobox2')
				:anchor(0.5, 0)
				:put(0, 80)
				:resize(P(100), 23)
				:on('changed', function (sender, value)
					if value then
						local lbl = widgets:get(1, 'label')
						lbl:setValue('Changed ' .. tostring(sender) .. '2, ' ..  tostring(value))
					end
				end)
		)
		:addChild(
			beGUI.RadioBox.new('RadioBox 3')
				:setId('radiobox3')
				:anchor(0.5, 0)
				:put(0, 100)
				:resize(P(100), 23)
				:on('changed', function (sender, value)
					if value then
						local lbl = widgets:get(1, 'label')
						lbl:setValue('Changed ' .. tostring(sender) .. '3, ' ..  tostring(value))
					end
				end)
		)
		:addChild(
			beGUI.ComboBox.new({ 'Item 1', 'Item 2', 'Item 3', 'More Items...' })
				:setId('combobox')
				:anchor(0.5, 0)
				:put(0, 120)
				:resize(P(100), 23)
				:on('changed', function (sender, value)
					local lbl = widgets:get(1, 'label')
					lbl:setValue('Changed ' .. tostring(sender) .. ', ' ..  tostring(value))
				end)
		)
		:addChild(
			beGUI.List.new()
				:setId('list')
				:anchor(0.5, 0)
				:put(0, 150)
				:resize(P(100), 80)
				:addChild( -- List items are added as children.
					beGUI.Button.new('Increase')
						:setId('button')
						:put(0, 0)
						:resize(P(100), 23)
						:on('clicked', function (_)
							local lbl = widgets:get(1, 'list', 'label1') -- Get the following one label.
							local num = tonumber(lbl:getValue())
							lbl:setValue(tostring(num + 1))
						end)
				)
				:addChild(
					beGUI.Label.new('1')
						:setId('label1')
						:put(P(1), 20)
						:resize(P(98), 23)
				)
				:addChild(
					beGUI.Label.new('Hold and slide...')
						:setId('label2')
						:put(P(1), 40)
						:resize(P(98), 23)
				)
				:addChild(
					beGUI.Label.new('Label 3')
						:setId('label3')
						:put(P(1), 60)
						:resize(P(98), 23)
				)
				:addChild(
					beGUI.Label.new('Item in a List')
						:setId('label4')
						:put(P(1), 80)
						:resize(P(98), 23)
				)
		)
		:addChild(
			beGUI.Picture.new({ resource = Resources.load('disk.png') })
				:setId('picture')
				:anchor(0, 0)
				:put(P(-50), 240)
				:resize(48, 48)
		)
		:addChild(
			beGUI.NumberBox.new(10, 1, 0, 100)
				:setId('numberbox1')
				:anchor(1, 0)
				:put(P(50), 240)
				:resize(P(50), 23)
				:on('changed', function (sender, value)
					local lbl = widgets:get(1, 'label')
					lbl:setValue('Changed ' .. tostring(sender) .. ', ' ..  tostring(value))
				end)
		)
		:addChild(
			beGUI.NumberBox.new(5, 0.1, 0, 10, function (val)
				return math.floor(val * 10 + 0.5) / 10
			end)
				:setId('numberbox2')
				:anchor(1, 1)
				:put(P(50), P(100))
				:resize(P(50), 23)
				:on('changed', function (sender, value)
					local lbl = widgets:get(1, 'label')
					lbl:setValue('Changed ' .. tostring(sender) .. ', ' ..  tostring(value))
				end)
		)
	local right = beGUI.Widget.new()
		:put(P(73), 15)     -- X: 73%, Y: 15.
		:resize(P(45), 290) -- W: 45%, H: 290.
		:addChild(
			beGUI.InputBox.new('', 'Input something...')
				:setId('inputbox')
				:anchor(0.5, 0)     -- X: middle, Y: top.
				:put(0, 0)          -- X: 0, Y: 0.
				:resize(P(100), 23) -- W: 100%, H: 23.
				:on('changed', function (sender, value)
					local lbl = widgets:get(2, 'label')
					lbl:setValue('Changed ' .. tostring(sender) .. ', ' ..  tostring(value))
				end)
		)
		:addChild(
			beGUI.Label.new('Click above')
				:setId('label')
				:anchor(0.5, 0)
				:put(0, 20)
				:resize(P(100), 23)
		)
		:addChild(
			beGUI.Droppable.new()
				:setId('droppable1')
				:anchor(0, 0)
				:put(P(-50), 40)
				:resize(P(40), 17)
				:addChild(
					beGUI.Custom.new()
						:setId('custom')
						:anchor(0, 0)
						:put(0, 0)
						:resize(P(100), P(100))
						:on('updated', function (sender, x, y, w, h)
							rect(x, y, x + w - 1, y + h - 1, false, sender.color or Color.new(0, 0, 0))
						end)
				)
				:on('entered', function (sender, draggable)
					local custom = widgets:get(2, 'droppable1', 'custom')
					custom.color = Color.new(0, 255, 0)

					local lbl = widgets:get(2, 'label')
					lbl:setValue('Entered ' .. sender.id .. ', ' .. draggable.id)
				end)
				:on('left', function (sender, draggable)
					local custom = widgets:get(2, 'droppable1', 'custom')
					custom.color = nil
					
					local lbl = widgets:get(2, 'label')
					lbl:setValue('Left ' .. sender.id .. ', ' .. draggable.id)
				end)
				:on('dropping', function (sender, draggable)
					return true
				end)
				:on('dropped', function (sender, draggable)
					local custom = widgets:get(2, 'droppable1', 'custom')
					custom.color = nil

					local lbl = widgets:get(2, 'label')
					lbl:setValue('Dropped ' .. sender.id .. ', ' .. draggable.id)
				end)
				:addChild(
					beGUI.Draggable.new()
						:setId('draggable1')
						:anchor(0, 0)
						:put(0, 0)
						:resize(P(100), P(100))
						:addChild(
							beGUI.Label.new('Drag me')
								:setId('label')
								:anchor(0, 0)
								:put(2, 0)
								:resize(P(100), P(100))
						)
				)
		)
		:addChild(
			beGUI.Droppable.new()
				:setId('droppable2')
				:anchor(1, 0)
				:put(P(50), 40)
				:resize(P(40), 17)
				:addChild(
					beGUI.Custom.new()
						:setId('custom')
						:anchor(0, 0)
						:put(0, 0)
						:resize(P(100), P(100))
						:on('updated', function (sender, x, y, w, h)
							rect(x, y, x + w - 1, y + h - 1, false, sender.color or Color.new(0, 0, 0))
						end)
				)
				:on('entered', function (sender, draggable)
					local custom = widgets:get(2, 'droppable2', 'custom')
					custom.color = Color.new(0, 255, 0)

					local lbl = widgets:get(2, 'label')
					lbl:setValue('Entered ' .. sender.id .. ', ' .. draggable.id)
				end)
				:on('left', function (sender, draggable)
					local custom = widgets:get(2, 'droppable2', 'custom')
					custom.color = nil

					local lbl = widgets:get(2, 'label')
					lbl:setValue('Left ' .. sender.id .. ', ' .. draggable.id)
				end)
				:on('dropping', function (sender, draggable)
					return true
				end)
				:on('dropped', function (sender, draggable)
					local custom = widgets:get(2, 'droppable2', 'custom')
					custom.color = nil

					local lbl = widgets:get(2, 'label')
					lbl:setValue('Dropped ' .. sender.id .. ', ' .. draggable.id)
				end)
		)
		:addChild(
			beGUI.Droppable.new()
				:setId('droppable3')
				:anchor(0, 0)
				:put(P(-50), 63)
				:resize(P(40), 17)
				:addChild(
					beGUI.Custom.new()
						:setId('custom')
						:anchor(0, 0)
						:put(0, 0)
						:resize(P(100), P(100))
						:on('updated', function (sender, x, y, w, h)
							rect(x, y, x + w - 1, y + h - 1, false, sender.color or Color.new(0, 0, 0))
						end)
				)
				:on('entered', function (sender, draggable)
					local custom = widgets:get(2, 'droppable3', 'custom')
					custom.color = Color.new(0, 255, 0)

					local lbl = widgets:get(2, 'label')
					lbl:setValue('Entered ' .. sender.id .. ', ' .. draggable.id)
				end)
				:on('left', function (sender, draggable)
					local custom = widgets:get(2, 'droppable3', 'custom')
					custom.color = nil

					local lbl = widgets:get(2, 'label')
					lbl:setValue('Left ' .. sender.id .. ', ' .. draggable.id)
				end)
				:on('dropping', function (sender, draggable)
					return true
				end)
				:on('dropped', function (sender, draggable)
					local custom = widgets:get(2, 'droppable3', 'custom')
					custom.color = nil

					local lbl = widgets:get(2, 'label')
					lbl:setValue('Dropped ' .. sender.id .. ', ' .. draggable.id)
				end)
				:addChild(
					beGUI.Draggable.new()
						:setId('draggable2')
						:anchor(0, 0)
						:put(0, 0)
						:resize(P(100), P(100))
						:addChild(
							beGUI.Label.new('Drag me 2')
								:setId('label')
								:anchor(0, 0)
								:put(2, 0)
								:resize(P(100), P(100))
						)
				)
		)
		:addChild(
			beGUI.Droppable.new()
				:setId('droppable4')
				:anchor(1, 0)
				:put(P(50), 63)
				:resize(P(40), 17)
				:addChild(
					beGUI.Custom.new()
						:setId('custom')
						:anchor(0, 0)
						:put(0, 0)
						:resize(P(100), P(100))
						:on('updated', function (sender, x, y, w, h)
							rect(x, y, x + w - 1, y + h - 1, false, sender.color or Color.new(0, 0, 0))
						end)
				)
				:on('entered', function (sender, draggable)
					local custom = widgets:get(2, 'droppable4', 'custom')
					if draggable.id == 'draggable2' then
						custom.color = Color.new(0, 255, 0)
					else
						custom.color = Color.new(255, 0, 0)
					end

					local lbl = widgets:get(2, 'label')
					lbl:setValue('Entered ' .. sender.id .. ', ' .. draggable.id)
				end)
				:on('left', function (sender, draggable)
					local custom = widgets:get(2, 'droppable4', 'custom')
					custom.color = nil
					
					local lbl = widgets:get(2, 'label')
					lbl:setValue('Left ' .. sender.id .. ', ' .. draggable.id)
				end)
				:on('dropping', function (sender, draggable)
					return draggable.id == 'draggable2'
				end)
				:on('dropped', function (sender, draggable)
					local custom = widgets:get(2, 'droppable4', 'custom')
					custom.color = nil

					local lbl = widgets:get(2, 'label')
					lbl:setValue('Dropped ' .. sender.id .. ', ' .. draggable.id)
				end)
		)
		:addChild(
			beGUI.List.new()
				:setId('list')
				:anchor(0.5, 0)
				:put(0, 90)
				:resize(P(100), 60)
				:addChild(
					beGUI.MultilineLabel.new('The Quick Brown Fox Jumps Over the Lazy Dog.\n[col=0xff0000ff]ABCDEFG[/col] [col=0x00ff00ff]HIJKLMN[/col] [col=0x0000ffff]OPQRST[/col] UVWXYZ abcdefg hijklmn opqrst uvwxyz 1234567890 ! @ # $ % ^ & * ( ) ` - = [ ] \\ ; \' , . / ~ _ + { } | : " < > ?')
						:setId('multilinelabel')
						:put(P(1), 0)
						:resize(P(98), 0) -- Height is automatically calculated.
				)
		)
		:addChild(
			beGUI.ProgressBar.new(0, Color.new(0, 0, 128))
				:setId('progressbar')
				:anchor(0.5, 0)
				:put(0, 160)
				:resize(P(100), 17)
				:addChild(
					beGUI.Label.new('3/5', 'center', false, 'font_white')
						:setId('label_numbers')
						:anchor(0.5, 1)
						:put(P(50), P(100))
						:resize(P(100), P(100))
				)
				:on('changed', function (sender, value, maxValue, shadowValue)
					local lblNums = sender:find('label_numbers')
					lblNums:setValue(tostring(value) .. '/' .. tostring(maxValue))
				end)
				:setMaxValue(5)
				:setValue(3)
		)
		:addChild(
			beGUI.Slide.new(3, 0, 5)
				:setId('slide')
				:anchor(0.5, 0)
				:put(0, 184)
				:resize(P(100), 17)
				:on('changed', function (sender, value)
					local prog = widgets:get(2, 'progressbar')
					prog:setValue(value)
				end)
		)
		:addChild(
			beGUI.Url.new('Bitty Engine | beGUI')
				:setId('url')
				:anchor(0.5, 0)
				:put(0, 210)
				:resize(-1, 12)
				:on('clicked', function (sender)
					Platform.surf('https://github.com/paladin-t/bitty/discussions/2')
				end)
		)
		:addChild(
			beGUI.Tab.new()
				:setId('tab')
				:anchor(0.5, 0)
				:put(0, 230)
				:resize(P(100), 57)
				:add('Tab 1')
				:add('Tab 2')
				:add('Tab 3')
				:setValue(1)
				:addChild(
					beGUI.Button.new('Button')
						:setId('button')
						:anchor(1, 0)
						:put(P(98), 23)
						:resize(60, 23)
						:on('clicked', function (sender)
							local lbl = sender.parent:get('label')
							lbl:setValue('Clicked ' .. tostring(sender))
						end)
				)
				:addChild(
					beGUI.Label.new('Hello world!', 'left', true)
						:setId('label')
						:anchor(0, 0)
						:put(4, 23)
						:resize(P(100), 23)
				)
				:setValue(2)
				:addChild(
					beGUI.Label.new('Greetings from tab 2.', 'left', true)
						:setId('label')
						:anchor(0, 0)
						:put(4, 23)
						:resize(P(100), 23)
				)
				:setValue(3)
				:addChild(
					beGUI.Label.new('Greetings from tab 3.', 'left', true)
						:setId('label')
						:anchor(0, 0)
						:put(4, 23)
						:resize(P(100), 23)
				)
				:setValue(1)
				:on('changed', function (sender, value)
					local lbl = widgets:get(2, 'label')
					lbl:setValue('Changed ' .. tostring(sender) .. ', ' ..  tostring(value))
				end)
		)
	widgets = beGUI.Widget.new()
		:put(0, 0)
		:resize(P(100), P(100))
		:addChild(
			left
		)
		:addChild(
			right
		)
	theme = beTheme.default()
end

function update(delta)
	cls(Color.new(255, 255, 255))

	if keyp(KeyCode.Up) then
		widgets:navigate('prev')
	elseif keyp(KeyCode.Down) then
		widgets:navigate('next')
	elseif keyp(KeyCode.Left) then
		widgets:navigate('dec')
	elseif keyp(KeyCode.Right) then
		widgets:navigate('inc')
	elseif keyp(KeyCode.Return) then
		widgets:navigate('press')
	elseif keyp(KeyCode.Esc) then
		widgets:navigate('cancel')
	end

	font(theme['font'].resource)
	widgets:update(theme, delta)
	font(nil)

	if DEBUG then
		local x, y, lmb = mouse()
		circ(x, y, 3, lmb, Color.new(255, 0, 0))
	end
end
