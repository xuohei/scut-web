GITHUB="github.com"
ASSET_REPO="Loyalsoldier/v2ray-rules-dat"
VERSION=$(curl --silent "https://api.github.com/repos/$ASSET_REPO/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/');
cd /etc/route/asset/
mkdir -p ./temp/
wget -P ./temp/ "https://$GITHUB/$ASSET_REPO/releases/download/$VERSION/geoip.dat"
file_size=`du ./temp/geoip.dat | awk '{print $1}'`
[ $file_size != "0" ] && mv -f ./temp/geoip.dat ./
wget -P ./temp/ "https://$GITHUB/$ASSET_REPO/releases/download/$VERSION/geosite.dat"
file_size=`du ./temp/geosite.dat | awk '{print $1}'`
[ $file_size != "0" ] && mv -f ./temp/geosite.dat ./
rm -rf ./temp/
