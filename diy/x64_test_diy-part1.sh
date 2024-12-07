#===============================================
# Description: OpenWrt_Build_2410_x64 DIY script
# File name: x64_test_diy-part1.sh
# Lisence: MIT
# By: GXNAS
#===============================================

# Git稀疏克隆，只克隆指定目录到本地
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}

# 插件库
git clone --depth=1 https://github.com/gxnas/OpenWrt_Build_x64_Packages package/GXNAS-package
git clone --depth=1 https://github.com/oppen321/Zero-package package/Zero-package

# golong1.23依赖
#git clone --depth=1 https://github.com/sbwml/packages_lang_golang -b 22.x feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 23.x feeds/packages/lang/golang

# Realtek 网卡 - R8168 & R8125 & R8126 & R8152 & R8101
rm -rf package/kernel/r8168 package/kernel/r8101 package/kernel/r8125 package/kernel/r8126
git clone https://github.com/sbwml/package_kernel_r8168 package/kernel/r8168
git clone https://github.com/sbwml/package_kernel_r8152 package/kernel/r8152
git clone https://github.com/sbwml/package_kernel_r8101 package/kernel/r8101
git clone https://github.com/sbwml/package_kernel_r8125 package/kernel/r8125
git clone https://github.com/sbwml/package_kernel_r8126 package/kernel/r8126

# 一键拨号
git clone --depth=1 https://github.com/sirpdboy/luci-app-netwizard package/luci-app-netwizard

# 在线更新
git clone --depth=1 https://github.com/gxnas/luci-app-gpsysupgrade package/luci-app-gpsysupgrade
sed -i 's/Variable1 = "*.*"/Variable1 = "3092099"/g' package/luci-app-gpsysupgrade/luasrc/model/cbi/gpsysupgrade/sysupgrade.lua
sed -i 's/Variable2 = "*.*"/Variable2 = "OpenWrt_Build_x64_2410"/g' package/luci-app-gpsysupgrade/luasrc/model/cbi/gpsysupgrade/sysupgrade.lua
sed -i 's/Variable3 = "*.*"/Variable3 = "OpenWrt_2305_x64_test"/g' package/luci-app-gpsysupgrade/luasrc/model/cbi/gpsysupgrade/sysupgrade.lua
sed -i 's/Variable4 = "*.*"/Variable4 = "OpenWrt_2305_x64_test"/g' package/luci-app-gpsysupgrade/luasrc/model/cbi/gpsysupgrade/sysupgrade.lua
sed -i 's/Variable1 = "*.*"/Variable1 = "3092099"/g' package/luci-app-gpsysupgrade/root/usr/bin/upgrade.lua
sed -i 's/Variable2 = "*.*"/Variable2 = "OpenWrt_Build_x64_2410"/g' package/luci-app-gpsysupgrade/root/usr/bin/upgrade.lua
sed -i 's/Variable3 = "*.*"/Variable3 = "OpenWrt_2305_x64_test"/g' package/luci-app-gpsysupgrade/root/usr/bin/upgrade.lua
sed -i 's/Variable4 = "*.*"/Variable4 = "OpenWrt_2305_x64_test"/g' package/luci-app-gpsysupgrade/root/usr/bin/upgrade.lua
echo -n "$(date +'%Y%m%d')" > package/base-files/files/etc/openwrt_version

# default settings
git clone https://github.com/sbwml/default-settings package/new/default-settings -b openwrt-24.10

# Theme
git clone --depth 1 https://github.com/sbwml/luci-theme-argon package/new/luci-theme-argon
cp -f $GITHUB_WORKSPACE/images/bg.webp package/new/luci-theme-argon/luci-theme-argon/htdocs/luci-static/argon/img/bg.webp

# OpenAppFilter
git clone https://github.com/sbwml/OpenAppFilter --depth=1 package/OpenAppFilter

# luci-app-partexp
git clone --depth=1 https://github.com/sirpdboy/luci-app-partexp package/luci-app-partexp

# luci-app-webdav
git clone https://github.com/sbwml/luci-app-webdav package/new/luci-app-webdav

# 自定义设置
cp -f $GITHUB_WORKSPACE/diy/banner package/base-files/files/etc/banner

# 移除要替换的包
rm -rf feeds/packages/net/{xray-core,v2ray-core,v2ray-geodata,sing-box,adguardhome,socat}
rm -rf feeds/packages/net/alist feeds/luci/applications/luci-app-alist
rm -rf feeds/packages/utils/v2dat
rm -rf feeds/packages/lang/golang

# 修改默认IP
sed -i 's/192.168.1.1/192.168.1.11/g' package/base-files/files/bin/config_generate

# 调整 x86 型号只显示 CPU 型号
sed -i 's/${g}.*/${a}${b}${c}${d}${e}${f}${hydrid}/g' package/lean/autocore/files/x86/autocore

# 设置ttyd免帐号登录
sed -i 's/\/bin\/login/\/bin\/login -f root/' feeds/packages/utils/ttyd/files/ttyd.config

# samba解除root限制
sed -i 's/invalid users = root/#&/g' feeds/packages/net/samba4/files/smb.conf.template

# coremark跑分定时清除
sed -i '/\* \* \* \/etc\/coremark.sh/d' feeds/packages/utils/coremark/*

# 修改 argon 为默认主题
sed -i '/set luci.main.mediaurlbase=\/luci-static\/bootstrap/d' feeds/luci/themes/luci-theme-bootstrap/root/etc/uci-defaults/30_luci-theme-bootstrap
sed -i 's/Bootstrap theme/Argon theme/g' feeds/luci/collections/*/Makefile
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/*/Makefile

# 最大连接数修改为65535
sed -i '/customized in this file/a net.netfilter.nf_conntrack_max=65535' package/base-files/files/etc/sysctl.conf

# 更改默认 Shell 为 zsh
#sed -i 's/\/bin\/ash/\/usr\/bin\/zsh/g' package/base-files/files/etc/passwd

# 修改主机名称
sed -i "/uci commit system/i\uci set system.@system[0].hostname='OpenWrt-GXNAS'" package/lean/default-settings/files/zzz-default-settings
sed -i "s/hostname='.*'/hostname='OpenWrt-GXNAS'/g" ./package/base-files/files/bin/config_generate

# 显示增加编译时间
sed -i "s/DISTRIB_REVISION='R[0-9]\+\.[0-9]\+\.[0-9]\+'/DISTRIB_REVISION='@R$build_date'/g" package/lean/default-settings/files/zzz-default-settings
sed -i 's/LEDE/OpenWrt_2410_x64_测试版 by GXNAS build/g' package/lean/default-settings/files/zzz-default-settings

# 修改右下角脚本版本信息
sed -i 's/<a class=\"luci-link\" href=\"https:\/\/github.com\/openwrt\/luci\" target=\"_blank\">Powered by <%= ver.luciname %> (<%= ver.luciversion %>)<\/a>/OpenWrt_2410_x64_测试版 by GXNAS build @R'"$build_date"'/' package/luci-theme-argon/luasrc/view/themes/argon/footer.htm
sed -i 's|<a href="https://github.com/jerrykuku/luci-theme-argon" target="_blank">ArgonTheme <%# vPKG_VERSION %></a>|<a class="luci-link" href="https://wp.gxnas.com" target="_blank">🌐固件编译者：【GXNAS博客】</a>|' package/luci-theme-argon/luasrc/view/themes/argon/footer.htm
sed -i 's|<%= ver.distversion %>|<a href="https://d.gxnas.com" target="_blank">👆点这里下载最新版本</a>|' package/luci-theme-argon/luasrc/view/themes/argon/footer.htm
sed -i "/<a class=\"luci-link\"/d; /<a href=\"https:\/\/github.com\/jerrykuku\/luci-theme-argon\"/d; s|<%= ver.distversion %>|OpenWrt_2410_x64_测试版 by GXNAS build @R$build_date|" package/luci-theme-argon/luasrc/view/themes/argon/footer_login.htm

# luci-compat - fix translation
sed -i 's/<%:Up%>/<%:Move up%>/g' feeds/luci/modules/luci-compat/luasrc/view/cbi/tblsection.htm
sed -i 's/<%:Down%>/<%:Move down%>/g' feeds/luci/modules/luci-compat/luasrc/view/cbi/tblsection.htm

# frpc名称
sed -i 's,发送,Transmission,g' feeds/luci/applications/luci-app-transmission/po/zh_Hans/transmission.po
sed -i 's,frp 服务器,FRPS 服务器,g' feeds/luci/applications/luci-app-frps/po/zh_Hans/frps.po
sed -i 's,frp 客户端,FRPC 客户端,g' feeds/luci/applications/luci-app-frpc/po/zh_Hans/frpc.po
sed -i 's/\("admin"\), *\("netwizard"\)/\1, "system", \2/g' package/luci-app-netwizard/luasrc/controller/*.lua

# default config
sed -i 's/#aio read size = 0/aio read size = 0/g' feeds/packages/net/samba4/files/smb.conf.template
sed -i 's/#aio write size = 0/aio write size = 0/g' feeds/packages/net/samba4/files/smb.conf.template
sed -i 's/invalid users = root/#invalid users = root/g' feeds/packages/net/samba4/files/smb.conf.template
sed -i 's/bind interfaces only = yes/bind interfaces only = no/g' feeds/packages/net/samba4/files/smb.conf.template
sed -i 's/#create mask/create mask/g' feeds/packages/net/samba4/files/smb.conf.template
sed -i 's/#directory mask/directory mask/g' feeds/packages/net/samba4/files/smb.conf.template
sed -i 's/0666/0644/g;s/0744/0755/g;s/0777/0755/g' feeds/luci/applications/luci-app-samba4/htdocs/luci-static/resources/view/samba4.js
sed -i 's/0666/0644/g;s/0777/0755/g' feeds/packages/net/samba4/files/samba.config
sed -i 's/0666/0644/g;s/0777/0755/g' feeds/packages/net/samba4/files/smb.conf.template

# 必要的补丁
pushd feeds/luci
    curl -s https://raw.githubusercontent.com/oppen321/path/refs/heads/main/Firewall/0001-luci-mod-status-firewall-disable-legacy-firewall-rul.patch | patch -p1
popd

./scripts/feeds update -a
./scripts/feeds install -a
