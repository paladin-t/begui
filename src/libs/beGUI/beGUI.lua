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

require 'libs/beGUI/beTheme'
local beStructures = require 'libs/beGUI/beGUI_Structures'
local beWidget = require 'libs/beGUI/beGUI_Widget'
local beBasics = require 'libs/beGUI/beGUI_Basics'
local beContainers = require 'libs/beGUI/beGUI_Containers'
local bePopups = require 'libs/beGUI/beGUI_Popups'
local beCustom = require 'libs/beGUI/beGUI_Custom'
local beTween = require 'libs/beGUI/beTween'

--[[
Exporting.
]]

beGUI = {
	version = '1.2.1',

	-- Data structure to represent relative number.
	percent = beStructures.percent,

	-- Widget class, base for other widgets, also could be used as container of other widgets.
	Widget = beWidget.Widget,
	-- Label widget.
	Label = beBasics.Label,
	-- MultilineLabel widget.
	MultilineLabel = beBasics.MultilineLabel,
	-- Url widget.
	-- Events:
	--   'clicked': function (sender) end
	Url = beBasics.Url,
	-- InputBox widget.
	-- Events:
	--   'changed': function (sender, value) end
	InputBox = beBasics.InputBox,
	-- Picture widget.
	Picture = beBasics.Picture,
	-- Button widget.
	-- Events:
	--   'clicked': function (sender) end
	Button = beBasics.Button,
	-- PictureButton widget.
	-- Events:
	--   'clicked': function (sender) end
	PictureButton = beBasics.PictureButton,
	-- CheckBox widget.
	-- Events:
	--   'changed': function (sender, value) end
	CheckBox = beBasics.CheckBox,
	-- RadioBox widget.
	-- Events:
	--   'changed': function (sender, value) end
	RadioBox = beBasics.RadioBox,
	-- ComboBox widget.
	-- Events:
	--   'changed': function (sender, value) end
	ComboBox = beBasics.ComboBox,
	-- NumberBox widget.
	-- Events:
	--   'changed': function (sender, value) end
	NumberBox = beBasics.NumberBox,
	-- ProgressBar widget.
	-- Events:
	--   'changed': function (sender, value, maxValue, shadowValue) end
	ProgressBar = beBasics.ProgressBar,
	-- Slide widget.
	-- Events:
	--   'changed': function (sender, value) end
	Slide = beBasics.Slide,
	-- List widget.
	List = beContainers.List,
	-- Draggable widget.
	Draggable = beContainers.Draggable,
	-- Droppable widget.
	-- Events:
	--   'entered': function (sender, draggable) end
	--   'left': function (sender, draggable) end
	--   'dropping': function (sender, draggable) return droppable end
	--   'dropped': function (sender, draggable) end
	--   'clicked': function (sender) end
	Droppable = beContainers.Droppable,
	-- Tab widget.
	-- Events:
	--   'changed': function (sender, value) end
	Tab = beContainers.Tab,
	-- Popup widget.
	Popup = bePopups.Popup,
	-- MessageBox widget.
	-- Events:
	--   'canceled': function (sender) end
	--   'confirmed': function (sender) end
	MessageBox = bePopups.MessageBox,
	-- QuestionBox widget.
	-- Events:
	--   'canceled': function (sender) end
	--   'confirmed': function (sender) end
	--   'denied': function (sender) end
	QuestionBox = bePopups.QuestionBox,
	-- Custom widget.
	-- Events:
	--   'updated': function (sender, x, y, w, h) end
	Custom = beCustom.Custom,
	-- Tweening helper.
	Tween = beTween.Tween
}
