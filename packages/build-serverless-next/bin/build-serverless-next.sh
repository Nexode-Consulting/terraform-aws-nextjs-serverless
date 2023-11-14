#!/bin/bash

# Clean-up old builds
rm -r .next
rm -r standalone
rm -r deployments

# Install necessary packages
npm i -D serverless@3.36.0 serverless-esbuild@1.48.5 esbuild@0.19.5 serverless-http@3.2.0 nextjs-image-optimization@0.2.12 image-redirection@0.2.12

# Inject code in build, and cleanup
cp -a ./app ./app-backup
find ./app -type f -name 'page.tsx' -exec sh -c 'printf "\nexport const runtime = '\''edge'\'';\n" >> "$0"' {} \;
set -e
next build
set +e
rm -r ./app
mv ./app-backup ./app

# Keep necessary files
cp -a .next/static .next/standalone/.next
cp -a .next/standalone standalone
rm standalone/server.js
cp node_modules/build-serverless-next/server.js standalone
cp next.config.js standalone

# Prepare deployment
mkdir deployments
mkdir standalone
mkdir nodejs

# Keeps necessary node modules
cp -a standalone/node_modules nodejs
cp -a node_modules/serverless nodejs/node_modules
cp -a node_modules/serverless-esbuild nodejs/node_modules
cp -a node_modules/esbuild nodejs/node_modules
cp -a node_modules/serverless-http nodejs/node_modules

# Zip node modules
zip -r deployments/layer.zip nodejs

# Keep image optimization/redirection source code zips
cd deployments
mkdir image-redirection
mkdir image-optimization
cd ..
cp node_modules/image-redirection/source.zip deployments/image-redirection/
cp node_modules/nextjs-image-optimization/source.zip deployments/image-optimization/

# Keep necessary files
cd standalone
mkdir -p static/_next
cp -a .next/static static/_next
# mkdir public/assets
# cp -a public/* public/assets

# Zip source code
rm -r node_modules
find . -name '*.html' -exec sed -i.backup 's|src="/|src="/assets/|g' '{}' \; 
find . -name '*.html' -exec sed -i.backup 's|src="/assets/_next/|src="/_next/|g' '{}' \; 
zip -r ../deployments/source.zip * .[!.]*
cd ..

# Clean-up
rm -r .next
# rm -r standalone
rm -r nodejs

# Remove installed node modules
npm uninstall serverless serverless-esbuild esbuild serverless-http nextjs-image-optimization image-redirection
