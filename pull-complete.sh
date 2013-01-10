#!/bin/sh
for i in amd64 lib sys
do
	cp -v -r $1/$i .
done
