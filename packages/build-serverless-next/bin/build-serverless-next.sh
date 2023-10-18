#!/bin/bash

rm -r .next
rm -r standalone
rm -r deployments

npm i -D serverless serverless-esbuild esbuild serverless-http

cp -a ./app ./app-backup
find ./app -type f -name 'page.tsx' -exec sh -c 'printf "\nexport const runtime = '\''edge'\'';\n" >> "$0"' {} \;
set -e
next build
set +e
rm -r ./app
mv ./app-backup ./app

cp -a .next/static .next/standalone/.next
# cp -a public .next/standalone

cp -a .next/standalone standalone
rm standalone/server.js
cp node_modules/build-serverless-next/server.js standalone
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
mkdir -p static/_next
cp -a .next/static static/_next
# mkdir public/assets
# cp -a public/* public/assets

rm -r node_modules
find . -name '*.html' -exec sed -i.backup 's|src="/|src="/assets/|g' '{}' \; 
find . -name '*.html' -exec sed -i.backup 's|src="/assets/_next/|src="/_next/|g' '{}' \; 
zip -r ../deployments/source.zip * .[!.]*
cd ..

rm -r .next
# rm -r standalone
rm -r nodejs
