## 华南理工大学校园网破解

自用服务，可实现免缴费、免登录、不限时、不限速的联网，同时兼具IPv4与IPv6双栈、无污染DNS、分流代理境外流量等功能。

网络拓扑为单臂旁路由模型，借助macvlan实现虚拟旁路由透明代理，系统为原生Debian。

+ `scutweb` ：核心破解容器，以 `http` 、`socks5` 与 `tproxy` 形式提供IPv4与IPv6出口；

+ `cleardns` ：无污染DNS服务，提供分流请求、广告拦截、域名劫持等功能；

+ `route` ：内网虚拟路由，根据规则分流与拦截客户端流量，同时可对客户端进行管理；

+ `freedom` ：出境代理流量服务，支持多种加密翻墙协议；

+ `archive` ：日志模块，主要分析与打包 `scutweb` 与 `route` 模块的日志；

+ `nginx` ：网页管理服务，带https反向代理，内外网环境下均可进行管理；

> 注：仓库中已屏蔽日志记录与部分敏感信息

本项目不会提供具体讲解，读懂相关配置与代码即可自行部署。

相关知识与项目： [TProxy](https://github.com/dnomd343/TProxy)、[ClearDNS](https://github.com/dnomd343/ClearDNS)、[Docker](https://docs.docker.com/)、[macvlan](https://docs.docker.com/network/macvlan/)、[Nginx](https://nginx.org/en/docs/)、[Xray](https://xtls.github.io/)、[Project V](https://www.v2fly.org/)、[AdGuardHome](https://github.com/AdguardTeam/AdguardHome)、[dnsproxy](https://github.com/AdguardTeam/dnsproxy)、[overture](https://github.com/shawn1m/overture)、[v2ray-rules](https://github.com/Loyalsoldier/v2ray-rules-dat)、[v2rayA](https://github.com/v2rayA/v2rayA)、[acme.sh](https://github.com/acmesh-official/acme.sh) ...
