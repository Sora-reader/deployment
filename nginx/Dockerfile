FROM nginx:1.20-alpine

RUN rm /etc/nginx/conf.d/default

COPY backend.conf /etc/nginx/conf.d/backend.conf
COPY frontend.conf /etc/nginx/conf.d/frontend.conf
