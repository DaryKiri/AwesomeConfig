-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
--Mi widget de volumen
require("volumeWidget")

----------------------------- LIBRERIAS PROPIAS IMPORTADAS------------------------------------------
--Libreria vicious para widgets
local vicious = require("vicious")
--Libreria para documentar keybinds usados
local keydoc = require("keydoc")
--Permite usar tags dinamicamente
local eminent = require("eminent") 

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
--beautiful.init("/usr/share/awesome/themes/default/theme.lua")
beautiful.init("/home/daryl/.config/awesome/themes/default/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "xfce4-terminal"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

----------------------------------LAYOUTS------------------------------------------------------------

-- Table of layouts to cover with awful.layout.inc, order matters.
-- He comentado los layouts que no me interesan
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
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {
	names = { "1-FILE", "2-WEB", "3-WEB1", "4-DEV", "5-DEV1", "6-SOCI", "7-OTH" },
	layout = { layouts[9], layouts[8], layouts[8], layouts[1], layouts[1], layouts[6],
		   layouts[2] }
}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag(tags.names, s, tags.layout)
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

myutils = {
   { "firefox", "firefox" },
   { "skype", "skype" }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
				    { "utils", myutils },
                                    { "open terminal", terminal },
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox

--  Network usage widget only for ethernet Uncoment for usage
--netwidget = wibox.widget.textbox()
-- Register widget
--vicious.register(netwidget, vicious.widgets.net, '<span color="#CC9393">${eth0 down_kb}</span> <span color="#7F9F7F">${eth0 up_kb}</span>', 3)


-- Create a textclock widget
mytextclock = awful.widget.textclock()

--Crear un widget de volumen de sonido
mytextvolume = create_volume_widget_text()

--Crear widget de batteria
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


-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
--Creacion de wibox abajo del todo----
mybottomwibox = {}
--------------------------------------
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
                                                      theme = { width = 250 }
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

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", height = "20", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    --right_layout:add(netwidget) --Cambiado UNCOMENT FOR USAGE
    right_layout:add(mytextvolume)
    right_layout:add(mytextclock)
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    --layout:set_middle(mytasklist[s]) -- Quitar tasklist de wibox de arriba
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
    
    --Prueba de dos wibox
    -- Create the bottom wibox
    mybottomwibox[s] = awful.wibox({ position = "bottom", screen = s, border_width = 0, height = 18 })
    bottom_layout = wibox.layout.align.horizontal()
    bottom_layout:set_middle(mytasklist[s])
    --bottom_layout:set_right(batterywidget)
    mybottomwibox[s]:set_widget(bottom_layout)

end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

---------------------------------ATAJOS DEL TECLADO------------------------
-- {{{ Key bindings
globalkeys = awful.util.table.join( 
    keydoc.group("Manipulacion del Layout"),
    awful.key({ modkey, 	  }, "g",      keydoc.display, "Guia atajos"),
    awful.key({ }, "Print", 
        function () 
            local date =os.date("%Y_%m_%d-%H_%M_%S") 
            local cmd =  "import -window root ~/Pictures/Screenshot_"..date..".png"
            awful.util.spawn_with_shell(cmd) 
            naughty.notify({text=cmd})
        end, "Captura de Pantalla"),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev, "Tag anterior"),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext, "Tag siguiente"),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore, "Volver a Tag reciente"),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end, "Focus Ventana siguiente"),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end, "Focus Ventana anterior"),
--    awful.key({ modkey,           }, "w", function () mymainmenu:show() end, "Mostrar menu"),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end, "Orden ventana izquierda"),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end, "Orden ventana derecha"),
-------------------------------FOCUS SOLO SI SE USA DOBLE SCREEN-----------------------------------------------------
--    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
--    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
--    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end, "Volver a ventana anterior"),

    
    keydoc.group("Atajos Volumen"),
    --Keys para aumentar volumen 
--awful.key({ }, "XF86AudioRaiseVolume", function ()
--   awful.util.spawn("amixer set Master 5%+", false) end, "Subir el volumen"),
--awful.key({ }, "XF86AudioLowerVolume", function ()
--   awful.util.spawn("amixer set Master 5%-", false) end, "Bajar el volumen"),
--awful.key({ }, "XF86AudioMute", function ()
--   awful.util.spawn("amixer set Master toggle", false) end, "Mutear el volumen"),

  awful.key({ }, "XF86AudioRaiseVolume", function ()
     inc_vol(mytextvolume) end, "Subir el volumen"),
  awful.key({ }, "XF86AudioLowerVolume", function ()
     decr_vol(mytextvolume) end, "Bajar el volumen"),
  awful.key({ }, "XF86AudioMute", function ()
     mute_vol(mytextvolume) end, "Mutear el volumen"),

    -- Standard program
    keydoc.group("Atajos estandares"),

    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end, "Abrir terminal"),
    awful.key({ modkey, "Control" }, "r", awesome.restart, "Reiniciar Awesome"),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit, "Quitar Awesome"),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end, "Aumentar tamano ventana"),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end, "Decrementar tamano ventana"),
--    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
--    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
--    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
--    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end, "Cambiar layout"),
--    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore, "Restaurar"),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end, "Correr una aplicacion"),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end, "Correr codigo Lua"),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end, "Barra de menu")
)
    
clientkeys = awful.util.table.join(
    keydoc.group("Atajos de ventana"),
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end, "Pantalla completa"),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end, "Matar ventana"),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     , "Convertir en floating"),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end, "Poner ventana en top"),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end, "Minimizar ventana"),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end, "Maximizar ventana")
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
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

-------------------REGLAS PARA CADA VENTANA INICIADA---------------------
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
		     maximized_vertical   = false, --Cambiado evita que firefox inicie en pantalla completa
 		     maximized_horizontal = false, --Cambiado
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },

------GUIA DE MAPEADO------------------------------------------------------------------------
    -- "files" = 1, "web1" = 2, "web2" = 3, "dev1" = 4, "dev2" = 5, "social" = 6, "other" = 7
    
    -- Mapear luakit a screen 1 tag 3 "web2"
    { rule = { class = "luakit" },
    properties = { tag = tags[1][3] } }, 
    -- Mapear la aplicacion de Firefox a screen 1 tag 2 y hacer que sea floating
    { rule = { class = "Firefox" },
    properties = { tag = tags[1][2], floating = true  } }, 
    -- Mapear la aplicacion Skype a screen 1 tag 6 "Social"
    { rule = { class = "Skype" },
    properties = { tag = tags[1][6] } },
    --Mapear eclipse a screen 1 tag 5 "dev2"
    { rule = { class = "Eclipse" },
    properties = { tag = tags[1][5] } },
    -- Mapear cliente android studio a screen 1 tag 5 "dev2"
    { rule = { class = "jetbrains-studio" },
    properties = { tag = tags[1][5] } },
    --Mapear Light Table a screen 1 tag 4 "dev1"
    { rule = { class = "LightTable" },
    properties = { tag = tags[1][4] } },
    --Mapear cliente gedit a screen 1 tag 4 "dev1"
    { rule = { class = "Gedit" },
    properties = { tag = tags[1][4] } },
    --Mapear thunar a files a screen 1 tag 1 "files"
    { rule = { class = "Thunar" },
    properties = { tag = tags[1][1] } },
    --Mapear cliente idea a dev a screen 1 tag 5 "dev1"
    { rule = { class = "jetbrains-idea-ce" },
    properties = { tag = tags[1][5] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

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

    local titlebars_enabled = false
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

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
