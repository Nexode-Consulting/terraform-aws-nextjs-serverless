#!/bin/bash

# build
rm -r build/
npm run build

# add node_modules
rm -r node_modules/
npm install --arch=x64 --platform=linux --omit=dev
cp -r node_modules/ build/node_modules/

# zip
cd build/
rm -r ../source.zip
zip -r ../source.zip *
cd ..

# cleanup
rm -r build/
npm i
