#!/bin/bash

# Tên screen session
SESSION_NAME="layeredge-bot"

# Hàm kiểm tra và cài đặt Node.js
install_nodejs() {
    echo "Kiểm tra Node.js..."
    if ! command -v node &> /dev/null; then
        echo "Đang cài đặt Node.js 18.x..."
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        sudo apt-get install -y nodejs
        
        # Kiểm tra lại sau khi cài đặt
        if ! command -v node &> /dev/null; then
            echo "Không thể cài đặt Node.js! Thoát..."
            exit 1
        fi
        
        echo "Cài đặt npm packages cần thiết..."
        sudo npm install -g npm@latest
    fi
}

# Cài đặt screen nếu chưa có
if ! command -v screen &> /dev/null; then
    echo "Cài đặt screen..."
    sudo apt-get update && sudo apt-get install -y screen
fi

# Kiểm tra và cài đặt Node.js
install_nodejs

# Tạo screen session mới và chạy các lệnh
screen -S $SESSION_NAME -dm bash -c '
    echo "Đang clone repository...";
    git clone https://github.com/vietlinhh02/LayerEdge-Auto-Bot || true;
    
    echo "Vào thư mục làm việc...";
    cd LayerEdge-Auto-Bot;
    
    echo "Cài đặt dependencies...";
    npm install;
    
    echo "Chạy file ref.js...";
    if node ref.js; then
        echo "ref.js chạy thành công! Bắt đầu main.js...";
        node main.js;
    else
        echo "Lỗi khi chạy ref.js!";
        exit 1;
    fi;
    
    while true; do
        sleep 3600;
    done
'

echo "----------------------------------------------"
echo "ĐÃ THIẾT LẬP THÀNH CÔNG!"
echo "Phiên bản Node.js: $(node -v)"
echo "Phiên bản npm: $(npm -v)"
echo "Để xem tiến trình: screen -r $SESSION_NAME"
echo "Để thoát khỏi chế độ xem: Ctrl+A sau đó D"
echo "----------------------------------------------"
