php_file="/etc/route/mode/check.php"
cat>$php_file<<"EOF"
<?php

$mode_list = '/etc/route/mode/mode.json';
$route_file = '/etc/route/config/routing.json';

$balancer = json_decode(file_get_contents($route_file), true)['routing']['balancers'];
$status = array();
foreach ($balancer as $row) {
    $status[] = $row['selector'][0];
}
$modes = json_decode(file_get_contents($mode_list), true);
foreach ($modes as $name => $mode) {
    if ($status === $mode) {
        $result = $name;
    }
}
$result = isset($result) ? $result : 'unknow';
echo $result . PHP_EOL;

?>
EOF
php $php_file
rm -f $php_file
