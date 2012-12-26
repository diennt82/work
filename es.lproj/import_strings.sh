#!/bin/bash

find . -name "*.xib" | while read FILENAME;
do
  ibtool --export-strings-file $FILENAME.strings $FILENAME
done
