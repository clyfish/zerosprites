#!/bin/bash

[[ ! -f sprites.txt ]] && echo "sprites.txt not found" && exit

echo ".sprites { background: url(sprites.png) no-repeat; }" > sprites.css

while read img x y
do
    w=`identify -format '%w' "$img"`
    h=`identify -format '%h' "$img"`
    [[ "$x" == 0 ]] || x="-${x}px"
    [[ "$y" == 0 ]] || y="-${y}px"
    echo ".${img%.*} { width: ${w}px; height: ${h}px; background-position: $x $y; }"
done < sprites.txt >> sprites.css
