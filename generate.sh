#!/bin/bash

if [ $# -ne 2 ]; then
  echo "Usage: $0 <template file> <output directory>"
  exit 1
fi
template=$1
output_dir=$2
if [ ! -f "$template" ]; then
  echo "File does not exist."
  exit 1
fi

dns_global_list=(
  https://1.1.1.1/dns-query
  https://1.0.0.1/dns-query
  https://8.8.8.8/dns-query
  https://8.8.4.4/dns-query
  https://9.9.9.9/dns-query
  https://149.112.112.112/dns-query
  tls://1.1.1.1
  tls://1.0.0.1
  tls://8.8.8.8
  tls://8.8.4.4
  tls://9.9.9.9
  tls://149.112.112.112
)
cdn_snippet_list=(
  https://fastly.jsdelivr.net/gh/senzyo/sing-box-rules@sing/
  https://gcore.jsdelivr.net/gh/senzyo/sing-box-rules@sing/
  https://testingcf.jsdelivr.net/gh/senzyo/sing-box-rules@sing/
  https://mirror.ghproxy.com/https://raw.githubusercontent.com/senzyo/sing-box-rules/sing/
  https://ghproxy.net/https://raw.githubusercontent.com/senzyo/sing-box-rules/sing/
  https://ghproxy.senzyo.net/https://raw.githubusercontent.com/senzyo/sing-box-rules/sing/
)

for dns_global in "${dns_global_list[@]}"; do
  if [[ $dns_global =~ "https:" ]]; then
    dns_protocol="doh"
    dns_china="https://223.5.5.5/dns-query"
  fi
  if [[ $dns_global =~ "tls:" ]]; then
    dns_protocol="dot"
    dns_china="tls://223.5.5.5"
  fi
  dns_server=$(echo "$dns_global" | awk -F/ '{print $3}')
  if [ -n "$dns_server" ]; then
    echo "Matched $dns_protocol of $dns_server"
    for cdn_snippet in "${cdn_snippet_list[@]}"; do
      cdn_server=$(echo "$cdn_snippet" | awk -F/ '{print $3}')
      if [ -n "$cdn_server" ]; then
        echo "Matched $cdn_server"
        final_output_dir=$output_dir/$dns_protocol/$dns_server/$cdn_server
        mkdir -p $final_output_dir
        jq --arg dns_china "$dns_china" --arg dns_global "$dns_global" --arg cdn_snippet "$cdn_snippet" \
          '.dns.servers[] |= if .tag=="国内DNS" then .address = $dns_china elif .tag=="国际DNS" then .address = $dns_global else . end | .route.rule_set[].url |= sub("https.*?sing\/"; $cdn_snippet)' $template >$final_output_dir/config.json
      else
        echo "Not matched."
      fi
    done
  else
    echo "Not matched."
  fi
done
