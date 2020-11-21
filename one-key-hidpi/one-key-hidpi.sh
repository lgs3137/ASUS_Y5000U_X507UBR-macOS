#!/bin/bash

# lgs3137修改适配ASUS Y5000U(X507UBR)
# stevezhengshiqi重写于2019.02.25
# 这个脚本是 https://github.com/xzhih/one-key-hidpi 的一个精简，谢谢@xzhih
# 只支持ASUS Y5000U (dae,15f5)

DISPLAYPATH="/Library/Displays/Contents/Resources/Overrides"

# 界面 (参考:https://github.com/xzhih/one-key-hidpi/master/hidpi.sh)
function interface() {
    echo '  _    _   _____   _____    _____    _____ '
    echo ' | |  | | |_   _| |  __ \  |  __ \  |_   _|'
    echo ' | |__| |   | |   | |  | | | |__) |   | |'
    echo ' |  __  |   | |   | |  | | |  ___/    | |'
    echo ' | |  | |  _| |_  | |__| | | |       _| |_ '
    echo ' |_|  |_| |_____| |_____/  |_|      |_____|'
    echo '此脚本只限于ASUS Y5000U(dae,15f5) !'
    echo '============================================'
}

# 选择选项
function choice() {
    choose=0
    echo '(1) 开启HiDPI'
    echo '(2) 关闭HiDPI'
    echo '(3) 退出'
    read -p "输入你的选择 [1~3]: " choose
}

# 如果网络连接失败，则退出
function networkWarn(){
    echo "错误: 下载one-key-hidpi失败, 请检查网络连接状态"
    clean
    exit 1
}

# 下载资源来自 https://github.com/lgs3137/ASUS_Y5000U_X507UBR-macOS/tree/master/one-key-hidpi
function download(){
    echo '正在下载屏幕文件...'
    mkdir -p one-key-hidpi
    cd one-key-hidpi
    curl -fsSL https://raw.githubusercontent.com/lgs3137/ASUS_Y5000U_X507UBR-macOS/master/one-key-hidpi/Icons.plist -O || networkWarn
    curl -fsSL https://raw.githubusercontent.com/lgs3137/ASUS_Y5000U_X507UBR-macOS/master/one-key-hidpi/DisplayVendorID-dae/DisplayProductID-15f5 -O || networkWarn
    curl -fsSL https://raw.githubusercontent.com/lgs3137/ASUS_Y5000U_X507UBR-macOS/master/one-key-hidpi/DisplayVendorID-dae/DisplayProductID-15f5.icns -O || networkWarn
    curl -fsSL https://raw.githubusercontent.com/lgs3137/ASUS_Y5000U_X507UBR-macOS/master/one-key-hidpi/DisplayVendorID-dae/DisplayProductID-15f5.tiff -O || networkWarn
    echo '下载完成'
    echo
}

function removeold() {
    # 卸载 HiScale
    echo '正在移除旧版本...'
    sudo launchctl remove /Library/LaunchAgents/org.zysuper.riceCracker.plist
    sudo pkill riceCrackerDaemon
    sudo rm -f /Library/LaunchAgents/org.zysuper.ricecracker.daemon.plist
    sudo rm -f /usr/bin/riceCrackerDaemon

    # 卸载旧版本one-key-hidpi
    sudo rm -rf $DISPLAYPATH/DisplayVendorID-dae
    echo '移除完成'
    echo
}

# 重新挂载系统分区, 如果macOS版本>=10.15
function remountSystem() {
    swver=$(sw_vers -productVersion | sed 's/\.//g' | colrm 5)
    if [[ $swver -ge 1015 ]]; then
        echo '正在重新挂载系统分区来获得写入权限...'
        sudo mount -uw /
        echo '挂载完成'
        echo '请在脚本运行结束后立即重启电脑, 让电脑重新给系统分区上锁!'
        echo
    fi
}

# 给Icons.plist创建备份
function backup() {
    echo '正在备份...'
    sudo mkdir -p $DISPLAYPATH/backup
    sudo cp $DISPLAYPATH/Icons.plist $DISPLAYPATH/backup/
    echo '备份完成'
    echo
}

# 拷贝屏幕文件夹
function copy() {
    echo '正在拷贝文件到目标路径...'
    sudo mkdir -p $DISPLAYPATH/DisplayVendorID-dae
    sudo cp ./Icons.plist $DISPLAYPATH/
    sudo cp ./DisplayProductID-15f5 $DISPLAYPATH/DisplayVendorID-dae/
    sudo cp ./DisplayProductID-15f5.icns $DISPLAYPATH/DisplayVendorID-dae/
    sudo cp ./DisplayProductID-15f5.tiff $DISPLAYPATH/DisplayVendorID-dae/
    echo '拷贝完成'
    echo
}

# 修复权限
function fixpermission() {
    echo '正在修复权限...'
    sudo chown root:wheel $DISPLAYPATH/Icons.plist
    sudo chown root:wheel $DISPLAYPATH/DisplayVendorID-dae
    sudo chown root:wheel $DISPLAYPATH/DisplayVendorID-dae/DisplayProductID-15f5
    sudo chown root:wheel $DISPLAYPATH/DisplayVendorID-dae/DisplayProductID-15f5.icns
    sudo chown root:wheel $DISPLAYPATH/DisplayVendorID-dae/DisplayProductID-15f5.tiff
    echo '修复完成'
    echo
}

# 清理
function clean() {
    echo '正在清理临时文件...'
    sudo rm -rf ../one-key-hidpi
    echo '清理完成'
    echo
}

# 安装
function install() {
    download
    remountSystem
    removeold
    backup
    copy
    fixpermission
    clean
    echo '很棒! 安装已结束, 请重启并在显示器面板选择1424x802分辨率! '
    exit 0
}

# 卸载
function uninstall() {
    echo '正在卸载one-key-hidpi...'
    remountSystem
    sudo rm -rf $DISPLAYPATH/DisplayVendorID-dae

    # 恢复 Icon.plist 从备份文件夹（如果存在）
    if [ -f "$DISPLAYPATH/backup/Icons.plist" ];then
        sudo cp $DISPLAYPATH/backup/Icons.plist $DISPLAYPATH/
        sudo chown root:wheel $DISPLAYPATH/Icons.plist
    fi

    # 移除备份文件夹
    sudo rm -rf $DISPLAYPATH/backup
    echo '卸载完成'
    exit 0
}

# 主程序
function main() {
    interface
    choice
    case $choose in
        1)
        install
        ;;

        2)
        uninstall
        ;;

        3)
        exit 0
        ;;

        *)
        echo "错误: 无效输入, 脚本将退出";
        exit 1
        ;;
    esac
}

main
