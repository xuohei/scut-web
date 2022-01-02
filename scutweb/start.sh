temp=`docker ps -a | grep -o scutweb`
if [ "$temp" != "" ]; then
  docker restart -t=0 scutweb > /dev/null
else
  docker run --restart always \
  --name scutweb \
  --network macvlan \
  --privileged -d \
  --volume /etc/scutweb/:/etc/xray/expose/ \
  --volume /etc/timezone:/etc/timezone:ro \
  --volume /etc/localtime:/etc/localtime:ro \
  dnomd343/tproxy:latest > /dev/null
fi
sleep 1s
docker ps -a
