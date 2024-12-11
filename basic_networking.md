# Cơ bản về Networking

## IP address:
Là số định danh của 1 thiết bị được cung cấp khi kết nối vào hệ thống mạng. Ở đây chỉ nói về IPv4.

## IPv4:
Gồm 4 bytes, giá trị nhỏ nhất là 0, giá trị lớn nhất là 2^32 -1 = ~4 tỉ address có thể sử dụng.

## Special address:
### Loopback address:
Dải địa chỉ từ 127.0.0.0/8 (127.0.0.0 -> 127.0.0.255).  
Đều được quy ước là `localhost`, có nghĩa là thiết bị của người đang thao tác. Người khác không thể sử dụng được.  
Mục đích để test network call khi phát triển phần mềm.   
Phổ biến thường thấy là 127.0.0.1

### Fault address | Any address: 0.0.0.0

## Private IP address:
Các địa chỉ IPv4 được quy ước dùng để sử dụng nội bộ
- Class A: 10.0.0.0/8 (10.0.0.0 – 10.255.255.255) support ~16 triệu address
- Class B: 172.16.0.0/12 (172.16.0.0 – 172.31.255.255) support ~1 triệu address
- Class C: 192.168.0.0/16 (192.168.0.0 – 192.168.255.255) support ~60k address

## Public IP address:
Các địa chỉ IPv4 được quy ước để public ra Internet. Chỉ có ~4 tỉ public ipv4 address.    
Có thể vào trang https://whatismyipaddress.com/ để xem địa chỉ public IP của mình.

## Gateway:
Là điểm có nhiệm vụ kết nối đến các network khác.  
Ví dụ trong 1 hệ thống mạng LAN thì Router chính là gateway.  
IP Address của Gateway thường là số đầu tiên trong subnet đó.    
### Ví dụ với network 192.168.1.0/24 thì:
- 192.168.1.0: địa chỉ này ko phân phối cho thiết bị nào, dùng để định danh toàn bộ network.
- 192.168.1.1: thường dùng làm địa chỉ cho Gateway.
- 192.168.1.2 - 192.168.1.244: dùng để phân phối cho các thiết bị trong mạng.
- 192.168.1.255: dùng để broadcast network request đến toàn bộ thiết bị trong mạng.

### Cách gateway hoạt động:
Trong 1 hệ thống mạng 192.168.1.0/24 (192.168.1.0 – 192.168.1.255).   
Nếu các thiết bị có trong dải IP này muốn giao tiếp với nhau, gateway sẽ truyền network data từ device này sang device khác.   
Nhưng nếu có thiết bị muốn gửi data đến IP address không nằm trong dải IP này, gateway sẽ gửi request ra bên ngoài.

Sơ đồ tham khảo:
https://drive.google.com/file/d/1xX6We7rG24eEsmbHAe1DjKYBAUooWc1i/view?usp=sharing

## Domain:
Tên miền. Dùng để gợi nhớ thay cho IP Address. Được cấu tạo từ các chuỗi ký tự và phân cách bằng dấu chấm, ví dụ `api.google.com`.  
Cấp độ máy chủ được sắp xếp từ phải sang trái. Ví dụ `api.google.com.vn` thì:
- `vn` là top-level domain
- `com` là second-level domain
- `google` là third-level domain
- `api` là fourth-level domain,
-  ...

Để một domain được sử dụng rộng rãi, nó phải được đăng ký vào máy chủ DNS.

## DNS:
Là hệ thống database dạng Map, chứa [tên_domain_name]:[IP_address].  
Khi cần send network request đến một domain nào đó:
- Hệ thống sẽ truy vấn máy chủ DNS để xác định được IP address
- Sau đó mới có thể gửi network request đến IP address đó.

```bash
# Ví dụ dùng lệnh ping:
ping google.com

# Response:
# PING google.com (142.250.197.206): 56 data bytes
# 64 bytes from 142.250.197.206: icmp_seq=0 ttl=116 time=41.395 ms
# 64 bytes from 142.250.197.206: icmp_seq=1 ttl=116 time=33.353 ms
```

Ví dụ khi dùng trình duyệt web, gõ vào `google.com`, trình duyệt cũng sẽ làm các bước tương tự, nhưng người dùng ko thấy được quá trình đó.

Có thể vào trang https://whois.domaintools.com để biết domain nào đó có IP address là gì.

## Network Port:
Khi muốn request vào 1 network nào đều cần biết IP address và port của nó.  
Thường khi sử dụng trình duyệt web, chúng ta ko phải nhập port, vì trình duyệt sẽ mặc định sử dụng port 80 cho HTTP và port 443 cho HTTPS.  
Hệ điều hành cung cấp 2^16 = ~65k port để sử dụng. Trong đó, các port từ 0 - 1023 đã được đăng ký cho các tiến trình của hệ thống. Các port từ 1024 trở lên được người dùng tuỳ ý sử dụng. Mỗi port chỉ được đăng ký bởi 1 tiến trình duy nhất, nếu trùng port thì phải exit tiến trình cũ hoặc sử dụng port khác.  
Ví dụ vài port đã được đăng ký trước:
- 22: Port SSH
- 80: Port HTTP
- 443: Port HTTPS

## Giao thức:
- UDP:
- TCP:
  - HTTP
  - WebSocket
  - FTP
  - SSH

## Các lệnh thử nghiệm network:
Dưới đây sử dụng `netcat`:

### TCP:
```bash
nc -l 12345 # nghe 127.0.0.1:12345 giao thức sử dụng TCP
nc 127.0.0.1 12345 # gửi network request đến 127.0.0.1:12345 sử dụng giao thức TCP
```

### UDP:
```bash
nc -u -l 12345 # nghe 127.0.0.1:12345 giao thức sử dụng UDP
nc -u 127.0.0.1 12345 # gửi network request đến 127.0.0.1:12345 sử dung giao thức UDP
```

### Port scaning:
```bash
nc -z -v 192.168.1.102 8080-8090 # quét host 192.168.1.102 với dải ports từ 8080 -> 8090
```