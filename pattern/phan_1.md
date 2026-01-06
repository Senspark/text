# Phần 1: Sai về mô hình:
## 1. Pattern God Object:
Là 1 class cái gì cũng làm. Sai nguyên tắc Đơn nhiệm: Mỗi class chỉ nên làm 1 chức năng duy nhất.

Hậu quả:
- Khó Refactor: Class được sử dụng khắp mọi nơi trong Application.
- File càng dài càng khó đọc; đọc chưa chắc hiểu và nhớ chức năng trong đó.
- Vì ôm nhiều nhiệm vụ: Thêm/xoá/sửa code khả năng cao gây ra breaking change.

## 2. Pattern Singleton:
Bất cứ thứ gì sử dụng static/global scope mà không phải vì nó ít thay đổi. Lifetime của object được gắn liền với Application.

Hậu quả:
- Khó kiểm soát lỗi: Vì không biết khi nào object được khởi tạo? Dev thường lấp liếm bằng các condition kiểm tra null để khởi tạo dynamic.
- Memory phình to: Vì object không bao giờ được destroy.
- Vì là single object: Không thể tái sử dụng.
- Không thấy được mối quan hệ phụ thuộc giữa các class, đặc biệt khi có nhiều class Singleton sử dụng lẫn nhau.

## 3. Combo kinh dị: God Object + Singleton + MonoBehaviour + Partial class:
Xuất hiện ở hầu hết các project của Senspark:
1. Bắt đầu bằng 1 class MonoBehaviour như bình thường
2. Khi cần nối 2 class với nhau -> Chọn cách dùng Singleton cho nhanh gọn lẹ
3. Khi cần viết thêm tính năng, viết thành 1 class dạng GameManager/GameScene/EntityManager -> God Object
4. Khi cảm thấy file dài quá, giấu bớt code sang file khác -> Partial class hoặc Kế thừa
5. Vì không kiểm soát được lifetime, khi cần sử dụng Prefab tuỳ thuộc vào điều kiện khác nhau -> Resources.Load

### Tổng hợp các code do Dev Senspark sáng tạo ra nhờ Pattern Singleton:

Khi 2 class cần function của nhau:
```csharp
class A : Singleton {
    void Work1() {
        B.instance.CallMe();
    }

    void Work2() {
        // ...
    }
}

class B : Singleton {
    void CallMe() {
        A.instance.Work2();
    }
}

// Tưởng tượng: A gọi điện thoại cho B; B nghe máy; Rồi đồng thời B dùng 1 cái điện thoại khác để gọi cho A.
```

Khi class con cần function của class cha:
```csharp
class A : Singleton {
    void Work1();
}

class B : A {
    void Work2() {
        A.instance.Work1(); // base.Work1() ?
    }
}
```

Khi class cha cần function của class con:
```csharp
class A : Singleton {
    void Work1() {
        B.instance.Work2(); // Cha muốn tồn tại thì phải phụ thuộc vào con -> Con được đẻ trước khi cha ra đời.
    }
}

class B : A {
    void Work2();
}
```

## Quy định:
- Cấm tuyệt đối Pattern Singleton.
- Hạn chế God Object.
- Những code sai do lịch sử để lại: Nếu fix được thì tốt. Không tiếp tục bắt chước Pattern đó nữa.
- Không dời Singleton sang ServiceLocator. Bản chất ServiceLocator cũng là Singleton với cái tên khác. Mục đích ServiceLocator là để dùng cho các function luôn cần alive trong suốt vòng đời của Application. Không phải để sử dụng để chứa các GameObject/MonoBehaviour của Unity (lifetime phụ thuộc vào Scene).