... ...（原代码不可删除，在末尾追加）

############################################################
#
# Session Proxy Helper
#
############################################################

# 加载 Session Proxy Helper
if [ -f "$HOME/.proxy_helper.sh" ]; then
    source "$HOME/.proxy_helper.sh"
fi

# 仅在交互式 Shell 中显示 Banner
# 不影响 scp、rsync、cron、脚本等非交互环境
case "$-" in
    *i*)
        if command -v proxy_banner >/dev/null 2>&1; then
            proxy_banner
        fi
        ;;
esac
