#!/bin/bash

set -e

# FONTS=(FreeSerif 'Liberation Serif')
# FONTS_DIR="/usr/share/fonts"
FONTS_DIR="~/.fonts/"
FONTS=(FreeSerif_mod Literaturnaya_lat)
# FONTS=(Literaturnaya_lat)
TEXT=./test1.txt

for font in "${FONTS[@]}"; do
    f=$(echo $font | perl -ne 's/\s+//g; print lc $_')
    text2image --text=$TEXT --outputbase=koi.$f.exp0 --font="$font" --fonts_dir=$FONTS_DIR
    tesseract koi.$f.exp0.tif koi.$f.exp0 box.train.stderr
done

unicharset_extractor koi.*.exp0.box
set_unicharset_properties -F font_properties -U unicharset -O output_unicharset --script_dir=./unicharsets/

shapeclustering -F font_properties -U output_unicharset koi.*.exp0.tr

mftraining -F font_properties -U output_unicharset -O koi.unicharset koi.*.exp0.tr
cntraining koi.*.exp0.tr

cp inttemp koi.inttemp
cp pffmtable koi.pffmtable
cp normproto koi.normproto
cp shapetable koi.shapetable

combine_tessdata koi.
