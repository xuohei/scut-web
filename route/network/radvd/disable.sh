status=`cat config | grep AdvSendAdvert | grep -o on`
if [ "$status" = "on" ]; then
  sed -i 's/^AdvSendAdvert=.*/AdvSendAdvert=off/;' ./config
  docker restart -t=0 route
fi
