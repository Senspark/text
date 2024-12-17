# Docker Cmd

```bash
# Build Dockerfile tại path . thành, đặt tag cho Image là demo
docker build -t demo . 

# Liệt kê tất cả các Image đang có trên máy
docker images

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

# Docker Compose

```bash
# Chạy tất cả các Container được khai báo trong file yaml
docker-compose up -d

# Stop tất cả các Container được khai báo trong file yaml
docker-compose down

# Trong trường hợp cần build lại container tên là demo1
docker-compose up -d --build demo1
```