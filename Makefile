.PHONY: write flash clean

NAME := scroller
MODEL := xc3s500e-5-vq100
FLASHBIT := $(HOME)/Papilio-Loader-2.6/papilio-prog/bscan_spi_xc3s500e.bit

SRCS := hdl/scroller.vhd
UCF := hdl/papilio.ucf

all: build/$(NAME).bit

write: build/$(NAME).bit
	sudo papilio-prog -f $<

flash: build/$(NAME).bit
	sudo papilio-prog -f $< -b $(FLASHBIT) -sa -r

clean:
	rm -rf build/*
	rm -f $(NAME).lso $(NAME)_map.xrpt $(NAME)_par.xrpt
	rm -rf _xmsgs xlnx_auto_0_xdb
	rm -f xilinx_device_details.xml

build/$(NAME).prj: $(SRCS)
	/bin/echo -e >$@ $(patsubst %,vhdl work "%"\\n, $(filter %.vhd, $(SRCS)))

build/$(NAME).xst: build/$(NAME).prj
	@mkdir -p build/xst/projnav.tmp
	@echo >$@ set -xsthdpdir "build/xst"
	@echo >>$@ set -tmpdir "build/xst/projnav.tmp"
	@echo >>$@ run
	@echo >>$@ -ifn $<
	@echo >>$@ -ifmt mixed
	@echo >>$@ -top $(NAME)
	@echo >>$@ -ofn build/$(NAME)
	@echo >>$@ -ofmt NGC
	@echo >>$@ -p $(MODEL)

build/$(NAME).ngc: build/$(NAME).xst
	xst -intstyle silent -ifn $< -ofn build/$(NAME).syr

build/$(NAME).ngd: build/$(NAME).ngc $(UCF)
	ngdbuild -intstyle silent -quiet -uc $(UCF) -p $(MODEL) -dd build/_ngo $< $@

build/$(NAME).ncd: build/$(NAME).ngd
	map -intstyle silent -p $(MODEL) -w -o $@ $<

build/$(NAME).par.ncd: build/$(NAME).ncd
	par -intstyle silent -w $< $@

build/$(NAME).bit: build/$(NAME).par.ncd
	bitgen -intstyle silent -w -g StartUpClk:CClk -g CRC:Enable $< $@
