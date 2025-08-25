# Hosting a Snapp in Lokinet

## Giới thiệu

**Lokinet** là một lớp mạng phi tập trung, ẩn danh cung cấp tên miền `.loki` để lưu trữ dịch vụ. Một **snapp** là ứng dụng web hoặc dịch vụ được lưu trữ trên mạng Lokinet.

Hướng dẫn này chỉ ra cách triển khai ứng dụng web sử dụng Docker containers với Lokinet để kết nối mạng và Nginx để phục vụ web.

## Yêu cầu hệ thống

- **Docker** và **Docker Compose**
- Hiểu biết cơ bản về containerization
- Cổng 8080 có sẵn trên máy chủ của bạn
- Kết nối internet để thiết lập ban đầu

## Cấu trúc dự án

```
snapp/
├── Dockerfile                    # Main snapp container build
├── docker-compose.yml           # Production deployment
├── Dockerfile.test              # Test client container
├── docker-compose.test.yml      # Testing environment
├── data/                        # Production data directory
│   ├── var_lib_lokinet/        # Lokinet configuration & data
│   ├── nginx/                  # Nginx configuration files
│   └── webroot/                # Web application files
└── test-data/                  # Test environment data
    └── var_lib_lokinet/        # Test Lokinet data
```

## Thành phần

### **Snapp Container** (`docker-compose.yml`)
- **Mục đích**: Lưu trữ dịch vụ web của bạn
- **Dịch vụ**: Nginx + Lokinet (tích hợp trong một container)
- **Cổng**: 8080:80 (host:container)

### **Test Container** (`docker-compose.test.yml`)
- **Mục đích**: Client để kiểm tra truy cập tên miền .loki
- **Dịch vụ**: Lokinet (chỉ phân giải DNS)

## Chi tiết Dockerfile

### **Dockerfile** - Snapp Container
**Chức năng**: Cài đặt, khởi động Lokinet và chạy web server Nginx cơ bản

**Quy trình hoạt động**:
1. **Cài đặt**: Ubuntu + Lokinet + Nginx + công cụ cần thiết
2. **Cấu hình Lokinet**: 
   - Tạo private key và bootstrap
   - Cấu hình virtual IP (10.67.0.1/16)
   - Thiết lập keyfile paths
3. **Khởi động dịch vụ**:
   - Khởi động Nginx web server
   - Chạy Lokinet network service
4. **Kết quả**: Container hoạt động với cả web server và network layer

### **Dockerfile.test** - Test Container
**Chức năng**: Cài đặt, khởi động Lokinet và thử gửi request đến Snapp qua tên miền .loki

**Quy trình hoạt động**:
1. **Cài đặt**: Ubuntu + Lokinet + công cụ DNS testing
2. **Cấu hình DNS**: 
   - Thiết lập nameserver 127.3.2.1 cho .loki domains
   - Cấu hình resolvconf
3. **Khởi động Lokinet**: 
   - Chạy Lokinet trong background
   - Chờ 15 giây để network sẵn sàng
4. **Kết quả**: Container có thể phân giải và truy cập .loki domains

---

## Run Snapp, Client

```bash
# Khởi động dịch vụ Snapp
docker-compose -f docker-compose.yml up --build -d

# Truy cập cục bộ
curl http://localhost:8080

# Khởi động dịch vụ Client truy cap Snapp
docker-compose -f docker-compose.test.yml up --build -d

```

## Lấy tên miền .loki

Để lấy tên miền .loki của Snapp, bạn cần thực thi vào container và chạy script `get_loki_address.sh`:

### **Bước 1: Kiểm tra container đang chạy**
```bash
docker ps
```

### **Bước 2: Thực thi vào Snapp container**
```bash
docker exec -it snapp-lokinet-1 /bin/bash
```

### **Bước 3: Chạy script lấy địa chỉ .loki**
```bash
./get_loki_address.sh
```

### **Kết quả:**
Script sẽ hiển thị tên miền .loki của bạn, ví dụ:
```
localhost.loki is an alias for 73qqjm7ju98g6obua8bprce1tjyyphnotknnijhpn8mypwumqs8o.loki.
```


### **Lưu ý quan trọng:**
- **DNS 127.3.2.1**: Chỉ hoạt động khi Lokinet đang chạy
- **Tên miền .loki**: Chỉ có thể truy cập từ mạng Lokinet
- **Bảo mật**: Lokinet cung cấp kết nối ẩn danh và mã hóa
- **Tốc độ**: Có thể chậm hơn internet thông thường do routing ẩn danh
