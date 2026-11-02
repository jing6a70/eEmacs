#!/usr/bin/env bash
# ~/.emacs.d/initmint.sh --- 新机器(Linux Mint / Ubuntu)上的字体初始化
#
# 配置里 early-init.el 指定了:
#   英文等宽: Fira Code   中文: Noto Sans CJK SC
# 本脚本负责把 Fira Code 装上并刷新字体缓存; 装完重启 Emacs 即可.
#
# 用法:  ./initmint.sh
#        ./initmint.sh --check    # 只检查, 不安装

set -euo pipefail

FONT_FAMILY="Fira Code"
CJK_FAMILY="Noto Sans CJK SC"

have_font() {
  fc-match "$FONT_FAMILY" 2>/dev/null | grep -qi "FiraCode\|Fira Code"
}

check_all() {
  local ok=0
  if have_font; then
    echo "[ok]   $FONT_FAMILY -> $(fc-match "$FONT_FAMILY")"
  else
    echo "[miss] $FONT_FAMILY"
    ok=1
  fi
  if fc-match "$CJK_FAMILY" 2>/dev/null | grep -qi "Noto Sans CJK"; then
    echo "[ok]   $CJK_FAMILY"
  else
    echo "[warn] $CJK_FAMILY 未安装, 中文会 fallback 到默认字体"
  fi
  return $ok
}

install_via_apt() {
  command -v apt-get >/dev/null 2>&1 || return 1
  apt-cache show fonts-firacode >/dev/null 2>&1 || return 1
  echo "==> apt-get install fonts-firacode"
  sudo apt-get update -qq
  sudo apt-get install -y fonts-firacode
}

install_via_download() {
  local dir="${XDG_DATA_HOME:-$HOME/.local/share}/fonts"
  local url="https://github.com/tonsky/FiraCode/releases/download/6.2/Fira_Code_v6.2.zip"
  local tmp
  tmp="$(mktemp -d)"
  echo "==> 下载 Fira Code 到 $dir"
  mkdir -p "$dir"
  if command -v curl >/dev/null 2>&1; then
    curl -fL "$url" -o "$tmp/fira.zip"
  elif command -v wget >/dev/null 2>&1; then
    wget -O "$tmp/fira.zip" "$url"
  else
    echo "需要 curl 或 wget" >&2
    rm -rf "$tmp"
    return 1
  fi
  command -v unzip >/dev/null 2>&1 || { echo "需要 unzip" >&2; rm -rf "$tmp"; return 1; }
  unzip -q "$tmp/fira.zip" -d "$tmp"
  find "$tmp" -name '*.ttf' -exec cp -f {} "$dir/" \;
  rm -rf "$tmp"
}

case "${1:-}" in
  --check|-c)
    check_all
    exit $?
    ;;
  -h|--help)
    sed -n '2,10p' "$0"
    exit 0
    ;;
esac

if have_font; then
  echo "==> $FONT_FAMILY 已安装: $(fc-match "$FONT_FAMILY")"
else
  echo "==> 未检测到 $FONT_FAMILY, 开始安装"
  if ! install_via_apt; then
    install_via_download
  fi
  fc-cache -f >/dev/null 2>&1 || true
fi

echo
check_all || {
  echo
  echo "字体仍未生效: 确认 $FONT_FAMILY 已安装, 然后重启 Emacs."
  exit 1
}

echo
echo "完成. 重启 Emacs 让 early-init.el 里的字体设置生效."
