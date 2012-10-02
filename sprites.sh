#!/bin/bash

BASE_DIR=$(cd `dirname $0` && pwd)

[[ $# -eq 0 ]] && {
    echo "Usage: $0 (directory | png files)"
    echo "Output consists of sprites.txt and sprites.png"
    exit 1
}

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
    echo "$png	`identify -format "%w %h" ../"$png"`"
done > image_size.txt
n=`wc -l < image_size.txt`

if [[ $n -le 8 ]]
then
    awk 'BEGIN{print '"$n"'}{print $2+1,$3+1}' image_size.txt > input_blobb.txt
    $BASE_DIR/blobb input_blobb.txt output_blobb.txt -n -fx -o &>/dev/null
    w=`awk 'NR==1{print int($1)-1}' output_blobb.txt`
    h=`awk 'NR==2{print int($1)-1}' output_blobb.txt`
    paste <(awk '{print $1}' image_size.txt) <(awk 'NR>='"$n"'+5 && NF==2{print int($1),int($2)}' output_blobb.txt) > ../sprites.txt
else
    awk '{print NR,$2+1,$3+1}' image_size.txt > input_btree.txt
    $BASE_DIR/btree input_btree.txt -simple -times 200 -maxIte 99999999 &>/dev/null
    w=`awk 'NR==2{print $3-1}' input_btree.txt.info`
    h=`awk 'NR==3{print $3-1}' input_btree.txt.info`
    paste <(awk '{print $1}' image_size.txt) <(awk 'NF==5{print $2,$4}' input_btree.txt.info) > ../sprites.txt
fi

cd ..
rm -r "$tmpdir"

convert -strip -size "${w}x${h}" xc:"rgba(0,0,0,0)" `awk '{print $1" -geometry +"$2"+"$3" -composite"}' sprites.txt` sprites.png
