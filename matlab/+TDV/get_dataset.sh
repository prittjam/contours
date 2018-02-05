#!/bin/bash
wget=/usr/bin/wget
datasets=("duomo" "ahus" "Alcatraz_courtyard" "water_tower" "lund_cath_large" "house" "uwo_large" "pumpkin" "GustavIIAdolf" "LUsphinx" "Buddah" "vercingetorix" "san_marco" "de_guerre" "eglise" "UofT" "nijo" "urbanII" "ahlstromer" "barcelona_cath" "fountain" "linkoping_dkyrka" "doge_palace" "eglise_int" "gbg" "kazan" "kronan" "lejonet" "nikolaiI" "orebro" "fine_arts_palace" "smolny")

for (( d=0; d<32; d++)); do
  dataset=${datasets[${d}]}
echo $dataset
url=http://vision.maths.lth.se/calledataset/${dataset}

if [ ! -d ../../data/${dataset}]; then
  mkdir -p ../../data/${dataset};
fi

wget -nH --cut-dirs=100 -r -l1 --accept "*.mat,*.zip" --directory-prefix=../../data/${dataset} "${url}"

unzip ../../data/${dataset}/"*.zip" -d ../../data/${dataset}

done
