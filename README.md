# beGUI

beGUI is a tiny and customizable GUI system for Lua, and fully written in Lua. It is originally created to run within the [Bitty Engine](https://github.com/paladin-t/bitty/), however it could be ported to other environments with some twists.

### Features

"beGUI" implements:

* Placable, resizable, anchorable, and nestable `Widget`
* `Label`
* `MultilineLabel`
* `Url`
* `InputBox`
* `Picture`
* `Button`
* `PictureButton`
* `CheckBox`
* `RadioBox`
* `ComboBox`
* `NumberBox`
* `ProgressBar`
* `Slide`
* Scrollable `List`
* `Draggable` and `Droppable`
* `Tab`
* `Popup`, `MessageBox`, `QuestionBox`
* `Custom`
* Navigation by key (or custom method)

### Glance

![beGUI 1](imgs/beGUI1.png)

![beGUI 2](imgs/beGUI2.png)

### Usage

Setup:

1. Clone this repository or download from [releases](https://github.com/paladin-t/begui/releases)
2. Open "src" directly or import it to your own projects with [Bitty Engine](https://github.com/paladin-t/bitty/)
3. See code and comments for details

Code:

```lua
require 'libs/beGUI/beGUI'

local widgets = nil
local theme = nil

function setup()
  local P = beGUI.percent -- Alias of percent.
  widgets = beGUI.Widget.new()
    :put(0, 0)
    :resize(P(100), P(100))
    :addChild(
      beGUI.Label.new('beGUI demo')
        :setId('label')
        :anchor(0, 0)
        :put(10, 10)
        :resize(100, 23)
    )
    :addChild(
      beGUI.Button.new('Button')
        :setId('button')
        :anchor(0, 0)
        :put(10, 36)
        :resize(100, 23)
        :on('clicked', function (sender)
          local lbl = widgets:find('label')
          lbl:setValue('Clicked ' .. tostring(sender))
        end)
    )
  theme = beTheme.default()
end

function update(delta)
  cls(Color.new(255, 255, 255))

  font(theme['font'].resource)
  widgets:update(theme, delta)
  font(nil)
end
```
