wget=/usr/bin/wget
dataset=fountain
url=http://vision.maths.lth.se/calledataset/${dataset}

if [ ! -d ../../data/${dataset}]; then
  mkdir -p ../../data/${dataset};
fi

>wget -nH --cut-dirs=100 -r -l1 --accept "*.mat,*.zip" --directory-prefix=../../data/${dataset} "${url}"

unzip ../../data/${dataset}/"*.zip" -d ../../data/${dataset}
