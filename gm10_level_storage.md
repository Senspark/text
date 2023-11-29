# Hệ thống lưu trữ levels của Gm10:
## A. Tổ chức thư mục:

### Firebase Storage:

Levels:
- Lv1:
    - 1.json
    - 2.json
    - ... (tương tự)
    - Meta.csv
- Lv2:
    - 1.json
    - 2.json
    - ... (tương tự)
    - Meta.csv
- Lv... (tương tự)
- Random:
    - 1.json
    - 2.json
    - ... (tương tự)
    - Meta.csv
- README.md

---
### Unity:
Assets
- LevelData:
    - Default:
        - (Cấu trúc giống như trên Firebase, nhưng chỉ bao gồm các file sẽ sử dụng mặc định, sẽ export theo bản build, các file còn thiếu sẽ lấy từ Firebase về ở runtime)
    - Editor:
        - (Cấu trúc giống như trên Firebase, có toàn bộ các file trên Firebase, chỉ sử dụng để thiết kế levels, sẽ ko export theo bản build)

---

## B. Giải thích cách hoạt động:
- Mục tiêu là lưu trữ toàn bộ các levels lên Firebase Storage.  
Remote Config sẽ khai báo chọn các file nhất định để áp dụng hoặc A/B Test.
- Bên trong thư mục `Levels` sẽ chứa 4 nội dung:
    1. Thư mục `Lv__` : Sẽ random các file trong này để áp dụng cho level cụ thể
    2. Thư mục `Random`: Sẽ random các file trong này để áp dụng cho các level nào ko chỉ định rõ thư mục như mục 1
    3. File `Meta.csv`: Danh sách các file sẽ pick trong thư mục này, và thông tin sơ lược của chúng.
    4. File `README.md`: Ghi giải thích về cách hoạt động

### Cấu trúc file RandomMeta.csv:
Cấu trúc CSV ví dụ như sau:
- Cột `file_name` là tên file
- Cột `difficulty` là độ khó, cho phép filter theo độ khó
- Cột `gold_value` là tổng giá trị của các items, có thể cho phép filter theo số vàng (dự tính)
```csv
file_name, difficulty, gold_value
1, 1, 1000
2, 10, 1800
3, 5, 1200
```

## C. Remote Config: 
Key: `level_config`  
Value: `String`

Cấu trúc CSV ví dụ như sau:
- Cột `level` dùng để khai báo các level sẽ pick trong thư mục riêng của nó, ngoài danh sách này sẽ pick trong thư mục Random
- Cột `pick_filter` dùng để khai báo cụ thể các file nào sẽ dùng để pick bên trong thư mục riêng.  
 Dấu `*` sẽ pick tất cả.   
 Dấu `-` dùng để ngăn cách  
- Trong trường hợp file ko tồn tại hoặc lỗi download hoặc file lỗi data thì sẽ pick theo Rule
- Những level ko có trong file này, mà có thư mục trên Firebase thì vẫn pick trong thư mục chung (thư mục Random)

```csv
level, pick_filter
1, 1-2-3-4
2, 1-2
3, *
5, *
6, 5
10, *
```

## D. Rule pick file (xử lý theo thứ tự từ trên xuống):
1. Nếu có set Remote Config: -> pick trong thư mục riêng của level đó với `pick_filter` đã set
2. Nếu ko pick được hoặc lỗi: -> pick random toàn bộ file trong thư mục riêng của level đó
3. Nếu vẫn ko pick được hoặc lỗi: -> pick random trong thư mục chung (thư mục Random)

Ở bất kỳ bước nào, nếu Firebase lỗi hoặc Timeout hoặc ko có Internet thì chuyển sang pick ở thư mục Default của Game.

## E. Analytics:
Vì levels được random, cho nên để xác định được user success/fail ở cụ thể file level nào, thì phải gửi kèm:
- `root_folder`: file lấy từ folder nào, ví dụ: `Lv1` hoặc `Lv9` hoặc `Random`
- `level_file`: tên của file, ví dụ: 5.json -> `5` hoặc 100.json -> `100`
- `storage`: nơi lưu trữ file: `local` hoặc `firebase`

Có thể reuse pattern của CostCenter, data mẫu:
```
- level: 1
- level_mode: "Arcade"
- success: "True"
- root_folder: "Lv1"
- level_file: "5"
- storage: "firebase"
```

## F. Ghi chú:
Vì việc thiết kế level cần sự trực quan nên sẽ thiết kế trực tiếp trên Unity & sync file với Firebase.  
Vậy nên cần 1 hệ thống sync file để cảnh báo việc ghi đè file đã có hay tạo file mới.
