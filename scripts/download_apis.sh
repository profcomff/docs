#!/bin/bash

while IFS="" read -r p || [ -n "$p" ]
do
  NAME=$(echo $p | cut -d ";" -f 1)
  URL=$(echo $p | cut -d ";" -f 2)
  rm ../docs/api/$NAME.json
  wget --tries=3 --output-document="../docs/api/$NAME.json" $URL
done < download_apis.txt
