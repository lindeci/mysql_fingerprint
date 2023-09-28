# 检查操作系统类型
if [ -f /etc/redhat-release ]; then
    # CentOS 系统
    sudo yum install -y flex gcc-c++
elif [ -f /etc/lsb-release ]; then
    # Ubuntu 系统
    sudo apt-get install -y flex g++
else
    echo "Unsupported operating system."
    exit 1
fi

flex -o sql_fingerprint.cc sql_fingerprint.l 
g++ sql_fingerprint.cc -o sql_fingerprint