FROM nginx:latest
WORKDIR /usr/share/nginx/html
COPY src /usr/share/nginx/html
