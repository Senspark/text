# Exception

Exception là tiêu chuẩn để control Error flow trong hệ thống phần mềm.  
### Đặc điểm:
- Exception hoạt động theo nguyên tắc Bubble Up từng call stack lên trên cho đến khi gặp try-catch.
- Trong trường hợp không có try-catch nào xử lý, nó sẽ crash Thread mà nó đang chạy, và log ra stack trace.
- Khi đã try-catch, nếu ko có khả năng giải quyết, có thể re-throw để phía trên trên xử lý.

Cấu trúc ví dụ:
```csharp
try {
    // Xử lý logic thông thường
}
catch (Exception e) {
    // Xử lý logic trong trường hợp catch được exception
}
finally {
    // Luôn chạy bất kể có try-catch được lỗi hay ko
    // Dùng để clean up & đưa chương trình về trạng thái normal nếu có lỗi xảy ra
}
```

Re-throw exception:
```csharp
catch (Exception e) {
    // throw new Exception(e.Message); // Ko throw new, sẽ mất stack trace.
    throw; // re-throw
}
```

Lỗi logic có thể gặp phải:  
Vô tình gây ra Exception trong catch block hoặc finally block
```csharp
catch (Exception e) {
    return 1 / 0; // DivideByZeroException
}
finally {
    return 1 / 0; // DivideByZeroException
}
```

### Trước khi có tiêu chuẩn về Exception:
- Các function thường return về error code để báo lỗi.
- Hoặc các ngôn ngữ khai báo 1 biến Global để lưu trạng thái lỗi.
- Các cách trên ko scale tốt khi hệ thống phức tạp.

### Theo định nghĩa của Java:
- Exception có nghĩa: Trường hợp nằm ngoài phạm vi có thể xử lý được, thông báo lên cấp trên để họ xử lý.
- Error có nghĩa: Lỗi không thể khắc phục được, buộc phải dừng chương trình.

# Android Thread & Crash & ANR

Document: https://developer.android.com/guide/components/processes-and-threads#java

### UI Thread (Main Thread):
- Khi mở 1 App, Android sẽ mở 1 Linux process & start 1 thread mặc định: UI Thread.
- UI Thread có nhiệm vụ cực kỳ quan trọng, là gửi event đến Android User Interface, tức là yêu cầu vẽ lên màn hình & nhận system callback (ví dụ nhấn vào màn hình, …). Do đó nó cũng thường được gọi là UI Thread.
- Vậy nên nếu code performance ko tốt hoặc sử dụng quá nhiều thứ trên UI Thread -> App phản hồi kém hoặc ko phản hồi với system callback -> nếu quá vài giây -> Hệ thống xác định `Application not Responding` (ANR).
- Vậy:
    - Ko được block UI Thread
    - Ko sử dụng Android UI toolkit ngoài UI Thread

### Worker Threads (Background Thread, Library Thread, ...):
- Sử dụng cho các tác vụ nặng, hoặc theo nhu cầu.
- Không thể update UI từ Worker Thread.

### Nguyên tắc của Thread:
- Tất cả các tác vụ sẽ hoạt động trên cùng 1 Thread, trừ khi dev explicit yêu cầu sử dụng Thread khác.

### Lưu ý:
- UI ở đây hiểu là Android UI (Các component Native UI của Android), không phải Game UI (như Unity, Cocos, …)

### Đối với Cocos Creator:
- Document: https://docs.cocos.com/creator/3.0/manual/en/advanced-topics/java-reflection.html
- Engine & Javascript VM được hoạt động trên GL Thread (Tên do Cocos quy ước) (Ko phải UI Thread). Do đó, nó ko block UI Thread.
- Trong trường hợp cần sử dụng các tính năng liên quan đến UI của Android. Phải đổi sang UI Thread.
- Trong trường hợp code logic bên Android cần gọi đến Game Logic. Phải đổi sang GL Thread.
- Javascript VM là Single Thread. Ko thể tạo Worker Thread để sử dụng cho Javascript.

### Đối với Unity:
- Document: https://docs.unity3d.com/6000.0/Documentation/ScriptReference/Android.AndroidApplication.InvokeOnUnityMainThread.html
- Document: https://docs.unity3d.com/6000.0/Documentation/ScriptReference/Android.AndroidApplication.InvokeOnUIThread.html
- Document: https://docs.unity3d.com/6000.0/Documentation/Manual/android-application-entries-game-activity-requirements.html
- Tương tự như với Cocos Creator, Unity gọi Thread riêng của họ là Unity Main Thread (Ko phải UI Thread).
- Các API của Unity là chỉ có thể được sử dụng ở Unity Main Thread. Do đó về cơ bản Unity cũng gần như là Single Thread.

## Tóm gọn:
- Khi Cocos Creator, Unity tự khởi tạo Thread riêng, do đó ko gây block UI Thread của Android.
- Mặc dù document của Cocos/Unity gọi là Main Thread, nhưng nó chỉ là 1 Worker Thread của Android.

## Vậy vấn đề ANR đến từ đâu:
- Tỉ lệ cao là đến từ những logic Native ở Android:
    - Thư viện của Game Engine có sử dụng UI Thread.
    - Thư viện thứ 3: Firebase, Ads, In app purchase, Analytics, …
    - Logic của dev viết ở phía Native của Android để giao tiếp với thư viện thứ 3.
    - Logic riêng của dev viết ở Native của Android.
- Thực hiện tác vụ nặng đến mức sử dụng hết tất cả tài nguyên của thiết bị.
- ...

### Cảnh báo nguy hiểm:
- Skipped … frames!  The application may be doing too much work on its main thread.
- Thông báo trên có nghĩa rằng Renderer yêu cầu data để vẽ lên màn hình, nhưng Main Thread ko phản hồi.
- Nhưng ko có nghĩa là App đã bị ANR, có thể thiết bị quá yếu, hoặc hệ điều hành bị quá tải.
- Nhưng nếu thông báo đó xuất hiện quá nhiều lần, hoặc số frame bị skip quá nhiều (giả sử 60 fps thì bị skip 600 frame = 10 giây); Thì cần phải xem xét, đặc biệt là trên máy Dev vốn có cấu hình trung bình.

# Crashlytics:

Đặt thêm logs trong trường hợp cần tìm ra lỗi