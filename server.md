# Server
### Mô hình hệ thống
- Nhiều client kết nối với server, client thì không đáng tin, client có nhiệm vụ hiển thị UI, nhận dữ liệu từ người chơi, gửi request lên server
- Server có nhiệm vụ xử lý request của client, và trả về response, request của client có thể chứa những thông tin không an toàn, hacker có thể thông qua tool gửi request lên mà không thông qua UI ở client, vì vậy các điều kiện chặn ngoài chặn ở client phải chặn cả ở server. Ví dụ về lỗi gacha BUY_GACHA_CHEST_V2, có thể do hacker gửi số quá lớn nên bị tràn số nên pass được bước trừ reward
- Server cũng có thể gửi request cho client
- Mục địch của việc sử dụng server: 
    + Tập trung dữ liệu nhiều người chơi lại để quản lý
    + Bật tắt tính năng dễ dàng
    + Bảo mật dữ liệu
- Database có nhiệm vụ lưu trữ dữ liệu của người chơi và data game
- Database chỉ lưu trữ dữ liệu và lấy dữ liệu lên, không xử lý thông tin. Ví dụ về code reward hiện tại của game bomb mỗi lần lưu đều cộng trừ từ phía db rồi server lại gọi xuống db để load lại reward, tăng gánh nặng cho db, đáng lẽ cộng trừ trên server và lưu kết quả xuống db, bỏ đi bước load từ db lên
- Redis: Trước đây không có redis nhưng khi phát triển gặp vấn đề server có thể gọi api nhưng api không chủ động liên lạc cho server được, vì vậy mới cần tới redis, 
 - Redis trong game bomb có 2 vai trò:
    + Như db thu nhỏ nhưng có thể lưu dữ liệu tạm thời, tự xoá sau khoảng thời gian nhất định
    + Khi lưu dữ liệu xuống redis sẽ bắn tới nhưng nơi lắng nghe sự kiện lưu này.
- Api thì như những server nhỏ, để xử lý những tính năng đặc biệt như login hay purchase hay blockchain, hoặc để xử lý những tác vụ năng thay server như referral
### Một số kinh nghiệm khi làm việc với server
- Đảm bảo client cũ vẫn chạy tốt, không dùng json parse ở client GachaChestItem.kt, BUY_GACHA_CHEST_V2
- Khi code một tính năng thì cần lưu log lại để xử lý khi gặp lỗi
- Không gửi thông tin lỗi cho user BaseEncryptRequestHandler.kt
- Cần try catch khi gọi qua các bên khác
- Một vấn đề sẽ có nhiều hướng giải quyết nên suy nghĩ và chọn ra hướng tốt nhất ví dụ về coin ranking lấy data của season hiện tại và nhiều season.
   + Hướng thứ nhất tách riêng 2 data và để server sort ngay từ đầu, nhưng vậy phải lưu thêm name, uid, nework
   + Hướng thứ 2 gộp lại lấy kết quả lên, khi nào cần thì sort
   + Hướng thứ 3 gộp lại chỉ trả kết quả, đấy việc sort xuống client
- Cần code cẩn thận vì sai sẽ ảnh hưởng đến toàn người chơi ví dụ về đợt change active house ACTIVE_HOUSE_V2 đây là trường hợp một người chơi thì không có bug, nhưng nhiều người chơi thì xảy ra bug
- Server luôn là thứ được ưu tiên hơn nếu phải chọn hiệu năng giữa client và server
- Xem xét việc thêm index vào db khi cần query bảng có nhiều dữ liệu
- Database khi thêm mới thì không sao nhưng khi thực hiện thay đổi như xoá, đổi dữ liệu thì cần cẩn thận, dữ liệu user thì khi muốn xoá nên thêm cột is_delete chứ không nên xoá hẳn
- Mỗi lần server gọi xuống database là server phải mở một kết nối, việc này cũng tốn hiệu năng nên nếu được nên nếu có từ 3 câu gọi sql liên tiếp nên suy nghĩ thử gộp lại thành một procedure hay function
### Tổng kết
Làm server không khó, chỉ cần code cẩn thận, đọc lại code vài lần khi code xong, làm nhiều rồi thì cũng quen nhưng khi làm thì hơi áp lực lúc release, sai là thấy mệt