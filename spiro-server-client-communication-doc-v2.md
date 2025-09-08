# Client-Server Flow V2

```mermaid
flowchart TD
    Start([App Install]) --> Step1[1. First Install<br/>Client gọi api /register]
    Step1 -->|Success: return UUID + Secret<br/>Fail: Lần sau thử lại| Step2[2. Sử dụng App bình thường]
    
    Step2 --> Step2a[Push data khi có thay đổi]
    Step2a -.->|Nếu fail: ignore| Step2
    
    Step2 --> Step2b[User bấm nút<br/>'Sync with Google'<br/>]
    Step2b --> Step3{3. Kiểm tra Google Account<br/>có link đến account<br/>và device nào chưa?}
    
    Step3 -->|Có rồi| Step3a[Hiện warning:<br/>'Chỉ support 1 device'<br/>Hiện nút 'Force Login']
    Step3 -->|Chưa| Step3b[Link Google account với device này]
    
    Step3a -->|User bấm Force Login| Step5[Force Login<br/>Thay đổi user data]
    Step5 -.-> Step5b[Device mới:<br/>Xoá data trên device<br/>Download data từ Server về]
    Step5 -.-> Step5a[Device cũ:<br/>Sẽ bị Server từ chối push data]
    Step5 --> Step3b
    Step5a --->|Force logout| Step6
    
    Step2 --> Step4[4. Nếu User bấm nút<br/>'Logout']
    Step4 --> Step4a[Hiện UI 'Gửi data lên server'<br/>Xoá data trên device]
    Step4a --> Step6[5. Màn hình Login]

    Step6 --> Step6b[Bấm Nút 'Login account cũ']
    Step6 --> Step6a[Bấm Nút 'Tạo account mới']
    Step6a -.-> Step1
    Step6b -.-> Step3
```

# Client push data:
Client chia data thành các category: Push lên toàn bộ data của category đó theo schema đã quy định sẵn với server, ví dụ:
```
{
    "user_sneakers": [],
    "user_balances": []
    // ...
}
```

Khi client cần data từ Server, client gửi request theo format sau:
```
{
    "request":[
        "user_sneakers",
        "user_balances",
        // ...
    ]
}
```

### Quy định giữa Client & Server:
#### 1. Không được thay đổi JSON schema của category đã quy định, ví dụ:
```
"user_sneakers": [
    "id": "...",
    "speed": "..."
],
```
Nếu phải thay đổi, thay đổi luôn cả key, ví dụ đổi key từ "user_sneakers" → "user_sneakers_v2"
#### 2. Quy định này chỉ để quy định cho giao tiếp qua network, không áp dụng cho cách lưu trữ data của Server và Client


## Các API Endpoint:
- /register: đăng ký lần đầu để có UUID & Secret.
- /login: nếu thông tin login không đúng. Đẩy ra màn hình Login.
- /push: Client push lên data mới.
- /link: Link với Google account.
- /pull: Download data từ server về.
- /leaderboard: Lấy về leaderboard để hiển thị.
