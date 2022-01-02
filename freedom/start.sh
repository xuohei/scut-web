temp=`docker ps -a | grep -o freedom`
if [ "$temp" != "" ]; then
    docker rm -f freedom > /dev/null
fi
docker run --restart always \
--name freedom \
--privileged -d \
--network macvlan \
--ip=192.168.2.5 \
--dns=192.168.2.4 \
-e V2RAYA_ADDRESS=0.0.0.0:80 \
-e V2RAYA_V2RAY_BIN=/usr/bin/xray \
-v /etc/freedom:/etc/v2raya \
-v /usr/bin/xray:/usr/bin/xray \
-v /etc/timezone:/etc/timezone:ro \
-v /etc/localtime:/etc/localtime:ro \
mzz2017/v2raya > /dev/null
sleep 1s
docker ps -a
