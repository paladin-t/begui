<img src="imgs/logo.png" width="128" height="128">

beGUI is a minimal customizable GUI system for Lua, and fully written in Lua.

Try it [in browser](https://paladin-t.github.io/begui/).

**Index**

- [Features](#features)
- [Setup](#setup)
- [Reference](#reference)
  - [1. Principles](#1-principles)
  - [2. Structures](#2-structures)
    - [beStructures.Percent](#bestructurespercent)
    - [beGUI.percent](#beguipercent)
    - [beStructures.Calc](#bestructurescalc)
    - [beGUI.calc](#beguicalc)
  - [3. Widget](#3-widget)
    - [beGUI.Widget](#beguiwidget)
  - [4. Basic Widgets](#4-basic-widgets)
    - [beGUI.Label](#beguilabel)
    - [beGUI.MultilineLabel](#beguimultilinelabel)
    - [beGUI.Url](#beguiurl)
    - [beGUI.InputBox](#beguiinputbox)
    - [beGUI.TextBox](#beguitextbox)
    - [beGUI.DocumentViewer](#beguidocumentviewer)
    - [beGUI.Picture](#beguipicture)
    - [beGUI.Button](#beguibutton)
    - [beGUI.PictureButton](#beguipicturebutton)
    - [beGUI.CheckBox](#beguicheckbox)
    - [beGUI.RadioBox](#beguiradiobox)
    - [beGUI.ComboBox](#beguicombobox)
    - [beGUI.DropdownComboBox](#beguidropdowncombobox)
    - [beGUI.NumberBox](#beguinumberbox)
    - [beGUI.ProgressBar](#beguiprogressbar)
    - [beGUI.Slide](#beguislide)
  - [5. Interactable Widgets](#5-interactable-widgets)
    - [beGUI.Clickable](#beguiclickable)
    - [beGUI.ClickableText](#beguiclickabletext)
    - [beGUI.Draggable](#beguidraggable)
    - [beGUI.Droppable](#beguidroppable)
  - [6. Container Widgets](#6-container-widgets)
    - [beGUI.Group](#beguigroup)
    - [beGUI.List](#beguilist)
    - [beGUI.Tab](#beguitab)
  - [7. Popup Widgets](#7-popup-widgets)
    - [beGUI.Popup](#beguipopup)
    - [beGUI.MessageBox](#beguimessagebox)
    - [beGUI.QuestionBox](#beguiquestionbox)
    - [beGUI.TextEditBox](#beguitexteditbox)
  - [8. Custom Widget](#8-custom-widget)
    - [beGUI.Custom](#beguicustom)
    - [Writing Your Own Widget](#writing-your-own-widget)
  - [9. Theme](#9-theme)
  - [10. Tweening](#10-tweening)
    - [beGUI.Tween](#beguitween)
- [License](#license)

# Features

![beGUI 1](imgs/beGUI1.png)

![beGUI 2](imgs/beGUI2.png)

"beGUI" implements:

* Placable, resizable, anchorable, and nestable `Widget`
* Textual `Label`, `MultilineLabel`, `Url`, `InputBox`
* Advanced textual `TextBox`, `DocumentViewer`
* `Picture`
* Clickable buttons `Button`, `PictureButton`
* `CheckBox`, `RadioBox`
* `ComboBox`, `DropdownComboBox`
* `NumberBox`
* `ProgressBar`, `Slide`
* `Clickable`, `ClickableText`
* `Group`
* Scrollable `List`
* `Draggable` and `Droppable`
* `Tab`
* `Popup`, `MessageBox`, `QuestionBox`, `TextEditBox`
* `Custom` to make your own update function
* And customizable by writing your own widget
* Navigation by key (or custom method)

Play live demo [in browser](https://paladin-t.github.io/begui/).

# Setup

beGUI is originally created to run within the [Bitty Engine](https://github.com/paladin-t/bitty/). The graphics primitives and input API is quite straightforward in Bitty Engine, it's possible to port it to other Lua-based environments with little twist, if that environment does `rect(...)`, `tex(...)`, `text(...)`, `mouse(...)`, etc.

1. Clone this repository or download from [releases](https://github.com/paladin-t/begui/releases)
2. Open "src" directly to run or copy everything under "src" to your own projects for [Bitty Engine](https://github.com/paladin-t/bitty/)

# Reference

## 1. Principles

beGUI implements a [retained mode](https://en.wikipedia.org/wiki/Retained_mode) GUI system, it separates behaviour and appearance into widget classes and theme preference. Widgets are organized in tree hierarchies, each widget can have none or one parent, and none or multiple children. There are two phases of the lib, first to construct the hierarchy, second to update it. It enumerates from root widget to it's descendents during update, beGUI will handle internal states like visibility, click event, etc. then draw it properly with the theme preference during this procedure.

Most of the member functions return the widget object itself, it makes it easier to write internal DSL to construct full hierarchy in a tree style code.

```lua
require 'libs/beGUI/beGUI'
require 'libs/beGUI/beTheme'

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

Each widget has an anchor property which represents for the locating point in its local space, a size property, and a position property for either absolute, percentage, or expression-based position in its parent's space relatively. The final position is calculated according to these two properties. An anchor component is typically in range of values from 0.0 to 1.0, but it could be also less than 0.0 or greater than 1.0. An absolute component represents for pixels. A relative component is typically in range of values from `Percent(0)` to `Percent(100)`, but it could be also less than `Percent(0)` or greater than `Percent(100)`. A expression calculation component could be a string, i.e. `'left'`, `'right'`, `'top'`, `'bottom'`, `'2%'`, `'0.02'`, `'100%-8px'`, `'20px'`, etc.

![](imgs/docking_absolutely.png)

![](imgs/docking_relatively.png)

Resources are splitted into nine grids evenly for flex scaled widgets.

![](imgs/grids.png)

## 2. Structures

<details open>
<summary>Structures</summary>

These structures are used to help organizing widget layout.

### beStructures.Percent

beStructures.`Percent` denotes relative value instead of absolute for positioning and sizing depending on its parent properties.

**Model: `require 'libs/beGUI/beGUI_Structures'`**

* beStructures.`Percent.new(amount)`: constructs a `Percent` object
  * `amount`: real number, no limit but often with range of values from 0 to 100
* `p.__mul(num)`: multiply the `Percent` value with another number
  * `num`: the number to multiply
  * returns result number

### beGUI.percent

Shortcut to create `Percent` object.

**Model: `require 'libs/beGUI/beGUI'`**

* beGUI.`percent(amount)`: constructs a `Percent` object
  * `amount`: real number, no limit but often with range of values from 0 to 100
  * returns `Percent`

### beStructures.Calc

beStructures.`Calc` denotes expression calculation for positioning and sizing depending on its parent properties.

**Model: `require 'libs/beGUI/beGUI_Structures'`**

* beStructures.`Calc.new(expr)`: constructs a `Calc` object
  * `expr`:expression calculation
* `p.__mul(num)`: multiply the `Calc` value with another number
  * `num`: the number to multiply
  * returns result number

### beGUI.calc

Shortcut to create `Calc` object.

**Model: `require 'libs/beGUI/beGUI'`**

* beGUI.`calc(expr)`: constructs a `Calc` object
  * `expr`:expression calculation
  * returns `calc`

This function supports the following formats:

* `'left'`, `'top'`, `'begin'`, `'head'`, `'front'` for 0%
* `'right'`, `'bottom'`, `'end'`, `'tail'`, `'back'` for 100%
* `'middle'`, `'center'`, `'centre'` for 50%
* `'2%'`, `'0.02'` for 2%
* `'100%-8px'`, `'2%+8px'` for relative percentage multiplied by the outer parameter, plus an absolute pixel offset
* `'20px'` for absolute pixel value

</details>

## 3. Widget

<details open>
<summary>Widget</summary>

### beGUI.Widget

**Model: `require 'libs/beGUI/beGUI'`**

**Constructor**

* beGUI.`Widget.new()`: constructs a `Widget` object

**Methods**

* `widget:setId(id)`: sets the ID of the `Widget`; an ID is used to identify a `Widget` from others for accessing
  * `id`: ID string
  * returns `self`
* `widget:get(...)`: gets a child `Widget` with the specific ID sequence
  * `...`: ID sequence of the full hierarchy path
  * returns the got `Widget` or `nil`
* `widget:find(id)`: finds the first matched `Widget` with the specific ID
  * `id`: ID string at any level of the hierarchy path
  * returns the found `Widget` or `nil`
* `widget:visible()`: gets the visibility of the `Widget`
  * returns boolean for visibility
* `widget:setVisible(val)`: sets the visibility of the `Widget`
  * `val`: whether it's visible
  * returns `self`
* `widget:capturable()`: gets the capturability of the `Widget`
  * returns boolean or string for capturability
* `widget:setCapturable(val)`: sets the capturability of the `Widget`
  * `val`: `true`, `false` or `'children'`
  * returns `self`
* `widget:anchor(x, y)`: sets the anchor of the `Widget`; anchor is used to calculate the offset when placing `Widget`
  * `x`: x position of the anchor in local space as number, typically [0.0, 1.0] for [left, right], but it could be also less than 0.0 or greater than 1.0
  * `y`: y position of the anchor in local space as number, typically [0.0, 1.0] for [top, bottom], but it could be also less than 0.0 or greater than 1.0
  * returns `self`
* `widget:offset()`: gets the offset of the `Widget`
  * returns offset `x`, `y` in world space
* `widget:put(x, y)`: sets the position of the `Widget`
  * `x`: number for absolute position; or `Percent` for relative position, typically with range of values from `Percent(0)` to `Percent(100)`, but it could be also less than `Percent(0)` or greater than `Percent(100)`; or `Calc` for expression calculation, see [beStructures.Calc](#bestructurescalc) for details
  * `y`: number for absolute position; or `Percent` for relative position, typically with range of values from `Percent(0)` to `Percent(100)`, but it could be also less than `Percent(0)` or greater than `Percent(100)`; or `Calc` for expression calculation, see [beStructures.Calc](#bestructurescalc) for details
  * returns `self`
* `widget:position()`: gets the position of the `Widget`
  * returns position `x`, `y` in local space
* `widget:worldPosition()`: gets the position of the `Widget` in world space
  * returns position `x`, `y` in world space
* `widget:resize(width, height)`: sets the size of the `Widget`
  * `width`: number for absolute size; or `Percent` for relative size, typically with range of values from `Percent(0.00...n)` to `Percent(100)`, but it could be also greater than `Percent(100)`; or `Calc` for expression calculation, see [beStructures.Calc](#bestructurescalc) for details
  * `height`: number for absolute size; or `Percent` for relative size, typically with range of values from `Percent(0.00...n)` to `Percent(100)`, but it could be also greater than `Percent(100)`; or `Calc` for expression calculation, see [beStructures.Calc](#bestructurescalc) for details
  * returns `self`
* `widget:size()`: gets the size of the `Widget`
  * returns size `width`, `height`
* `widget:alpha()`: gets the alpha value of the `Widget`
  * returns transparency number, with range of values from 0 to 255
* `widget:setAlpha(val)`: sets the alpha value of the `Widget`
  * `val`: number with range of value from 0 to 255, or nil for default (255)
  * returns `self`
* `widget:getChild(idOrIndex)`: gets the child with the specific ID or index
  * `idOrIndex`: ID string, or index number
  * returns the found child or nil
* `widget:insertChild(child, index)`: inserts a child before the specific index
  * `child`: the child `Widget` to insert
  * returns `self`
* `widget:addChild(child)`: adds a child to the end of the children list
  * `child`: the child `Widget` to add
  * returns `self`
* `widget:removeChild(childOrIdOrIndex)`: removes a child with the specific child, or its ID or index
  * `child`: child `Widget`, or its ID string, or index number
  * returns `self`
* `widget:foreachChild(handler)`: iterates all children, and calls the specific handler
  * `handler`: the children handler in form of `function (child, index) end`
  * returns `self`
* `widget:sortChildren(comp)`: sorts all children with the specific comparer
  * `comp`: the comparer in form of `function (left, right) end`
  * returns `self`
* `widget:getChildrenCount()`: gets the count of all children
  * returns children count number
* `widget:clearChildren()`: clears all children
  * returns `self`
* `widget:openPopup(content)`: opens a popup
  * `content`: the popup to open
  * returns `self`
* `widget:closePopup()`: closes any popup
  * returns `self`
* `widget:update(theme, delta, event = nil)`: updates the `Widget` and its children recursively
  * `theme`: the theme to draw with
  * `delta`: elapsed time since previous update
  * `event`: optional, omit it for common usage, pass a prefilled event to prevent default event

**Events**

* `widget:on(event, handler)`: registers the handler of the specific event
  * `event`: event name string
  * `handler`: callback function
  * returns `self`
* `widget:off(event)`: unregisters the handlers of the specific event
  * `event`: event name string
  * returns `self`

**Other Methods**

* `widget:navigatable()`: gets whether this `Widget` is navigatable
  * returns `'all'` for fully navigatable, `nil` for non-navigatable, `'children'` for children only, `'content'` for content only
* `widget:navigate(dir)`: navigates through widgets, call this to perform key navigation, etc.
  * `dir`: can be one in `'prev'`, `'next'`, `'press'`, `'cancel'`
* `widget:queriable()`: gets whether this `Widget` is queriable
  * returns `true` for queriable, otherwise `false`
* `widget:setQueriable(val)`: sets whether this `Widget` is queriable
  * `val`: whether this `Widget` is queriable
  * returns `self`
* `widget:query(x, y)`: queries a `Widget` at the specific position
  * `x`: the x position to query
  * `y`: the y position to query
  * returns the queried `Widget` or `nil`
* `widget:captured()`: gets whether this `Widget` has captured mouse event.
  * returns `true` for captured, otherwise `false`
* `widget:touch(theme, delta, event)`: touches the `Widget` and its children recursively; this operation calls the `update` to refresh the widgets' layout but doesn't draw anything; used to prepare layout in advance to avoid flicking before tweening, etc. do not call this unless you really need to
  * `theme`: the theme to draw with
  * `delta`: elapsed time since previous update
  * `event`: optional, omit it for common usage, pass a prefilled event to prevent default event
  * returns `self`
* `widget:tween(t)`: schedules a tweening procedure
  * `t`: the tweening object
  * returns `self`
* `widget:clearTweenings()`: clears all tweening procedures
  * returns `self`

</details>

## 4. Basic Widgets

<details open>
<summary>Basic Widgets</summary>

### beGUI.Label

**Model: `require 'libs/beGUI/beGUI'`, implements beGUI.`Widget`**

**Constructor**

* beGUI.`Label.new(content, alignment = 'left', clip_ = false, theme = nil, shadow = nil)`: constructs a `Label` with the specific content
  * `content`: the content string
  * `alignment`: one in `nil`, `'left'`, `'right'`, `'center'`
  * `clip_`: whether to clip drawing outside this `Widget`'s bounds
  * `theme`: custom theme
  * `shadow`: shadow theme for shadowed drawing

**Methods**

* `label:getValue()`: gets the content text
  * returns the content string
* `label:setValue(val)`: sets the content text
  * `val`: the specific content string
  * returns `self`
* `label:alignment()`: gets the alignment
  * returns the alignment preference string
* `label:setAlignment(val)`: sets the alignment preference
  * `val`: the specific alignment preference string
  * returns `self`
* `label:clipping()`: gets whether to clip drawing outside the `Widget`'s bounds
  * returns `true` for clipping, otherwise `false`
* `label:setClipping(val)`: sets whether to clip drawing outside the `Widget`'s bounds
  * `val`: `true` to clip
  * returns `self`
* `label:setTheme(theme, shadow = nil)`: sets the theme
  * `theme`: the custom theme
  * `shadow`: the custom shadow theme
  * returns `self`

### beGUI.MultilineLabel

**Model: `require 'libs/beGUI/beGUI'`, implements beGUI.`Widget`**

**Constructor**

* beGUI.`MultilineLabel.new(content, lineHeight = nil, alighment = 'left')`: constructs a `MultilineLabel` with the specific content
  * `content`: the content string
  * `lineHeight`: the custom line height
  * `alignment`: one in `nil`, `'left'`, `'right'`, `'center'`

**Methods**

* `multilinelabel:getValue()`: gets the content text
  * returns the content string
* `multilinelabel:setValue(val)`: sets the content text
  * `val`: the specific content string
  * returns `self`
* `multilinelabel:lineHeight()`: gets the line height
  * returns the line height
* `multilinelabel:setLineHeight(val)`: sets the line height
  * `val`: the specific line height
  * returns `self`
* `multilinelabel:alignment()`: gets the alignment
  * returns the alignment preference string
* `multilinelabel:setAlignment(val)`: sets the alignment preference, the preference falls to `'left'` if had set flex width to `true`
  * `val`: the specific alignment preference string
  * returns `self`
* `multilinelabel:setTheme(theme, widgetTheme)`: sets the theme
  * `theme`: the custom font theme
  * `widgetTheme`: the custom widget theme
  * returns `self`
* `multilinelabel:flexWidth()`: gets whether to calculate `Widget` width automatically
  * returns `true` for calculating automatically, otherwise `false`
* `multilinelabel:setFlexWidth(val)`: sets whether to calculate `Widget` width automatically
  * `val`: `true` to calculate automatically
  * returns `self`
* `multilinelabel:flexHeight()`: gets whether to calculate `Widget` height automatically
  * returns `true` for calculating automatically, otherwise `false`
* `multilinelabel:setFlexHeight(val)`: sets whether to calculate `Widget` height automatically
  * `val`: `true` to calculate automatically
  * returns `self`
* `multilinelabel:pattern()`: gets the word split pattern
  * returns the word split pattern string
* `multilinelabel:setPattern(val)`: sets the word split pattern
  * `val`: the specific word split pattern
  * returns `self`
* `multilinelabel:translator()`: gets the word translator
  * returns the word translator
* `multilinelabel:setTranslator(val)`: sets the word translator
  * `val`: the specific word translator
  * returns `self`

### beGUI.Url

**Model: `require 'libs/beGUI/beGUI'`, implements beGUI.`Widget`**

**Constructor**

* beGUI.`Url.new(content, alighment = 'left', clip_ = false, theme = nil)`: constructs a `Url` with the specific content
  * `content`: the content string
  * `alignment`: one in `nil`, `'left'`, `'right'`, `'center'`
  * `clip_`: whether to clip drawing outside this `Widget`'s bounds
  * `theme`: custom theme

**Methods**

* `url:getValue()`: gets the content text
  * returns the content string
* `url:setValue(val)`: sets the content text
  * `val`: the specific content string
  * returns `self`
* `url:alignment()`: gets the alignment
  * returns the alignment preference string
* `url:setAlignment(val)`: sets the alignment preference
  * `val`: the specific alignment preference string
  * returns `self`
* `url:clipping()`: gets whether to clip drawing outside the `Widget`'s bounds
  * returns `true` for clipping, otherwise `false`
* `url:setClipping(val)`: sets whether to clip drawing outside the `Widget`'s bounds
  * `val`: `true` to clip
  * returns `self`
* `url:setTheme(theme)`: sets the theme
  * `theme`: the custom theme
  * returns `self`
* `url:enabled()`: gets whether this `Widget` is enabled
  * returns `true` for enabled, otherwise `false`
* `url:setEnabled(val)`: sets whether this `Widget` is enabled
  * `val`: `true` for enabled, otherwise `false`
  * returns `self`

**Events**

* `url:on('clicked', function (sender) end)`: registers an event which will be triggered when the `Widget` has been clicked
  * returns `self`

### beGUI.InputBox

**Model: `require 'libs/beGUI/beGUI'`, implements beGUI.`Widget`**

**Constructor**

* beGUI.`InputBox.new(content, placeholder)`: constructs an InputBox with the specific content
  * `content`: the content string
  * `placeholder`: the placeholder string when there's no input yet

**Methods**

* `inputbox:getValue()`: gets the content text
  * returns the content string
* `inputbox:setValue(val)`: sets the content text
  * `val`: the specific content string
* `inputbox:setTheme(theme, placeholderTheme)`: sets the theme
  * `theme`: the custom font theme
  * `placeholderTheme`: the custom placeholder theme
  * returns `self`
* `inputbox:placeholder()`: gets the placeholder text
  * returns the placeholder string
* `inputbox:setPlaceholder(val)`: sets the placeholder text
  * `val`: the specific placeholder string
  * returns `self`
* `inputbox:enabled()`: gets whether this `Widget` is enabled
  * returns `true` for enabled, otherwise `false`
* `inputbox:setEnabled(val)`: sets whether this `Widget` is enabled
  * `val`: `true` for enabled, otherwise `false`
  * returns `self`

**Events**

* `inputbox:on('changed', function (sender, value) end)`: registers an event which will be triggered when the `Widget` content text has been changed
  * returns `self`

### beGUI.TextBox

**Model: `require 'libs/beGUI/beGUI'`, implements beGUI.`Widget`**

**Constructor**

* beGUI.`TextBox.new(content[, tb])`: constructs a TextBox with the specific content
  * `content`: the content string
  * `tb`: an optional `TextBox` object (created by Bitty API), if omitted, a new `TextBox` is created; if provided, the existing one is reused

**Methods**

* `textBox:getValue()`: gets the content text
  * returns the content string
* `textBox:setValue(val)`: sets the content text
  * `val`: the specific content string
* `textBox:setTheme(theme)`: sets the theme
  * `theme`: the custom font theme
  * returns `self`
* `textBox:setOption(key, val)`: sets the options of the `TextBox`
  * `key`: the option key
  * `val`: the option value
  * returns `self`
* `textBox:useFont(asset)`: uses the specific font config for the `TextBox`
  * `asset`: the JSON object or asset path of the font config
  * returns `self`
* `textBox:focused()`: gets whether the `TextBox` is focused
  * returns `true` for focused, otherwise `false`
* `textBox:focus()`: focuses the `TextBox`
  * returns `self`
* `textBox:location()`: gets the current cursor position of the `TextBox`
	* returns two values for line and column respectively
* `textBox:locate(ln, col)`: sets the current cursor position of the `TextBox`
  * `ln`: the cursor line
  * `col`: the cursor column
  * returns `self`
* `textBox:selection()`: gets the current selection positions of the `TextBox`
	* returns four values for line 1 and column 1, line 2 and column 2 respectively
* `textBox:selectRange(ln1, col1, ln2, col2)`: sets the current selection of the `TextBox`
  * `ln1`: the first cursor line
  * `col1`: the first cursor column
  * `ln2`: the second cursor line
  * `col2`: the second cursor column
  * returns `self`
* `textBox:selectAll()`: selects all text of the `TextBox`
  * returns `self`
* `textBox:lineCount()`: gets the total line of the `TextBox`
  * returns the total line count
* `textBox:lineAt(ln)`: gets the text at the specific line
  * `ln`: the line index
  * returns the line text
* `textBox:columnsAt(ln)`: gets the column count at the specific line
  * `ln`: the line index
  * returns the column count
* `textBox:clear()`: clears all content of the `TextBox`
  * returns `self`
* `textBox:copy()`: copys the selected text of the `TextBox`
  * returns `self`
* `textBox:cut()`: cuts the selected text of the `TextBox`
  * returns `self`
* `textBox:paste([txt])`: pastes text from the clipboard to the `TextBox`
  * `txt`: optional, the text to paste, omit to paste from clipboard
  * returns `self`
* `textBox:delete()`: deletes the selected text of the `TextBox`
  * returns `self`
* `textBox:indent()`: performs an indent operation
  * returns `self`
* `textBox:unindent()`: performs an unindent operation
  * returns `self`
* `textBox:undoable()`: gets whether there are undoable records
  * returns `true` for undoable, otherwise `false`
* `textBox:undo()`: performs an undo operation
  * returns `self`
* `textBox:redoable()`: gets whether there are redoable records
  * returns `true` for redoable, otherwise `false`
* `textBox:redo()`: performs a redo operation
  * returns `self`
* `textBox:hasUnsavedChanges()`: gets whether the `TextBox` has unsaved changes
	* returns `true` if there are unsaved changes; otherwise `false`
* `textBox:markChangesSaved()`: marks the `TextBox`'s changes as saved
  * returns `self`
* `textBox:ensureCursorVisible(forceAbove = false, slowMode = false)`: ensures the cursor is visible within the `TextBox`
	* `forceAbove`: if `true`, forces the cursor to be positioned in the upper part of the viewport
	* `slowMode`: whether to scroll slowly
	* returns `self`

### beGUI.DocumentViewer

**Model: `require 'libs/beGUI/beGUI'`, implements beGUI.`Widget`**

**Constructor**

* beGUI.`DocumentViewer.new(content[, dv])`: constructs a DocumentViewer with the specific content
  * `content`: the content string
  * `dv`: an optional `DocumentViewer` object (created by Bitty API), if omitted, a new `DocumentViewer` is created; if provided, the existing one is reused

**Methods**

* `docViewer:getValue()`: gets the content text
  * returns the content string
* `docViewer:setValue(val)`: sets the content text
  * `val`: the specific content string
* `docViewer:setTheme(theme)`: sets the theme
  * `theme`: the custom font theme
  * returns `self`
* `docViewer:setOption(key, val)`: sets the options of the `DocumentViewer`
  * `key`: the option key
  * `val`: the option value
  * returns `self`
* `docViewer:useFont(asset)`: uses the specific font config for the `DocumentViewer`
  * `asset`: the JSON object or asset path of the font config
  * returns `self`
* `docViewer:load(doc)`: loads a document asset from the current project
	* `doc`: the path to the document asset

### beGUI.Picture

**Model: `require 'libs/beGUI/beGUI'`, implements beGUI.`Widget`**

**Constructor**

* beGUI.`Picture.new(content, stretched = false, permeation = false)`: constructs a Picture with the specific content
  * `content`: the content `Texture`
  * `stretched`: whether to use 9-grid-based splitting for stretching
  * `permeation`: whether to use permeation correction

**Methods**

* `picture:setValue(content, stretched = false, permeation = false)`: sets the content `Texture`
  * `content`: the content `Texture`
  * returns `self`
* `picture:stretched()`: gets whether to use 9-grid-based splitting for stretching
  * returns `true` for 9-grid-based splitting, otherwise `false`
* `picture:setStretched(val)`: sets whether to use 9-grid-based splitting for stretching
  * `val`: `true` to use 9-grid-based splitting for stretching
  * returns `self`
* `picture:permeation()`: gets whether to use permeation correction
  * returns `true` for permeation correction, otherwise `false`
* `picture:setPermeation(val)`: sets whether to use permeation correction
  * `val`: `true` to use permeation correction
  * returns `self`
* `picture:color()`: gets the mask color of the `Picture`
  * returns the mask color or `nil`
* `picture:setColor(val)`: sets the mask color of the `Picture`
  * `val`: the specific mask color
  * returns `self`

### beGUI.Button

**Model: `require 'libs/beGUI/beGUI'`, implements beGUI.`Widget`**

**Constructor**

* beGUI.`Button.new(content)`: constructs a Button with the specific content
  * `content`: the content string

**Methods**

* `button:setValue(content)`: sets the content text
  * `val`: the specific content string
* `button:setTheme(theme, themeNormal, themeDown, themeDisabled)`: sets the theme
  * `theme`: the custom font theme
  * `themeNormal`: the custom theme for normal state
  * `themeDown`: the custom theme for pressed state
  * `themeDisabled`: the custom theme for disabled state
  * returns `self`
* `button:enabled()`: gets whether this `Widget` is enabled
  * returns `true` for enabled, otherwise `false`
* `button:setEnabled(val)`: sets whether this `Widget` is enabled
  * `val`: `true` for enabled, otherwise `false`
  * returns `self`

**Events**

* `button:on('clicked', function (sender) end)`: registers an event which will be triggered when the `Widget` has been clicked
  * returns `self`

### beGUI.PictureButton

**Model: `require 'libs/beGUI/beGUI'`, implements beGUI.`Widget`**

**Constructor**

* beGUI.`PictureButton.new(content, repeat_ = false, theme = nil, background = nil)`: constructs a `PictureButton` with the specific content
  * `content`: the content `Texture`
  * `repeat_`: whether to enable repeating event
  * `theme`: the custom theme
  * `background`: optional, the custom background `Texture`

**Methods**

* `picturebutton:setTheme(theme, widgetTheme)`: sets the theme
  * `theme`: the custom font theme
  * `widgetTheme`: the custom widget theme
  * returns `self`
* `picturebutton:enabled()`: gets whether this `Widget` is enabled
  * returns `true` for enabled, otherwise `false`
* `picturebutton:setEnabled(val)`: sets whether this `Widget` is enabled
  * `val`: `true` for enabled, otherwise `false`
  * returns `self`

**Events**

* `picturebutton:on('clicked', function (sender) end)`: registers an event which will be triggered when the `Widget` has been clicked
  * returns `self`

### beGUI.CheckBox

**Model: `require 'libs/beGUI/beGUI'`, implements beGUI.`Widget`**

**Constructor**

* beGUI.`CheckBox.new(content, value = false)`: constructs a `CheckBox` with the specific content
  * `content`: the content string
  * `value`: the initial checked state

**Methods**

* `checkbox:getValue()`: gets whether this `Widget` is checked
  * returns `true` for checked, otherwise `false`
* `checkbox:setValue(val)`: sets whether this `Widget` is checked
  * `val`: `true` for checked, otherwise `false`
  * returns `self`
* `checkbox:setContent(val)`: sets the text content of this `Widget`
  * `val`: the content string
  * returns `self`
* `checkbox:enabled()`: gets whether this `Widget` is enabled
  * returns `true` for enabled, otherwise `false`
* `checkbox:setEnabled(val)`: sets whether this `Widget` is enabled
  * `val`: `true` for enabled, otherwise `false`
  * returns `self`

**Events**

* `checkbox:on('changed', function (sender, value) end)`: registers an event which will be triggered when the `Widget` checked state has been changed
  * returns `self`

### beGUI.RadioBox

**Model: `require 'libs/beGUI/beGUI'`, implements beGUI.`Widget`**

**Constructor**

* beGUI.`RadioBox.new(content, value = false)`: constructs a `RadioBox` with the specific content
  * `content`: the content string
  * `value`: the initial checked state

**Methods**

* `radiobox:getValue()`: gets whether this `Widget` is checked
  * returns `true` for checked, otherwise `false`
* `radiobox:setValue(val)`: sets whether this `Widget` is checked; not recommended to call this manually
  * `val`: `true` for checked, otherwise `false`
* `radiobox:setContent(val)`: sets the text content of this `Widget`
  * `val`: the content string
  * returns `self`
* `radiobox:enabled()`: gets whether this `Widget` is enabled
  * returns `true` for enabled, otherwise `false`
* `radiobox:setEnabled(val)`: sets whether this `Widget` is enabled
  * `val`: `true` for enabled, otherwise `false`
  * returns `self`

**Events**

* `radiobox:on('changed', function (sender, value) end)`: registers an event which will be triggered when the `Widget` checked state has been changed
  * returns `self`

### beGUI.ComboBox

**Model: `require 'libs/beGUI/beGUI'`, implements beGUI.`Widget`**

A `ComboBox` provides multiple in-place options for selecting.

**Constructor**

* beGUI.`ComboBox.new(content, value = nil)`: constructs a `ComboBox` with the specific content
  * `content`: list of string
  * `value`: the selected index number

**Methods**

* `combobox:getItemAt(index)`: gets the item text at the specific index
  * `index`: the specific index to get
  * returns got item string or `nil`
* `combobox:addItem(item)`: adds an item string with the specific content text
  * `item` the specific item text to add
  * returns `self`
* `combobox:removeItemAt(index)`: removes the item at the specific index
  * `index` the specific index to remove
  * returns `true` for success, otherwise `false`
* `combobox:clearItems()`: clears all items
  * returns `self`
* `combobox:getValue()`: gets the selected index
  * returns the selected index number
* `combobox:setValue(val)`: sets the selected index
  * `val`: the specific selected index
  * returns `self`
* `combobox:scrollable()`: gets whether can scroll the widget by mouse wheel
  * returns `true` for scrollable, otherwise `false`
* `combobox:setScrollable(val)`: sets whether can scroll the widget by mouse wheel
  * `val`: `true` for allowing scrolling with a mouse wheel, otherwise `false`
  * returns `self`
* `combobox:enabled()`: gets whether this `Widget` is enabled
  * returns `true` for enabled, otherwise `false`
* `combobox:setEnabled(val)`: sets whether this `Widget` is enabled
  * `val`: `true` for enabled, otherwise `false`
  * returns `self`

**Events**

* `combobox:on('changed', function (sender, value) end)`: registers an event which will be triggered when the `Widget` selection state has been changed
  * returns `self`

### beGUI.DropdownComboBox

**Model: `require 'libs/beGUI/beGUI'`, implements beGUI.`Widget`**

A `DropdownComboBox` is similar to a `ComboBox`, it provides multiple options for selecting, but in a dropdown list.

**Constructor**

* beGUI.`DropdownComboBox.new(content, value = nil)`: constructs a `DropdownComboBox` with the specific content
  * `content`: list of string
  * `value`: the selected index number

**Methods**

* `dropdown:getItemAt(index)`: gets the item text at the specific index
  * `index`: the specific index to get
  * returns got item string or `nil`
* `dropdown:addItem(item)`: adds an item string with the specific content text
  * `item` the specific item text to add
  * returns `self`
* `dropdown:removeItemAt(index)`: removes the item at the specific index
  * `index` the specific index to remove
  * returns `true` for success, otherwise `false`
* `dropdown:clearItems()`: clears all items
  * returns `self`
* `dropdown:getValue()`: gets the selected index
  * returns the selected index number
* `dropdown:setValue(val)`: sets the selected index
  * `val`: the specific selected index
  * returns `self`
* `dropdown:scrollable()`: gets whether can scroll the widget by mouse wheel
  * returns `true` for scrollable, otherwise `false`
* `dropdown:setScrollable(val)`: sets whether can scroll the widget by mouse wheel
  * `val`: `true` for allowing scrolling with a mouse wheel, otherwise `false`
  * returns `self`
* `dropdown:enabled()`: gets whether this `Widget` is enabled
  * returns `true` for enabled, otherwise `false`
* `dropdown:setEnabled(val)`: sets whether this `Widget` is enabled
  * `val`: `true` for enabled, otherwise `false`
  * returns `self`

**Events**

* `dropdown:on('changed', function (sender, value) end)`: registers an event which will be triggered when the `Widget` selection state has been changed
  * returns `self`

### beGUI.NumberBox

**Model: `require 'libs/beGUI/beGUI'`, implements beGUI.`Widget`**

**Constructor**

* beGUI.`NumberBox.new(value, step, min = nil, max = nil, trim = nil, format = nil)`: constructs a `NumberBox` with the specific value
  * `value`: the initial value number
  * `step`: the changing step
  * `min`: the minumum limit
  * `max`: the maximum limit
  * `trim`: optional, used to trim before value setting
  * `format`: optional, used to format value for output

**Methods**

* `numberbox:getValue()`: gets the value number
  * returns the value number
* `numberbox:setValue(val)`: sets the value number
  * `val`: the specific value number
  * returns `self`
* `numberbox:getMinValue()`: gets the minimum limit number
  * returns the minimum limit number
* `numberbox:setMinValue(val)`: sets the minimum limit number
  * `val`: the specific minimum limit number
  * returns `self`
* `numberbox:getMaxValue()`: gets the maximum limit number
  * returns the maximum limit number
* `numberbox:setMaxValue(val)`: sets the maximum limit number
  * `val`: the specific maximum limit number
  * returns `self`
* `numberbox:step()`: gets the changing step
  * returns the changing step
* `numberbox:setStep(val)`: sets the changing step
  * `val`: the specific changing step number
  * returns `self`
* `numberbox:trim()`: gets the trim function
  * returns the trim function
* `numberbox:setTrim(val)`: sets the trim function
  * `val`: the specific trim function
  * returns `self`
* `numberbox:format()`: gets the format function
  * returns the format function
* `numberbox:setFormat(val)`: sets the format function
  * `val`: the specific format function
  * returns `self`
* `numberbox:setValueTheme(val)`: sets the value theme
  * `val`: the specific theme
  * returns `self`
* `numberbox:scrollable()`: gets whether can scroll the widget by mouse wheel
  * returns `true` for scrollable, otherwise `false`
* `numberbox:setScrollable(val)`: sets whether can scroll the widget by mouse wheel
  * `val`: `true` for allowing scrolling with a mouse wheel, otherwise `false`
  * returns `self`
* `numberbox:enabled()`: gets whether this `Widget` is enabled
  * returns `true` for enabled, otherwise `false`
* `numberbox:setEnabled(val)`: sets whether this `Widget` is enabled
  * `val`: `true` for enabled, otherwise `false`
  * returns `self`

**Events**

* `numberbox:on('changed', function (sender, value) end)`: registers an event which will be triggered when the `Widget` value has been changed
  * returns `self`

### beGUI.ProgressBar

**Model: `require 'libs/beGUI/beGUI'`, implements beGUI.`Widget`**

**Constructor**

* beGUI.`ProgressBar.new(max, color, increasing = 'right')`: constructs a `ProgressBar`
  * `max`: the maximum value
  * `color`: the color for the completed bar
  * `increasing`: indicates whether to increase from left to right, or reversed, one in `'left'`, `'right'`

**Methods**

* `progressbar:getValue()`: gets the value number
  * returns the value number
* `progressbar:setValue(val)`: sets the value number
  * `val`: the specific value number
  * returns `self`
* `progressbar:getMaxValue()`: gets the maximum limit number
  * returns the maximum limit number
* `progressbar:setMaxValue(val)`: sets the maximum limit number
  * `val`: the specific maximum limit number
  * returns `self`
* `progressbar:getShadowValue()`: gets the shadow value number
  * returns the value number
* `progressbar:setShadowValue(val)`: sets the shadow value number
  * `val`: the specific shadow value number
  * returns `self`
* `progressbar:setTheme(theme)`: sets the theme
  * `theme`: the custom theme
  * returns `self`

**Events**

* `progressbar:on('changed', function (sender, value, maxValue, shadowValue) end)`: registers an event which will be triggered when the `Widget` value has been changed
  * returns `self`

### beGUI.Slide

**Model: `require 'libs/beGUI/beGUI'`, implements beGUI.`Widget`**

**Constructor**

* beGUI.`Slide.new(value, min, max)`: constructs a `Slide` with the specific value
  * `value`: the initial value number
  * `min`: the minimum limit number
  * `max`: the maximum limit number

**Methods**

* `slide:getValue()`: gets the value number
  * returns the value number
* `slide:setValue(val)`: sets the value number
  * `val`: the specific value number
  * returns `self`
* `slide:getMinValue()`: gets the minimum limit number
  * returns the minimum limit number
* `slide:setMinValue(val)`: sets the minimum limit number
  * `val`: the specific minimum limit number
  * returns `self`
* `slide:getMaxValue()`: gets the maximum limit number
  * returns the maximum limit number
* `slide:setMaxValue(val)`: sets the maximum limit number
  * `val`: the specific maximum limit number
  * returns `self`
* `slide:scrollable()`: gets whether can scroll the widget by mouse wheel
  * returns `true` for scrollable, otherwise `false`
* `slide:setScrollable(val)`: sets whether can scroll the widget by mouse wheel
  * `val`: `true` for allowing scrolling with a mouse wheel, otherwise `false`
  * returns `self`
* `slide:enabled()`: gets whether this `Widget` is enabled
  * returns `true` for enabled, otherwise `false`
* `slide:setEnabled(val)`: sets whether this `Widget` is enabled
  * `val`: `true` for enabled, otherwise `false`
  * returns `self`

**Events**

* `slide:on('changed', function (sender, value) end)`: registers an event which will be triggered when the `Widget` value has been changed
  * returns `self`

</details>

## 5. Interactable Widgets

<details open>
<summary>Interactable Widgets</summary>

### beGUI.Clickable

**Model: `require 'libs/beGUI/beGUI'`, implements beGUI.`Widget`**

**Constructor**

* beGUI.`Clickable.new()`: constructs a `Clickable` with the specific value

**Methods**

* `clickable:getRule()`: gets the click detection rule
  * returns the click detection rule, can be either `'inside'` or `'outside'`; defaults to `'inside'`
* `clickable:setRule(val)`: sets the click detection rule
  * `val`: the click detection rule, can be either `'inside'` or `'outside'`; defaults to `'inside'`
  * returns `self`
* `clickable:enabled()`: gets whether this `Widget` is enabled
  * returns `true` for enabled, otherwise `false`
* `clickable:setEnabled(val)`: sets whether this `Widget` is enabled
  * `val`: `true` for enabled, otherwise `false`
  * returns `self`

**Events**

* `clickable:on('clicked', function (sender) end)`: registers an event which will be triggered when the `Widget` has been clicked
  * returns `self`

### beGUI.ClickableText

**Model: `require 'libs/beGUI/beGUI'`, implements beGUI.`Widget`**

**Constructor**

* beGUI.`ClickableText.new(content)`: constructs a `ClickableText` with the specific value
  * `content`: the content string

**Methods**

* `clickableText:getValue()`: gets the content text
  * returns the content string
* `clickableText:setValue(val)`: sets the content text
  * `val`: the specific content string
  * returns `self`
* `clickableText:selected()`: gets whether this widget has been selected
  * returns `true` for selected, otherwise `false`
* `clickableText:setSelected(val)`: sets whether this widget has been selected
  * `val`: `true` for selected, `false` for not selected
  * returns `self`
* `clickableText:selectable()`: gets whether this widget is selectable
  * returns `true` for selectable, otherwise `false`
* `clickableText:setSelectable(val)`: sets whether this widget is selectable
  * `val`: `true` for selectable, `false` for not selectable
  * returns `self`
* `clickableText:setTheme(theme, normalTheme, selectedTheme, disabledTheme)`: sets the theme
  * `theme`: the widget theme
  * `normalTheme`: the normal theme
  * `selectedTheme`: the selected theme
  * `disabledTheme`: the not selectable theme
  * returns `self`
* `clickableText:enabled()`: gets whether this `Widget` is enabled
  * returns `true` for enabled, otherwise `false`
* `clickableText:setEnabled(val)`: sets whether this `Widget` is enabled
  * `val`: `true` for enabled, otherwise `false`
  * returns `self`

**Events**

* `clickableText:on('selected', function (sender) end)`: registers an event which will be triggered when the `Widget` has been selected
  * returns `self`
* `clickableText:on('deselected', function (sender) end)`: registers an event which will be triggered when the `Widget` has been deselected
  * returns `self`
* `clickableText:on('clicked', function (sender) end)`: registers an event which will be triggered when the `Widget` has been clicked
  * returns `self`

### beGUI.Draggable

**Model: `require 'libs/beGUI/beGUI'`, implements beGUI.`Widget`**

**Constructor**

* beGUI.`Draggable.new()`: constructs a `Draggable`

**Methods**

* `draggable:enabled()`: gets whether this `Widget` is enabled
  * returns `true` for enabled, otherwise `false`
* `draggable:setEnabled(val)`: sets whether this `Widget` is enabled
  * `val`: `true` for enabled, otherwise `false`
  * returns `self`

### beGUI.Droppable

**Model: `require 'libs/beGUI/beGUI'`, implements beGUI.`Widget`**

**Constructor**

* beGUI.`Droppable.new()`: constructs a `Droppable`

**Methods**

* `droppable:enabled()`: gets whether this `Widget` is enabled
  * returns `true` for enabled, otherwise `false`
* `droppable:setEnabled(val)`: sets whether this `Widget` is enabled
  * `val`: `true` for enabled, otherwise `false`
  * returns `self`

**Events**

* `droppable:on('entered', function (sender, draggable) end)`: registers an event which will be triggered when the `Widget` has been entered by a `Draggable`
  * returns `self`
* `droppable:on('left', function (sender, draggable) end)`: registers an event which will be triggered when the `Widget` has been left by a `Draggable`
  * returns `self`
* `droppable:on('dropping', function (sender, draggable) return droppable end)`: registers an event which will be triggered when the `Widget` has been hovering by a `Draggable`
  * returns `self`
* `droppable:on('dropped', function (sender, draggable) end)`: registers an event which will be triggered when the `Widget` has been dropped by a `Draggable`
  * returns `self`
* `droppable:on('clicked', function (sender) end)`: registers an event which will be triggered when the `Widget` has been clicked
  * returns `self`

</details>

## 6. Container Widgets

<details open>
<summary>Container Widgets</summary>

### beGUI.Group

**Model: `require 'libs/beGUI/beGUI'`, implements beGUI.`Widget`**

**Constructor**

* beGUI.`Group.new(content)`: constructs a `Group`
  * `content`: the content string

**Methods**

* `group:getValue()`: gets the content text
  * returns the content string
* `group:setValue(val)`: sets the content text
  * `val`: the specific content string
  * returns `self`
* `group:enabled()`: gets whether this `Widget` is enabled
  * returns `true` for enabled, otherwise `false`
* `group:setEnabled(val)`: sets whether this `Widget` and its children is enabled
  * `val`: `true` for enabled, otherwise `false`
  * returns `self`

### beGUI.List

**Model: `require 'libs/beGUI/beGUI'`, implements beGUI.`Widget`**

**Constructor**

* beGUI.`List.new(withScrollBar = false)`: constructs a `List`
  * `withScrollBar`: whether to draw scroll bar(s)

**Methods**

* `list:scrollableVertically()`: gets whether to allow scrolling vertically
  * returns `true` for allowing scrolling vertically, otherwise `false`
* `list:setScrollableVertically(val)`: sets whether to allow scrolling vertically
  * `val`: `true` for allowing scrolling vertically, otherwise `false`
  * returns `self`
* `list:scrollableHorizontally()`: gets whether to allow scrolling horizontally
  * returns `true` for allowing scrolling horizontally, otherwise `false`
* `list:setScrollableHorizontally(val)`: sets whether to allow scrolling horizontally
  * `val`: `true` for allowing scrolling horizontally, otherwise `false`
  * returns `self`
* `list:scrollSpeed()`: gets the scroll speed
  * returns the scroll speed
* `list:setScrollSpeed(val)`: sets the scroll speed
  * `val`: the specific scroll speed
  * returns `self`
* `list:setTheme(theme)`: sets the theme
  * `theme`: the custom theme
  * returns `self`
* `list:scrollable()`: gets whether can scroll the widget by mouse wheel
  * returns `true` for scrollable, otherwise `false`
* `list:setScrollable(val)`: sets whether can scroll the widget by mouse wheel
  * `val`: `true` for allowing scrolling with a mouse wheel, otherwise `false`
  * returns `self`
* `list:enabled()`: gets whether this `Widget` is enabled
  * returns `true` for enabled, otherwise `false`
* `list:setEnabled(val)`: sets whether this `Widget` and its children is enabled
  * `val`: `true` for enabled, otherwise `false`
  * returns `self`

### beGUI.Tab

**Model: `require 'libs/beGUI/beGUI'`, implements beGUI.`Widget`**

**Constructor**

* beGUI.`Tab.new()`: constructs a `Tab`

**Methods**

* `tab:add(title)`: adds a `Tab` page with the specific title
  * `title`: the `Tab` page title to add
  * returns `self`
* `tab:count()`: gets the page count of the `Tab` `Widget`
  * returns the `Tab` page count
* `tab:getValue()`: gets the active page index
  * returns the active page index number
* `tab:setValue(val)`: sets the active page index
  * `val`: the specific page index
  * returns `self`
* `tab:tabSize()`: gets the specified `Tab` size
  * returns the specified `Tab` size
* `tab:setTabSize(val)`: sets the specified `Tab` size
  * `val`: the specified `Tab` size
  * returns `self`
* `tab:scrollable()`: gets whether can scroll the widget by mouse wheel
  * returns `true` for scrollable, otherwise `false`
* `tab:setScrollable(val)`: sets whether can scroll the widget by mouse wheel
  * `val`: `true` for allowing scrolling with a mouse wheel, otherwise `false`
  * returns `self`
* `tab:enabled()`: gets whether this `Widget` is enabled
  * returns `true` for enabled, otherwise `false`
* `tab:setEnabled(val)`: sets whether this `Widget` and its children is enabled
  * `val`: `true` for enabled, otherwise `false`
  * returns `self`

**Events**

* `tab:on('changed', function (sender, value) end)`: registers an event which will be triggered when the `Widget` page has been switched
  * returns `self`

</details>

## 7. Popup Widgets

<details open>
<summary>Popup Widgets</summary>

### beGUI.Popup

**Model: `require 'libs/beGUI/beGUI'`, implements beGUI.`Widget`**

**Constructor**

* beGUI.`Popup.new()`: constructs a `Popup`

### beGUI.MessageBox

**Model: `require 'libs/beGUI/beGUI'`, implements beGUI.`Popup`**

**Constructor**

* beGUI.`MessageBox.new(closable, title, message, confirm = 'OK')`: constructs a `MessageBox`
  * `closable`: `true` to enable the close button, `false` to disable
  * `title`: the title text
  * `message`: the message text
  * `confirm`: the text for the confirm button

**Events**

* `messagebox:on('canceled', function (sender) end)`: registers an event which will be triggered when the `Popup` has been canceled
  * returns `self`
* `messagebox:on('confirmed', function (sender) end)`: registers an event which will be triggered when the `Popup` has been confirmed
  * returns `self`

### beGUI.QuestionBox

**Model: `require 'libs/beGUI/beGUI'`, implements beGUI.`Popup`**

**Constructor**

* beGUI.`QuestionBox.new(closable, title, message, confirm, deny)`: constructs a `QuestionBox`
  * `closable`: `true` to enable the close button, `false` to disable
  * `title`: the title text
  * `message`: the message text
  * `confirm`: the text for the confirm button
  * `deny`: the text for the deny button

**Events**

* `questionbox:on('canceled', function (sender) end)`: registers an event which will be triggered when the `Popup` has been canceled
  * returns `self`
* `questionbox:on('confirmed', function (sender) end)`: registers an event which will be triggered when the `Popup` has been confirmed
  * returns `self`
* `questionbox:on('denied', function (sender) end)`: registers an event which will be triggered when the `Popup` has been denied
  * returns `self`

### beGUI.TextEditBox

**Model: `require 'libs/beGUI/beGUI'`, implements beGUI.`Popup`**

**Constructor**

* beGUI.`TextEditBox.new(closable, title, content, confirm, deny)`: constructs a `TextEditBox`
  * `closable`: `true` to enable the close button, `false` to disable
  * `title`: the title text
  * `content`: the content text
  * `confirm`: the text for the confirm button
  * `deny`: the text for the deny button

**Events**

* `textEditBox:on('canceled', function (sender) end)`: registers an event which will be triggered when the `Popup` has been canceled
  * returns `self`
* `textEditBox:on('confirmed', function (sender) end)`: registers an event which will be triggered when the `Popup` has been confirmed
  * returns `self`
* `textEditBox:on('denied', function (sender) end)`: registers an event which will be triggered when the `Popup` has been denied
  * returns `self`

</details>

## 8. Custom Widget

<details open>
<summary>Custom Widget</summary>

There are two ways to customize your own `Widget`, one is to use the beWidget.`Custom` `Widget`, the other is to write your own `Widget` class.

### beGUI.Custom

The `Custom` `Widget` exposes a `'updated'` event to let you write short customized update routine in the callback.

**Model: `require 'libs/beGUI/beGUI'`, implements beGUI.`Widget`**

**Constructor**

* beGUI.`Custom.new(name = 'Custom')`: constructs a `Custom` `Widget`
  * `name`: the custom `Widget` name used to perform `__tostring`

**Methods**

* `custom:name()`: gets the custom `Widget` name
  * returns the custom `Widget` name
* `custom:setName(val)`: sets the custom `Widget` name
  * `val`: the specific custom `Widget` name
  * returns `self`

**Events**

* `custom:on('updated', function (sender, x, y, w, h, delta, event) end)`: registers an event which will be triggered when the `Widget` has been updated per frame
  * returns `self`

### Writing Your Own Widget

You can also write your own `Widget` inheriting from beWidget.`Widget`.

```lua
local beClass = require 'libs/beGUI/beClass'
local beUtils = require 'libs/beGUI/beGUI_Utils'
local beWidget = require 'libs/beGUI/beGUI_Widget'

local MyWidget = beClass.class({
  _value = nil, -- Define your fields.
  _pressed = false,

  ctor = function (self, ...)
    beWidget.Widget.ctor(self)

    -- Customize your constructor.
  end,

  __tostring = function (self)
    return 'MyWidget'
  end,

  getValue = function (self) -- Define your properties.
    return self._value
  end,
  setValue = function (self, val)
    if self._value == val then
      return self
    end
    self._value = val
    self:_trigger('changed', self, self._value)

    return self
  end,

  _update = function (self, theme, delta, dx, dy, event)
    -- Ignore if invisible.
    if not self.visibility then
      return
    end

    -- Get the offset x, y, which is calculated by this widget's size and its anchor.
    local ox, oy = self:offset()
    -- Get the position x, y in local space.
    local px, py = self:position()
    -- Calculate the final position with the delta position, offset and local position,
    -- where the delta position (`dx`, `dy`) is from this widget's parent, or 0, 0 for root widget.
    local x, y = dx + px + ox, dy + py + oy
    -- Get the size width, height of this widget.
    local w, h = self:size()

    -- The following code detects clicking.
    local down = false
    if event.context.active and event.context.active ~= self then
      self._pressed = false
    elseif event.canceled or event.context.dragging then
      event.context.active = nil
      self._pressed = false
    elseif self._pressed then
      down = event.mouseDown
    else
      -- Intersection detection.
      down = event.mouseDown and Math.intersects(event.mousePosition, Rect.byXYWH(x, y, w, h))
    end
    if down and not self._pressed then
      event.context.active = self
      self._pressed = true
    elseif not down and self._pressed then
      event.context.active = nil
      self._pressed = false
      event.context.focus = self
      self:_trigger('clicked', self) -- Trigger 'clicked' event by clicking.
    elseif event.context.focus == self and event.context.navigated == 'press' then
      self:_trigger('clicked', self) -- Trigger 'clicked' event by key navigation.
      event.context.navigated = false
    end

    -- Draw the widget.
    local elem = down and theme['button_down'] or theme['button'] -- Using the button theme.
    beUtils.tex9Grid(elem, x, y, w, h, nil, self.transparency, nil) -- Draw texture.
    beUtils.textCenter(self._value, theme['font'], x, y, w, h, elem.content_offset, self.transparency) -- Draw text.

    -- Call base update to update its children.
    beWidget.Widget._update(self, theme, delta, dx, dy, event)
  end
}, beWidget.Widget)
```

</details>

## 9. Theme

<details open>
<summary>Theme</summary>

Defined in "src/libs/beGUI/beTheme.lua". Widget classes will lookup for image resources, client area, content offset, fonts, colors and all other appearance preferences from it.

</details>

## 10. Tweening

<details open>
<summary>Tweening</summary>

beGUI is integrated with a tweening lib adapted from [kikito/tween.lua](https://github.com/kikito/tween.lua), which allows to create tweening animations.

### beGUI.Tween

**Model: `require 'libs/beGUI/beGUI'`**

**Constructor**

* beGUI.`Tween.new(duration, subject, target, easing, loop)`: constructs a `Tween` object
  * `duration`: the duration in seconds
  * `subject`: the tweening subject
  * `target`: the tweening target
  * `easing`: the easing function
  * `loop`: whether to loop the tweening

**Methods**

* `tween:reset()`: resets the `Tween` object
  * returns `self`
* `tween:set(clock)`: sets the `Tween` object to a specific clock point
  * `clock`: the click time point
  * returns `true` for success, otherwise `false`
* `tween:update(delta)`: updates the `Tween` object with a specific delta time in seconds
  * returns `true` for success, otherwise `false`

**Events**

* `tween:on('changed', function (sender) end)`: registers an event which will be triggered when the `Tween` has been updated
  * returns `self`
* `tween:on('completed', function (sender) end)`: registers an event which will be triggered when the `Tween` has completed or looped
  * returns `self`
* `tween:off(event)`: unregisters the handlers of the specific event
  * `event`: event name string
  * returns `self`

</details>

# License

beGUI is distributed under the MIT license.
