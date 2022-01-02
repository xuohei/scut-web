cat>/etc/route/rules.php<<"EOF"
<?php

$path = '/etc/route/';

function get_records($file_name) {
    global $path;
    $content = file_get_contents($path . $file_name);
    if (trim($content) == null) { return array(); }
    $content = explode(PHP_EOL, $content);
    $records = array();
    foreach ($content as $row) {
        $row = trim($row);
        if ($row == null) { continue; }
        if (substr($row, 0, 1) === '#') { continue; }
        $records[] = $row;
    }
    return $records;
}

$rules[] = array(
    'type' => 'field',
    'inboundTag' => 'direct',
    'outboundTag' => 'direct4'
);

$rules[] = array(
    'type' => 'field',
    'inboundTag' => 'direct6',
    'outboundTag' => 'direct6'
);

$rules[] = array(
    'type' => 'field',
    'inboundTag' => 'proxy',
    'outboundTag' => 'proxy4'
);

$rules[] = array(
    'type' => 'field',
    'inboundTag' => 'proxy6',
    'outboundTag' => 'proxy6'
);

$records = get_records('rules/block_domain');
if (count($records) !== 0) {
    $rules[] = array(
        'type' => 'field',
        'domain' => $records,
        'outboundTag' => 'block'
    );
}

$records = get_records('rules/block_ip');
if (count($records) !== 0) {
    $rules[] = array(
        'type' => 'field',
        'ip' => $records,
        'outboundTag' => 'block'
    );
}

$records = get_records('rules/direct_domain');
if (count($records) !== 0) {
    $rules[] = array(
        'type' => 'field',
        'inboundTag' => ['tproxy'],
        'domain' => $records,
        'balancerTag' => 'direct'
    );
}

$records = get_records('rules/direct_domain');
if (count($records) !== 0) {
    $rules[] = array(
        'type' => 'field',
        'inboundTag' => ['tproxy6'],
        'domain' => $records,
        'balancerTag' => 'direct6'
    );
}

$records = get_records('rules/proxy_domain');
if (count($records) !== 0) {
    $rules[] = array(
        'type' => 'field',
        'inboundTag' => ['tproxy'],
        'domain' => $records,
        'balancerTag' => 'proxy'
    );
}

$records = get_records('rules/proxy_domain');
if (count($records) !== 0) {
    $rules[] = array(
        'type' => 'field',
        'inboundTag' => ['tproxy6'],
        'domain' => $records,
        'balancerTag' => 'proxy6'
    );
}

$rules[] = array(
    'type' => 'field',
    'inboundTag' => ['tproxy'],
    'domain' => ['geosite:cn'],
    'balancerTag' => 'direct'
);

$rules[] = array(
    'type' => 'field',
    'inboundTag' => ['tproxy6'],
    'domain' => ['geosite:cn'],
    'balancerTag' => 'direct6'
);

$records = get_records('rules/direct_ipv4');
if (count($records) !== 0) {
    $rules[] = array(
        'type' => 'field',
        'ip' => $records,
        'balancerTag' => 'direct'
    );
}

$records = get_records('rules/direct_ipv6');
if (count($records) !== 0) {
    $rules[] = array(
        'type' => 'field',
        'ip' => $records,
        'balancerTag' => 'direct6'
    );
}

$records = get_records('rules/proxy_ipv4');
if (count($records) !== 0) {
    $rules[] = array(
        'type' => 'field',
        'ip' => $records,
        'balancerTag' => 'proxy'
    );
}

$records = get_records('rules/proxy_ipv6');
if (count($records) !== 0) {
    $rules[] = array(
        'type' => 'field',
        'ip' => $records,
        'balancerTag' => 'proxy6'
    );
}

$rules[] = array(
    'type' => 'field',
    'inboundTag' => ['tproxy'],
    'ip' => ['geoip:cn','geoip:private'],
    'balancerTag' => 'direct'
);

$rules[] = array(
    'type' => 'field',
    'inboundTag' => ['tproxy6'],
    'ip' => ['geoip:cn','geoip:private'],
    'balancerTag' => 'direct6'
);

$rules[] = array(
    'type' => 'field',
    'inboundTag' => ['tproxy'],
    'balancerTag' => 'proxy'
);

$rules[] = array(
    'type' => 'field',
    'inboundTag' => ['tproxy6'],
    'balancerTag' => 'proxy6'
);

file_put_contents($path . 'rules/temp.json', json_encode($rules));
$contents = '"rules": ' . shell_exec('jq . ' . $path . 'rules/temp.json');
shell_exec('rm -f ' . $path . 'rules/temp.json');
$contents = explode(PHP_EOL, $contents);
foreach ($contents as &$content) {
    if ($content == null) { continue; }
    $content = '    ' . $content;
}
$contents = implode(PHP_EOL, $contents);

$config = '{
  "routing": {
    "domainStrategy": "IPOnDemand",' . PHP_EOL . $contents;
$config = substr($config, 0, strlen($config) - 1) . ',' . PHP_EOL;

$config_raw = explode(PHP_EOL, file_get_contents($path . 'config/routing.json'));
foreach ($config_raw as $row) {
    if (strstr($row, '    "balancers": [')) {
        $flag_start = true;
    }
    if (isset($flag_start)) {
        $config .= $row . PHP_EOL;
    }
}
$config = substr($config, 0, strlen($config) - 1);
file_put_contents($path . 'config/routing.json', $config);

?>
EOF
php /etc/route/rules.php
rm -f /etc/route/rules.php
temp=`docker ps -a | grep -o route`
if [ "$temp" != "" ]; then
  docker restart -t=0 route > /dev/null
else
  docker run --restart always \
  --name route \
  --network macvlan \
  --privileged -d \
  --volume /etc/route/:/etc/xray/expose/ \
  --volume /etc/timezone:/etc/timezone:ro \
  --volume /etc/localtime:/etc/localtime:ro \
  dnomd343/tproxy:latest > /dev/null
fi
sleep 1s
docker ps -a
