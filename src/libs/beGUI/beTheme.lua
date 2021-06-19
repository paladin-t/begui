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

local default = function ()
	local font_ = Font.new('fonts/ascii 8x8.png', Vec2.new(8, 8))

	return {
		['font'] = {
			resource = font_,
			color = Color.new(0, 0, 0)
		},
		['font_white'] = {
			resource = font_,
			color = Color.new(255, 255, 255)
		},
		['font_placeholder'] = {
			resource = font_,
			color = Color.new(138, 138, 138)
		},
		['font_title'] = {
			resource = font_,
			color = Color.new(255, 255, 255)
		},
		['font_url'] = {
			resource = font_,
			color = Color.new(0, 102, 255)
		},
		['font_url_hover'] = {
			resource = font_,
			color = Color.new(0, 162, 255)
		},

		['label'] = {
			content_offset = nil
		},
		['label_shadow'] = {
			content_offset = { 1, 1 }
		},
		['multilinelabel'] = {
			content_offset = nil
		},

		['url'] = {
			content_offset = nil
		},
		['url_down'] = {
			content_offset = nil
		},

		['inputbox'] = {
			resource = Resources.load('imgs/panel_white.png'),
			area = { 0, 0, 17, 17 },
			content_offset = { 2, 0 }
		},

		['button'] = {
			resource = Resources.load('imgs/button.png'),
			area = { 0, 0, 23, 23 },
			content_offset = nil
		},
		['button_down'] = {
			resource = Resources.load('imgs/button.png'),
			area = { 0, 23, 23, 23 },
			content_offset = { 0, 1 }
		},

		['button_close'] = {
			resource = Resources.load('imgs/button_close.png'),
			area = { 0, 0, 19, 19 },
			content_offset = nil
		},
		['button_close_down'] = {
			resource = Resources.load('imgs/button_close.png'),
			area = { 0, 19, 19, 19 },
			content_offset = nil
		},

		['checkbox'] = {
			resource = Resources.load('imgs/checkbox.png'),
			area = { 0, 0, 13, 13 },
			content_offset = { 16, 1 }
		},
		['checkbox_selected'] = {
			resource = Resources.load('imgs/checkbox.png'),
			area = { 0, 13, 13, 13 },
			content_offset = { 16, 1 }
		},

		['radiobox'] = {
			resource = Resources.load('imgs/radiobox.png'),
			area = { 0, 0, 13, 13 },
			content_offset = { 16, 1 }
		},
		['radiobox_selected'] = {
			resource = Resources.load('imgs/radiobox.png'),
			area = { 0, 13, 13, 13 },
			content_offset = { 16, 1 }
		},

		['combobox'] = {
			resource = Resources.load('imgs/panel_gray.png'),
			area = { 0, 0, 17, 17 },
			content_offset = { 1, 1 }
		},
		['combobox_button_left'] = {
			resource = Resources.load('imgs/button_left.png'),
			area = { 0, 0, 17, 17 },
			content_offset = nil
		},
		['combobox_button_left_down'] = {
			resource = Resources.load('imgs/button_left.png'),
			area = { 0, 17, 17, 17 },
			content_offset = nil
		},
		['combobox_button_right'] = {
			resource = Resources.load('imgs/button_right.png'),
			area = { 0, 0, 17, 17 },
			content_offset = nil
		},
		['combobox_button_right_down'] = {
			resource = Resources.load('imgs/button_right.png'),
			area = { 0, 17, 17, 17 },
			content_offset = nil
		},

		['numberbox'] = {
			resource = Resources.load('imgs/panel_gray.png'),
			area = { 0, 0, 17, 17 },
			content_offset = { 1, 1 }
		},
		['numberbox_button_up'] = {
			resource = Resources.load('imgs/button_up.png'),
			area = { 0, 0, 17, 17 },
			content_offset = nil
		},
		['numberbox_button_up_down'] = {
			resource = Resources.load('imgs/button_up.png'),
			area = { 0, 17, 17, 17 },
			content_offset = nil
		},
		['numberbox_button_down'] = {
			resource = Resources.load('imgs/button_down.png'),
			area = { 0, 0, 17, 17 },
			content_offset = nil
		},
		['numberbox_button_down_down'] = {
			resource = Resources.load('imgs/button_down.png'),
			area = { 0, 17, 17, 17 },
			content_offset = nil
		},

		['progressbar'] = {
			resource = Resources.load('imgs/progressbar.png'),
			area = { 0, 0, 17, 17 },
			content_offset = { 2, 2 }
		},

		['slide'] = {
			resource = Resources.load('imgs/slide.png'),
			area = { 0, 0, 13, 17 },
			content_offset = nil
		},

		['list'] = {
			resource = Resources.load('imgs/panel_white.png'),
			area = { 0, 0, 17, 17 },
			content_offset = nil
		},

		['tab'] = {
			resource = nil,
			area = nil,
			content_offset = { 3, 3 }
		},
		['tab_title'] = {
			content_offset = nil
		},

		['window'] = {
			resource = Resources.load('imgs/window.png')
		}
	}
end

beTheme = {
	default = default
}
