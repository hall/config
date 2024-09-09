/* Taken from https://github.com/djpohly/dwl/issues/466 */
#define COLOR(hex)    { ((hex >> 24) & 0xFF) / 255.0f, \
                        ((hex >> 16) & 0xFF) / 255.0f, \
                        ((hex >> 8) & 0xFF) / 255.0f, \
                        (hex & 0xFF) / 255.0f }
/* appearance */
static const int sloppyfocus               = 1;  /* focus follows mouse */
static const int bypass_surface_visibility = 0;  /* 1 means idle inhibitors will disable idle tracking even if it's surface isn't visible  */
static const unsigned int borderpx         = 1;  /* border pixel of windows */
//static const float rootcolor[]             = COLOR(0x222222ff);
//static const float bordercolor[]           = COLOR(0x444444ff);
//static const float focuscolor[]            = COLOR(0x005577ff);
//static const float urgentcolor[]           = COLOR(0xff0000ff);
static const int showbar                   = 1; /* 0 means no bar */
static const int topbar                    = 1; /* 0 means bottom bar */
static const char *fonts[]                 = {"monospace:size=10"};
static const float rootcolor[]             = COLOR(0x000000ff);
/* This conforms to the xdg-protocol. Set the alpha to zero to restore the old behavior */
static const float fullscreen_bg[]         = {0.1f, 0.1f, 0.1f, 1.0f}; /* You can also use glsl colors */

static uint32_t colors[][3]                = {
    /*               fg          bg          border    */
    [SchemeNorm] = { 0xbbbbbbff, 0x222222ff, 0x444444ff },
    [SchemeSel]  = { 0xeeeeeeff, 0x005577ff, 0x005577ff },
    [SchemeUrg]  = { 0,          0,          0x770000ff },
};

static char *tags[] = { "1", "2", "3" };

static int log_level = WLR_ERROR;

/* NOTE: ALWAYS keep a rule declared even if you don't use rules (e.g leave at least one example) */
static const Rule rules[] = {
    /* app_id             title       tags mask     isfloating   monitor */
    { "Gimp_EXAMPLE",     NULL,       0,            1,           -1 }, /* Start on currently visible tags floating, not tiled */
    { "firefox_EXAMPLE",  NULL,       1 << 8,       0,           -1 }, /* Start on ONLY tag "9" */
};

/* layout(s) */
static const Layout layouts[] = {
    /* symbol     arrange function */
    { "[]=",      tile },
    { "><>",      NULL },    /* no layout function means floating behavior */
    { "[M]",      monocle },
};

/* monitors */
static const MonitorRule monrules[] = {
    /* name       mfact  nmaster scale layout       rotate/reflect                x    y */
    { "eDP-1",    0.55f, 1,      1,    &layouts[0], WL_OUTPUT_TRANSFORM_NORMAL,   0,   0 },
    { "DP-5",     0.55f, 1,      1,    &layouts[0], WL_OUTPUT_TRANSFORM_NORMAL,   0, -1080 },
    { "DP-6",     0.55f, 1,      1,    &layouts[0], WL_OUTPUT_TRANSFORM_270,  -1080, -1080 },
};

static const struct xkb_rule_names xkb_rules = {
    .layout = "us",
    .variant = "dvorak",
    //.options = "ctrl:nocaps",
};

static const int repeat_rate = 50;
static const int repeat_delay = 200;

/* Trackpad */
static const int tap_to_click = 1;
static const int tap_and_drag = 1;
static const int drag_lock = 1;
static const int natural_scrolling = 1;
static const int disable_while_typing = 1;
static const int left_handed = 0;
static const int middle_button_emulation = 0;

static const enum libinput_config_scroll_method scroll_method = LIBINPUT_CONFIG_SCROLL_2FG;
static const enum libinput_config_click_method click_method = LIBINPUT_CONFIG_CLICK_METHOD_CLICKFINGER;
static const uint32_t send_events_mode = LIBINPUT_CONFIG_SEND_EVENTS_ENABLED;
static const enum libinput_config_accel_profile accel_profile = LIBINPUT_CONFIG_ACCEL_PROFILE_ADAPTIVE;
static const double accel_speed = 0.0;
static const enum libinput_config_tap_button_map button_map = LIBINPUT_CONFIG_TAP_MAP_LRM;

#define MODKEY WLR_MODIFIER_ALT //_LOGO

#define TAGKEYS(KEY,SKEY,TAG) \
    { MODKEY,                    KEY,            view,            {.ui = 1 << TAG} }, \
    { MODKEY|WLR_MODIFIER_CTRL,  KEY,            toggleview,      {.ui = 1 << TAG} }, \
    { MODKEY|WLR_MODIFIER_SHIFT, SKEY,           tag,             {.ui = 1 << TAG} }, \
    { MODKEY|WLR_MODIFIER_CTRL|WLR_MODIFIER_SHIFT,SKEY,toggletag, {.ui = 1 << TAG} }

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
static const char *termcmd[] = { "foot", NULL };
static const char *menucmd[] = { "wmenu-run", NULL };
static const char *lockcmd[] = { "waylock", NULL };

static const Key keys[] = {
    /* modifier                     key                       function        argument */
    { MODKEY,                    XKB_KEY_p,          spawn,          {.v = menucmd} },
    { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_Return,     spawn,          {.v = termcmd} },
    { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_P,          spawn,          {.v = lockcmd} },
    { MODKEY,                    XKB_KEY_b,          togglebar,      {0} },
    { MODKEY,                    XKB_KEY_j,          focusstack,     {.i = +1} },
    { MODKEY,                    XKB_KEY_k,          focusstack,     {.i = -1} },
    { MODKEY,                    XKB_KEY_i,          incnmaster,     {.i = +1} },
    { MODKEY,                    XKB_KEY_d,          incnmaster,     {.i = -1} },
    { MODKEY,                    XKB_KEY_h,          setmfact,       {.f = -0.05f} },
    { MODKEY,                    XKB_KEY_l,          setmfact,       {.f = +0.05f} },
    { MODKEY,                    XKB_KEY_Return,     zoom,           {0} },
    { MODKEY,                    XKB_KEY_Tab,        view,           {0} },
    { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_C,          killclient,     {0} },
    { MODKEY,                    XKB_KEY_t,          setlayout,      {.v = &layouts[0]} },
    { MODKEY,                    XKB_KEY_f,          setlayout,      {.v = &layouts[1]} },
    { MODKEY,                    XKB_KEY_m,          setlayout,      {.v = &layouts[2]} },
    { MODKEY,                    XKB_KEY_space,      setlayout,      {0} },
    { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_space,      togglefloating, {0} },
    { MODKEY,                    XKB_KEY_e,          togglefullscreen, {0} },
    { MODKEY,                    XKB_KEY_0,          view,           {.ui = ~0} },
    { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_parenright, tag,            {.ui = ~0} },
    { MODKEY,                    XKB_KEY_comma,      focusmon,       {.i = WLR_DIRECTION_LEFT} },
    { MODKEY,                    XKB_KEY_period,     focusmon,       {.i = WLR_DIRECTION_RIGHT} },
    { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_less,       tagmon,         {.i = WLR_DIRECTION_LEFT} },
    { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_greater,    tagmon,         {.i = WLR_DIRECTION_RIGHT} },
    TAGKEYS(          XKB_KEY_1, XKB_KEY_exclam,                     0),
    TAGKEYS(          XKB_KEY_2, XKB_KEY_at,                         1),
    TAGKEYS(          XKB_KEY_3, XKB_KEY_numbersign,                 2),
    TAGKEYS(          XKB_KEY_4, XKB_KEY_dollar,                     3),
    TAGKEYS(          XKB_KEY_5, XKB_KEY_percent,                    4),
    TAGKEYS(          XKB_KEY_6, XKB_KEY_asciicircum,                5),
    TAGKEYS(          XKB_KEY_7, XKB_KEY_ampersand,                  6),
    TAGKEYS(          XKB_KEY_8, XKB_KEY_asterisk,                   7),
    TAGKEYS(          XKB_KEY_9, XKB_KEY_parenleft,                  8),
    { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_Q,          quit,           {0} },

    /* Ctrl-Alt-Backspace and Ctrl-Alt-Fx used to be handled by X server */
    { WLR_MODIFIER_CTRL|WLR_MODIFIER_ALT,XKB_KEY_Terminate_Server, quit, {0} },
    /* Ctrl-Alt-Fx is used to switch to another VT */
#define CHVT(n) { WLR_MODIFIER_CTRL|WLR_MODIFIER_ALT,XKB_KEY_XF86Switch_VT_##n, chvt, {.ui = (n)} }
    CHVT(1), CHVT(2), CHVT(3), CHVT(4), CHVT(5), CHVT(6),
    CHVT(7), CHVT(8), CHVT(9), CHVT(10), CHVT(11), CHVT(12),
};

static const Button buttons[] = {
//	{ MODKEY, BTN_LEFT,   moveresize,     {.ui = CurMove} },
//	{ MODKEY, BTN_MIDDLE, togglefloating, {0} },
//	{ MODKEY, BTN_RIGHT,  moveresize,     {.ui = CurResize} },
    { ClkLtSymbol, 0,      BTN_LEFT,   setlayout,      {.v = &layouts[0]} },
    { ClkLtSymbol, 0,      BTN_RIGHT,  setlayout,      {.v = &layouts[2]} },
    { ClkTitle,    0,      BTN_MIDDLE, zoom,           {0} },
    { ClkStatus,   0,      BTN_MIDDLE, spawn,          {.v = termcmd} },
    { ClkClient,   MODKEY, BTN_LEFT,   moveresize,     {.ui = CurMove} },
    { ClkClient,   MODKEY, BTN_MIDDLE, togglefloating, {0} },
    { ClkClient,   MODKEY, BTN_RIGHT,  moveresize,     {.ui = CurResize} },
    { ClkTagBar,   0,      BTN_LEFT,   view,           {0} },
    { ClkTagBar,   0,      BTN_RIGHT,  toggleview,     {0} },
    { ClkTagBar,   MODKEY, BTN_LEFT,   tag,            {0} },
    { ClkTagBar,   MODKEY, BTN_RIGHT,  toggletag,      {0} },
};

