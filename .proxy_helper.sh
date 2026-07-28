#!/usr/bin/env bash
# ==========================================================
# Proxy Helper v3.0
# 配合 ~/.bashrc 文件，自动生效
# ==========================================================

PROXY_HOST="192.168.123.16"
PROXY_PORT="10808"

# 可选认证（留空表示无需认证）
PROXY_USERNAME=""
PROXY_PASSWORD=""

if [ -n "$PROXY_USERNAME" ] || [ -n "$PROXY_PASSWORD" ]; then
    PROXY_AUTH="${PROXY_USERNAME}:${PROXY_PASSWORD}@"
else
    PROXY_AUTH=""
fi

PROXY_HTTP="http://${PROXY_AUTH}${PROXY_HOST}:${PROXY_PORT}"
PROXY_SOCKS="socks5h://${PROXY_AUTH}${PROXY_HOST}:${PROXY_PORT}"

_green(){ printf "\033[32m%s\033[0m\n" "$1"; }
_red(){ printf "\033[31m%s\033[0m\n" "$1"; }
_yellow(){ printf "\033[33m%s\033[0m\n" "$1"; }

proxytest() {
    timeout 1 bash -c "</dev/tcp/${PROXY_HOST}/${PROXY_PORT}" >/dev/null 2>&1
}

proxyon() {
    if proxytest; then
        export http_proxy="$PROXY_HTTP"
        export https_proxy="$PROXY_HTTP"
        export HTTP_PROXY="$PROXY_HTTP"
        export HTTPS_PROXY="$PROXY_HTTP"
        export ALL_PROXY="$PROXY_SOCKS"
        export all_proxy="$PROXY_SOCKS"
        _green "Proxy Enabled."
    else
        _red "Proxy server ${PROXY_HOST}:${PROXY_PORT} is offline."
        return 1
    fi
}

proxyoff() {
    unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY
    unset ALL_PROXY all_proxy
    _green "Proxy Disabled."
}

proxytoggle() {
    if [ -n "${ALL_PROXY:-}" ]; then
        proxyoff
    else
        proxyon
    fi
}

proxyshow() {
    echo "========== Proxy Status =========="
    if [ -n "${ALL_PROXY:-}" ]; then
        echo "Status : ON"
    else
        echo "Status : OFF"
    fi
    echo "Server : ${PROXY_HOST}:${PROXY_PORT}"
    echo "HTTP   : ${HTTP_PROXY:-<disabled>}"
    echo "SOCKS  : ${ALL_PROXY:-<disabled>}"
    echo "=================================="
}

myip() {
    curl -4 -fsSL https://ifconfig.me || echo "Unable to detect."
    echo
}

ghtest() {
    curl -o /dev/null -s -w "GitHub HTTP:%{http_code} Time:%{time_total}s\n" https://github.com
}

proxyhelp() {
cat <<EOF
Proxy Helper Commands

proxyon       Enable proxy
proxyoff      Disable proxy
proxytoggle   Toggle proxy
proxyshow     Show status
proxytest     Test proxy server
myip          Show public IP
ghtest        Test GitHub
proxyhelp     Show help
EOF
}

proxy_banner() {
    local vstat="○ Offline"
    local pstat="○ OFF"

    if proxytest; then
        vstat="● Online"
    fi

    if [ -n "${ALL_PROXY:-}" ]; then
        pstat="● ON"
    fi

    cat <<EOF

┌────────────────────────────────────────────────────────────┐
│                  Debian Proxy Helper                       │
├────────────────────────────────────────────────────────────┤
│ Proxy Server : ${PROXY_HOST}:${PROXY_PORT}                        │
│ V2rayN       : ${vstat}                                    │
├────────────────────────────────────────────────────────────┤
│ 外网连接：proxyon                                          │
│ 正常直连：proxyoff                                         │
│ 当前设置仅对本 SSH 会话生效                                │
├────────────────────────────────────────────────────────────┤
│ proxyshow  proxytest  proxytoggle                          │
│ myip       ghtest    proxyhelp                             │
├────────────────────────────────────────────────────────────┤
│ *配置文件：~/.bashrc  ~/.proxy_helper.sh                   │
└────────────────────────────────────────────────────────────┘

EOF
}
