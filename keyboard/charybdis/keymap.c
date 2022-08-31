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
  LAYER_SYMBOLS,
  LAYER_POINTER,
  LAYER_MEDIA,
  LAYER_EXTRA,
};

enum keycodes {
  WS_LEFT = SAFE_RANGE,
  WS_RGHT,
  TB_LEFT,
  TB_RGHT,
  IM_OPEN,
  VD_OPEN
};

#define P(kc) LT(LAYER_POINTER, kc)
#define SPC_SYM LT(LAYER_SYMBOLS, KC_SPC)
#define BSP_SYM LT(LAYER_SYMBOLS, KC_BSPC)
#define TAB_MED LT(LAYER_MEDIA, KC_TAB)
#define ENT_MED LT(LAYER_MEDIA, KC_ENT)

// clang-format off
const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
  [LAYER_BASE] = LAYOUT_charybdis_3x5(
    DV_QUOT, DV_COMM,  DV_DOT,    DV_P,    DV_Y,     DV_F,     DV_G,    DV_C,    DV_R,    DV_L,
    G(DV_A), A(DV_O), S(DV_E), C(DV_U),    DV_I,     DV_D,  C(DV_H), S(DV_T), A(DV_N), G(DV_S),
 P(DV_SCLN),    DV_Q,    DV_J,    DV_K,    DV_X,     DV_B,     DV_M,    DV_W,    DV_V, P(DV_Z),
                       KC_ESC, SPC_SYM, TAB_MED,   ENT_MED,  BSP_SYM),
  [LAYER_SYMBOLS] = LAYOUT_charybdis_3x5(
     DV_GRV,    KC_7,    KC_8,    KC_9, DV_LBRC,   DV_RBRC, XXXXXXX, XXXXXXX, XXXXXXX, KC_F12,
    DV_MINS,    KC_4,    KC_5,    KC_6, KC_0,      XXXXXXX, KC_LCTL, KC_LSFT, KC_LALT, KC_LGUI,
     DV_EQL,    KC_1,    KC_2,    KC_3, DV_SLSH,   DV_BSLS, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,
                      XXXXXXX, KC_DEL, XXXXXXX,   XXXXXXX, KC_DEL),
  [LAYER_POINTER] = LAYOUT_charybdis_3x5(
    XXXXXXX, XXXXXXX, XXXXXXX, DPI_MOD, S_D_MOD,   S_D_MOD, DPI_MOD, XXXXXXX, XXXXXXX, XXXXXXX,
    KC_LGUI, KC_LALT, KC_LSFT, KC_LCTL, XXXXXXX,   XXXXXXX, KC_LCTL, KC_LSFT, KC_LALT, KC_LGUI,
    _______, DRGSCRL, SNIPING, EEP_RST,   RESET,     RESET, EEP_RST, SNIPING, DRGSCRL, _______,
                      KC_BTN3, KC_BTN1, KC_BTN2,   KC_BTN2, KC_BTN1),
  [LAYER_MEDIA] = LAYOUT_charybdis_3x5(
    XXXXXXX,RGB_RMOD, RGB_TOG, RGB_MOD, TG(LAYER_EXTRA),   KC_BRIU, KC_BRID,RGB_RMOD, RGB_TOG, RGB_MOD,
    KC_LGUI, KC_LALT, KC_LSFT, KC_LCTL, XXXXXXX,   KC_MUTE, KC_LEFT, KC_DOWN,   KC_UP, KC_RGHT,
    KC_MPRV, KC_VOLD, KC_MUTE, KC_VOLU, KC_MNXT,   KC_MPLY, KC_MPRV, KC_VOLD, KC_VOLU, KC_MNXT,
                      XXXXXXX, XXXXXXX, _______,   _______, XXXXXXX),
  [LAYER_EXTRA] = LAYOUT_charybdis_3x5(
    WS_LEFT, XXXXXXX, XXXXXXX, WS_RGHT, TG(LAYER_EXTRA),   XXXXXXX, XXXXXXX,XXXXXXX, XXXXXXX, XXXXXXX,
    KC_LEFT, KC_DOWN,   KC_UP, KC_RGHT, XXXXXXX,   XXXXXXX, KC_LEFT, KC_DOWN,   KC_UP, KC_RGHT,
    TB_LEFT, XXXXXXX, XXXXXXX, TB_RGHT, XXXXXXX,   XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,
                      VD_OPEN, IM_OPEN, _______,   _______, XXXXXXX),
};
// clang-format on

bool process_record_user(uint16_t keycode, keyrecord_t *record) {

  report_mouse_t currentReport = pointing_device_get_report();
  switch (keycode) {
  case WS_LEFT:
    if (record->event.pressed) {
      register_code(KC_LGUI);
      register_code(KC_LALT);
      register_code(KC_LEFT);
    } else {
      unregister_code(KC_LGUI);
      unregister_code(KC_LALT);
      unregister_code(KC_LEFT);
    }
    break;
  case WS_RGHT:
    if (record->event.pressed) {
      register_code(KC_LGUI);
      register_code(KC_LALT);
      register_code(KC_RGHT);
    } else {
      unregister_code(KC_LGUI);
      unregister_code(KC_LALT);
      unregister_code(KC_RGHT);
    }
    break;
  case TB_RGHT:
    if (record->event.pressed) {
      register_code(KC_LCTL);
      register_code(KC_TAB);
    } else {
      unregister_code(KC_LCTL);
      unregister_code(KC_TAB);
    }
    break;
  case TB_LEFT:
    if (record->event.pressed) {
      register_code(KC_LCTL);
      register_code(KC_LSFT);
      register_code(KC_TAB);
    } else {
      unregister_code(KC_LCTL);
      unregister_code(KC_LSFT);
      unregister_code(KC_TAB);
    }
    break;
  case IM_OPEN:
    if (record->event.pressed) {
      currentReport.buttons |= MOUSE_BTN2;
      pointing_device_set_report(currentReport);
      pointing_device_send();
      currentReport.buttons &= ~MOUSE_BTN2;
      pointing_device_set_report(currentReport);
      pointing_device_send();
    } else {
      register_code(KC_DOWN);
      unregister_code(KC_DOWN);
      register_code(KC_ENT);
      unregister_code(KC_ENT);
    }
    break;
  case VD_OPEN:
    if (record->event.pressed) {
      currentReport.buttons |= MOUSE_BTN2;
      pointing_device_set_report(currentReport);
      pointing_device_send();
      currentReport.buttons &= ~MOUSE_BTN2;
      pointing_device_set_report(currentReport);
      pointing_device_send();
    } else {
      register_code(KC_DOWN);
      unregister_code(KC_DOWN);
      register_code(KC_DOWN);
      unregister_code(KC_DOWN);
      register_code(KC_DOWN);
      unregister_code(KC_DOWN);
      register_code(KC_DOWN);
      unregister_code(KC_DOWN);
      register_code(KC_DOWN);
      unregister_code(KC_DOWN);
      register_code(KC_DOWN);
      unregister_code(KC_DOWN);
      register_code(KC_DOWN);
      unregister_code(KC_DOWN);

      register_code(KC_ENT);
      unregister_code(KC_ENT);
    }
    break;
  }
  return true;
}

// Automatically enable sniping-mode on the pointer layer.
layer_state_t layer_state_set_kb(layer_state_t state) {
    state = layer_state_set_user(state);
    charybdis_set_pointer_sniping_enabled(layer_state_cmp(state, LAYER_POINTER));
    return state;
}

// pointer layer active after pointer movement
// #define CHARYBDIS_AUTO_POINTER_LAYER_TRIGGER_ENABLE
// #define CHARYBDIS_AUTO_POINTER_LAYER_TRIGGER_TIMEOUT_MS 500
// #define CHARYBDIS_AUTO_POINTER_LAYER_TRIGGER_THRESHOLD 2
// static uint16_t auto_pointer_layer_timer = 0;

// #ifdef CHARYBDIS_AUTO_POINTER_LAYER_TRIGGER_ENABLE
// #    include "timer.h"
// #endif 


// #ifdef POINTING_DEVICE_ENABLE
// #    ifdef CHARYBDIS_AUTO_POINTER_LAYER_TRIGGER_ENABLE
// report_mouse_t pointing_device_task_user(report_mouse_t mouse_report) {
//     if (abs(mouse_report.x) > CHARYBDIS_AUTO_POINTER_LAYER_TRIGGER_THRESHOLD || abs(mouse_report.y) > CHARYBDIS_AUTO_POINTER_LAYER_TRIGGER_THRESHOLD) {
//         if (auto_pointer_layer_timer == 0) {
//             layer_on(LAYER_POINTER);
// #        ifdef RGB_MATRIX_ENABLE
//             rgb_matrix_mode_noeeprom(RGB_MATRIX_NONE);
//             rgb_matrix_sethsv_noeeprom(HSV_GREEN);
// #        endif  // RGB_MATRIX_ENABLE
//         }
//         auto_pointer_layer_timer = timer_read();
//     }
//     return mouse_report;
// }

// void matrix_scan_kb(void) {
//     if (auto_pointer_layer_timer != 0 && TIMER_DIFF_16(timer_read(), auto_pointer_layer_timer) >= CHARYBDIS_AUTO_POINTER_LAYER_TRIGGER_TIMEOUT_MS) {
//         auto_pointer_layer_timer = 0;
//         layer_off(LAYER_POINTER);
// #        ifdef RGB_MATRIX_ENABLE
//         rgb_matrix_mode_noeeprom(RGB_MATRIX_STARTUP_MODE);
// #        endif  // RGB_MATRIX_ENABLE
//     }
//     matrix_scan_user();
// }
// #    endif  // CHARYBDIS_AUTO_POINTER_LAYER_TRIGGER_ENABLE

// #endif      // POINTING_DEVICE_ENABLE