status=`cat config | grep AdvSendAdvert | grep -o off`
if [ "$status" = "off" ]; then
  sed -i 's/^AdvSendAdvert=.*/AdvSendAdvert=on/;' ./config
  docker restart -t=0 route
fi
