# Phần 1: Dev Sprint

### Dev Sprint (Không liên quan đến Sprint trên Monday):
- Chỉ áp dụng cho Team Dev.
- Dev Sprint không thay thế Monday.
- Trong phạm vi tài liệu này - Dev Sprint được gọi tắt là Sprint.

### Mục đích của Sprint:
- Transparent công việc và performance của Dev.
- Tránh Overload cho Dev và QA.
- Tổ chức và kế hoạch làm việc khoa học.

### Nguyên tắc:
- Mỗi Sprint chỉ kéo dài 1 tuần (5 ngày làm việc).
- Ngày bắt đầu của mỗi Sprint sẽ tuỳ thuộc vào project.

### Tổ chức của 1 Table:
| Backlog | This Week (Sprint) | In Progress | Blocked | Done |
|---------|--------------------|-------------|---------|------|

---

# Phần 2: Các Stage của Sprint:
## 1. Planning:
- Bắt đầu của mỗi Sprint sẽ có buổi họp Team để chọn các Task trong cột Backlog, estimate time & move chúng sang cột This Week
- Mỗi ngày Dev có 6 tiếng để làm việc theo Sprint.
- Tổng cộng mỗi tuần Dev có 30 tiếng (10 tiếng còn lại dùng cho: thảo luận, suy nghĩ, vệ sinh, ăn uống, giải lao, ...).
- Planning estimate time không được vượt quá 30 tiếng.
- Trong trường hợp Planning không đủ 30 tiếng. Vẫn Start Sprint. Thời gian còn trống sẽ được bố trí sau.
- Đối với các Task lớn hoặc kéo dài trên 3 ngày. Break down thành các Task nhỏ hơn.
- Đối với các Task chưa estimate được ngay (cần research). Tạo 1 Task Research. Điều chỉnh lại Sprint khi đã estimate xong.

## 2. Start Sprint:
- Dev chỉ được thực hiện theo các Task ở cột This Week (Sprint)
- Không thực hiện các yêu cầu của bên thứ 3, các phát sinh mới sẽ được thêm vào cột Backlog, sẽ lên lịch ở Sprint tiếp theo.
- Khi Sprint đã bắt đầu, cột This Week không được thêm Task vào, chỉ có thể remove ra.

## 3. Processing:
- Dev chọn 1 Task ở cộg This Week và move sang cột In Progress. Mỗi Dev chỉ được có 1 Task duy nhất ở In Progress.
- Nếu có vấn đề phải pending Task. Move lại nó sang cột This Week.
- Khi làm xong. Move Task sang cột Done.
- Task được coi là Done khi:
    - Code hoàn thành và commit lên Git
    - Self-test pass (dev tự test)
    - Code review (nếu có reviewer)
- Ghi lại thời gian làm thực tế vào Task

## 4. Emergency:
Luôn báo lại cho quản lý, nếu có phát sinh vấn đề ngoài dự kiến.
- Nếu có phát sinh khẩn cấp, báo lại cho quản lý để cân nhắc điều chỉnh lại Sprint.
- Nếu thời gian thực hiện Task vượt quá x1.5 lần so với thời gian đã estimate - mà vẫn chưa giải quyết xong, báo lại cho quản lý.
- Nếu Task bị stuck, báo lại cho quản lý.
- Trong trường hợp Dev off (nghỉ), Sprint sẽ được điều chỉnh lại vào cuối chu kỳ.

## 5. End Sprint:
- Kết thúc khi đến ngày quy định.
- Team tiến hành review lại Sprint:
    - Hoàn thành vs Không hoàn thành
    - Chất lượng công việc
    - Số lượng Bug tạo ra
- Build product và bàn giao cho QA (nếu đã đủ để test được).

## 6. Testing:
- Kết quả Test thường sẽ đến muộn. Cho nên Sprint mới sẽ bắt đầu trước khi có kết quả Test.
- Các Task phát sinh từ kết quả Test sẽ được đánh dấu là [BUG], phân loại theo mức độ High/Medium/Low, đưa chúng vào cột Backlog.
- Trong trường hợp cần fix khẩn cấp, báo lại cho quản lý để điều chỉnh lại Sprint.
### 6.1. Bug severity:
- High: Crash/ANR/blocking
- Normal: Wrong logic, chức năng sai
- Low: UI/UX issues

---

# Phần 3. Phụ lục:

## 1. Các project:
### Sprint sẽ bắt đầu và kết thúc vào:
- Gm10 (Việt + Đạt): thứ 2 mỗi tuần
- Craft (Mạnh): thứ 3 mỗi tuần
- Tribe War (Stickwar 4) (anh Tài): thứ 4 mỗi tuần
- Stick Dynasty (Stickwar 1) (anh Tài): thứ 4 mỗi tuần
- Spiro (Hoàng + Sang): thứ 5 mỗi tuần
- Goods Sort (Khoa): thứ 6 mỗi tuần

## 2. Thời điểm build game và bàn giao cho QA:
- Cố định sẽ rơi vào ngày kết thúc Sprint.
- Trong trường hợp fix bugs của Sprint đã done, thì build lại không cần đợi ngày.

## 3. Phối hợp với các bộ phận khác:
- Tự do trao đổi.
- Nhưng Dev chỉ thực hiện theo quy định của Sprint, không chen ngang Sprint mà không thông qua quản lý.

## 4. Git commit:
- Để dễ phân biệt, các commit sẽ có prefix theo task id, ví dụ: `[98] Tính năng Abc` -> Task Id = 98
- Đối với Task có nhiều commit, từng commit cũng prefix theo task id như vậy.

## 5. Lưu ý khác:
- Sprint không phải là version. 1 version có thể kéo dài qua nhiều Sprint.