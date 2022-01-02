cat>>scan.php<<"EOF"
<?php

$ip2name = array(
    '192.168.2.1' => 'Redmi AX3000',
    '192.168.2.2' => 'SCUT Web Patch',
    '192.168.2.3' => 'Clear DNS Server',
    '192.168.2.4' => 'Network Route',
    '192.168.2.5' => 'GFW Crossed',
    '192.168.2.34' => 'Raspberry-PI 4B',
    '192.168.2.97' => 'TL-WDA6332RE',
    '192.168.2.98' => 'MOAP1200D',
    '192.168.2.99' => 'TL-SG2005'
);

function my_net() {
    $info = shell_exec('ifconfig');
    $info = explode(PHP_EOL . PHP_EOL, $info);
    foreach ($info as $row) {
        if (strstr($row, 'macvlan')) { break; }
    }
    preg_match('/inet (192.168.2.[0-9]{1,3}) /', $row, $match);
    $ip = isset($match[1]) ? $match[1] : '';
    preg_match('/ether (([0-9a-f]{2}:){5}[0-9a-f]{2}) /', $row, $match);
    $mac = isset($match[1]) ? $match[1] : '';
    return array(
        'ip' => $ip,
	'mac' => strtoupper($mac)
    );
}

function nmap_scan($area) {
    shell_exec('nmap -sn -PR ' . $area . ' -oX temp');
    $raw = file_get_contents('temp');
    shell_exec('rm -f temp');
    $info = json_decode(json_encode(simplexml_load_string($raw)), true)['host'];
    if (isset($info['status'])) {
        $temp = $info;
        $info = array();
        $info[] = $temp;
    }
    foreach ($info as $row) {
        $type = $row['status']['@attributes']['reason'];
        if ($type === 'arp-response') {
            $ip = isset($row['address'][0]) ? $row['address'][0]['@attributes'] : null;
            $mac = isset($row['address'][1]) ? $row['address'][1]['@attributes'] : null;
        } else if ($type === 'localhost-response') {
            $ip = $row['address']['@attributes'];
            $mac = null;
        } else {
            echo 'error -> unknow type' . PHP_EOL;
            continue;
        }
        $hostname = isset($row['hostnames']['hostname']) ? $row['hostnames']['hostname']['@attributes'] : null;
        if ($ip !== null) {
            if ($ip['addrtype'] === 'ipv4') {
                $ip = $ip['addr'];
            } else {
                echo 'error -> unknow ip type' . PHP_EOL;
                $ip = null;
            }
        }
        if ($mac !== null) {
            if ($mac['addrtype'] === 'mac') {
                $mac = $mac['addr'];
            } else {
                echo 'error -> unknow mac type' . PHP_EOL;
                $mac = null;
            }
        }
        if ($hostname !== null) {
            if ($hostname['type'] === 'PTR') {
                $hostname = $hostname['name'];
            } else {
                echo 'error -> unknow hostname type' . PHP_EOL;
                $hostname = null;
            }
        }
        if ($ip === null) {
            echo 'error -> no ip address' . PHP_EOL;
            continue;
        }
        $list[$ip] = array(
            'mac' => $mac,
            'name' => $hostname
        );
    }
    return $list;
}

function sort_client($clients) {
    foreach ($clients as $ip => $info) {
        $temp[substr($ip, 10 - strlen($ip))] = $info;
    }
    ksort($temp);
    foreach ($temp as $ip_postfix => $info) {
        unset($temp[$ip_postfix]);
        $temp['192.168.2.' . $ip_postfix] = $info;
    }
    return $temp;
}

function client_scan() {
    global $ip2name, $mac2name;
    $clients = nmap_scan('192.168.2.0/24');
    sleep(3);
    $client_list_1 = nmap_scan('192.168.2.100-199');
    sleep(3);
    $client_list_2 = nmap_scan('192.168.2.100-199');
    foreach ($client_list_1 as $ip => $info) {
        if (!isset($clients[$ip])) { $clients[$ip] = $info; }
    }
    foreach ($client_list_2 as $ip => $info) {
        if (!isset($clients[$ip])) { $clients[$ip] = $info; }
    }
    $self = my_net();
    if (isset($self['ip'])) {
        $clients[$self['ip']]['mac'] = $self['mac'];
    }
    foreach ($ip2name as $ip => $name) {
        if (isset($clients[$ip])) {
            $clients[$ip]['name'] = $name;
        }
    }
    foreach ($mac2name as $mac => $name) {
        foreach ($clients as $ip => $client) {
            if ($client['mac'] === $mac) {
                $clients[$ip]['name'] = $name;
                break;
            }
        }
    }
    return sort_client($clients);
}

$mac2name = json_decode(file_get_contents('/etc/route/client.json'), true);
$clients = client_scan();
$length = 0;
foreach ($clients as $info) {
    if (strlen($info['name']) > $length) {
        $length = strlen($info['name']);
    }
}
echo '┌───────────────┬───────────────────┬' . str_pad('', ($length + 2) * 3, '─') . '┐' . PHP_EOL;
$dhcp_area = false;
$color = "1;30m";
foreach ($clients as $ip => $info) {
    if (!$dhcp_area && substr($ip, 10 - strlen($ip)) >= 100) {
        echo '├───────────────┼───────────────────┼' . str_pad('', ($length + 2) * 3, '─') . '┤' . PHP_EOL;
        $color = "36m";
        $dhcp_area = true;
    }
    $row = '│ ';
    $row .= "\033[" . $color . str_pad($ip, 13, ' ') . "\033[0m";
    $row .= ' │ ';
    $row .= "\033[" . $color . str_pad($info['mac'], 17, ' ') . "\033[0m";
    $row .= ' │ ';
    $row .= "\033[" . $color . str_pad($info['name'], $length, ' ') . "\033[0m";
    $row .= ' │';
    echo $row . PHP_EOL;
}
echo '└───────────────┴───────────────────┴' . str_pad('', ($length + 2) * 3, '─') . '┘' . PHP_EOL;

?>
EOF

php ./scan.php
rm -f ./scan.php
