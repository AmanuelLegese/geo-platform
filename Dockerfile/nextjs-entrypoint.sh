#!/bin/sh
set -e

# If the project is not initialized yet, scaffold it.
if [ ! -f package.json ]; then
  echo "[entrypoint] No package.json found; scaffolding Next.js app..."
  npx create-next-app@latest . --yes --typescript --tailwind --eslint --app --src-dir --import-alias "@/*"
  echo "[entrypoint] Installing dependencies..."
  npm install
fi

# If the host mounted an empty directory, node_modules might not exist yet.
if [ ! -d node_modules ]; then
  echo "[entrypoint] node_modules missing; installing dependencies..."
  npm install
fi

# Execute the command
exec "$@"
