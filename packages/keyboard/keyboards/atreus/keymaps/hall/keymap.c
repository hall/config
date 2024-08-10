#include QMK_KEYBOARD_H
#include "keymap_dvorak.h"

#define LEADER_PER_KEY_TIMING
#define LEADER_TIMEOUT 300

// aliases
#define L_OUTER MT(MOD_LALT, KC_DEL)
#define L_THUMB LT(MO(1), KC_BSPC)
#define L_INNER MT(MOD_LCTL, KC_ESC)
#define R_INNER MT(MOD_LSFT, KC_ENT)
#define R_THUMB LT(MO(2), KC_SPC)
#define R_OUTER MT(MOD_LGUI, KC_TAB)

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
    LAYOUT(
        DV_QUOT, DV_COMM, DV_DOT,  DV_P,    DV_Y,                      DV_F,    DV_G,    DV_C,    DV_R,    DV_L,
        DV_A,    DV_O,    DV_E,    DV_U,    DV_I,                      DV_D,    DV_H,    DV_T,    DV_N,    DV_S,
        DV_SCLN, DV_Q,    DV_J,    DV_K,    DV_X,                      DV_B,    DV_M,    DV_W,    DV_V,    DV_Z,
        KC_F12, TO(3),   KC_HYPR, L_OUTER, L_THUMB, L_INNER, R_INNER, R_THUMB, R_OUTER, MOD_MEH, _______, _______),
    LAYOUT(
        DV_GRV,  DV_EXLM, DV_AT,   DV_HASH, DV_LBRC,                   DV_RBRC, DV_0,    DV_1,    DV_2,    DV_3,
        DV_DLR,  DV_PERC, DV_CIRC, DV_AMPR, DV_LPRN,                   DV_RPRN, DV_4,    DV_5,    DV_6,    DV_7,
        DV_ASTR, DV_MINS, DV_EQL,  _______, DV_SLSH,                   DV_BSLS, DV_8,    DV_9,    UC(0x218A), UC(0x218B),
        _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______),
    LAYOUT(
        KC_WH_U, KC_BTN3, KC_MS_U, KC_BTN1, KC_BTN2,                   KC_MUTE, _______, KC_UP,   _______, QK_BOOT,
        KC_WH_D, KC_MS_L, KC_MS_D, KC_MS_R, KC_BRIU,                   KC_VOLU, KC_LEFT, KC_DOWN, KC_RIGHT, _______,
        _______, _______, _______, _______, KC_BRID,                   KC_VOLD, KC_MPRV, KC_MPLY, KC_MNXT, _______,
        _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______),
    LAYOUT(
        MI_OCTU, MI_MODSU, MI_TRNSU, MI_MOD,  MI_SUST,                   _______, MI_C,    MI_Cs,   MI_D,    MI_Ds,
        MI_OCTD, MI_MODSD, MI_TRNSD, _______, _______,                   _______, MI_E,    MI_F,    MI_Fs,   MI_G,
        _______, _______,  _______,  _______, _______,                   _______, MI_Gs,   MI_A,    MI_As,   MI_B,
        _______, TO(0),    _______,  _______, _______, _______, _______, _______, _______, _______, _______, _______),
};

