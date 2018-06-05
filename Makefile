SHELL := /bin/bash
TEXT = ./test1.txt
FONTS_DIR = ./fonts/
fonts = FreeSerif_mod Literaturnaya_lat

include marker

marker: Makefile
	@touch $@
	$(MAKE) clean
	$(MAKE)

all: koi.traineddata

koi.%.exp0.box koi.%.exp0.tif: $(TEXT)
	text2image --text=$(TEXT) --outputbase="koi.$*.exp0" --font="$*" --fonts_dir=$(FONTS_DIR)

koi.%.exp0.tr: koi.%.exp0.tif
	tesseract $^ koi.$*.exp0 box.train.stderr

unicharset: $(foreach font,$(fonts),koi.$(font).exp0.box)
	unicharset_extractor $^

output_unicharset: unicharset
	set_unicharset_properties -F font_properties -U $^ -O $@ --script_dir=./unicharsets/

shapetable: output_unicharset $(foreach font,$(fonts),koi.$(font).exp0.tr)
	shapeclustering -F font_properties -U $< $(filter-out $<,$^)

koi.unicharset inttemp pffmtable: output_unicharset $(foreach font,$(fonts),koi.$(font).exp0.tr)
	mftraining -F font_properties -U $< -O koi.unicharset $(filter-out $<,$^)

normproto: $(foreach font,$(fonts),koi.$(font).exp0.tr)
	cntraining $^

koi.%: %
	cp $* $@

koi.traineddata: koi.shapetable koi.inttemp koi.pffmtable koi.normproto koi.unicharset
	combine_tessdata koi.

prepare: unicharsets font_config

unicharsets:
	mkdir -p unicharsets
	cd unicharsets && wget -c https://raw.githubusercontent.com/tesseract-ocr/langdata/master/{Common,Cyrillic,Latin}.unicharset

font_config:
	wget -c https://raw.githubusercontent.com/tesseract-ocr/langdata/master/font_properties

clean:
	rm -f *inttemp *pffmtable *normproto *shapetable *unicharset *tr *tif *box *traineddata
