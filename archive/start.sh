temp=`docker ps -a | grep -o archive`
if [ "$temp" != "" ]; then
    docker rm -f archive > /dev/null
fi
docker run --restart always -d -it \
--name archive \
-v /etc/archive/:/etc/archive/ \
-v /etc/scutweb/log/:/etc/scutweb/log/ \
-v /etc/route/log/:/etc/route/log/ \
-v /etc/timezone:/etc/timezone:ro \
-v /etc/localtime:/etc/localtime:ro \
archive:latest > /dev/null
sleep 1s
docker ps -a
