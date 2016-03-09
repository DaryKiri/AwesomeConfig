-- Propio Script para widget volumen contiene las funciones necesarias para que mi widget funcione
-- Creado por: DaryKiri
-- Solo para Amixer, tambien puedes acomodarlo a tu gusto
-- Instrucciones de uso:
-- 	Crear el widget con create_volume_widget_text()
-- 	Incorporar los botones con cada funcion de aumentar, decrementar y mutear el sonido
-- 	Meter el widget en el wibox

local awful = require("awful")
local wibox = require("wibox")

--Funcion para obtener el volumen desde amixer
function get_volume()
	--He usado $5 alomejor, no funciona en otros ordenadores
	local fich = io.popen("amixer get Master |grep % |awk '{print $5}'|sed 's/[^0-9]//g' | sed '1d'")
	vol_string = fich:read("*l")
	fich:close()
	return vol_string
end

--Funcion para obtener si esta muteado o no
function get_mute()
	--He usado $6 alomejor, no funciona en otros ordenadores
	local fich1 = io.popen("amixer get Master | grep % | awk '{print $6}' | sed '1d' | tr -d '[]'")
	mute_string = fich1:read("*l")
	fich1:close()
	return tostring(mute_string)
end

--Funcion para updatear el widget
function update(widget)
	volumen = get_volume()
	mute    = get_mute()
	if mute == "off" then
	   widget:set_text("Vol:" .. mute) 
	else 
	   widget:set_text( "Vol:" .. volumen .. "/100" ) 
	end
end

--Funcion para aumentar el volumen
function inc_vol(widget)
	awful.util.spawn("amixer set Master 5%+", false)
	update(widget)
end

--Funcion para decrementar volumen
function decr_vol(widget)
	awful.util.spawn("amixer set Master 5%-", false)
	update(widget)
end

--Funcion para mutear el volumen
function mute_vol(widget)
	awful.util.spawn("amixer set Master toggle", false)
	update(widget)
end

--Funcion que crea el widget version texto
function create_volume_widget_text()
	vol_widget = wibox.widget.textbox()
	--Updateamos el widget
	update(vol_widget)
	return vol_widget
end
