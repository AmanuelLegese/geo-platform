# Use the official Node.js image as the base image
FROM node:20-alpine

# Provide libc6 compatibility for some native deps (optional)
RUN apk add --no-cache libc6-compat

WORKDIR /app

# Install an entrypoint helper that bootstraps the app if missing
RUN cat > /usr/local/bin/nextjs-entrypoint.sh <<'EOF'
#!/bin/sh
set -e

# If the project isn’t initialized yet, scaffold it.
if [ ! -f package.json ]; then
  echo "[entrypoint] No package.json found; scaffolding Next.js app..."
  npx create-next-app@latest . --yes --typescript --tailwind --eslint --app --src-dir --import-alias "@/*"
fi

# Install dependencies if missing.
if [ ! -d node_modules ]; then
  echo "[entrypoint] Installing dependencies..."
  npm install
fi

# Run the passed command
exec "$@"
EOF

RUN chmod +x /usr/local/bin/nextjs-entrypoint.sh

# Mounting a host directory can hide files in the image, so the entrypoint will scaffold the app if missing.
ENTRYPOINT ["/usr/local/bin/nextjs-entrypoint.sh"]

# Default to dev server; override with "npm start" for production.
CMD ["npm", "run", "dev"]
