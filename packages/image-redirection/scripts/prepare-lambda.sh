#!/bin/bash

# build
rm -r build/
npm run build

# zip
cd build/
rm -r ../source.zip
zip -r ../source.zip *
cd ..
