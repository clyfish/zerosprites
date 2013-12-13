#!/usr/bin/env python
import re, sys

convert = lambda text: int(text) if text.isdigit() else text
alphanum_key = lambda key: [convert(c) for c in re.split('([0-9]+)', key)]

if __name__ == "__main__":
    sys.stdout.write(''.join(sorted(sys.stdin.readlines(), key=alphanum_key)))
