#!/bin/bash

# --- 0. 参数检查 ---
if [ $# -ne 3 ]; then
  echo "Usage: $0 <source template> <output directory> <output file>"
  exit 1
fi

TEMPLATE=$1
OUTPUT_DIR=$2
CONFIG_NAME=$3

if [ ! -f "$TEMPLATE" ]; then
  echo "Error: Template file '$TEMPLATE' does not exist."
  exit 1
fi

# --- 1. 定义支持的协议与地址逻辑 ---

# 定义服务商及其支持的协议: "名称:协议1,协议2..."
DNS_CHINA_LIST=(
  "ali:https,tls,quic,h3"
  "dnspod:https,tls"
)

DNS_GLOBAL_LIST=(
  "adguard:https,tls,quic,h3"
  "cloudflare:https,tls,quic,h3"
  "google:https,tls,quic,h3"
  "opendns:https,tls"
)

# CDN配置: "别名|URL前缀"
CDN_LIST=(
  "fastly.jsdelivr.net|https://fastly.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/"
  "gcore.jsdelivr.net|https://gcore.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/"
  "testingcf.jsdelivr.net|https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/"
  "ghproxy.net|https://ghproxy.net/https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/sing/"
  "gh-proxy.org|https://gh-proxy.org/https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/sing/"
  "ghfast.top|https://ghfast.top/https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/sing/"
)

# --- 2. 获取 DNS 地址 ---

get_dns_host() {
  local provider=$1
  local proto=$2

  case "$provider" in
    ali)        echo "dns.alidns.com" ;;
    adguard)    echo "unfiltered.adguard-dns.com" ;;
    google)     echo "dns.google" ;;
    opendns)    echo "dns.opendns.com" ;;
    
    # 特殊情况: 不同协议地址不同
    dnspod)
      [[ "$proto" == "https" ]] && echo "doh.pub" || echo "dot.pub"
      ;;
    cloudflare)
      [[ "$proto" == "tls" ]] && echo "1dot1dot1dot1.cloudflare-dns.com" || echo "cloudflare-dns.com"
      ;;
  esac
}

# --- 3. 生成逻辑 ---

generate_config() {
  local protocol=$1
  local cn_name=$2
  local cn_host=$3
  local global_name=$4
  local global_host=$5
  local cdn_name=$6
  local cdn_url=$7

  local path="$OUTPUT_DIR/$protocol/$cn_name/$global_name/$cdn_name"
  
  # 只有目录不存在时才调用 mkdir
  [[ -d "$path" ]] || mkdir -p "$path"

  jq --arg protocol "$protocol" \
     --arg dns_china "$cn_host" \
     --arg dns_global "$global_host" \
     --arg cdn_prefix "$cdn_url" '
    .dns.servers |= map(
      if .tag == "ProxyDNS" then
        .server = $dns_global | .type = $protocol
      elif .tag == "DirectDNS" then
        .server = $dns_china | .type = $protocol
      else
        .
      end
    )
    | .route.rule_set[].url |= sub("https.*?sing\/"; $cdn_prefix)
  ' "$TEMPLATE" > "$path/$CONFIG_NAME"
}

echo "Starting generation..."

# --- 4. 主循环 ---

for cn_item in "${DNS_CHINA_LIST[@]}"; do
  IFS=':' read -r cn_name cn_protos <<< "$cn_item"
  
  for global_item in "${DNS_GLOBAL_LIST[@]}"; do
    IFS=':' read -r global_name global_protos <<< "$global_item"
    
    # 遍历 CDN (最内层通常是 CDN)
    for cdn_item in "${CDN_LIST[@]}"; do
      IFS='|' read -r cdn_name cdn_url <<< "$cdn_item"

      # 协议通常是各个服务商的交集。
      # 检查当前的 CN 和 Global 是否都支持该协议。
      
      # 将协议字符串转为数组
      IFS=',' read -ra valid_cn_protos <<< "$cn_protos"
      IFS=',' read -ra valid_global_protos <<< "$global_protos"

      # 取出所有可能的协议 (https tls quic h3)
      for protocol in https tls quic h3; do
        
        # 检查 CN 是否支持当前协议
        if [[ ! " ${valid_cn_protos[*]} " =~ " ${protocol} " ]]; then continue; fi
        
        # 检查 Global 是否支持当前协议
        if [[ ! " ${valid_global_protos[*]} " =~ " ${protocol} " ]]; then continue; fi

        # 获取实际地址
        cn_host=$(get_dns_host "$cn_name" "$protocol")
        global_host=$(get_dns_host "$global_name" "$protocol")

        # 生成
        # echo "Gen: $protocol | $cn_name -> $global_name | $cdn_name"
        generate_config "$protocol" "$cn_name" "$cn_host" "$global_name" "$global_host" "$cdn_name" "$cdn_url"
      
      done
    done
  done
done

# --- 5. 统计输出 ---

dir_count=$(find "$OUTPUT_DIR" -type d | wc -l)
file_count=$(find "$OUTPUT_DIR" -type f | wc -l)
echo "Generation Complete."
echo "Directory Count: $dir_count"
echo "File Count: $file_count"