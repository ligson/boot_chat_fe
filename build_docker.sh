#bin/bash
echo "Building docker image"
pkVersion=0.0.0
flutter build web
echo "开始编译镜像:dockerhub.yonyougov.top/crux/boot-chat-fe:$pkVersion"
docker build -t dockerhub.yonyougov.top/crux/boot-chat-fe:$pkVersion .
echo "开始推送镜像:dockerhub.yonyougov.top/crux/boot-chat-fe:$pkVersion"
docker push dockerhub.yonyougov.top/crux/boot-chat-fe:$pkVersion