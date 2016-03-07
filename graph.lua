require 'cairo'

require 'widgets'

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
        cairo_translate(cr, 0.5, 0.5)
        cairo_select_font_face (cr, "White Rabbit", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL);
        cairo_set_font_size (cr, 12.0);
        
        local a_arg=conky_parse('${cpu cpu1}')
        local a_num=tonumber(a_arg)
        
        if not graph then
            graph = makeGraph(500, {x=23, y=111, angle=0, w=150, h=-50, lineWidth=1, color=color, bgColor=bgColor, borderColor=borderColor, padding=1.5, border=1, fillColor=nil})
        end
        
        graph.draw(cr, a_num / 100)
        drawLabel(cr, a_arg .. "%", 55, 195, 0, color)
    end
end
