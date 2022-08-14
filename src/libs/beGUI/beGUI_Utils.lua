--[[
The MIT License

Copyright (C) 2021 - 2022 Tony Wang

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

--[[
Constants.
]]

local function toKeycode(k)
	return (1 << 30) | k
end

local KeyCodeLShift = toKeycode(225)
local KeyCodeRShift = toKeycode(229)

--[[
Helper functions.
]]

--[[ Number. ]]

local function NaN(val)
	return 0 / 0
end

local function isNaN(val)
	return val ~= val
end

local function round(val)
	if val >= 0 then
		return math.floor(val + 0.5)
	else
		return math.ceil(val - 0.5)
	end
end

local function clamp(x, min, max)
	return math.max(math.min(x, max), min)
end

--[[ Math. ]]

local function intersected(rect1, rect2)
	if not rect1 then
		return nil
	end
	if not rect2 then
		return rect1
	end

	local x1, y1, x2, y2 =
		math.max(rect1:xMin(), rect2:xMin()),
		math.max(rect1:yMin(), rect2:yMin()),
		math.min(rect1:xMax(), rect2:xMax()),
		math.min(rect1:yMax(), rect2:yMax())
	if x1 >= x2 or y1 >= y2 then
		return nil
	end

	return Rect.new(x1, y1, x2, y2)
end

--[[ String. ]]

local function startsWith(txt, part)
	return part == '' or string.sub(txt, 1, #part) == part
end

local function endsWith(str, part)
	return part == '' or string.sub(str, -#part) == part
end

local function split(txt, sep, pattern, translate)
	local result = { }
	for line in string.gmatch(txt, '[^\n]*') do
		if sep == nil then
			local i = 1
			for str in string.gmatch(line, pattern or '[\33-\127\192-\255]+[\128-\191]*') do
				if translate then
					str = translate(str, i)
				end
				local codes = { }
				for _, v in utf8.codes(str) do
					table.insert(codes, v)
				end
				local j = nil
				for i = #codes, 1, -1 do
					if codes[i] <= 255 then
						break
					end
					j = i
				end
				if j == nil then
					table.insert(result, str)
				else
					local first, second = '', ''
					for k = 1, j - 1, 1 do
						first = first .. utf8.char(codes[k])
					end
					for k = j, #codes, 1 do
						second = second .. utf8.char(codes[k])
					end
					if first ~= '' then
						table.insert(result, first)
					end
					if second ~= '' then
						table.insert(result, second)
					end
				end
				i = i + 1
			end
		else
			local i = 1
			for str in string.gmatch(line, '([^' .. sep .. ']+)') do
				if translate then
					str = translate(str, i)
				end
				table.insert(result, str)
				i = i + 1
			end
		end
		table.insert(result, '\n')
	end
	table.remove(result)

	return result
end

local function escape(txt, defaultColor, tokenize, pattern, translate)
	local fill = function (result, txt, col)
		if tokenize then
			local chars = split(txt, nil, pattern, translate)
			for i, c in ipairs(chars) do
				local code = utf8.codepoint(c)
				if code <= 255 then
					if c ~= '\n' then
						c = c .. ' '
					end
				else
					local nextCode = i < #chars and utf8.codepoint(chars[i + 1]) or 256
					if nextCode <= 255 then
						if c ~= '\n' then
							c = c .. ' '
						end
					end
				end
				table.insert(
					result,
					{
						text = c,
						color = col
					}
				)
			end
		else
			table.insert(
				result,
				{
					text = txt,
					color = col
				}
			)
		end
	end

	local result = { }
	while #txt > 0 do
		local i = string.find(txt, '%[col=')
		if i == nil then
			fill(result, txt, defaultColor)
			txt = ''
		else
			local head = string.sub(txt, 1, i - 1)
			fill(result, head, defaultColor)
			txt = string.sub(txt, i + 5)
			local j = string.find(txt, '%]')
			if j == nil then
				error('Invalid escape.')
			end
			local col = string.sub(txt, 1, j - 1)
			local rgba = tonumber(col)
			rgba = ((rgba >> 24) & 0xff) | ((rgba << 8) & 0xff0000) | ((rgba >> 8) & 0xff00) | ((rgba << 24) & 0xff000000)
			col = Color.new()
			col:fromRGBA(rgba)
			txt = string.sub(txt, j + 1)
			local k = string.find(txt, '%[/col%]')
			if k == nil then
				error('Invalid escape.')
			end
			local text = string.sub(txt, 1, k - 1)
			fill(result, text, col)
			txt = string.sub(txt, k + 6)
		end
	end

	return result
end

--[[ List. ]]

local function car(lst)
	if not lst or #lst == 0 then
		return nil
	end

	return lst[1]
end

local function cdr(lst)
	if not lst or #lst == 0 then
		return { }
	end
	lst = table.pack(table.unpack(lst))
	table.remove(lst, 1)

	return lst
end

local function exists(lst, elem)
	if not lst then
		return false
	end

	for _, v in pairs(lst) do
		if v == elem then
			return true
		end
	end

	return false
end

local function filter(lst, pred)
	if not lst then
		return nil
	end

	local result = { }
	for _, v in ipairs(lst) do
		if pred and pred(v) then
			table.insert(result, v)
		elseif not pred and not v then
			return { }
		end
	end

	return result
end

--[[ Dictionary. ]]

local function merge(first, second)
	if first == nil and second == nil then
		return nil
	end
	local result = { }
	if first then
		for k, v in pairs(first) do
			result[k] = v
		end
	end
	if second then
		for k, v in pairs(second) do
			result[k] = v
		end
	end

	return result
end

--[[ Text drawing. ]]

local function tex3Grid(elem, x, y, w, h, permeation, alpha, color_)
	local img = elem.resource
	local area = elem.area
	local srcx, srcy = 0, 0
	local srcw, srch = img.width, img.height
	if area then
		srcx, srcy = area[1], area[2]
		srcw, srch = area[3], area[4]
	end
	local col = nil
	if color_ or alpha then
		if color_ then
			if alpha then
				col = Color.new(color_.r, color_.g, color_.b, color_.a * (alpha / 255))
			else
				col = color_
			end
		else
			if alpha then
				col = Color.new(255, 255, 255, alpha)
			end
		end
	end
	if srcw == w and srch == h then
		if area then
			if col then
				tex(img, x, y, w, h, srcx, srcy, srcw, srch, 0, Vec2.new(0.5, 0.5), false, false, col)
			else
				tex(img, x, y, w, h, srcx, srcy, srcw, srch)
			end
		else
			if col then
				tex(img, x, y, w, h, x, y, w, h, 0, Vec2.new(0.5, 0.5), false, false, col)
			else
				tex(img, x, y, w, h)
			end
		end
	else
		if col then
			permeation = 0
		elseif not permeation then
			permeation = 1
		end
		x, y, w, h = math.floor(x), math.floor(y), math.floor(w), math.floor(h)
		local w_1_3 = math.floor(srcw * 1 / 3)
		local srcx1, srcx2, srcx3, srcx4 = srcx, srcx + w_1_3, srcx + srcw - w_1_3 - 1, srcx + srcw - 1
		local srcwBorder, srcwMiddle = srcx2 - srcx1 + 1, srcx3 - srcx2 + 1
		local dstx1, dstx2, dstx3, dstx4 = x, x + srcwBorder, x + w - srcwBorder, x + w - 1
		if col then
			tex(img, dstx2 - permeation, y, dstx3 - dstx2 + permeation * 2, h, srcx2, srcy, srcwMiddle, srch, 0, Vec2.new(0.5, 0.5), false, false, col) -- Middle.
			tex(img, dstx1,              y, srcwBorder,                     h, srcx1, srcy, srcwBorder, srch, 0, Vec2.new(0.5, 0.5), false, false, col) -- Left.
			tex(img, dstx3,              y, srcwBorder,                     h, srcx3, srcy, srcwBorder, srch, 0, Vec2.new(0.5, 0.5), false, false, col) -- Right.
		else
			tex(img, dstx2 - permeation, y, dstx3 - dstx2 + permeation * 2, h, srcx2, srcy, srcwMiddle, srch) -- Middle.
			tex(img, dstx1,              y, srcwBorder,                     h, srcx1, srcy, srcwBorder, srch) -- Left.
			tex(img, dstx3,              y, srcwBorder,                     h, srcx3, srcy, srcwBorder, srch) -- Right.
		end
	end
end

local function tex9Grid(elem, x, y, w, h, permeation, alpha, color_)
	local img = elem.resource
	local area = elem.area
	local srcx, srcy = 0, 0
	local srcw, srch = img.width, img.height
	if area then
		srcx, srcy = area[1], area[2]
		srcw, srch = area[3], area[4]
	end
	local col = nil
	if color_ or alpha then
		if color_ then
			if alpha then
				col = Color.new(color_.r, color_.g, color_.b, color_.a * (alpha / 255))
			else
				col = color_
			end
		else
			if alpha then
				col = Color.new(255, 255, 255, alpha)
			end
		end
	end
	if srcw == w and srch == h then
		if area then
			if col then
				tex(img, x, y, w, h, srcx, srcy, srcw, srch, 0, Vec2.new(0.5, 0.5), false, false, col)
			else
				tex(img, x, y, w, h, srcx, srcy, srcw, srch)
			end
		else
			if col then
				tex(img, x, y, w, h, x, y, w, h, 0, Vec2.new(0.5, 0.5), false, false, col)
			else
				tex(img, x, y, w, h)
			end
		end
	else
		if col then
			permeation = 0
		elseif not permeation then
			permeation = 1
		end
		x, y, w, h = math.floor(x), math.floor(y), math.floor(w), math.floor(h)
		local w_1_3, h_1_3 = math.floor(srcw * 1 / 3), math.floor(srch * 1 / 3)
		local srcx1, srcx2, srcx3, srcx4 = srcx, srcx + w_1_3, srcx + srcw - w_1_3 - 1, srcx + srcw - 1
		local srcy1, srcy2, srcy3, srcy4 = srcy, srcy + h_1_3, srcy + srch - h_1_3 - 1, srcy + srch - 1
		local srcwBorder, srcwMiddle = srcx2 - srcx1 + 1, srcx3 - srcx2 + 1
		local srchBorder, srchMiddle = srcy2 - srcy1 + 1, srcy3 - srcy2 + 1
		local dstx1, dstx2, dstx3, dstx4 = x, x + srcwBorder, x + w - srcwBorder, x + w - 1
		local dsty1, dsty2, dsty3, dsty4 = y, y + srchBorder, y + h - srchBorder, y + h - 1
		if col then
			tex(img, dstx2 - permeation, dsty2 - permeation, dstx3 - dstx2 + permeation * 2, dsty3 - dsty2 + permeation * 2, srcx2, srcy2, srcwMiddle, srchMiddle, 0, Vec2.new(0.5, 0.5), false, false, col) -- Center.
			tex(img, dstx2 - permeation, dsty1,              dstx3 - dstx2 + permeation * 2, srchBorder,                     srcx2, srcy1, srcwMiddle, srchBorder, 0, Vec2.new(0.5, 0.5), false, false, col) -- Middle top.
			tex(img, dstx1,              dsty2 - permeation, srcwBorder,                     dsty3 - dsty2 + permeation * 2, srcx1, srcy2, srcwBorder, srchMiddle, 0, Vec2.new(0.5, 0.5), false, false, col) -- Left middle.
			tex(img, dstx3,              dsty2 - permeation, srcwBorder,                     dsty3 - dsty2 + permeation * 2, srcx3, srcy2, srcwBorder, srchMiddle, 0, Vec2.new(0.5, 0.5), false, false, col) -- Right middle.
			tex(img, dstx2 - permeation, dsty3,              dstx3 - dstx2 + permeation * 2, srchBorder,                     srcx2, srcy3, srcwMiddle, srchBorder, 0, Vec2.new(0.5, 0.5), false, false, col) -- Middle bottom.
			tex(img, dstx1,              dsty1,              srcwBorder,                     srchBorder,                     srcx1, srcy1, srcwBorder, srchBorder, 0, Vec2.new(0.5, 0.5), false, false, col) -- Left top.
			tex(img, dstx3,              dsty1,              srcwBorder,                     srchBorder,                     srcx3, srcy1, srcwBorder, srchBorder, 0, Vec2.new(0.5, 0.5), false, false, col) -- Right top.
			tex(img, dstx1,              dsty3,              srcwBorder,                     srchBorder,                     srcx1, srcy3, srcwBorder, srchBorder, 0, Vec2.new(0.5, 0.5), false, false, col) -- Left bottom.
			tex(img, dstx3,              dsty3,              srcwBorder,                     srchBorder,                     srcx3, srcy3, srcwBorder, srchBorder, 0, Vec2.new(0.5, 0.5), false, false, col) -- Right bottom.
		else
			tex(img, dstx2 - permeation, dsty2 - permeation, dstx3 - dstx2 + permeation * 2, dsty3 - dsty2 + permeation * 2, srcx2, srcy2, srcwMiddle, srchMiddle) -- Center.
			tex(img, dstx2 - permeation, dsty1,              dstx3 - dstx2 + permeation * 2, srchBorder,                     srcx2, srcy1, srcwMiddle, srchBorder) -- Middle top.
			tex(img, dstx1,              dsty2 - permeation, srcwBorder,                     dsty3 - dsty2 + permeation * 2, srcx1, srcy2, srcwBorder, srchMiddle) -- Left middle.
			tex(img, dstx3,              dsty2 - permeation, srcwBorder,                     dsty3 - dsty2 + permeation * 2, srcx3, srcy2, srcwBorder, srchMiddle) -- Right middle.
			tex(img, dstx2 - permeation, dsty3,              dstx3 - dstx2 + permeation * 2, srchBorder,                     srcx2, srcy3, srcwMiddle, srchBorder) -- Middle bottom.
			tex(img, dstx1,              dsty1,              srcwBorder,                     srchBorder,                     srcx1, srcy1, srcwBorder, srchBorder) -- Left top.
			tex(img, dstx3,              dsty1,              srcwBorder,                     srchBorder,                     srcx3, srcy1, srcwBorder, srchBorder) -- Right top.
			tex(img, dstx1,              dsty3,              srcwBorder,                     srchBorder,                     srcx1, srcy3, srcwBorder, srchBorder) -- Left bottom.
			tex(img, dstx3,              dsty3,              srcwBorder,                     srchBorder,                     srcx3, srcy3, srcwBorder, srchBorder) -- Right bottom.
		end
	end
end

local function textLeftSameLine(txt, font_, x, y, w, h, offset_, alpha)
	local dx = offset_ and offset_[1] or 0
	local dy = offset_ and offset_[2] or 0
	local margin, scale = font_.margin or 1, font_.scale or 1
	local textWidth, textHeight = measure(txt, font_.resource, margin, scale)
	local fx, fy = x + dx, y + dy
	local col = alpha and Color.new(font_.color.r, font_.color.g, font_.color.b, alpha) or font_.color
	text(txt, fx, fy, col, margin, scale)

	return fx, fy, textWidth, textHeight
end

local function textLeft(txt, font_, x, y, w, h, offset_, alpha)
	local dx = offset_ and offset_[1] or 0
	local dy = offset_ and offset_[2] or 0
	local margin, scale = font_.margin or 1, font_.scale or 1
	local textWidth, textHeight = measure(txt, font_.resource, margin, scale)
	local fx, fy = x + dx, y + (h - textHeight) * 0.5 + dy
	local col = alpha and Color.new(font_.color.r, font_.color.g, font_.color.b, alpha) or font_.color
	text(txt, fx, fy, col, margin, scale)

	return fx, fy, textWidth, textHeight
end

local function textCenter(txt, font_, x, y, w, h, offset_, alpha)
	local dx = offset_ and offset_[1] or 0
	local dy = offset_ and offset_[2] or 0
	local margin, scale = font_.margin or 1, font_.scale or 1
	local textWidth, textHeight = measure(txt, font_.resource, margin, scale)
	local fx, fy = x + (w - textWidth) * 0.5 + dx, y + (h - textHeight) * 0.5 + dy
	local col = alpha and Color.new(font_.color.r, font_.color.g, font_.color.b, alpha) or font_.color
	text(txt, fx, fy, col, margin, scale)

	return fx, fy, textWidth, textHeight
end

local function textRight(txt, font_, x, y, w, h, offset_, alpha)
	local dx = offset_ and offset_[1] or 0
	local dy = offset_ and offset_[2] or 0
	local margin, scale = font_.margin or 1, font_.scale or 1
	local textWidth, textHeight = measure(txt, font_.resource, margin, scale)
	local fx, fy = x + (w - textWidth) + dx, y + (h - textHeight) * 0.5 + dy
	local col = alpha and Color.new(font_.color.r, font_.color.g, font_.color.b, alpha) or font_.color
	text(txt, fx, fy, col, margin, scale)

	return fx, fy, textWidth, textHeight
end

--[[
Exporting.
]]

return {
	KeyCodeLShift = KeyCodeLShift,
	KeyCodeRShift = KeyCodeRShift,
	NaN = NaN,
	isNaN = isNaN,
	round = round,
	clamp = clamp,
	intersected = intersected,
	startsWith = startsWith,
	endsWith = endsWith,
	split = split,
	escape = escape,
	car = car,
	cdr = cdr,
	exists = exists,
	filter = filter,
	merge = merge,
	tex3Grid = tex3Grid,
	tex9Grid = tex9Grid,
	textLeftSameLine = textLeftSameLine,
	textLeft = textLeft,
	textCenter = textCenter,
	textRight = textRight
}
