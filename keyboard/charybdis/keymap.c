#include QMK_KEYBOARD_H
#include "keymap_dvorak.h"

// redefine GASC as mod-tap variants
#undef G
#define G(kc) GUI_T(kc)
#undef A
#define A(kc) ALT_T(kc)
#undef S
#define S(kc) SFT_T(kc)
#undef C
#define C(kc) CTL_T(kc)

enum layers {
    LAYER_BASE,
    LAYER_POINTER,
    LAYER_MEDIA,
    LAYER_SYMBOLS,
    LAYER_NUMERAL,
};

#define P(kc)    LT(LAYER_POINTER, kc)
#define SPC_SYM  LT(LAYER_SYMBOLS, KC_SPC)
#define TAB_MED  LT(LAYER_MEDIA,   KC_TAB)
#define BSP_NUM  LT(LAYER_NUMERAL, KC_BSPC)

#define LAYOUT(...) LAYOUT_charybdis_3x5(__VA_ARGS__)

// clang-format off
const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
  [LAYER_BASE] = LAYOUT(
    DV_QUOT, DV_COMM, DV_DOT,  DV_P,    DV_Y,      DV_F,    DV_G,    DV_C,    DV_R,    DV_L,    \
  G(DV_A), A(DV_O), S(DV_E), C(DV_U),   DV_I,      DV_D,  C(DV_H), S(DV_T), A(DV_N), G(DV_S),   \
  P(DV_SCLN),DV_Q,    DV_J,    DV_K,    DV_X,      DV_B,    DV_M,    DV_W,    DV_V,  P(DV_Z),   \
                      KC_ESC,  SPC_SYM, TAB_MED,   KC_ENT, BSP_NUM),
  [LAYER_POINTER] = LAYOUT(
    XXXXXXX, XXXXXXX, XXXXXXX, DPI_MOD, S_D_MOD,   S_D_MOD, DPI_MOD, XXXXXXX, XXXXXXX, XXXXXXX, \
    KC_LGUI, KC_LALT, KC_LSFT, KC_LCTL, XXXXXXX,   XXXXXXX, KC_LCTL, KC_LSFT, KC_LALT, KC_LGUI, \
    _______, DRGSCRL, SNIPING, EEP_RST,   RESET,     RESET, EEP_RST, SNIPING, DRGSCRL, _______, \
                      KC_BTN2, KC_BTN1, KC_BTN3,   KC_BTN3, KC_BTN1),
  [LAYER_MEDIA] = LAYOUT(
    XXXXXXX,RGB_RMOD, RGB_TOG, RGB_MOD, XXXXXXX,   KC_BRIU, KC_BRID, RGB_RMOD,RGB_TOG, RGB_MOD, \
    KC_LGUI, KC_LALT, KC_LSFT, KC_LCTL, XXXXXXX,   KC_MUTE, KC_LEFT, KC_DOWN,   KC_UP, KC_RGHT, \
    KC_MPRV, KC_VOLD, KC_MUTE, KC_VOLU, KC_MNXT,   KC_MPLY, KC_MPRV, KC_VOLD, KC_VOLU, KC_MNXT, \
                      XXXXXXX, XXXXXXX, _______,   XXXXXXX, XXXXXXX),
  [LAYER_SYMBOLS] = LAYOUT(
    DV_TILD, DV_AMPR, DV_ASTR, DV_PIPE, DV_LCBR,   DV_RCBR, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, \
    DV_GRV,  DV_DLR,  DV_PERC, DV_CIRC, DV_LBRC,   DV_RBRC, KC_LCTL, KC_LSFT, KC_LALT, KC_LGUI, \
    DV_UNDS, DV_EXLM, DV_AT,   DV_HASH, DV_LPRN,   DV_RPRN, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, \
                      XXXXXXX, _______, XXXXXXX,   XXXXXXX, XXXXXXX),
  [LAYER_NUMERAL] = LAYOUT(
    DV_PLUS, KC_7,    KC_8,    KC_9,    DV_BSLS,   XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, \
    DV_MINS, KC_4,    KC_5,    KC_6,    XXXXXXX,   XXXXXXX, KC_LCTL, KC_LSFT, KC_LALT, KC_LGUI, \
     DV_EQL, KC_1,    KC_2,    KC_3,    DV_SLSH,   XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, \
                      XXXXXXX, KC_0,    XXXXXXX,   XXXXXXX, _______),
};
// clang-format on

#ifdef CHARYBDIS_AUTO_POINTER_LAYER_TRIGGER_ENABLE
#    include "timer.h"
#endif

// Automatically enable sniping-mode on the pointer layer.
#define CHARYBDIS_AUTO_SNIPING_ON_LAYER LAYER_POINTER

#ifdef CHARYBDIS_AUTO_POINTER_LAYER_TRIGGER_ENABLE
static uint16_t auto_pointer_layer_timer = 0;
#    ifndef CHARYBDIS_AUTO_POINTER_LAYER_TRIGGER_TIMEOUT_MS
#        define CHARYBDIS_AUTO_POINTER_LAYER_TRIGGER_TIMEOUT_MS 1000
#    endif
#    ifndef CHARYBDIS_AUTO_POINTER_LAYER_TRIGGER_THRESHOLD
#        define CHARYBDIS_AUTO_POINTER_LAYER_TRIGGER_THRESHOLD 8
#    endif
#endif

#ifdef POINTING_DEVICE_ENABLE
#    ifdef CHARYBDIS_AUTO_POINTER_LAYER_TRIGGER_ENABLE
report_mouse_t pointing_device_task_user(report_mouse_t mouse_report) {
    if (abs(mouse_report.x) > CHARYBDIS_AUTO_POINTER_LAYER_TRIGGER_THRESHOLD || abs(mouse_report.y) > CHARYBDIS_AUTO_POINTER_LAYER_TRIGGER_THRESHOLD) {
        if (auto_pointer_layer_timer == 0) {
            layer_on(LAYER_POINTER);
#        ifdef RGB_MATRIX_ENABLE
            rgb_matrix_mode_noeeprom(RGB_MATRIX_NONE);
            rgb_matrix_sethsv_noeeprom(HSV_GREEN);
#        endif
        }
        auto_pointer_layer_timer = timer_read();
    }
    return mouse_report;
}

void matrix_scan_kb(void) {
    if (auto_pointer_layer_timer != 0 && TIMER_DIFF_16(timer_read(), auto_pointer_layer_timer) >= CHARYBDIS_AUTO_POINTER_LAYER_TRIGGER_TIMEOUT_MS) {
        auto_pointer_layer_timer = 0;
        layer_off(LAYER_POINTER);
#        ifdef RGB_MATRIX_ENABLE
        rgb_matrix_mode_noeeprom(RGB_MATRIX_STARTUP_MODE);
#        endif
    }
    matrix_scan_user();
}
#    endif

#    ifdef CHARYBDIS_AUTO_SNIPING_ON_LAYER
layer_state_t layer_state_set_kb(layer_state_t state) {
    state = layer_state_set_user(state);
    charybdis_set_pointer_sniping_enabled(layer_state_cmp(state, CHARYBDIS_AUTO_SNIPING_ON_LAYER));
    return state;
}
#    endif
#endif

#ifdef RGB_MATRIX_ENABLE
// Forward-declare this helper function since it is defined in rgb_matrix.c.
void rgb_matrix_update_pwm_buffers(void);
#endif

void shutdown_user(void) {
#ifdef RGBLIGHT_ENABLE
    rgblight_enable_noeeprom();
    rgblight_mode_noeeprom(RGBLIGHT_MODE_STATIC_LIGHT);
    rgblight_setrgb_red();
#endif
#ifdef RGB_MATRIX_ENABLE
    rgb_matrix_set_color_all(RGB_RED);
    rgb_matrix_update_pwm_buffers();
#endif
}
