<p align="center">
    <img src="https://sing-box.sagernet.org/assets/icon.svg" width="100px" align="center" />
    <h2 align="center">sing-box-templates</h2>
    <p align="center">
        搭配 <a href="https://github.com/Toperlock/sing-box-subscribe">Toperlock/sing-box-subscribe</a> 使用的 <a href="https://sing-box.sagernet.org/zh/">sing-box</a> 配置转换模板, 仅适用于客户端<br />
    </p>
</p>

<h3>
    <p align="center">
        ⚠️ 要求 sing-box 版本 ≥ <a href="https://sing-box.sagernet.org/zh/changelog/">1.12.0</a> ⚠️
    </p>
</h3>

- [1. 模板分类](#1-模板分类)
- [2. 选择模板](#2-选择模板)
  - [2.1 TUN](#21-tun)
  - [2.2 Mixed](#22-mixed)
- [3. 使用示例](#3-使用示例)
- [4. 注意](#4-注意)
- [5. DNS 服务商](#5-dns-服务商)
  - [5.1 Ali DNS](#51-ali-dns)
  - [5.2 DNSPod](#52-dnspod)
- [6. 规则集 CDN](#6-规则集-cdn)

## 1. 模板分类

文件的存储路径按照 "入站方式 → DNS 协议 → DirectDNS 服务商 → ProxyDNS 服务商 → 规则集 CDN → 配置文件名称" 进行层级划分。

比如对于 `https://raw.githubusercontent.com/senzyo/sing-box-templates/public/tun/https/ali/google/testingcf.jsdelivr.net/config.json`, 即 `https://raw.githubusercontent.com/senzyo/sing-box-templates/<Git 分支名称>/<入站方式>/<DNS 协议>/<DirectDNS 服务商>/<ProxyDNS 服务商>/<规则集 CDN>/<配置文件名称>`。

- `入站方式` 的可选值: `mixed`, `tun`
- `DNS 协议` 的可选值: `https`, `tls`, `quic`, `h3`
- `DirectDNS 服务商` 的可选值: `ali`, `dnspod`
- `ProxyDNS 服务商` 的可选值: `adguard`, `cloudflare`, `google`, `opendns`
- `规则集 CDN` 的可选值: `fastly.jsdelivr.net`, `gcore.jsdelivr.net`, `testingcf.jsdelivr.net`, `ghproxy.net`(推荐), `gh-proxy.org`(推荐), `ghfast.top`(域名经常变动, 关注地址发布页 [ghproxy.link](https://ghproxy.link/))
- `配置文件名称` 的可选值: 
  - 对于 `入站方式` 为 `mixed` 的, 可选值: `config.json`
  - 对于 `入站方式` 为 `tun` 的, 可选值: `config.json`, `config_fakeip.json`, `config_apple.json`

当然有些 DNS 服务商不支持 DNS over QUIC (DoQ) 或 DNS over HTTP3 (DoH3), 所以, 当你用上述可选值选择模板时, 确保它在 [public](https://github.com/senzyo/sing-box-templates/tree/public) 分支中是存在的。

## 2. 选择模板

### 2.1 TUN

推荐 Android, Linux 和 Windows 使用入站方式为 `tun` 的模板, 比如:

```
https://raw.githubusercontent.com/senzyo/sing-box-templates/public/tun/https/ali/google/testingcf.jsdelivr.net/config.json
```

也可使用 FakeIP, 比如:

```
https://raw.githubusercontent.com/senzyo/sing-box-templates/public/tun/https/ali/google/testingcf.jsdelivr.net/config_fakeip.json
```

或者只支持 IPv4 的 FakeIP, 比如:

```
https://raw.githubusercontent.com/senzyo/sing-box-templates/public/tun/https/ali/google/testingcf.jsdelivr.net/config_fakeip_ipv4_only.json
```

对于 Apple 设备, 使用文件名为 `config_apple.json` 的模板, 比如:

```
https://raw.githubusercontent.com/senzyo/sing-box-templates/public/tun/https/ali/google/testingcf.jsdelivr.net/config_apple.json
```

### 2.2 Mixed

不推荐使用入站方式仅为 `mixed` 的模板, 比如:

```
https://raw.githubusercontent.com/senzyo/sing-box-templates/public/mixed/https/ali/google/testingcf.jsdelivr.net/config.json
```

## 3. 使用示例

```bash
#!/bin/bash

url_gene="https://a.com"  # 生成配置的后端地址
url_sub="https://b.com"   # 来自机场的订阅链接
url_tpl="https://raw.githubusercontent.com/senzyo/sing-box-templates/public/tun/https/ali/google/testingcf.jsdelivr.net/config.json"  # 配置所用模板的地址
url_dl="$url_gene/config/$url_sub&ua=clashmeta&emoji=1&file=$url_tpl"
echo $url_dl
curl -L -o config.json "$url_dl"
```

也就是说, 可以拼接 `生成配置的后端地址`+`来自机场的订阅链接`+`配置所用模板的地址` 得到最终的订阅地址, 然后将其添加至 Android 或 Apple 设备的 sing-box 图形客户端中。比如: `https://a.com/config/https://b.com&ua=clashmeta&emoji=1&file=https://raw.githubusercontent.com/senzyo/sing-box-templates/public/tun/https/ali/google/testingcf.jsdelivr.net/config.json`

对于 Linux 和 Windows, 可参阅 [sing-box on Linux](https://senzyo.net/2024-2/#日常使用) 和 [sing-box on Windows](https://senzyo.net/2024-3/#日常使用)。

至于 [Toperlock/sing-box-subscribe](https://github.com/Toperlock/sing-box-subscribe) 的更多参数信息, 请阅读其 [README](https://github.com/Toperlock/sing-box-subscribe/blob/main/instructions/README.md)。

## 4. 注意

在 Windows 中, 如果在 TUN 配置中启用了严格路由, 则: 

- 不必手动启用组策略中 `计算机配置`→`管理模板`→`网络`→`DNS 客户端`→`禁用智能多宿主名称解析` 这一策略了, 保持这一策略为 `未配置/已禁用` 即可。
- 不必手动为 sing-box 配置 Windows 防火墙, sing-box 会自动配置的。
- 不然, 你会发现虽然测速延迟还可以, 但实际速度很慢。
- 由于 mihomo 和 sing-box 都使用 sing-tun, 所以上述注意事项同样适用于 mihomo。

## 5. DNS 服务商

`DirectDNS` 包括 `Ali DNS` 和 `DNSPod`。

`ProxyDNS` 包括 `AdGuard DNS`, `Cisco OpenDNS`, `Cloudflare DNS` 和 `Google DNS`。

更多 DNS 服务商 [参考](https://senzyo.net/2022-22/)。

### 5.1 Ali DNS

根据 [公共 DNS 免费版接入限速](https://help.aliyun.com/zh/dns/public-dns-free-version-access-speed-limit-notification), **单 IP 访问量** 超过 **20 QPS**, **UDP/TCP** 流量超过 **2000 bps** 将被限速。
升级到公共 DNS [付费版](https://help.aliyun.com/zh/dns/pricing-overview), 每月有 **1000 万次** 的免费解析额度。

### 5.2 DNSPod

根据 [DoH 与 DoT 说明](https://docs.dnspod.cn/public-dns/dot-doh/), **单个域名解析调用频率** 限制为 **20 QPS**。
开通腾讯云 Public DNS [专业版](https://docs.dnspod.cn/public-dns/pricing-description/), 每月有 **300 万次** 的免费解析额度。

```json
  "dns": {
    "servers": [
      {
        "tag": "ProxyDNS",
        "type": "https",
        "server": "dns.google",
        "domain_resolver": "AliDNS",
        "detour": "🚀FinalOut"
      },
      {
        "tag": "DirectDNS",
        "type": "https",
        "server": "dns.alidns.com",
        "domain_resolver": "AliDNS"
      },
      {
        "tag": "AliDNS",
        "type": "udp",
        "server": "223.5.5.5"
      }
    ],
  ...
  },
```

## 6. 规则集 CDN

仅影响客户端下载规则集的速度。

```json
  "route": {
  ...
    "rule_set": [
    ...
      {
        "tag": "geosite-category-games",
        "type": "remote",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/category-games.srs",
        "download_detour": "🐢Direct",
        "update_interval": "3d"
      },
    ...
    ]
  }
```

源地址举例: 

```
https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/sing/geo/geosite/category-games.json
```

CDN 地址列举:

```
https://fastly.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/category-games.json
```

```
https://gcore.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/category-games.json
```

```
https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/category-games.json
```

```
https://ghproxy.net/https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/sing/geo/geosite/category-games.json
```

```
https://gh-proxy.org/https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/sing/geo/geosite/category-games.json
```

```
https://ghfast.top/https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/sing/geo/geosite/category-games.json
```

由于 GFW 省墙的存在, 各地情况各不相同, 如果在下载规则集时多次遭遇失败, 可自行替换模板中使用的 CDN。

