require 'cairo'

require 'widgets'

--[[
for k,v in pairs(math) do
  print(k .. "=" .. tostring(v))
end
--]]--

graph = nil

function conky_draw_lines()
    local updates=conky_parse('${updates}')
    update_num=tonumber(updates)
    if update_num > 5 then
        if conky_window==nil then return end
        local w=conky_window.width
        local h=conky_window.height
        local color = {r=1, g=0.5, b=0, a=1}
        local bgColor = {r=0, g=0.5, b=0.9, a=0.15}
        local borderColor = {r=0, g=1, b=1, a=1}
        local fillColor = {r=0.5, g=0, b=0, a=0.5}
        local cs=cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, w, h)
        local cr=cairo_create(cs)
--        cairo_scale(cr, 4, 4)
        cairo_translate(cr, 0.5, 0.5)
        cairo_select_font_face (cr, "White Rabbit", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL);
        cairo_set_font_size (cr, 12.0);
        
        local a_arg=conky_parse('${cpu cpu1}')
        local a_num=tonumber(a_arg)
        
        if not graph then
            graph = makeGraph(500, {x=23, y=111, angle=0, w=150, h=-50, lineWidth=1, color=color, bgColor=bgColor, borderColor=borderColor, padding=1.5, border=1, fillColor=nil})
        end
        
        --print("Still alive")
        
        graph.draw(cr, a_num / 100)
        drawLabel(cr, a_arg .. "%", 55, 195, 0, color)
    end
end

--[[

function deg2rad(x)
    return x * math.pi / 180
end

function drawBarWithPercent(cr, val, x, y, angle, w, h, color, bgColor, borderColor, padding, border)
    drawBar(cr, tonumber(val) / 100, x, y, angle, w, h, color, bgColor, borderColor, padding, border)
    drawLabel(cr, tostring(val) .. "%", x, y + 13.5, angle, color)
end

function drawRoundline(cr, val, x, y, startAngle, angleWidth, startRadius, radiusWidth, lineWidth, color, bgColor, borderColor, padding, border)
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
    offset = padding / midRadius
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

function drawBar(cr, val, x, y, angle, w, h, color, bgColor, borderColor, padding, border)
    cairo_save(cr)
    cairo_translate(cr, x, y)
    cairo_rotate(cr, angle)
    -- border
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
    -- background
    cairo_set_source_rgba (cr, bgColor.r, bgColor.g, bgColor.b, bgColor.a);
    cairo_set_operator(cr, CAIRO_OPERATOR_SOURCE);
    cairo_fill(cr);
    cairo_set_operator(cr, CAIRO_OPERATOR_OVER);
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

]]--
