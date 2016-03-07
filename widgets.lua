
function deg2rad(x)
    return x * math.pi / 180
end

function drawBarWithPercent(cr, val, x, y, angle, w, h, color, bgColor, borderColor, padding, border)
    drawBar(cr, tonumber(val) / 100, x, y, angle, w, h, color, bgColor, borderColor, padding, border)
    drawLabel(cr, tostring(val) .. "%", x, y + 13.5, angle, color)
end

function drawRoundline(cr, val, x, y, startAngle, angleWidth, startRadius, radiusWidth, lineWidth, color, bgColor, borderColor, padding, endPadding, border)
    cairo_save(cr)
    cairo_translate(cr, x, y)
    
    local negative = false
    if angleWidth < 0 then
        startAngle = startAngle + angleWidth
        angleWidth = -angleWidth
        negative = true
    end
    local endRadius = startRadius + radiusWidth
    local solid = false
    if lineWidth < 0 then
        solid = true
    end
    
    cairo_rotate(cr, startAngle)
--    fullAngle = endAngle - startAngle
    fullAngle = angleWidth
    -- border
    cairo_new_sub_path(cr)
    cairo_set_source_rgba(cr, borderColor.r, borderColor.g, borderColor.b, borderColor.a);
    cairo_set_line_width (cr, border);
    cairo_arc(cr, 0, 0, startRadius, 0, fullAngle)
      -- line not needed - arcs connect
    cairo_arc_negative(cr, 0, 0, endRadius, fullAngle, 0)
    cairo_arc(cr, 0, 0, startRadius, 0, 0) -- connect to the beginning of first arc
    cairo_stroke_preserve(cr);
    -- background
    cairo_set_source_rgba (cr, bgColor.r, bgColor.g, bgColor.b, bgColor.a);
    cairo_set_operator(cr, CAIRO_OPERATOR_SOURCE);
    cairo_fill(cr);
    cairo_set_operator(cr, CAIRO_OPERATOR_OVER);
    -- indicator
    cairo_set_source_rgba(cr, color.r, color.g, color.b, color.a);
    local offset = 2 * padding
    cairo_set_line_width(cr, math.abs(endRadius - startRadius) - offset);
    cairo_new_sub_path(cr)
    local midRadius = (startRadius + endRadius) / 2
    offset = endPadding / midRadius
    local maxBarAngle = (fullAngle - 2*offset)
    if solid then
        if negative then
            cairo_arc(cr, 0, 0, midRadius, offset + maxBarAngle * (1-val), fullAngle - offset)
        else
            cairo_arc(cr, 0, 0, midRadius, offset, offset + maxBarAngle * val)
        end
    else
        if negative then
            val = 1 - val
        end
        local halfWidth = lineWidth / (2 * midRadius)
        cairo_arc(cr, 0, 0, midRadius, offset + maxBarAngle * val - halfWidth, offset + maxBarAngle * val + halfWidth)
    end
    cairo_stroke(cr)
    
    cairo_restore(cr)
end

function drawLabel(cr, text, x, y, angle, color)
    cairo_save(cr)
    cairo_translate(cr, x, y)
    cairo_rotate(cr, angle)
    cairo_set_source_rgba(cr, color.r, color.g, color.b, color.a);
    cairo_show_text (cr, text);    
    cairo_restore(cr)
end

local function saveTranslateAndRotate(cr, x, y, angle)
    cairo_save(cr)
    cairo_translate(cr, x, y)
    cairo_rotate(cr, angle)
end

local function drawRectBorderAndBackground(cr, w, h, borderColor, borderWidth, preserve, bgColor)
    cairo_set_source_rgba(cr, borderColor.r, borderColor.g, borderColor.b, borderColor.a);
    cairo_set_line_width (cr, borderWidth);
    cairo_move_to(cr, 0, 0);
    cairo_rel_line_to(cr, 0, h);
    cairo_rel_line_to(cr, w, 0);
    cairo_rel_line_to(cr, 0, -h);
    cairo_rel_line_to(cr, -w, 0);
    cairo_rel_line_to(cr, 0, 0.1);
    if bgColor == nil then
        if preserve then
            cairo_stroke_preserve(cr);
        else
            cairo_stroke(cr)
        end
        return
    end
    cairo_stroke_preserve(cr);
    cairo_set_source_rgba (cr, bgColor.r, bgColor.g, bgColor.b, bgColor.a);
    cairo_set_operator(cr, CAIRO_OPERATOR_SOURCE);
    cairo_fill(cr);
    cairo_set_operator(cr, CAIRO_OPERATOR_OVER);    
end

local function drawRectBorder(cr, w, h, borderColor, borderWidth, preserve)
    drawRectBorderAndBackground(cr, w, h, borderColor, borderWidth, preserve, nil)
end

function drawBar(cr, val, x, y, angle, w, h, color, bgColor, borderColor, padding, border)
    --[[
    cairo_save(cr)
    cairo_translate(cr, x, y)
    cairo_rotate(cr, angle)
    --]]--
    saveTranslateAndRotate(cr, x, y, angle)
    
    -- border
    --[[
    cairo_set_source_rgba(cr, borderColor.r, borderColor.g, borderColor.b, borderColor.a);
    cairo_set_line_width (cr, border);
--    cairo_move_to(cr, x, y);
    cairo_move_to(cr, 0, 0);
    cairo_rel_line_to(cr, 0, h);
    cairo_rel_line_to(cr, w, 0);
    cairo_rel_line_to(cr, 0, -h);
    cairo_rel_line_to(cr, -w, 0);
    cairo_rel_line_to(cr, 0, 0.1);
    cairo_stroke_preserve(cr);
    --]]--
    drawRectBorderAndBackground(cr, w, h, borderColor, border, true, bgColor)
    --[[
    drawRectBorder(cr, w, h, borderColor, border, true)
    -- background
    cairo_set_source_rgba (cr, bgColor.r, bgColor.g, bgColor.b, bgColor.a);
    cairo_set_operator(cr, CAIRO_OPERATOR_SOURCE);
    cairo_fill(cr);
    cairo_set_operator(cr, CAIRO_OPERATOR_OVER);
    ]]--
    -- indicator
    cairo_set_source_rgba(cr, color.r, color.g, color.b, color.a);
    local offset = 2 * padding
    if (w < 0) then
        offset = -offset
    end
    cairo_set_line_width(cr, w - offset);
    offset = padding
    if (h < 0) then
        offset = -offset
    end
    cairo_move_to(cr, w/2, offset);
--    cairo_move_to(cr, x + w/2, y + offset);
    cairo_rel_line_to(cr, 0, val * (h - 2*offset));
    cairo_stroke(cr);
    cairo_restore(cr)
end

function makeGraph(bufSize, extraArgs)
    local graph = {buf={}, bufSize=bufSize, i=0}
    table.foreach(extraArgs, function(k, v) graph[k] = v end)
    graph.update = function(val)
        local i = graph.i
        graph.buf[i] = val
        i = i + 1
        if i >= graph.bufSize then
            i = 0
        end
        graph.i = i
    end
    graph.draw = function(cr, val, ...)
        graph.update(val)
        graph.redraw(cr, ...)
    end
    graph.redraw = function(cr, x, y, angle, w, h, lineWidth, color, bgColor, borderColor, padding, border, fillColor)
        local x = x or graph.x
        local y = y or graph.y
        local angle = angle or graph.angle
        local w = w or graph.w
        local h = h or graph.h
        local lineWidth = lineWidth or graph.lineWidth or 1
        local color = color or graph.color
        local bgColor = bgColor or graph.bgColor
        local borderColor = borderColor or graph.borderColor
        local padding = padding or graph.padding
        local border = border or graph.border
        local fillColor = fillColor or graph.fillColor
        
        saveTranslateAndRotate(cr, x, y, angle)
        drawRectBorderAndBackground(cr, w, h, borderColor, border, true, bgColor)
        
        local paddingx = w > 0 and padding or -padding
        local paddingy = h > 0 and padding or -padding
        local rw = w - 2*paddingx
        local rh = h - 2*paddingy
        local rx = paddingx
        local ry = paddingy
        local xps = rw / graph.bufSize
        local ypv = rh
        cairo_move_to(cr, rx, ry)
        
        local offset = graph.i
        local bufSize = graph.bufSize
        local i = 0
        while i < bufSize do
            local idx = i + offset
            if idx >= bufSize then
                idx = idx - bufSize
            end
            local val = graph.buf[idx] or 0
            cairo_line_to(cr, rx + xps * i, ry + ypv * val)
            i = i + 1
        end
        cairo_line_to(cr, rx + rw, ry)
        if color then
            cairo_set_source_rgba(cr, color.r, color.g, color.b, color.a);
            cairo_set_line_width (cr, lineWidth);
            if fillColor then
                cairo_stroke_preserve(cr)
            else
                cairo_stroke(cr)
            end
        end
        if fillColor then
            cairo_set_operator(cr, CAIRO_OPERATOR_SOURCE);
            cairo_set_source_rgba(cr, fillColor.r, fillColor.g, fillColor.b, fillColor.a);
            cairo_fill(cr)
        end
        cairo_restore(cr)
    end
    return graph
end
