php_file="/etc/route/mode/set.php"
cat>$php_file<<"EOF"
<?php

$mode_list = '/etc/route/mode/mode.json';
$route_file = '/etc/route/config/routing.json';

if ($argc !== 2) { die('error param' . PHP_EOL); }
$target_mode = $argv[1];
$modes = json_decode(file_get_contents($mode_list), true);
if (!isset($modes[$target_mode])) { die('unknow mode' . PHP_EOL); }
$mode = $modes[$target_mode];

$route = explode(PHP_EOL, file_get_contents($route_file));
$num = 0;
foreach ($route as &$row) {
    if (strstr($row, '"selector":')) {
        $row = '        "selector": [ "' . $mode[$num] . '" ]';
        $num++;
    }
}
$route = implode(PHP_EOL, $route);
file_put_contents($route_file, $route);

?>
EOF
php $php_file $1
rm -f $php_file
docker restart -t=0 route > /dev/null
