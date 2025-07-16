# ./mern/frontend/Dockerfile

# ---- Stage 1: Build the React App ----
FROM node:18.9.1 AS builder

WORKDIR /app

COPY package*.json ./
RUN npm install
COPY . .

# IMPORTANT: Make sure this script exists in your package.json!
RUN npm run build


# ---- Stage 2: Serve with Nginx ----
FROM nginx:stable-alpine

# This assumes your 'npm run build' command creates a 'dist' folder.
# If it creates a 'build' folder, change '/app/dist' to '/app/build'
COPY --from=builder /app/dist /usr/share/nginx/html

# Expose port 80, which is the default for Nginx
EXPOSE 80

# The default Nginx command starts the server automatically.
CMD ["nginx", "-g", "daemon off;"]