# Quy định giao tiếp Server-Client

## Mục tiêu thiết kế

- **Trải nghiệm liền mạch**: Không để việc giao tiếp với Server làm gián đoạn trải nghiệm của User
- **Offline-first**: Ưu tiên thiết kế App theo dạng Offline-first
- **Vai trò của Server**: Chỉ đảm bảo không gian lận và sync data khi sử dụng nhiều thiết bị

---

## 1. Các loại Request gửi lên Server

### Request Schema
Tất cả request đều sử dụng phương thức **POST** với payload schema:

```typescript
interface RequestPayload {
    type: string;      // Tên của handler cần gọi
    payload: object;   // Data gửi cho handler (kiểu object)
}
```

### Phân loại Request

```mermaid
graph LR
    A[Client Request] --> B{Request Type}
    B --> C[Read Request<br/>POST /read]
    B --> D[Write Request<br/>POST /write]
    
    C --> E[Đọc data từ server]
    D --> F[Yêu cầu ghi data<br/>Server có thể đồng ý/từ chối]
    
    style C fill:#e1f5fe
    style D fill:#fff3e0
```

#### Ví dụ cụ thể:
- **Read requests:**
  - Lấy balances của user (các currency, tiền trong account)
  - Lấy số lượng item của user (sneaker, fish, ...)

- **Write requests:**
  - Cộng thưởng cho user khi hoàn thành nhiệm vụ
  - Mua item abc
  - Fusion item abc

---

## 2. Quy định Response của Server

### Status Code

```mermaid
graph TD
    A[Server Response] --> B{Status Code}
    B -->|200| C[✅ Server đã xử lý]
    B -->|400| D[❌ Lỗi Client]
    B -->|401| E[🔒 Chưa đăng nhập]
    B -->|500| F[⚠️ Lỗi Server]
    
    C --> G[Response Schema đảm bảo]
    D --> H[Client tự xử lý<br/>Không gửi lại]
    E --> I[Client đăng nhập lại]
    F --> J[Client có thể retry]
    
    style C fill:#c8e6c9
    style D fill:#ffcdd2
    style E fill:#fff9c4
    style F fill:#ffccbc
```

| Status Code | Ý nghĩa | Xử lý |
|------------|---------|-------|
| **200** | Server đã xử lý | Xem Response Schema bên dưới |
| **400** | Lỗi của Client (thiếu/sai data) | Client tự xử lý, không gửi lại |
| **401** | Chưa đăng nhập | Client phải đăng nhập lại |
| **500** | Lỗi bất ngờ của Server | Client có thể thử lại sau |

### Response Schema (Status 200)

```typescript
interface ServerResponse {
    success: boolean;           // true: server đồng ý | false: server từ chối
    error?: {                   // undefined khi success == true
        code: string;           // Error code cho đa ngôn ngữ (vd: "data_not_found")
        message: string;        // Error message cho developer
    };
    data?: object;             // undefined khi success == false
}
```

⚠️ **Lưu ý quan trọng:**
- Status Code **200**: Response Schema được đảm bảo đúng như trên
- Status Code **khác 200**: Response Schema có thể không đúng (ví dụ: lỗi đường truyền)

---

## 3. Cách Client phân loại Write Request

### Phân loại theo mức độ kiểm soát của Server

```mermaid
graph TD
    A[Write Request] --> B{Mức độ kiểm soát}
    B --> C[🟢 Server không kiểm soát]
    B --> D[🟡 Server kiểm soát một phần]
    B --> E[🔴 Server kiểm soát hoàn toàn]
    
    C --> F[Không Block UI<br/>Xử lý như Local Storage<br/>Server luôn đồng ý]
    D --> G[Không Block UI<br/>Delay kết quả<br/>Server có thể từ chối]
    E --> H[Block UI hoặc Delay<br/>Chờ phản hồi Server<br/>Data quan trọng]
    
    style C fill:#c8e6c9
    style D fill:#fff9c4
    style E fill:#ffcdd2
```

#### a. 🟢 Server không kiểm soát data
- **Đặc điểm**: Server ghi nhận và lưu tiến trình, thường luôn đồng ý
- **Xử lý Client**: Không cần Block UI, xử lý như Local Storage
- **Ví dụ**: Lưu progress game offline

#### b. 🟡 Server kiểm soát một phần data
- **Đặc điểm**: Server có thể từ chối để chống gian lận
- **Xử lý Client**: Không Block UI, delay kết quả cho đến khi có phản hồi
- **Ví dụ**: Nhận phần thưởng (chỉ nhận được 1 lần)

#### c. 🔴 Server kiểm soát hoàn toàn data
- **Đặc điểm**: Data quan trọng (Token, NFT, tiền Fiat)
- **Xử lý Client**: Phải chờ phản hồi Server, có thể Block UI hoặc Block một phần
- **Ví dụ**: Giao dịch tiền tệ, NFT

---

## 4. Cách Client xử lý Read Request

```mermaid
sequenceDiagram
    participant LS as Local Storage
    participant C as Client
    participant S as Server
    
    C->>S: Read Request
    alt Success
        S-->>C: Response với data mới
        C->>LS: Replace data local với data server
        Note over C,LS: Server data là nguồn tin cậy
    else Fail
        S-->>C: Error/Timeout
        C->>C: Tuỳ chọn retry hoặc không
        Note over C,LS: Tiếp tục dùng data local
    end
```

### Nguyên tắc:
- **Mục đích**: Sync data giữa Local Storage và Server
- **Ưu tiên**: Data của Server luôn là nguồn đáng tin cậy
- **Xử lý lỗi**: Client có thể tuỳ chọn retry hoặc không

---

## 5. Cách Client xử lý Write Request

### Luồng xử lý Write Request

```mermaid
flowchart TD
    Start([Client cần gửi Write Request]) --> Save[Lưu Request xuống Local Storage]
    Save --> Send[Gửi Request đến Server]
    Send --> Wait{Nhận được Response?}
    
    Wait -->|Có| CheckCode{Status Code?}
    Wait -->|Không/Timeout| Retry1[Lên lịch Retry<br/>Không xoá trong Storage]
    
    CheckCode -->|200| Delete1[Xoá Request trong Storage]
    Delete1 --> CheckSuccess{Server đồng ý?}
    CheckSuccess -->|Success=true| ProcessSuccess[Xử lý thành công]
    CheckSuccess -->|Success=false| ProcessReject[Xử lý từ chối]
    
    CheckCode -->|!= 200| CheckSchema{Có Schema đúng?}
    CheckSchema -->|Có| Delete2[Xoá Request trong Storage]
    Delete2 --> ShowError[Hiện UI thông báo User]
    CheckSchema -->|Không| Retry2[Lên lịch Retry<br/>Không xoá trong Storage]
    
    style Delete1 fill:#c8e6c9
    style Delete2 fill:#ffcdd2
    style Retry1 fill:#fff9c4
    style Retry2 fill:#fff9c4
```

### Quy tắc Retry

- **Thứ tự**: Gửi tuần tự từng request theo thứ tự (không gửi cùng lúc)
- **Ưu tiên**: Xử lý request retry trước các request mới
- **Persistence**: Luôn lưu Write Request xuống Storage để đảm bảo không mất khi app crash

---

## 6. Cách Client quản lý các Service liên quan đến Server

### a. Khi khởi động App

```mermaid
sequenceDiagram
    participant LS as Local Storage
    participant Mem as Memory
    participant Svc as Service
    participant Srv as Server
    
    Note over Svc: App khởi động
    Svc->>LS: Đọc data
    LS-->>Mem: Load data vào memory
    Svc->>Srv: Gửi Read Request
    Note over Svc,Mem: Dùng data local trong lúc chờ
    Srv-->>Svc: Response với data mới
    Svc->>Mem: Update data từ Server
    Note over Svc,Mem: Tin data của Server
```

### b. Khi đang dùng App

#### Phân loại method trong Service:

| Method Pattern | Ý nghĩa | Khi nào dùng |
|---------------|---------|--------------|
| `async doSomething(data): Promise<data>` | Nên Block UI hoặc tuỳ chọn | Operations quan trọng |
| `doSomething(data, onCompleted: () => data)` | Block UI một phần | Operations trung bình |
| `registerEvent(eventName, onEventHappened: () => data)` | Không Block UI | Operations background |

---

## 7. Các vấn đề khó xử lý

### Tình huống phức tạp

```mermaid
graph TD
    A[Vấn đề khó] --> B[User chơi Offline lâu]
    A --> C[Item phái sinh phức tạp]
    
    B --> D[Data conflict khi sync]
    C --> E[Server không xác thực được]
    
    D --> F[Cần quy tắc merge data]
    E --> G[Cần validation rules rõ ràng]
    
    F --> H[Thử nghiệm thực tế]
    G --> H
    H --> I[Rút ra Flow an toàn]
    
    style A fill:#ffcdd2
    style H fill:#c8e6c9
```

### Giải pháp đề xuất:

1. **Conflict Resolution**: Xây dựng quy tắc merge data rõ ràng
2. **Validation Rules**: Định nghĩa rules validation cho từng loại item
3. **Testing**: Thử nghiệm kỹ các scenario edge case
4. **Monitoring**: Theo dõi và log các case bất thường để cải thiện

---

## Tổng kết

### Nguyên tắc vàng:
1. ✅ **Offline-first**: App phải hoạt động tốt cả khi không có mạng
2. ✅ **User Experience**: Không làm gián đoạn trải nghiệm người dùng
3. ✅ **Data Integrity**: Server là nguồn dữ liệu tin cậy cuối cùng
4. ✅ **Anti-cheat**: Server kiểm soát các data quan trọng
5. ✅ **Resilience**: Xử lý tốt các trường hợp lỗi và retry

### Best Practices:
- Luôn persist Write Request để đảm bảo không mất data
- Phân loại request theo mức độ quan trọng để xử lý UI phù hợp
- Sử dụng event-driven architecture cho các operations không quan trọng
- Test kỹ các scenario offline và conflict resolution