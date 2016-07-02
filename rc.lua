--[[
    Some code are adapted from:
    Multicolor Awesome WM config 2.0
    github.com/copycat-killer
--]]

-- {{{ Imported libraies
-- Standard awesome library
local gears     = require("gears")
local awful     = require("awful")
awful.rules     = require("awful.rules")
                  require("awful.autofocus")
-- Widget and layout library
local wibox     = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty   = require("naughty") --Set to global or not
local menubar   = require("menubar")
-- Library for widgets
--local vicious   = require("vicious")
-- Library for key cheatsheet
local keydoc    = require("keydoc")
-- Library for dynamic taggging
local eminent   = require("eminent")
--Lain library
local lain      = require("lain")
-- Own imported libraries
                  require("volumeWidget")
-- }}}

-- Local variables for future use
local home_env = os.getenv("HOME")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions

-- Themes define colours, icons, font and wallpapers.
--beautiful.init("/usr/share/awesome/themes/default/theme.lua") --default theme
--beautiful.init(home_env .. "/.config/awesome/themes/default/theme.lua")
beautiful.init(home_env .. "/.config/awesome/themes/multicolor/theme.lua")


modkey      = "Mod4"
altkey      = "Mod1"
terminal    = "xfce4-terminal" or "xterm"
editor      = os.getenv("EDITOR") or "nano"
editor_cmd  = terminal .. " -e " .. editor

browser     = "firefox"
browser1    = "opera"
--ide         = "idea"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.floating, --1
    awful.layout.suit.tile, --2
    awful.layout.suit.tile.left, --3
    awful.layout.suit.tile.bottom, --4
    awful.layout.suit.tile.top, --5
    awful.layout.suit.fair, --6
    awful.layout.suit.fair.horizontal, --7
--    awful.layout.suit.spiral,
--    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max, --8
--    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier --9
}

--quake terminal
local quakeconsole = {}
for s = 1, screen.count() do
    quakeconsole[s] = lain.util.quake({app = terminal})
end
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Tags
tags = {
	names = { "file", "web", "web1", "dev", "dev1", "social", "other" },
	layout = { layouts[9], layouts[8], layouts[8], layouts[1], layouts[1], layouts[6], layouts[2] }
}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag(tags.names, s, tags.layout)
end
-- }}}

-- {{{ Menu MODIFY LATER
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

--submenu
myutils = {
   { "firefox", "firefox" },
   { "skype", "skype" }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "utils", myutils },
                                    { "open terminal", terminal }, --entry
                                  },
                          theme = { height = 16, width = 130}
                        })

--[[ Test
mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })
--]]

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}
-- {{{ Wibox
markup = lain.util.markup

-- textclock widget
clockicon = wibox.widget.imagebox(beautiful.widget_clock)
mytextclock = lain.widgets.abase({
    timeout  = 60,
    cmd      = "date +'%A %d %B %R'",
    settings = function()
        local t_output = ""
        local o_it = string.gmatch(output, "%S+")

        for i=1,3 do t_output = t_output .. " " .. o_it(i) end

        widget:set_markup(markup("#7788af", t_output) .. markup("#343639", " > ") .. markup("#de5e1e", o_it(1)) .. " ")
    end
})

-- Calendar widget
lain.widgets.calendar:attach(mytextclock, { font_size = 10 })

-- / fs disk usage widget (root)
fsicon = wibox.widget.imagebox(beautiful.widget_fs)
fswidget = lain.widgets.fs({
    settings  = function()
        widget:set_markup(markup("#80d9d8", fs_now.used .. "% "))
    end
})

-- CPU widget
cpuicon = wibox.widget.imagebox()
cpuicon:set_image(beautiful.widget_cpu)
cpuwidget = lain.widgets.cpu({
    settings = function()
        widget:set_markup(markup("#e33a6e", cpu_now.usage .. "% "))
    end
})

-- Coretemp widget
tempicon = wibox.widget.imagebox(beautiful.widget_temp)
tempwidget = lain.widgets.temp({
    settings = function()
        widget:set_markup(markup("#f1af5f", coretemp_now .. "°C "))
    end
})

-- Battery widget
baticon = wibox.widget.imagebox(beautiful.widget_batt)
batwidget = lain.widgets.bat({
    settings = function()
        perc = bat_now.perc .. "% "
        if bat_now.ac_status == 1 then
            perc = perc .. "Plug "
        end
        widget:set_text(perc)
    end
})

-- ALSA volume widget
volicon = wibox.widget.imagebox(beautiful.widget_vol)
volumewidget = lain.widgets.alsa({
    settings = function()
        if volume_now.status == "off" then
            volume_now.level = volume_now.level .. "M"
        end

        widget:set_markup(markup("#7493d2", volume_now.level .. "% "))
    end
})

-- Net widget
netdownicon = wibox.widget.imagebox(beautiful.widget_netdown)
--netdownicon.align = "middle"
netdowninfo = wibox.widget.textbox()
netupicon = wibox.widget.imagebox(beautiful.widget_netup)
--netupicon.align = "middle"
netupinfo = lain.widgets.net({
    settings = function()
        widget:set_markup(markup("#e54c62", net_now.sent .. " "))
        netdowninfo:set_markup(markup("#87af5f", net_now.received .. " "))
    end
})

-- MEM widget
memicon = wibox.widget.imagebox(beautiful.widget_mem)
memwidget = lain.widgets.mem({
    settings = function()
        widget:set_markup(markup("#e0da37", mem_now.used .. "M "))
    end
})

-- MPD widget
mpdicon = wibox.widget.imagebox()
mpdwidget = lain.widgets.mpd({
    settings = function()
        mpd_notification_preset = {
            text = string.format("%s [%s] - %s\n%s", mpd_now.artist,
                mpd_now.album, mpd_now.date, mpd_now.title)
        }

        if mpd_now.state == "play" then
            artist = mpd_now.artist .. " > "
            title  = mpd_now.title .. " "
            mpdicon:set_image(beautiful.widget_note_on)
        elseif mpd_now.state == "pause" then
            artist = "mpd "
            title  = "paused "
        else
            artist = ""
            title  = ""
            mpdicon:set_image(nil)
        end
        widget:set_markup(markup("#e54c62", artist) .. markup("#b2b2b2", title))
    end
})

-- Spacer
spacer = wibox.widget.textbox(" ")

--[[ My own widgets
--Create widget of volume
mytextvolume = create_volume_widget_text()

--Create widget of battery
--Is not working
batterywidget = wibox.widget.textbox()
batterywidget:set_text(" | Battery | ")
batterywidgettimer = timer({ timeout = 5 })
batterywidgettimer:connect_signal("timeout",
    function()
        fh = assert(io.popen("acpi | cut -d, -f 2,3 -", "r"))
        batterywidget:set_text(" |" .. fh:read("*l") .. " | ")
        fh:close()
    end
)
--batterywidgettimer:start()
-- ]]
-- }}}

-- {{{ Layout

-- Create a wibox for each screen and add it
mywibox = {} --Top wibox
mybottomwibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}

mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({
                                                      --theme = { width = 250 }
                                                      width=250 --Test
                                                  })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do

    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()

    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))

    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the upper wibox
    mywibox[s] = awful.wibox({ position = "top", height = "20", screen = s })

    -- Widgets that are aligned to the upper left
    local left_layout = wibox.layout.fixed.horizontal()
    --left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])
    left_layout:add(mpdicon)
    left_layout:add(mpdwidget)

    -- Widgets that are aligned to the upper right
    local right_layout = wibox.layout.fixed.horizontal()
    --if s == 1 then right_layout:add(wibox.widget.systray()) end
    --right_layout:add(mytextvolume)
    right_layout:add(netdownicon)
    right_layout:add(netdowninfo)
    right_layout:add(netupicon)
    right_layout:add(netupinfo)
    right_layout:add(volicon)
    right_layout:add(volumewidget)
    right_layout:add(memicon)
    right_layout:add(memwidget)
    right_layout:add(cpuicon)
    right_layout:add(cpuwidget)
    right_layout:add(fsicon)
    right_layout:add(fswidget)
    right_layout:add(tempicon)
    right_layout:add(tempwidget)
    right_layout:add(baticon)
    right_layout:add(batwidget)
    right_layout:add(clockicon)
    right_layout:add(mytextclock)
    --right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    --layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)

    -- Create the bottom wibox
    mybottomwibox[s] = awful.wibox({ position = "bottom", screen = s, border_width = 0, height = 20 })

    local bottom_left_layout = wibox.layout.fixed.horizontal()

    local bottom_right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then bottom_right_layout:add(wibox.widget.systray()) end --Only adds systray to screen 1
    bottom_right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with tasklist in the middle)
    local bottom_layout = wibox.layout.align.horizontal()
    bottom_layout:set_left(bottom_left_layout)
    bottom_layout:set_middle(mytasklist[s])
    bottom_layout:set_right(bottom_right_layout)
    mybottomwibox[s]:set_widget(bottom_layout)

end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    --Right click keys
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    --Mouse wheel keys
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(

    keydoc.group("Layout browsing"),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev, "Focus Previous Tag"),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext, "Focus Next Tag"),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore, "Focus previously selected Tag"),

    keydoc.group("Client manipulation"),
    --By direction manipulation
    awful.key({ modkey }, "j",
        function()
            awful.client.focus.bydirection("down")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "k",
        function()
            awful.client.focus.bydirection("up")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "h",
        function()
            awful.client.focus.bydirection("left")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "l",
        function()
            awful.client.focus.bydirection("right")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end, "Switch to previous focused client"),

    --[[ Default manipulation

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end, "Focus next window"),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end, "Focus previous window"),
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end, "Switch client with next client"),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end, "Switch client with previous client"),

    -- Only when using multiple screens
    --awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    --awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    --awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),

    --]]
    
--[[ Old volume control
    --Keys used to manage volume
--awful.key({ }, "XF86AudioRaiseVolume", function ()
--   awful.util.spawn("amixer set Master 5%+", false) end, "Increase volume"),
--awful.key({ }, "XF86AudioLowerVolume", function ()
--   awful.util.spawn("amixer set Master 5%-", false) end, "Decrease volume"),
--awful.key({ }, "XF86AudioMute", function ()
--   awful.util.spawn("amixer set Master toggle", false) end, "Mute volume"),


  awful.key({ }, "XF86AudioRaiseVolume", function ()
     inc_vol(mytextvolume) end, "Increase volume"),
  awful.key({ }, "XF86AudioLowerVolume", function ()
     decr_vol(mytextvolume) end, "Decrease volume"),
  awful.key({ }, "XF86AudioMute", function ()
     mute_vol(mytextvolume) end, "Mute volume"),
--]]

    keydoc.group("Volume control"),
    awful.key({ }, "XF86AudioRaiseVolume",
        function ()
            os.execute(string.format("amixer set %s 1%%+", volumewidget.channel))
            volumewidget.update()
        end, "Increase volume"),
    awful.key({ }, "XF86AudioLowerVolume",
        function ()
            os.execute(string.format("amixer set %s 1%%-", volumewidget.channel))
            volumewidget.update()
        end, "Decrease volume"),
    awful.key({ }, "XF86AudioMute",
        function ()
            os.execute(string.format("amixer set %s toggle", volumewidget.channel))
            volumewidget.update()
        end, "Mute volume"),

    keydoc.group("MPD Control"),
    awful.key({ altkey, "Control" }, "Up",
        function ()
            awful.util.spawn_with_shell("mpc toggle || ncmpc toggle || pms toggle")
            mpdwidget.update()
        end, "Play/Pause music"),
    awful.key({ altkey, "Control" }, "Down",
        function ()
            awful.util.spawn_with_shell("mpc stop || ncmpc stop || pms stop")
            mpdwidget.update()
        end, "Stop playing"),
    awful.key({ altkey, "Control" }, "Left",
        function ()
            awful.util.spawn_with_shell("mpc prev || ncmpc prev || pms prev")
            mpdwidget.update()
        end, "Previous song"),
    awful.key({ altkey, "Control" }, "Right",
        function ()
            awful.util.spawn_with_shell("mpc next || ncmpc next || pms next")
            mpdwidget.update()
        end, "Next song"),

    keydoc.group("User programs"),
    awful.key({ modkey }, "q", function () awful.util.spawn(browser) end),
    awful.key({ modkey }, "i", function () awful.util.spawn(browser2) end),

    keydoc.group("Standard"),
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end, "Open terminal"),
    awful.key({ modkey, "Control" }, "r", awesome.restart, "Restart Awesome"),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit, "Quit Awesome"),
    awful.key({ modkey, 	  }, "g",      keydoc.display, "Cheat sheet"),
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end, "Run prompt"),
    awful.key({ modkey }, "p", function() menubar.show() end, "Menubar"),
    awful.key({ modkey,           },"z", function() quakeconsole[mouse.screen]:toggle() end, "Dropdown terminal"),
    awful.key({ modkey }, "c", function () os.execute("xsel -p -o | xsel -i -b") end, "Copy to clipboard"),
    awful.key({ modkey }, "w",
        function()
            mymainmenu:show({ keygrabber = true})
        end, "Show Menu"
    ),
    awful.key({ modkey }, "b",
        function()
            mywibox[mouse.screen].visible = not mywibox[mouse.screen].visible
            mybottomwibox[mouse.screen].visible = not mybottomwibox[mouse.screen].visible
        end, "Show/Hide Wibox"
    ),
    awful.key({ }, "Print",
        function ()
            local title_out = "Screenshot taken"
            local text_out = "Saved on: " .. home_env .. "/Pictures/Screenshot"
            local cmd =  home_env .. "/.config/awesome/scripts/screenshot.sh"
            awful.util.spawn_with_shell(cmd)
            naughty.notify({title=title_out, text=text_out})
        end, "Screenshot"
    ),
    awful.key({ modkey }, "x",
        function ()
            awful.prompt.run({ prompt = "Run Lua code: " },
                mypromptbox[mouse.screen].widget,
                awful.util.eval, nil,
                awful.util.getdir("cache") .. "/history_eval")
        end, "Run lua code"),

    keydoc.group("Widgets popups"),
    awful.key({ altkey,           }, "c",      function () lain.widgets.calendar:show(7) end),
    awful.key({ altkey,           }, "h",      function () fswidget.show(7) end),

    keydoc.group("Layout manipulation"),
    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end, "Increase master width"),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end, "Decrease master width"),
    --awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    --awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    --awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    --awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end, "Next layout"),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end, "Previous layout"),
    awful.key({ modkey, "Control" }, "n", awful.client.restore, "Restore client")
)
    
clientkeys = awful.util.table.join(
    keydoc.group("Client"),
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end, "Fullscreen"),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end, "Kill client"),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     , "Toggle client floating"),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end, "Swap client with master"),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen,                         "Client to next screen"),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end, "Set client on-top"),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end, "Minimize client"),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end, "Maximize client")
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
--TODO PUT KEYDOC GUIDE HERE
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.movetotag(tag)
                          end
                     end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.toggletag(tag)
                          end
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}


-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     maximized_vertical   = false, --Ensure firefox doesn't initialize on fullscreen mode
 		             maximized_horizontal = false,
                     size_hints_honor = false } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },

    -- Guide to choose tag
    -- "files" = 1, "web1" = 2, "web2" = 3, "dev1" = 4, "dev2" = 5, "social" = 6, "other" = 7

    -- Bind luakit to screeen 1 tag 3 "web1"
    { rule = { class = "luakit" },
    properties = { tag = tags[1][3] } },
    -- Bind firefox to screen 1 tag 2 and start it with floating status
    { rule = { class = "Firefox" },
    properties = { tag = tags[1][2], floating = true  } },
    -- Bind skype to screen 1 tag 6 "social"
    { rule = { class = "Skype" },
    properties = { tag = tags[1][6] } },
    -- Bind eclipse to screen 1 tag 5 "dev1"
    { rule = { class = "Eclipse" },
    properties = { tag = tags[1][5] } },
    --Bind android studio to screen 1 tag 5 "dev1"
    { rule = { class = "jetbrains-studio" },
    properties = { tag = tags[1][5] } },
    -- Bind Light Table to screen 1 tag 4 "dev"
    { rule = { class = "LightTable" },
    properties = { tag = tags[1][4] } },
    -- Bind gedit to screen 1 tag 4 "dev"
    { rule = { class = "Gedit" },
    properties = { tag = tags[1][4] } },
    -- Bind thunar to screem 1 tag 1 "files"
    { rule = { class = "Thunar" },
    properties = { tag = tags[1][1] } },
    -- Bind idea to screen 1 tag 5 "dev1"
    { rule = { class = "jetbrains-idea-ce" },
    properties = { tag = tags[1][5] } },
    -- Bind notepadqq to screen 1 tag 4 "dev"
    {rule = { class = "notepadqq-bin" },
    properties = { tag = tags[1][4] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
local sloppyfocus_last = {c=nil}
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            --Skip focusing the client if the mouse wasn't moved.
            if c ~= sloppyfocus_last.c then
                client.focus = c
                sloppyfocus_last.c = c
            end
        end
    end)

    --[[ Uncomment to use original config
    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
    --]]

    local titlebars_enabled = false --Enable tilebar for each clients
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                )

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c):set_widget(layout)
    end
end)

-- No border for maximized or single clients
client.connect_signal("focus",
    function(c)
        if c.maximized_horizontal == true and c.maximized_vertical == true then
            c.border_width = 0
        elseif #awful.client.visible(mouse.screen) > 1 then
            c.border_width = beautiful.border_width
            c.border_color = beautiful.border_focus
        end
    end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{ Arrange signal handler
for s = 1, screen.count() do screen[s]:connect_signal("arrange",
    function ()
        local clients = awful.client.visible(s)
        local layout  = awful.layout.getname(awful.layout.get(s))

        if #clients > 0 then
            for _, c in pairs(clients) do -- Floaters always have borders
            if awful.client.floating.get(c) or layout == "floating" then
                c.border_width = beautiful.border_width
            end
            end
        end
    end)
end
-- }}}

--client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
--client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
