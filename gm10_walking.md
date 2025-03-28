# Sơ đồ và mô tả Service Đi Bộ

```mermaid
flowchart TD

  subgraph Service [Service đi bộ]
    START
    STOP
    GET_STATE
  end
  
  subgraph ServiceData [Service Data]
    subgraph Session [Session Data]
      Current_Session(Data của Session hiện tại)
      Previous_Session(Data của 1 Session trước đó)
    end

    subgraph State [Trạng thái của Service]
      UN_START
      STARTING
      NEED_PERMISSION
      STARTED
    end
    
  end
  
  subgraph Game_UI [Giao diện Game]
    G_UI(Game UI)
    G_STOP_BUTTON(Nút STOP)
    G_RECORD_BUTTON(Nút START/RECORD)
  end

  subgraph Notification [Thanh thông báo]
    N_STOP_BUTTON(Nút STOP)
  end

  GET_STATE --> ServiceData

  G_UI --> GET_STATE
  G_RECORD_BUTTON --> START
  G_STOP_BUTTON --> STOP

  START --> ServiceData
  STOP --> ServiceData

  N_STOP_BUTTON --> STOP

  ServiceData --> AUTO_UPDATE(Service tự thông báo data mới đến Game)
```

---

## 📌 Ghi chú chi tiết

### 🧩 Các phương thức của `Service đi bộ`:
- `START`: Bắt đầu ghi 1 Session đi bộ mới.
- `STOP`: Dừng Session hiện tại.
- `GET_STATE`: Lấy `Service Data`, bao gồm:
    - Trạng thái (`STATE`)
    - Dữ liệu Session hiện tại (nullable)
    - Dữ liệu Session trước đó (nullable)

### 🚦 Trạng thái (`STATE`) gồm:
- `UN_START`: Đang ko làm gì cả.
- `STARTING`: Đang khởi động. Có thể dẫn đến `NEED_PERMISSION` hoặc `STARTED`.
- `NEED_PERMISSION`: Thiếu quyền, cần xin quyền.
- `STARTED`: Đang record Session.

### 📊 Dữ liệu 1 `Session` bao gồm:
- `Session ID`: số tăng dần từ 1.
- `Thời điểm bắt đầu`.
- `Thời điểm kết thúc` (nullable - nếu là Session hiện tại sẽ ko có thông tin này này).
- `Số bước đã đi`.
- `Số km`: = số bước × 0.6m.
- `Số giây đã đi` từ lúc bắt đầu.

### 📱 Cách sử dụng:
- Khi chuẩn bị sử dụng tính năng, gọi `GET_STATE` để lấy:
    - Trạng thái:
        - Nếu `UN_START`: hiển thị nút Record → gọi `START`.
        - Nếu `STARTED`: hiển thị nút Stop → gọi `STOP`.
        - Nếu `NEED_PERMISSION`: hiển thị nút xin quyền → gọi `START`, hệ thống sẽ tự động xin quyền.
    - Dựa vào `Session Data` hiện tại và trước đó để tính toán & hiển thị thông tin phù hợp.

### 🔁 Trong quá trình sử dụng:
- Service sẽ tự thông báo khi `Session Data` thay đổi (UI có thể cập nhật theo).

### 🌙 Khi thoát game:
- Service vẫn hoạt động nền.
- Nếu người dùng bấm `STOP` trong thanh thông báo Android → `STOP` Session hiện tại.
- Muốn Record Session mới, cần mở lại game và gọi `START`.
