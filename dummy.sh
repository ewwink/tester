#!/usr/bin/bash


mkdir -p /app/dir

touch dir/dummy1.txt
touch dir/dummy2.txt

zip -r dummy.zip .

echo "copied"