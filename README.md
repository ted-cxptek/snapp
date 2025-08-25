# Hosting a Snapp in Lokinet

## Giới thiệu

**Lokinet** là một lớp mạng phi tập trung, ẩn danh cung cấp tên miền `.loki` để lưu trữ dịch vụ. Một **snapp** là ứng dụng web hoặc dịch vụ được lưu trữ trên mạng Lokinet.

Hướng dẫn này chỉ ra cách triển khai ứng dụng web sử dụng Docker containers với Lokinet để kết nối mạng và Nginx để phục vụ web.

- Repository: https://github.com/ted-cxptek/snapp

## Chi tiết Dockerfile

### **Dockerfile** - Snapp Container (`Dockerfile`)

**Chức năng**: Cài đặt, khởi động Lokinet và chạy web server Nginx cơ bản

**Quy trình hoạt động**:

1. **Cài đặt**: Ubuntu + Lokinet + Nginx + công cụ cần thiết
2. **Cấu hình Lokinet**:
    - Tạo private key và bootstrap
    - Cấu hình virtual IP (10.67.0.1/16)
    - Thiết lập keyfile paths
3. **Khởi động**
    - Khởi động Nginx web server
    - Chạy Lokinet network service, Chờ 15 giây để Lokinet sẵn sàng
    - Có thể check logs của container để biết Lokinet đã sẵn sàng
        
        `docker logs --tail 1000 -f container-id`
        

### **Dockerfile.test** - Test Container (`Dockerfile.test`)

**Chức năng**: Cài đặt, khởi động Lokinet và thử gửi request đến Snapp qua tên miền .loki

**Quy trình hoạt động**:

1. **Cài đặt**: Ubuntu + Lokinet + công cụ DNS testing
2. **Cấu hình DNS**:
    - Thiết lập nameserver 127.3.2.1 cho .loki domains
    - Cấu hình resolvconf
3. **Khởi động Lokinet**:
    - Chạy Lokinet trong background
    - Chờ 15 giây để network sẵn sàng
    - Có thể check logs của container để biết Lokinet đã sẵn sàng
        
        `docker logs --tail 1000 -f container-id`
        

---

## Start Snapp và Client

```bash
# Khởi động dịch vụ Snapp
docker-compose -f docker-compose.yml up --build -d

# Truy cập cục bộ, test web server
curl <http://localhost:8080>

# Khởi động dịch vụ Client truy cap Snapp
docker-compose -f docker-compose.test.yml up --build -d

```

## Lấy SNapp loki domain

Để lấy tên miền .loki của Snapp, bạn cần thực thi vào Snapp container và chạy script `get_loki_address.sh`:

```bash
# Exec to Snapp container
docker exec -it snapp-lokinet-1 /bin/bash
# Run script to get loki address
./get_loki_address.sh

```

```bash
# Result:
Using domain server:
Name: 127.3.2.1
Address: 127.3.2.1#53
Aliases:

localhost.loki is an alias for t5hn48fdpwo3zjhu49z8q8qtrz3q977rki89t4s318cgpgjm519y.loki.

```

`t5hn48fdpwo3zjhu49z8q8qtrz3q977rki89t4s318cgpgjm519y.loki` là tên miền Loki của Snapp

## Kiểm tra request tới SNapp

Cần thực thi vào container của Client đã chạy Lokinet:

```bash
# Exec to Client container
docker exec -it snapp-lokinet-test /bin/bash

# Try curl to Snapp domain
curl t5hn48fdpwo3zjhu49z8q8qtrz3q977rki89t4s318cgpgjm519y.loki

```

```bash
# Output
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lokinet SNApp</title>
 </head>
 <body>...</body>
</html>

```

Hoặc có thể curl tới `http://kcpyawm9se7trdbzncimdi5t7st4p5mh9i1mg7gkpuubi4k4ku1y.loki/` , là domain Oxen cung cấp để test

## Kết luận

- Có thể config Snap như là một web server, server của dịch vụ Chat
- Các Client cần chạy Lokinet để có thể giao tiếp với Server(Snapp) đảm bảo việc privacy, cả 2 bên Client và Server đều ẩn danh và riêng tư

## Tài liệu kham thảo

| **Chủ đề** | **Nội dung** | **Link** |
| --- | --- | --- |
| Hosting Snapp | Guide hosting snap | https://docs.oxen.io/oxen-docs/products-built-on-oxen/lokinet/snapps/hosting-snapps |
| Troubleshooting DNS resolve | Khắc phục lỗi DNS resolve | https://docs.oxen.io/oxen-docs/products-built-on-oxen/lokinet/guides/linux-troubleshooting |
| Lokinet Domain | Một số Lokinet domain có sẵn | https://loki.network/2020/04/07/lokinet-gui-release/ |