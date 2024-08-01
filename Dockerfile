FROM dockerhub.yonyougov.top/public/nginx:alpine
USER root
ADD ./build/web /usr/share/nginx/html/
COPY ./default.conf /etc/nginx/conf.d/
