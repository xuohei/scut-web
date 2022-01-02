DIR=/etc/route/log
mkdir -p $DIR/temp
mkdir -p $DIR/archive
cp $DIR/access.log $DIR/error.log $DIR/temp/
mv $DIR/connection.log $DIR/temp/
ps -ef | grep format.php | grep -v grep | awk '{print $1}' | xargs kill -9
cat /dev/null > $DIR/access.log > $DIR/error.log
php /etc/archive/prog/format.php &
date=`php -r "echo date('Y-m-d',strtotime('0 day'));"`
tar cf $DIR/archive/$date.tar -C$DIR/temp/ access.log error.log connection.log
bzip2 $DIR/archive/$date.tar --best
rm -rf $DIR/temp/
