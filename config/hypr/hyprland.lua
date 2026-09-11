-- Hyprland Lua Configuration (v0.56.2+)
-- Catppuccin Mocha — Exquisite Glassmorphic Developer Environment

------------------
---- MONITORS ----
------------------
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function ()
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("waybar")
    hl.exec_cmd("dunst")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("blueman-applet")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
hl.env("XCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "Catppuccin Mocha Dark")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "Catppuccin Mocha Dark")
hl.env("GTK_THEME", "catppuccin-mocha-blue-standard+default")
hl.env("GTK_ICON_THEME", "Papirus-Dark")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SCREENSHOTS_DIR", "$HOME/Pictures/Screenshots")

-----------------------
---- LOOK AND FEEL ----
-----------------------
hl.config({
    general = {
        gaps_in              = 6,
        gaps_out             = 10,
        border_size          = 2,
        col = {
            active_border    = { colors = {"rgba(89b4faee)", "rgba(cba6f7ee)"}, angle = 135 },
            inactive_border  = "rgba(454759aa)",
        },
        layout               = "dwindle",
        allow_tearing        = false,
    },

    decoration = {
        rounding       = 14,
        rounding_power = 2,

        active_opacity    = 0.92,
        inactive_opacity  = 0.82,
        fullscreen_opacity = 1.0,

        shadow = {
            enabled       = true,
            range         = 8,
            render_power  = 4,
            color         = "rgba(11111b99)",
            offset        = "0, 4",
            scale         = 1,
        },

        blur = {
            enabled        = true,
            size           = 14,
            passes         = 5,
            vibrancy       = 0.18,
            contrast       = 1.1,
            brightness     = 0.95,
            noise          = 0.025,
            xray           = false,
            ignore_opacity = true,
            popups         = true,
            popups_ignorealpha = 0.15,
        },

        dim_inactive     = true,
        dim_strength     = 0.15,
    },

    animations = {
        enabled = true,
    },
})

-- ── Curves ───────────────────────────────────────────────
hl.curve("easeOutQuint",    { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic",  { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",          { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",    { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",           { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })

-- ── Springs ──────────────────────────────────────────────
hl.curve("default",         { type = "spring", mass = 1, stiffness = 238.1191, dampening = 24.21279333 })
hl.curve("easy",            { type = "spring", mass = 1, stiffness = 120,      dampening = 14 })

-- ── Animations ───────────────────────────────────────────
hl.animation({ leaf = "global",        enabled = true,  speed = 12,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true,  speed = 6,    bezier = "easeOutQuint" })
hl.animation({ leaf = "borderangle",   enabled = true,  speed = 8,    bezier = "easeOutQuint" })

hl.animation({ leaf = "windows",       enabled = true,  speed = 5,    spring = "easy" })
hl.animation({ leaf = "windowsIn",     enabled = true,  speed = 4.5,  spring = "easy",         style = "popin 85%" })
hl.animation({ leaf = "windowsOut",    enabled = true,  speed = 1.6,  bezier = "linear",       style = "popin 85%" })

hl.animation({ leaf = "fadeIn",        enabled = true,  speed = 2,    bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true,  speed = 1.5,  bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true,  speed = 3.5,  bezier = "quick" })

hl.animation({ leaf = "layers",        enabled = true,  speed = 4,    bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true,  speed = 4.5,  bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true,  speed = 1.6,  bezier = "linear",       style = "fade" })

hl.animation({ leaf = "fadeLayersIn",  enabled = true,  speed = 2,    bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true,  speed = 1.5,  bezier = "almostLinear" })

hl.animation({ leaf = "workspaces",    enabled = true,  speed = 2.2,  bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true,  speed = 2.2,  bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true,  speed = 2.2,  bezier = "almostLinear", style = "fade" })

hl.animation({ leaf = "zoomFactor",    enabled = true,  speed = 8,    bezier = "quick" })

-----------------------
---- LAYOUTS --------
-----------------------
hl.config({
    dwindle = {
        preserve_split = true,
        force_split    = 2,
        pseudotile     = true,
    },
})

hl.config({
    master = {
        new_status    = "master",
        new_on_top    = true,
        mfact         = 0.55,
    },
})

-----------------
----  MISC  ----
-----------------
hl.config({
    misc = {
        force_default_wallpaper    = 0,
        disable_hyprland_logo      = true,
        disable_splash_rendering   = true,
        new_window_takes_over_fullscreen = 2,
    },
})

---------------
---- INPUT ----
---------------
hl.config({
    input = {
        kb_layout      = "us",
        follow_mouse   = 1,
        sensitivity    = 0,
        accel_profile  = "flat",
        touchpad = {
            natural_scroll = false,
        },
    },
})

hl.gesture({
    fingers  = 3,
    direction = "horizontal",
    action   = "workspace",
})

hl.gesture({
    fingers  = 4,
    direction = "vertical",
    action   = "workspace",
})

hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})

---------------------
---- KEYBINDINGS ----
---------------------
local mainMod = "SUPER"

-- Terminals
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("alacritty"))

-- App Launchers & Command Hub
hl.bind(mainMod .. " + A",         hl.dsp.exec_cmd("/home/shaheer/.config/rofi/scripts/runner-menu.sh"))
hl.bind(mainMod .. " + R",         hl.dsp.exec_cmd("rofi -show run"))
hl.bind(mainMod .. " + D",         hl.dsp.exec_cmd("rofi -show drun"))
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.exec_cmd("rofi -show window"))
hl.bind(mainMod .. " + ALT + D",   hl.dsp.exec_cmd("rofi -show ssh"))

-- Window Actions
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + C",         hl.dsp.exec_cmd("qalculate-gtk || gnome-calculator || kitty --class calc -e python3 -q"))
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.window.close())

-- File Managers
hl.bind(mainMod .. " + E",         hl.dsp.exec_cmd("thunar"))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd("kitty -e yazi"))

-- Browsers
hl.bind(mainMod .. " + W",         hl.dsp.exec_cmd("firefox"))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("brave-browser"))

-- Code Editors
hl.bind(mainMod .. " + V",         hl.dsp.exec_cmd("code"))
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("kitty -e nvim"))

-- Screenshots (rofi menu)
hl.bind("Print",                   hl.dsp.exec_cmd("/home/shaheer/.config/rofi/scripts/screenshot-menu.sh"))
hl.bind("SHIFT + Print",           hl.dsp.exec_cmd("grim - | wl-copy && notify-send 'Screenshot' 'Copied to clipboard'"))
hl.bind(mainMod .. " + Print",     hl.dsp.exec_cmd("/home/shaheer/.config/rofi/scripts/screenshot-menu.sh"))

-- Window State & Layout
hl.bind(mainMod .. " + F",         hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P",         hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J",         hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + SPACE",     hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mainMod .. " + T",         hl.dsp.exec_cmd("kitty -e tmux new-session -A -s main"))
hl.bind(mainMod .. " + G",         hl.dsp.exec_cmd("xdg-open https://www.google.com"))
hl.bind(mainMod .. " + SHIFT + G", hl.dsp.exec_cmd("hyprctl dispatch lockgroups toggle"))

-- Navigation (Focus)
hl.bind(mainMod .. " + left",      hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right",     hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",        hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",      hl.dsp.focus({ direction = "down" }))

-- Window Movement (Shift + Arrows)
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.exec_cmd("hyprctl dispatch movewindow l"))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.exec_cmd("hyprctl dispatch movewindow r"))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.exec_cmd("hyprctl dispatch movewindow u"))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.exec_cmd("hyprctl dispatch movewindow d"))

-- Window Resizing (Ctrl + Arrows)
hl.bind(mainMod .. " + CTRL + left",   hl.dsp.exec_cmd("hyprctl dispatch resizeactive -30 0"))
hl.bind(mainMod .. " + CTRL + right",  hl.dsp.exec_cmd("hyprctl dispatch resizeactive 30 0"))
hl.bind(mainMod .. " + CTRL + up",     hl.dsp.exec_cmd("hyprctl dispatch resizeactive 0 -30"))
hl.bind(mainMod .. " + CTRL + down",   hl.dsp.exec_cmd("hyprctl dispatch resizeactive 0 30"))

-- Workspaces 1-10
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end

-- Scratchpad (Magic Workspace)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Mouse Binds
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Hardware & Media Keys
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })
hl.bind("XF86AudioNext",        hl.dsp.exec_cmd("playerctl next"),                                 { locked = true })
hl.bind("XF86AudioPause",       hl.dsp.exec_cmd("playerctl play-pause"),                            { locked = true })
hl.bind("XF86AudioPlay",        hl.dsp.exec_cmd("playerctl play-pause"),                            { locked = true })
hl.bind("XF86AudioPrev",        hl.dsp.exec_cmd("playerctl previous"),                             { locked = true })

-- Panel & System Shortcuts
hl.bind(mainMod .. " + CTRL + W",  hl.dsp.exec_cmd("/home/shaheer/.config/hypr/scripts/wallpaper-menu.sh"))
hl.bind(mainMod .. " + ALT + W",   hl.dsp.exec_cmd("/home/shaheer/.config/hypr/scripts/wallpaper-rotate.sh"))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("pkill waybar; setsid waybar &; notify-send 'Waybar' 'Reloaded successfully'"))

hl.bind(mainMod .. " + Escape",    hl.dsp.exec_cmd("/home/shaheer/.config/rofi/scripts/power-menu.sh"))
hl.bind(mainMod .. " + H",         hl.dsp.exec_cmd("xdg-open http://127.0.0.1:7777"))
hl.bind(mainMod .. " + ALT + M",   hl.dsp.exec_cmd("hyprctl dispatch exit"))

-- Cognitive Velocity & Quick Modals
hl.bind(mainMod .. " + I",         hl.dsp.exec_cmd("/home/shaheer/.config/rofi/scripts/capture-menu.sh"))
hl.bind(mainMod .. " + SHIFT + I", hl.dsp.exec_cmd("kitty --class capture -e /home/shaheer/.local/bin/capture"))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("kitty --class proj -e /home/shaheer/.local/bin/proj"))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.exec_cmd("kitty --class focus -e /home/shaheer/.local/bin/focus 25"))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.exec_cmd("kitty --class cheat -e /home/shaheer/.local/bin/cheat"))
hl.bind(mainMod .. " + slash",     hl.dsp.exec_cmd("kitty --class cheat -e /home/shaheer/.local/bin/cheat"))
hl.bind(mainMod .. " + ALT + L",   hl.dsp.exec_cmd("kitty --class mastery -e /home/shaheer/.local/bin/mastery connect"))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("kitty --class scratch -e /home/shaheer/.local/bin/scratch"))
hl.bind(mainMod .. " + X",         hl.dsp.exec_cmd("/home/shaheer/.config/rofi/scripts/clipboard-menu.sh"))
hl.bind(mainMod .. " + N",         hl.dsp.exec_cmd("/home/shaheer/.config/rofi/scripts/wifi-menu.sh"))
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd("/home/shaheer/.config/rofi/scripts/bluetooth-menu.sh"))
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd("/home/shaheer/.config/rofi/scripts/player-menu.sh"))
hl.bind(mainMod .. " + EQUAL",     hl.dsp.exec_cmd("/home/shaheer/.config/rofi/scripts/brightness-menu.sh"))

-- Lockscreen
hl.bind(mainMod .. " + L",         hl.dsp.exec_cmd("hyprlock"))
hl.bind("CTRL + ALT + Delete",    hl.dsp.exec_cmd("loginctl lock-session"))

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- Float rules
hl.window_rule({ name = "float-pavucontrol", match = { class = "pavucontrol" }, float = true })
hl.window_rule({ name = "float-blueman",     match = { class = "blueman-manager" }, float = true })
hl.window_rule({ name = "float-nm-editor",   match = { class = "nm-connection-editor" }, float = true })
hl.window_rule({ name = "float-thunar",      match = { class = "Thunar" }, float = true })
hl.window_rule({ name = "float-file-roller", match = { class = "File-roller" }, float = true })
hl.window_rule({ name = "float-imv",         match = { class = "imv" }, float = true })
hl.window_rule({ name = "float-mpv",         match = { class = "mpv" }, float = true })
hl.window_rule({ name = "float-yad",         match = { class = "yad" }, float = true })
hl.window_rule({ name = "float-obsidian",    match = { class = "obsidian" }, float = true, size = {1200, 800} })
hl.window_rule({ name = "float-calculator",  match = { class = "gnome-calculator" }, float = true })
hl.window_rule({ name = "float-virt-mgr",    match = { class = "virt-manager" }, float = true, size = {1000, 700} })
hl.window_rule({ name = "float-qalculate",   match = { class = "qalculate-gtk" }, float = true })
hl.window_rule({ name = "float-file-picker", match = { title = "Open File" }, float = true })
hl.window_rule({ name = "float-save-picker", match = { title = "Save File" }, float = true })
hl.window_rule({ name = "float-dir-picker",  match = { title = "Open Folder" }, float = true })
hl.window_rule({ name = "float-pip",         match = { title = "Picture-in-Picture" }, float = true, pin = true })

-- Modals & Cognitive Tools
hl.window_rule({ name = "float-proj",        match = { class = "proj" }, float = true, size = {900, 500} })
hl.window_rule({ name = "float-focus",       match = { class = "focus" }, float = true, size = {750, 350} })
hl.window_rule({ name = "float-cheat",       match = { class = "cheat" }, float = true, size = {950, 550} })
hl.window_rule({ name = "float-scratch",     match = { class = "scratch" }, float = true, size = {850, 520} })
hl.window_rule({ name = "float-capture",     match = { class = "capture" }, float = true, size = {800, 400} })
hl.window_rule({ name = "float-mastery",     match = { class = "mastery" }, float = true, size = {950, 600} })
hl.window_rule({ name = "float-think",       match = { class = "think" }, float = true, size = {950, 600} })
hl.window_rule({ name = "float-health",      match = { class = "health" }, float = true, size = {900, 580} })
hl.window_rule({ name = "float-clean",       match = { class = "clean" }, float = true, size = {850, 500} })
hl.window_rule({ name = "float-calc",        match = { class = "calc" }, float = true, size = {600, 400} })

-- Browser opacity
hl.window_rule({ name = "opacity-firefox",   match = { class = "firefox" }, opacity = 0.90 })
hl.window_rule({ name = "opacity-brave",     match = { class = "Brave-browser" }, opacity = 0.90 })

-- IDE opacity
hl.window_rule({ name = "opacity-code",      match = { class = "Code" }, opacity = 0.88 })
hl.window_rule({ name = "opacity-code-oss",  match = { class = "code-oss" }, opacity = 0.88 })
hl.window_rule({ name = "opacity-cursor",    match = { class = "Cursor" }, opacity = 0.88 })

-- Terminal opacity
hl.window_rule({ name = "opacity-kitty",     match = { class = "kitty" }, opacity = 0.82 })
hl.window_rule({ name = "opacity-alacritty", match = { class = "Alacritty" }, opacity = 0.82 })
