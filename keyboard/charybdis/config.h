#pragma once


/* Disable unused features. */
#define NO_ACTION_ONESHOT

// docs.qmk.fm/using-qmk/software-features/tap_hold
// bit.ly/tap-or-hold
#define TAPPING_TERM 200
#define TAPPING_FORCE_HOLD
#define PERMISSIVE_HOLD
#define IGNORE_MOD_TAP_INTERRUPT

/* Charybdis-specific features. */

#ifdef POINTING_DEVICE_ENABLE
// Enable pointer acceleration, which increases the speed by ~2x for large
// displacement, while maintaining 1x speed for slow movements.  See also:
// - `CHARYBDIS_POINTER_ACCELERATION_FACTOR`
#    define CHARYBDIS_POINTER_ACCELERATION_ENABLE

// Automatically enable the pointer layer when moving the trackball.  See also:
// - `CHARYBDIS_AUTO_POINTER_LAYER_TRIGGER_TIMEOUT_MS`
// - `CHARYBDIS_AUTO_POINTER_LAYER_TRIGGER_THRESHOLD`
// #define CHARYBDIS_AUTO_POINTER_LAYER_TRIGGER_ENABLE
#endif  // POINTING_DEVICE_ENABLE

/* RGB Matrix. */

#ifdef RGB_MATRIX_ENABLE
// Limit maximum brightness to keep power consumption reasonable, and avoid
// disconnects.
#    undef RGB_MATRIX_MAXIMUM_BRIGHTNESS
#    define RGB_MATRIX_MAXIMUM_BRIGHTNESS 64

// Rainbow swirl as startup mode.
#    define ENABLE_RGB_MATRIX_CYCLE_LEFT_RIGHT
#    define RGB_MATRIX_STARTUP_MODE RGB_MATRIX_CYCLE_LEFT_RIGHT

// Slow swirl at startup.
#    define RGB_MATRIX_STARTUP_SPD 32

// Startup values.
#    define RGB_MATRIX_STARTUP_HUE 0
#    define RGB_MATRIX_STARTUP_SAT 255
#    define RGB_MATRIX_STARTUP_VAL RGB_MATRIX_MAXIMUM_BRIGHTNESS
#    define RGB_MATRIX_STARTUP_HSV RGB_MATRIX_STARTUP_HUE, RGB_MATRIX_STARTUP_SAT, RGB_MATRIX_STARTUP_VAL
#endif  // RGB_MATRIX_ENABLE
