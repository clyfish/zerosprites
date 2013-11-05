#!/bin/bash

RECTPACK_TIMEOUT=20

BASE_DIR=`dirname $0`

[[ $# -le 1 || ! "$1" =~ ^[0-9]+$ ]] && {
    echo "Usage: $0 padding (directory | png files)"
    echo "Output consists of sprites.txt and sprites.png"
    exit 1
}

padding=$1
shift

which identify &>/dev/null && which convert &>/dev/null || {
    echo "Please install ImageMagick"
    exit 1
}

files=`find "$@" -name "*.png" \! -name sprites.png`
[[ -z "$files" ]] && echo "no input png files" && exit

tmpdir=".sprites.sh.$$"
mkdir "$tmpdir"
cd "$tmpdir"

for png in $files
do
    echo "$png	`identify -format "%w %h" ../"$png" | awk -v padding="$padding" '{print $1+padding, $2+padding}'`"
done > input.txt
n=`wc -l < input.txt`

(
    ulimit -t "$RECTPACK_TIMEOUT"
    $BASE_DIR/rectpack -qb0 -i `awk '{if(NR!=1){printf ","}printf "%s",$2"x"$3}' input.txt` > output_rectpack.txt
)

if [[ `wc -l < output_rectpack.txt` -eq $((n+1)) ]]
then
    w=`awk -v padding="$padding" 'NR==1{print $1-padding}' output_rectpack.txt`
    h=`awk -v padding="$padding" 'NR==1{print $2-padding}' output_rectpack.txt`
    paste <(awk '{print $2, $3, $1, NR}' input.txt | sort) <(awk -F'[x(), ]+' 'NR>1{print $1, $2, $3, $4}' output_rectpack.txt | sort) | sort -n -k4 | awk '{print $3, $7, $8}' > ../sprites.txt
else
    awk '{print NR,$2,$3}' input.txt > input_btree.txt
    $BASE_DIR/btree input_btree.txt -simple -times 200 -maxIte 99999999 &>/dev/null
    w=`awk -v padding="$padding" 'NR==2{print $3-padding}' input_btree.txt.info`
    h=`awk -v padding="$padding" 'NR==3{print $3-padding}' input_btree.txt.info`
    paste <(awk '{print $1}' input.txt) <(awk 'NF==5{print $2,$4}' input_btree.txt.info) > ../sprites.txt
fi

cd ..
rm -r "$tmpdir"

convert -strip -size "${w}x${h}" xc:"rgba(0,0,0,0)" `awk '{print $1" -geometry +"$2"+"$3" -composite"}' sprites.txt` sprites.png
