#!/bin/bash

#检查参数合法性
function check() {
    if [[ "$1" != "prod" && "$1" != "stage"  && "$1" != "qa" && "$1" != "jzs" ]]; then
        echo -e "\r\nUsage: sh run.sh $2 qa|stage|prod|jzs";
        exit;
    fi
}
#错误处理
function error_exit {
  echo "$1" 1>&2
  exit 1
}

#停止容器
function stop() {
    check $1 stop;
    (docker stop $1 && echo "stop $1 success") || echo "stop $1 error";
}

#删除容器
function remove() {
    check $1 remove;
    (docker rm $1 && echo "remove $1 success") || echo "remove $1 error";
}

#运行测试、打包、生成docker镜像
function build() {
    if [[ "$1" = "prod" || "$1" = "jzs" ]]; then
        buildWithMaven;
    else
        buildWithMavenWrapper;
    fi
}

#使用maven打包
function buildWithMaven() {
    (mvn clean install dockerfile:build && echo "build success") || error_exit "build error";
}

#使用maven wrapper打包
function buildWithMavenWrapper() {
    chmod 777 ./mvnw;
    (./mvnw clean install dockerfile:build && echo "build success") || error_exit "build error";
}

#启动容器 参数1:运行环境 参数2:端口<prod 8089|stage 8089|qa 8088|jzs 8090>
function start() {
    check $1 start;
    docker run --name $1 \
    -e "SPRING_PROFILES_ACTIVE=$1" \
    -d \
    -p $2:$2 \
    -v /var/log/hongfund/$1:/var/log/hongfund/$1 \
    -e TZ=Asia/Shanghai \
    hongfund/efi
}

#启动容器 参数1:运行环境 参数2:端口<prod 8089|stage 8089|qa 8088>
function clean() {
    (docker rmi $(docker images -aq -f "dangling=true") && echo "clean success") || echo "clean error"
}

#部署qa
function qa() {
    stop qa;
    remove qa;
    build qa;
    start qa 8088;
    clean;
}

#部署stage
function stage() {
    stop stage;
    remove stage;
    build stage;
    start stage 8089;
    clean;
}

#部署prod
function prod() {
    stop prod;
    remove prod;
    build prod;
    start prod 8089;
    clean;
}

#部署jzs
function jzs() {
    stop jzs;
    remove jzs;
    build jzs;
    start jzs 8090;
    clean;
}

function show_help() {
    echo -e "\r\n\t欢迎使用hongfund"
    echo -e "\r\nUsage: sh run.sh stop|remove|build|start|qa|stage|prod|jzs"
    exit;
}

function main() {
    Command=$1
    case "${Command}" in
        stop)       stop "$2" ;;
        remove)     remove "$2" ;;
        build)      build "$2" ;;
        start)      start "$2" "$3" ;;
        qa)         qa ;;
        stage)      stage ;;
        prod)       prod ;;
        jzs)        jzs ;;
        clean)      clean ;;
        *)          show_help ;;
    esac
}
main "$@"
