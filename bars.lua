require 'cairo'

require 'widgets'

--[[
for k,v in pairs(math) do
  print(k .. "=" .. tostring(v))
end
--]]--

function conky_draw_lines()
    local updates=conky_parse('${updates}')
    update_num=tonumber(updates)
    if update_num > 5 then
        if conky_window==nil then return end
        local w=conky_window.width
        local h=conky_window.height
        local color = {r=0, g=1, b=1, a=1}
        local bgColor = {r=0, g=0.5, b=0.9, a=0.15}
        local cs=cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, w, h)
        local cr=cairo_create(cs)
--        cairo_scale(cr, 4, 4)
        cairo_translate(cr, 0.5, 0.5)
        cairo_select_font_face (cr, "White Rabbit", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL);
        cairo_set_font_size (cr, 12.0);
        
        --Line 1
        local a_arg=conky_parse('${cpu cpu1}')
        local a_num=tonumber(a_arg)
        --            x    y                                 thck,barcolor,   bgcolor  ,alf,pad
--        draw_bar(cr, 50, 110, a_num, a_arg .. "%", 10, 0, 1, 1, 0, 0.5, 0.9, 1, 1.5)
        drawBarWithPercent(cr, a_arg, 43, 111, 0, 13, -103, color, bgColor, color, 1.5, 1)
        --line 2
        local b_arg=conky_parse('${cpu cpu2}')
        local b_num=tonumber(b_arg)
--        draw_bar(cr, 80, 110, b_num, b_arg .. "%", 10, 0, 1, 1, 0, 0.5, 0.9, 1, 1.5)
        drawBarWithPercent(cr, b_arg, 73, 111, 0, 13, -103, color, bgColor, color, 1.5, 1)
        --line 3
        local c_arg=conky_parse('${cpu cpu3}')
        local c_num=tonumber(c_arg)
--        draw_bar(cr, 110, 110, c_num, c_arg .. "%", 10, 0, 1, 1, 0, 0.5, 0.9, 1, 1.5)
        drawBarWithPercent(cr, c_arg, 103, 111, 0, 13, -103, color, bgColor, color, 1.5, 1)
        --line 4
        local d_arg=conky_parse('${cpu cpu4}')
        local d_num=tonumber(d_arg)
--        draw_bar(cr, 140, 110, d_num, d_arg .. "%", 10, 0, 1, 1, 0, 0.5, 0.9, 1, 1.5)
        
        --                      val      x    y     a   w   h   color  bgColor  brdCol pad brd
        drawBarWithPercent(cr, d_arg, 133, 111, 0, 13, -103, color, bgColor, color, 1.5, 1)

        local e_arg=conky_parse('${cpu cpu5}')
        local e_num=tonumber(e_arg)
        drawBarWithPercent(cr, e_arg, 163, 111, 0, 13, -103, color, bgColor, color, 1.5, 1)
        
        local f_arg=conky_parse('${cpu cpu6}')
        local f_num=tonumber(f_arg)
        drawBarWithPercent(cr, f_arg, 193, 111, 0, 13, -103, color, bgColor, color, 1.5, 1)
        
        local g_arg=conky_parse('${cpu cpu7}')
        local g_num=tonumber(g_arg)
        drawBarWithPercent(cr, g_arg, 223, 111, 0, 13, -103, color, bgColor, color, 1.5, 1)
        
        local h_arg=conky_parse('${cpu cpu8}')
        local h_num=tonumber(h_arg)
        drawBarWithPercent(cr, h_arg, 253, 111, 0, 13, -103, color, bgColor, color, 1.5, 1)
        
        drawRoundline(cr, d_num / 100, 100, 180, deg2rad(180), 4, 30, 15, -1, color, bgColor, color, 2, 2, 1)
        drawLabel(cr, d_arg .. "%", 55, 195, 0, color)
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
