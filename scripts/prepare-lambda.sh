#!/bin/bash

rm -r .next
rm -r standalone
rm -r deployments

npm i -D serverless serverless-esbuild esbuild serverless-http
next build

cp -a .next/static .next/standalone/.next
cp -a public .next/standalone

cp -a .next/standalone standalone
rm standalone/server.js
cp server.js standalone
cp next.config.js standalone

mkdir deployments
mkdir standalone
mkdir nodejs

cp -a standalone/node_modules nodejs
cp -a node_modules/serverless nodejs/node_modules
cp -a node_modules/serverless-esbuild nodejs/node_modules
cp -a node_modules/esbuild nodejs/node_modules
cp -a node_modules/serverless-http nodejs/node_modules

zip -r deployments/layer.zip nodejs

cd standalone
rm -r node_modules
find . -name '*.html' -exec sed -i.backup 's|src="/|src="/assets/|g' '{}' \; 
zip -r ../deployments/source.zip * .[!.]*
cd ..

rm -r .next
# rm -r standalone
rm -r nodejs
