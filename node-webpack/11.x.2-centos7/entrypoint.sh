#!/bin/sh
find /webpack/src/  -maxdepth 1 -mindepth 1   \! -name "*.git" \! -name "dist"  -exec cp -rf {} /app/ \;
npm install
npm audit fix
exec "$@"