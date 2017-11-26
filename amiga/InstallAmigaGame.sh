#!/bin/bash

RETROPIE_HOST="retropie"
RETROPIE_USR="pi"
RETROPIE_PASS="raspberry"
RETROPIE_AMIGA_DATA_ROM=/home/pi/RetroPie/roms/amiga-data/Games_WHDLoad

TMP_DIR=/tmp

usage() {
  echo
  echo "Usage:"
  echo "InstallAmigaGame.sh <path-to-lha-game>"
  echo "After the installation process update needs to be performed"
  echo
}

rm_tmp() {
  rm -fr "${TMP_DIR}" > /dev/null 2>&1
}

if [ $# -eq 0 ]; then
  echo "Error: No arguments supplied"
  usage
  exit 1
fi

if [ -z "$1" ]; then
    echo "Error: No argument supplied"
    usage
    exit 1
fi

LHA_PACK="$1"

if [ ! -f "${LHA_PACK}" ]; then
    echo "Error: LHA pack file '${LHA_PACK}' does not exist!"
    exit 1
fi

echo "Processing ${LHA_PACK} file..."
lha_file=$(basename "${LHA_PACK}")
lha_ext="${lha_file##*.}"

if [ "$lha_ext" != "lha" ]; then
  echo "Warning: expected archive extention is lha"
fi

# check if lha is installed
type lha > /dev/null
if [[ $? -ne 0 ]]; then
  echo "Error: lha unpacker is not installed"
  exit 1
fi

TMP_DIR=${TMP_DIR}/${lha_file}
# try to remove TMP_DIR just in case
rm_tmp
mkdir -p "$TMP_DIR"
if [[ $? -ne 0 ]]; then
  echo "Error: Unable to create temporary directory ${TMP_DIR}"
  exit 1
fi

echo "Extracting package..."
lha -xw="${TMP_DIR}" "${LHA_PACK}" > /dev/null
if [[ $? -ne 0 ]]; then
  echo "Error: Cannot extract ${LHA_PACK}"
  rm_tmp
  exit 1
fi
echo "Done"

echo "Cheking type..."
types=("AGA" "CD32" "CDTV" "DemoVersions" "HDF" "HDF_AGA" "HDF_AltLanguage"
"HDF_CDTV" "HDF_DemoVersions" "Unofficial")
game_type=""
for t in "${types[@]}"; do
  if [[ $lha_file == *"${t}"* ]]; then
    game_type=$t
    RETROPIE_AMIGA_DATA_ROM=${RETROPIE_AMIGA_DATA_ROM}_${t}
    break
  fi
done

if [ -z "$game_type" ]; then
  echo "Standard type"
else
  echo "${game_type} type"
fi

echo "Uploading game to ${RETROPIE_HOST}"
# extract the directory
path=$(ls -d "${TMP_DIR}"/*/)
if [ $? -ne 0 ]; then
  echo "Error: unable to find directory with the game"
  rm_tmp
  exit 1
fi
path=${path%/}
sshpass -p "${RETROPIE_PASS}" scp -r "${path}"\
  "${RETROPIE_USR}@${RETROPIE_HOST}:${RETROPIE_AMIGA_DATA_ROM}"

if [ $? -ne 0 ]; then
  echo "Error: unable to upload the game"
  rm_tmp
  exit 1
else
  echo "Done"
fi

rm_tmp
