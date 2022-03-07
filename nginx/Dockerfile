FROM nginx:1.20-alpine

RUN apk add certbot certbot-nginx

# TODO: if no certificate, then generate

COPY autorenew .
RUN crontab autorenew

RUN rm /etc/nginx/conf.d/default.conf
COPY backend.conf /etc/nginx/conf.d/backend.conf
COPY frontend.conf /etc/nginx/conf.d/frontend.conf

