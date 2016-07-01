-- Created by: DaryKiri
-- Requires Amixer
-- How to use:
-- 	Create a variable that uses this widget using: create_volume_widget_text()
-- 	Afert that, insert it on the wiibox

local awful = require("awful")
local wibox = require("wibox")

--Functions to get information about the volume
function get_volume()
	--Using $5, It may not get the expected output if using another version of amixer
	local fd = io.popen("amixer get Master |grep % |awk '{print $5}'|sed 's/[^0-9]//g' | sed '1d'")
	local vol_string = fd:read("*l")
	fd:close()
	return vol_string
end

function get_mute()
	--Using $6, It may not get the expected output if using another version of amixer
	local fd = io.popen("amixer get Master | grep % | awk '{print $6}' | sed '1d' | tr -d '[]'")
	local mute_string = fd:read("*l")
	fd:close()
	return tostring(mute_string)
end

--Functions to update and change the volume
function update(widget)
	local volumen = get_volume()
	local mute    = get_mute()
	if mute == "off" then
	   widget:set_text("Vol:" .. mute)
	else 
	   widget:set_text( "Vol:" .. volumen .. "/100" )
	end
end

function inc_vol(widget)
	awful.util.spawn("amixer set Master 5%+", false)
	update(widget)
end

function decr_vol(widget)
	awful.util.spawn("amixer set Master 5%-", false)
	update(widget)
end

function mute_vol(widget)
	awful.util.spawn("amixer set Master toggle", false)
	update(widget)
end

--Creates de widget
function create_volume_widget_text()
	local vol_widget = wibox.widget.textbox()
	--Updatting the widget
	update(vol_widget)
	return vol_widget
end
