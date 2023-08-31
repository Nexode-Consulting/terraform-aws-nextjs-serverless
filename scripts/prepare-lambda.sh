#!/bin/bash

rm -r .next
rm -r standalone
rm -r deployments

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
zip -r ../deployments/source.zip * .[!.]*
cd ..

rm -r .next
rm -r standalone
rm -r nodejs
