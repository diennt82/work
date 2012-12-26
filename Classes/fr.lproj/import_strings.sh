#!/bin/bash

find . -name "*.xib" | while read FILENAME;
do
#  ibtool --export-strings-file $FILENAME.strings $FILENAME
  ibtool --strings-file $FILENAME.strings --write $FILENAME $FILENAME 
done
