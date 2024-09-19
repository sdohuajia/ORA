#!/bin/bash

# 脚本保存路径
SCRIPT_PATH="$HOME/ora.sh"

# 主菜单函数
main_menu() {
    while true; do
        clear
        echo "脚本由大赌社区哈哈哈哈编写，推特 @ferdie_jhovie，免费开源，请勿相信收费"
        echo "如有问题，可联系推特，仅此只有一个号"
        echo "        __  _
    .-:'  `; `-._
   (_,           )
 ,'o"(            )>
(__,-'            )
   (             )
    `-'._.--._.-'
"
        echo "================================================================"
        echo "退出脚本，请按键盘 ctrl + C 退出即可"
        echo "请选择要执行的操作:"
        echo "1) 部署环境"
        echo "2) 启动节点"
        echo "3) 查看日志"
        echo "4) 退出"
        read -p "选择一个操作: " choice

        case $choice in
            1)
                deploy_environment
                ;;
            2)
                start_node
                ;;
            3)
                view_logs
                ;;
            *)
                exit 0
                ;;
        esac
    done
}

# 部署环境函数
deploy_environment() {
    # 更新并升级系统
    echo "更新系统包..."
    sudo apt update -y && sudo apt upgrade -y

    # 安装必要的依赖包
    echo "安装必要的依赖包..."
    sudo apt install -y ca-certificates zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev tmux iptables curl nvme-cli git wget make jq libleveldb-dev build-essential pkg-config ncdu tar clang bsdmainutils lsb-release libssl-dev libreadline-dev libffi-dev gcc screen unzip lz4

    # 检查 Docker 是否已安装
    if ! command -v docker &> /dev/null
    then
        echo "Docker 未安装，正在安装 Docker..."

        # 添加 Docker 的 GPG 密钥
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

        # 设置 Docker 仓库
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        # 更新软件包列表
        sudo apt-get update

        # 安装 Docker
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io

        # 检查 Docker 版本
        docker version
    else
        echo "Docker 已安装。"
        docker version
    fi

    # 检查 Docker Compose 是否已安装
    if ! command -v docker-compose &> /dev/null
    then
        echo "Docker Compose 未安装，正在安装最新版本..."

        # 获取最新的 Docker Compose 版本号
        VER=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)

        # 下载并安装 Docker Compose
        sudo curl -L "https://github.com/docker/compose/releases/download/${VER}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

        # 赋予执行权限
        sudo chmod +x /usr/local/bin/docker-compose

        # 检查 Docker Compose 版本
        docker-compose --version
    else
        echo "Docker Compose 已安装。"
        docker-compose --version
    fi

    # 将用户添加到 Docker 组
    echo "配置 Docker 用户组..."
    sudo groupadd docker
    sudo usermod -aG docker $USER
    newgrp docker

    # 克隆 Tora Docker Compose 仓库
    echo "克隆 Tora Docker Compose 仓库..."
    git clone https://github.com/ora-io/tora-docker-compose
    cd tora-docker-compose

    # 复制 .env 文件
    echo "配置 .env 文件..."
    cp .env.example .env

    # 提示用户输入私钥和其他信息
    echo "请填写以下信息："

    read -p "请输入您的 Privkey: " PRIVKEY
    read -p "请输入 WSS Main: " WSS_MAIN
    read -p "请输入 HTTPS Main: " HTTPS_MAIN
    read -p "请输入 Sepholia WSS: " SEPHOLIA_WSS
    read -p "请输入 Sepholia HTTPS: " SEPHOLIA_HTTPS

    # 将用户输入写入 .env 文件
    sed -i "s/PRIVATE_KEY=.*/PRIVATE_KEY=$PRIVKEY/" .env
    sed -i "s/WSS_MAIN=.*/WSS_MAIN=$WSS_MAIN/" .env
    sed -i "s/HTTPS_MAIN=.*/HTTPS_MAIN=$HTTPS_MAIN/" .env
    sed -i "s/SEPHOLIA_WSS=.*/SEPHOLIA_WSS=$SEPHOLIA_WSS/" .env
    sed -i "s/SEPHOLIA_HTTPS=.*/SEPHOLIA_HTTPS=$SEPHOLIA_HTTPS/" .env

    echo ".env 文件已配置完成！"
    echo "部署环境完成，按任意键返回主菜单..."
    read -n 1 -s
}

# 启动节点函数
start_node() {
    # 让用户输入 vm.overcommit_memory 参数值，默认值为 2
    read -p "请输入 vm.overcommit_memory 值 (默认 2): " overcommit_value
    overcommit_value=${overcommit_value:-2}

    # 设置内核参数
    echo "设置 vm.overcommit_memory 为 $overcommit_value..."
    sudo sysctl vm.overcommit_memory=$overcommit_value

    # 启动节点
    echo "启动节点..."
    cd tora-docker-compose
    docker compose up

    echo "节点已启动，按任意键返回主菜单..."
    read -n 1 -s
}

# 查看日志函数
view_logs() {
    # 查看 Docker Compose 日志
    echo "查看 Tora Docker Compose 日志..."
    cd tora-docker-compose
    docker compose logs -f

    echo "日志查看完毕，按任意键返回主菜单..."
    read -n 1 -s
}

# 运行主菜单
main_menu
