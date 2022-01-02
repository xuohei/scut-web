<?php

error_reporting(E_ALL || ~E_NOTICE);
$log_file = '/etc/route/log/error.log';
$output_file = '/etc/route/log/connection.log';

$redisSetting = array(
    'host' => '127.0.0.1',
    'port' => '6379',
    'prefix' => 'connection-'
);

$fd = inotify_init();
stream_set_blocking($fd, 1); // 阻塞式
$watch = inotify_add_watch($fd, $log_file, IN_MODIFY);

$fp = fopen($log_file, "r");
$file_size = filesize($log_file);
fseek($fp, $file_size);

$fo = fopen($output_file, "a+");

while ($events = inotify_read($fd)) {
    usleep(500);
    foreach ($events as $event) {
        if ($event['mask'] !== 2) { continue; }
        clearstatcache();
        $file_size_new = filesize($log_file);
        $add_size = $file_size_new - $file_size;
        $file_size = $file_size_new;
	if ($add_size <= 0) { continue; }
        $content = fread($fp, $add_size);
        if (!$content) { continue; }
        new_content($content); // 抓取到新输入内容
        ob_flush();
        flush();
    }
}

fclose($fo);
fclose($fp);
inotify_rm_watch($fd, $watch);
fclose($fd);

function new_content($content) {
    $content = explode(PHP_EOL, $content);
    foreach ($content as $row) {
        $row = trim($row);
	if ($row == null) { continue; }
        if (!strstr($row, '[Info]')) { continue; }
        new_line($row);
    }
}

function new_line($row) {
    if (strstr($row, 'proxy/dokodemo: received request for')) {
        $info = explode('proxy/dokodemo: received request for', $row);
        $info[0] = substr($info[0], 28);
        $id = substr($info[0], 0, strlen($info[0]) - 2);
        if ($id == null) { return; }
	$source = trim($info[1]);
        new_receive($id, $source);
    }
    if (strstr($row, 'app/dispatcher: taking detour')) {
        $info = explode('app/dispatcher: taking detour', $row);
        $time = substr($row, 0, 19);
        $info[0] = substr($info[0], 28);
	$id = substr($info[0], 0, strlen($info[0]) - 2);
        if ($id == null) { return; }
        $info = explode(' for ', trim($info[1]));
        $info[0] = substr($info[0], 1);
        $route = substr($info[0], 0, strlen($info[0]) - 1);
	$info[1] = substr($info[1], 1);
        $target = substr($info[1], 0, strlen($info[1]) - 1);
        new_dispatcher($id, $route, $target, $time);
    }
}

function new_receive($id, $source) {
    setRedisData($id, $source, 600);
}

function new_dispatcher($id, $route, $target, $time) {
    $source = getRedisData($id);
    if (!$source) { return; }
    if (substr($target, 0, 4) === 'tcp:') {
        $type = 'TCP';
    } else if (substr($target, 0, 4) === 'udp:') {
        $type = 'UDP';
    } else {
        return;
    }
    $target = substr($target, 4 - strlen($target));
    if (substr($route, -1) === '4') {
	$ip_version = 'IPv4';
        $route = substr($route, 0, strlen($route) - 1);
    } else if (substr($route, -1) === '6') {
        $ip_version = 'IPv6';
        $route = substr($route, 0, strlen($route) - 1);
    } else {
        $ip_version = '';
    }
    new_connection(array(
        'time' => $time,
        'type' => $type,
        'source' => $source,
	'target' => $target,
	'route' => $route,
	'ip_version' => $ip_version
    ));
}

function getRedisData($key) { // 查询Redis缓存 不存在返回NULL
    global $redisSetting;
    $redis = new Redis();
    $redis->connect($redisSetting['host'], $redisSetting['port']);
    if ($redisSetting['passwd'] !== '') {
        $redis->auth($redisSetting['passwd']); // 密码认证
    }
    $redisKey = $redisSetting['prefix'] . $key;
    $redisValue = $redis->exists($redisKey) ? $redis->get($redisKey) : NULL;
    return $redisValue;
}

function setRedisData($key, $data, $cacheTTL = 0) { // 写入Redis缓存 默认不过期
    global $redisSetting;
    $redis = new Redis();
    $redis->connect($redisSetting['host'], $redisSetting['port']);
    if ($redisSetting['passwd'] !== '') {
        $redis->auth($redisSetting['passwd']); // 密码认证
    }
    $redisKey = $redisSetting['prefix'] . $key;
    $status = $redis->set($redisKey, $data); // 写入数据库
    if ($cacheTTL > 0) {
        $redis->pexpire($redisKey, $cacheTTL * 1000); // 设置过期时间 单位 ms = s * 1000
    }
    return $status;
}

function new_connection($info) {
    global $fo;
    $record = '[' . $info['time'] . '] ';
    $record .= str_pad($info['source'], 19, ' ') . ' -> ';
    $record .= str_pad('[' . $info['ip_version'] . ']', 6, ' ') . ' ';
    $record .= $info['type'] . ' ' . str_pad($info['route'], 6, ' ') . ' -> ';
    $record .= $info['target'];
    fwrite($fo, $record . PHP_EOL);
}

?>
