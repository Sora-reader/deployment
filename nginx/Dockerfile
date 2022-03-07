FROM nginx:1.20-alpine

RUN apk add certbot certbot-nginx


# cron to autorenew certificates
COPY autorenew .
RUN crontab autorenew

RUN rm /etc/nginx/conf.d/default.conf
COPY backend.conf /etc/nginx/templates/backend.conf.template
COPY frontend.conf /etc/nginx/templates/frontend.conf.template

COPY entrypoint.sh ./
RUN chmod +x entrypoint.sh
ENTRYPOINT ./entrypoint.sh

