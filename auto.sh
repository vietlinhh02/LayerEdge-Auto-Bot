#!/bin/bash

# ==============================================
# Cấu hình có thể tùy chỉnh
# ==============================================
SESSION_NAME="LayerEdge-AutoBot"       # Tên screen session
REPO_URL="https://github.com/vietlinhh02/LayerEdge-Auto-Bot.git"  # URL GitHub repo
NODE_VERSION="18"                      # Phiên bản Node.js yêu cầu
LOG_FILE="layeredge.log"               # Tên file log
INSTALL_DIR="$HOME/LayerEdge-Auto-Bot"      # Thư mục cài đặt

# ==============================================
# Cài đặt màu sắc cho terminal
# ==============================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ==============================================
# Hàm hiển thị trạng thái
# ==============================================
print_status() {
  echo -e "${CYAN}[STATUS]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

print_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

print_error() {
  echo -e "${RED}[ERROR]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# ==============================================
# Hàm kiểm tra lỗi
# ==============================================
check_error() {
  if [ $? -ne 0 ]; then
    print_error "$1"
    exit 1
  fi
}

# ==============================================
# Hàm cài đặt phụ thuộc
# ==============================================
install_dependencies() {
  print_status "Kiểm tra hệ thống..."
  
  # Kiểm tra và cài đặt screen
  if ! command -v screen &> /dev/null; then
    print_status "Cài đặt screen..."
    sudo apt-get update -qq && sudo apt-get install -y -qq screen
    check_error "Không thể cài đặt screen!"
  fi

  # Kiểm tra Node.js
  if ! command -v node &> /dev/null || [ $(node -v | cut -d'v' -f2 | cut -d'.' -f1) -lt $NODE_VERSION ]; then
    print_status "Cài đặt Node.js $NODE_VERSION.x..."
    curl -fsSL https://deb.nodesource.com/setup_$NODE_VERSION.x | sudo -E bash - >/dev/null
    sudo apt-get install -y -qq nodejs >/dev/null
    check_error "Không thể cài đặt Node.js!"
  fi

  # Kiểm tra git
  if ! command -v git &> /dev/null; then
    print_status "Cài đặt git..."
    sudo apt-get install -y -qq git >/dev/null
    check_error "Không thể cài đặt git!"
  fi
}

# ==============================================
# Hàm chạy bot
# ==============================================
run_bot() {
  print_status "Khởi động bot..."
  cd $INSTALL_DIR || exit 1

  # Tạo screen session và chạy lệnh
  screen -dmS $SESSION_NAME bash -c "
    echo 'Cài đặt dependencies...'
    npm install --quiet
    if [ \$? -ne 0 ]; then
      echo 'Lỗi cài đặt dependencies!'
      exit 1
    fi
    
    echo 'Chạy ref.js...'
    node ref.js && \
    echo 'Chạy main.js...' && \
    node main.js
    while true; do sleep 3600; done
  "

  check_error "Không thể khởi động bot!"
}

# ==============================================
# Hàm chính
# ==============================================
main() {
  # Tạo thư mục và file log
  mkdir -p $INSTALL_DIR
  exec > >(tee -a $INSTALL_DIR/$LOG_FILE) 2>&1

  # Hiển thị banner
  echo -e "${CYAN}"
  echo "=============================================="
  echo " LayerEdge Auto Bot - Deployment Script"
  echo " Phiên bản: 2.0.0"
  echo " Tác giả: Viet Linh"
  echo "=============================================="
  echo -e "${NC}"

  # Cài đặt phụ thuộc
  install_dependencies

  # Clone/Cập nhật repo
  if [ -d "$INSTALL_DIR/.git" ]; then
    print_status "Cập nhật repository..."
    git -C $INSTALL_DIR pull origin main
  else
    print_status "Clone repository..."
    git clone $REPO_URL $INSTALL_DIR
  fi
  check_error "Lỗi khi clone/cập nhật repository!"

  # Chạy bot
  run_bot

  # Hiển thị hướng dẫn
  echo -e "\n${GREEN}"
  echo "=============================================="
  echo " CÀI ĐẶT THÀNH CÔNG!"
  echo "=============================================="
  echo -e "${YELLOW}Để xem bot:${NC}"
  echo "screen -r $SESSION_NAME"
  echo -e "${YELLOW}Để thoát chế độ xem:${NC} Ctrl+A → D"
  echo -e "${YELLOW}File log:${NC} $INSTALL_DIR/$LOG_FILE"
  echo -e "${GREEN}==============================================${NC}"
}

# Chạy hàm chính
main
