temp=`docker ps -a | grep -o cleardns`
if [ "$temp" != "" ]; then
  docker rm -f cleardns > /dev/null
fi
docker run --restart always \
--name cleardns \
--network macvlan \
--privileged -d \
-v /etc/cleardns:/etc/cleardns \
-v /etc/timezone:/etc/timezone:ro \
-v /etc/localtime:/etc/localtime:ro \
dnomd343/cleardns:latest > /dev/null
sleep 1s
docker ps -a
