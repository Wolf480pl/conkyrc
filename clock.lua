require 'cairo'

require 'widgets'

--[[
for k,v in pairs(os) do
  print(k .. "=" .. tostring(v))
end
--]]--

lastTime = nil
lastUpdates = nil

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
        
        local time = os.time()
        if (time ~= lastTime) then
            lastTime = time
            lastUpdates = update_num
        end
        
        local s_num=(time % 60) + ((updates - lastUpdates) % 10) / 10.0
        local s_arg=tostring(s_num)
        
        local m_num=math.floor((time / 60.0) % 60)
        local m_arg=tostring(math.floor(m_num * 10) / 10)
        
        local h_num=math.floor((time / 3600) % 24)
        local h_arg=tostring(h_num)
        local brdColor = color

        --                       val   x    y   startAngle   angleWidth  sRad radW linW color bgColor brdColr pad ePad brd
        drawRoundline(cr, h_num / 24, 100, 150, deg2rad(-90), deg2rad(360), 35, 15, -1, color, bgColor, brdColor, 1, 0, 1)
        
        --                       val   x    y   startAngle   angleWidth  sRad radW linW color bgColor brdColr pad ePad brd
        drawRoundline(cr, m_num / 60, 100, 150, deg2rad(-90), deg2rad(360), 50, 15, -1, color, bgColor, brdColor, 1, 0, 1)
        
        --                       val   x    y   startAngle   angleWidth  sRad radW linW color bgColor brdColr pad ePad brd
        drawRoundline(cr, s_num / 60, 100, 150, deg2rad(-90), deg2rad(360), 65, 15, -1, color, bgColor, brdColor, 1, 0, 1)


        local txt = string.format("%02d:%02d:%02.1f", h_num, m_num, s_num)
        drawLabel(cr, txt, 65, 155, 0, color)        

        
    end
end

