#!/bin/bash

LIBRARY=$1
TMP_DIR=$(mktemp -d)

# 解压静态库
ar x $LIBRARY --output $TMP_DIR

# 检查每个目标文件
for OBJ in $TMP_DIR/*.o; do
    HAS_TEXTREL=$(readelf -d $OBJ 2>/dev/null | grep TEXTREL)
    if [[ -n $HAS_TEXTREL ]]; then
        echo "ERROR: $OBJ contains non-PIC code (TEXTREL detected)."
        exit 1
    fi

    HAS_ABSOLUTE_RELOC=$(objdump -r $OBJ 2>/dev/null | grep R_X86_64_32)
    if [[ -n $HAS_ABSOLUTE_RELOC ]]; then
        echo "ERROR: $OBJ uses absolute relocations (non-PIC)."
        exit 1
    fi
done

echo "All objects in $LIBRARY are PIC-compatible."
rm -rf $TMP_DIR
