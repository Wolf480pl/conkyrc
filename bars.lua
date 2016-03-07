require 'cairo'

require 'widgets'

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
        --                      val      x    y     a   w   h   color  bgColor  brdCol pad brd
        drawBarWithPercent(cr, a_arg, 43, 111, 0, 13, -103, color, bgColor, color, 1.5, 1)
        --line 2
        local b_arg=conky_parse('${cpu cpu2}')
        local b_num=tonumber(b_arg)
        drawBarWithPercent(cr, b_arg, 73, 111, 0, 13, -103, color, bgColor, color, 1.5, 1)
        --line 3
        local c_arg=conky_parse('${cpu cpu3}')
        local c_num=tonumber(c_arg)
        drawBarWithPercent(cr, c_arg, 103, 111, 0, 13, -103, color, bgColor, color, 1.5, 1)
        --line 4
        local d_arg=conky_parse('${cpu cpu4}')
        local d_num=tonumber(d_arg)
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
