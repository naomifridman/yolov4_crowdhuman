#!/bin/bash

set -e

# check argument
if [[ -z $1 || ! $1 =~ [[:digit:]]x[[:digit:]] ]]; then
  echo "ERROR: This script requires 1 argument, \"input dimension\" of the YOLO model."
  echo "The input dimension should be {width}x{height} such as 608x608 or 416x256.".
  exit 1
fi

if which python3 > /dev/null; then
  PYTHON=python3
else
  PYTHON=python
fi

echo "** Install requirements"
# "gdown" is for downloading files from GoogleDrive
pip3 install --user gdown > /dev/null

# make sure to download dataset files to "yolov4_crowdhuman/data/raw/"
mkdir -p $(dirname $0)/raw
pushd $(dirname $0)/raw > /dev/null

get_file()
{
  # do download only if the file does not exist
  if [[ -f $2 ]];  then
    echo Skipping $2
  else
    echo Downloading $2...
    python3 -m gdown.cli $1
  fi
}

# down links from google drive need to be created at:
# https://sites.google.com/site/gdocs2direct/

echo "** Download dataset files"
#get_file https://drive.google.com/uc?id=134QOvaatwKdy0iIeNqA_p-xkAhkV4F8Y CrowdHuman_train01.zip
#get_file https://drive.google.com/uc?id=17evzPh7gc1JBNvnW1ENXLy5Kr4Q_Nnla CrowdHuman_train02.zip
#get_file https://drive.google.com/uc?id=1tdp0UCgxrqy1B6p8LkR-Iy0aIJ8l4fJW CrowdHuman_train03.zip
#get_file https://drive.google.com/uc?id=18jFI789CoHTppQ7vmRSFEdnGaSQZ4YzO CrowdHuman_val.zip

echo "** Download dataset files  CrowdHuman_train03.zip"
get_file https://drive.google.com/uc?export=download&id=1-1noaH0ZfCDiHYw2oM1pCE6EaNOyTbOj #CrowdHuman_train03.zip
echo "** Download dataset files  CrowdHuman_val.zip"
get_file https://drive.google.com/uc?export=download&id=1ho6apKoazy1fM4JC5PYk-nH_efsb1nli #CrowdHuman_val.zip

# test data is not needed...
# get_file https://drive.google.com/uc?id=1tQG3E_RrRI4wIGskorLTmDiWHH2okVvk CrowdHuman_test.zip
echo "** Download dataset files  annotation_train.odgt"
get_file https://drive.google.com/u/0/uc?id=1UUTea5mYqvlUObsC1Z8CFldHJAtLtMX3 annotation_train.odgt
get_file https://drive.google.com/u/0/uc?id=10WIRwu8ju8GRLuCkZ_vT6hnNxs5ptwoL annotation_val.odgt

# unzip image files (ignore CrowdHuman_test.zip for now)
echo "** Unzip dataset files"
for f in  CrowdHuman_train03.zip CrowdHuman_val.zip ; do
  unzip -n ${f}
done

echo "** Create the crowdhuman-$1/ subdirectory"
rm -rf ../crowdhuman-$1/
mkdir ../crowdhuman-$1/
ln Images/*.jpg ../crowdhuman-$1/

# the crowdhuman/ subdirectory now contains all train/val jpg images

echo "** Generate yolo txt files"
cd ..
${PYTHON} gen_txts.py $1

popd > /dev/null

echo "** Done."
