QMK_HOME ?= ${HOME}/qmk_firmware

NAME := charybdis
BOARD := bastardkb/$(NAME)/3x5
#BOARD := atreus

LAYOUT=${QMK_HOME}/keyboards/${BOARD}/keymaps/hall

.PHONY: flash
flash: | ${LAYOUT}
	qmk flash -kb $(BOARD) -km hall

${LAYOUT}:
	ln -s ${PWD}/$(NAME) ${LAYOUT}

.PHONY: clean
clean:
	rm ${LAYOUT}
	qmk clean
