# 使用Ubuntu基础镜像
FROM ubuntu:22.04

# 设置代理（替换为你的代理URL）
# ENV http_proxy=http://192.168.104.4:5566
# ENV https_proxy=http://192.168.104.4:5566
# ENV no_proxy=localhost,127.0.0.1

# 安装必要的工具
RUN apt-get update && \
    apt-get install -y \
    tar \
    qemu \
    qemu-utils \
    parted \
    e2fsprogs \
    kmod \
    fdisk \
    util-linux \
    xz-utils \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 将处理脚本复制到容器中
COPY create_rootfs.sh /usr/local/bin/create_rootfs.sh

# 设置脚本为可执行
RUN chmod +x /usr/local/bin/create_rootfs.sh

# 设置默认命令
CMD ["/usr/local/bin/create_rootfs.sh"]
