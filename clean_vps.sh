#!/bin/bash

# 一键清理VPS垃圾文件和不必要依赖的脚本
echo "欢迎使用VPS清理脚本！"
echo "请确认需要清理的内容："

# 函数：询问用户是否执行某项清理
ask_permission() {
    while true; do
        read -p "$1 (y/n): " choice
        case $choice in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "请输入 y 或 n";;
        esac
    done
}

# 清理APT缓存
if ask_permission "是否清理APT缓存？"; then
    echo "清理APT缓存..."
    apt-get clean
    apt-get autoclean
fi

# 移除不再需要的依赖包
if ask_permission "是否移除不必要的依赖包？"; then
    echo "移除不必要的依赖包..."
    apt-get autoremove -y
fi

# 删除临时文件
if ask_permission "是否删除临时文件（/tmp 和 /var/tmp）？"; then
    echo "删除临时文件..."
    rm -rf /tmp/*
    rm -rf /var/tmp/*
fi

# 清理日志文件
if ask_permission "是否清理日志文件（/var/log）？"; then
    echo "清理旧日志文件..."
    find /var/log -type f -name "*.log" -exec truncate -s 0 {} \;
    find /var/log -type f -name "*.gz" -delete
fi

# 删除用户下载目录中的文件
if ask_permission "是否清理用户下载目录（~/Downloads）？"; then
    echo "清理用户下载目录中的垃圾文件..."
    rm -rf ~/Downloads/* 2>/dev/null
fi

# 显示清理后的磁盘空间
echo "清理完成！当前磁盘使用情况："
df -h /

echo "清理脚本执行完毕！"
