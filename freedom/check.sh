php_file="/etc/freedom/check.php"
cat>$php_file<<"EOF"
<?php

$time_out = 20;

$check_list = array(
    "ipv4_direct" => ["http://baidu.com", "192.168.2.4:1084"],
    "ipv6_direct" => ["http://test6.nju.edu.cn", "192.168.2.4:1086"],
    "ipv4_proxy" => ["http://google.com", "192.168.2.4:1094"],
    "ipv6_proxy" => ["http://ipv6.google.com", "192.168.2.4:1096"]
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
