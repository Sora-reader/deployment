FROM nginx:1.20-alpine

RUN apk add certbot certbot-nginx

# TODO: if no certificate, then generate

COPY autorenew .
RUN crontab autorenew

RUN rm /etc/nginx/conf.d/default.conf
COPY backend.conf /etc/nginx/templates/backend.conf.template
COPY frontend.conf /etc/nginx/templates/frontend.conf.template

