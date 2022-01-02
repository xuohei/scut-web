php_file="/etc/scutweb/check.php"
cat>$php_file<<"EOF"
<?php

$time_out = 20;

$check_list = array(
    "nodeA_IPv4" => ["http://baidu.com", "192.168.2.2:1681"],
    "nodeB_IPv4" => ["http://baidu.com", "192.168.2.2:1682"],
    "nodeC_IPv4" => ["http://baidu.com", "192.168.2.2:1683"],
    "nodeA_IPv6" => ["http://test6.nju.edu.cn", "192.168.2.2:1681"],
    "nodeB_IPv6" => ["http://test6.nju.edu.cn", "192.168.2.2:1682"],
    "nodeC_IPv6" => ["http://test6.nju.edu.cn", "192.168.2.2:1683"],
);

foreach ($check_list as $name => $fields) {
    echo $name . ' -> ';
    if (check_target($fields[0], $fields[1])) {
        echo 'ok' . PHP_EOL;
    } else {
        echo 'error' . PHP_EOL;
    }
}

function check_target($url, $socks) {
    global $time_out;
    $cmd = 'curl --silent ' . $url . ' --max-time ' . $time_out . ' --socks5 ' . $socks;
    $content = shell_exec($cmd);
    return (strstr(strtolower($content), '<html')) ? true : false;
}

?>
EOF
php $php_file
rm -f $php_file
