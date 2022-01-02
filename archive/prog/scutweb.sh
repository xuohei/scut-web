DIR=/etc/scutweb/log
mkdir -p $DIR/temp
mkdir -p $DIR/archive
cp $DIR/access.log $DIR/error.log $DIR/temp/
cat /dev/null > $DIR/access.log > $DIR/error.log
date=`php -r "echo date('Y-m-d',strtotime('0 day'));"`
tar cf $DIR/archive/$date.tar -C$DIR/temp/ access.log error.log
bzip2 $DIR/archive/$date.tar --best
rm -rf $DIR/temp/
