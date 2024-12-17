# Cơ bản về Docker

## Docker là gì:

Website: https://www.docker.com/

- Docker Desktop
- Docker CLI

Docker là công cụ cho phép đóng gói ứng dụng (bao gồm code, thư viện, dependencies) vào một container. Container này có
thể chạy trên bất kỳ thiết bị nào.
Các ví dụ về tính ko nhất quán:

1. Dev code trên hệ điều hành A (ví dụ Windows), nhưng phát hành trên hệ điều hành khác (ví dụ Linux).
2. Dev A code trên hệ điều hành A, nhưng trong team có Dev B code trên hệ điều hành B.
3. Máy tính cần chạy cùng lúc nhiều project, nhưng các project cần môi trường khác nhau. Ví dụ project A cần NodeJS 16,
   project B cần NodeJS 20.
4. ...

Docker giúp giải quyết các vấn đề sau:

- Mỗi ứng dụng được đóng gói vào từng Container riêng biệt. Môi trường, thư viện, dependencies của từng Container được
  tách biệt với nhau.
- Môi trường của Docker tách biệt với hệ điều hành & môi trường mà nó được cài đặt. Cho nên nó không phụ thuộc vào môi
  trường của máy Dev.
- Có thể hiểu mỗi Container là 1 máy ảo.

## Quy trình release phần mềm:
Trước đây:
- Push code lên Git.
- SSH vào máy chạy ứng dụng, pull code mới từ Git, build, restart ứng dụng.
- -> Phần mềm phải được setup ở mỗi máy chạy ứng dụng.

Docker:
- Build Docker Image từ code.
- Push Docker Image lên Docker Registry (Docker Hub, Google Cloud build, ...).
- Pull Docker Image, run Container trên máy chạy ứng dụng.
- -> Image chỉ được build 1 lần, và tái sử dụng ở bất kỳ máy nào.

## Các khái niệm:
- Dockerfile: File mô tả cách build Docker Image. Thường được đặt tên là `Dockerfile`.
- Docker Image: File snapshot chứa tất cả các thành phần cần thiết để tạo Docker Container.
- Docker Container: Một máy ảo được tạo ra từ Docker Image.

## Các lệnh Docker cơ bản:
```bash

# Build Dockerfile tại path . thành, đặt tag cho Image là demo
docker build -t demo . 

# Liệt kê tất cả các Image đang có trên máy
docker images

# Tạo network tên là example-network
docker network create example-network

# Run Container từ Image demo
# -p Khai báo port sử dụng, ở đây máy host mở port 4000, container mở port 3000, map 2 port này với nhau
# -d Chạy Container ở chế độ daemon
# --name Đặt name cho Container
# --network Liên kết Container với example-network vừa tạo
docker run -p 4000:3000 --name demo --network example-network -d demo

# Liệt kê tất cả các Container đang chạy
docker ps

# Xem logs của container tên là demo
docker logs demo

# Dừng container tên là demo
docker stop demo

# Xóa container tên là demo
docker rm demo

# Test from host
curl http://localhost:4000

# Test from container
docker run -p 4001:3000 --name demo --network example-network -d demo2
docker network inspect my-network
docker exec -it demo2 sh
apk add curl
curl http://demo:3000
exit
```

## Docker Compose:
Docker Compose giúp việc khai báo và khởi động Container dễ dàng hơn.  
Docker Compose được khai báo bằng file `.yaml`. Thông thường được đặt tên là `docker-compose.yaml`.  

Cấu trúc ví dụ cho trường hợp 2 Container như ví dụ trên:
```yaml
services:

  demo1:
    image: demo
    container_name: demo1
    environment:
      TZ: 'Asia/Bangkok'
    ports:
      - "4001:3000"
    networks:
      - example-network

  demo2:
    image: demo
    container_name: demo2
    environment:
      TZ: 'Asia/Bangkok'
    ports:
      - "4002:3000"
    networks:
      - example-network

networks:
  example-network:
    driver: bridge
```

```bash
# Chạy tất cả các Container được khai báo trong file yaml
docker-compose up -d

# Stop tất cả các Container được khai báo trong file yaml
docker-compose down

# Trong trường hợp cần build lại container tên là demo1
docker-compose up -d --build demo1
```

## Docker Hub:
Docker Hub là nơi lưu trữ các Docker Image được public trên Internet, được cộng đồng đóng góp.  
Trang web: https://hub.docker.com/

Ví dụ sử dụng:
```bash
# Pull Image redis từ Docker Hub
docker pull redis

# Run Container từ Image redis
docker run --name some-redis -d redis
```