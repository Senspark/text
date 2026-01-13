# Tiêu chuẩn code cho Unity Projects

---

## 1. Cấu trúc thư mục tiêu chuẩn

### Tổ chức cây thư mục Assets

```
Assets/
├── Audio/
├── Art/
│   ├── Materials/
│   ├── Models/
│   ├── Textures (3D)/
│   └── Sprites (2D)/
├── Scripts/
│   └── Shaders/
├── Docs/
├── Plugins/
├── Scenes/
└── Prefabs/
    ├── Gameplay/
    ├── Levels/
    └── UI/
```

**Lưu ý:**
- Bên trong các thư mục trên: Tự tổ chức sub-folder cho hợp lý
- Không để bừa bãi thư mục dù ở folder nào

**Giải thích thêm:**
- **Scripts**: chỉ được chứa code C#
- **Plugins**: chứa code/assets của bên thứ 3 hoặc script riêng cho Android/iOS

**Quy tắc đặt tên:**
- Luôn dùng CamelCase - không dùng khoảng trống (space)
- Đặt tên theo số nhiều (Scripts thay cho Script)

### B. Asset Management

- Kiểm tra thường xuyên Sprite Atlas có được sử dụng đúng chưa. Xoá các Sprite không còn được sử dụng.

---

## 2. Về Code

### A. Naming convention (cách đặt tên)

- Tiêu chuẩn của ngôn ngữ. Tham khảo: [Microsoft C# Naming Guidelines](https://learn.microsoft.com/en-us/dotnet/csharp/fundamentals/coding-style/identifier-names)
- Theo format của project (nếu có editor_config)
- Theo tiêu chuẩn của IDE (Rider) để match với toàn bộ project.
- Không ghi sai chính tả
- Đặt tên phải miêu tả được tính năng chính xác. Không làm nhiều hơn nội dung đó.

### B. Code Format & Style

- Luôn phải format code. Tiêu chuẩn thụt lề là 4 space.
- IDE sử dụng là Rider. Không sử dụng Visual Studio Code.
- `if`, `for`, `while` luôn phải có cặp ngoặc (`{}`)
- Sử dụng `var` khi type ở vế bên phải đã rõ ràng.

### C. Code Quality

- Code, Files, Assets nào không còn sử dụng → Xoá.
- Nếu cấu trúc thư mục không còn phù hợp → Sắp xếp lại.
- Không duplicate code. Nếu code lặp lại hơn 2 lần → refactor lại.

### D. Code Organization

- Method không được dài quá 30 lines.
- File `.cs` không được dài quá 500 lines.
- Bổ sung comment nếu chức năng của đoạn code đó phức tạp.
- Class phải có namespace. Namespace follow theo cấu trúc thư mục.
- `WARNING == ERROR`. Fix tất cả các Warning mà IDE đánh dấu.
- Sắp xếp members trong class theo thứ tự sau:
    1. **Fields** (public → protected → private)
    2. **Properties** (public → protected → private)
    3. **Methods**:
        - MonoBehaviour: Unity lifecycle methods đầu tiên (Awake, Start, OnEnable, OnDisable, OnDestroy, Update, FixedUpdate, LateUpdate)
        - Sau đó: public → protected → private methods

**Ví dụ:**

```csharp
public class PlayerController : MonoBehaviour
{
    // Fields
    public float speed;
    [SerializedField] private Rigidbody _rb;
    private float _velocity;
    
    // Properties
    public bool IsMoving { get; private set; }
    
    // Unity Lifecycle Methods
    private void Awake() { }
    private void Start() { }
    private void Update() { }
    
    // Public Methods
    public void Move() { }
    
    // Private Methods
    private void CalculateVelocity() { }
}
```

### E. Design Pattern

- Nghiêm cấm Singleton & God Class.
- Không kế thừa quá 3 bậc.
- Không sử dụng `Infinite Loop` nếu không cần thiết.
- Không viết `static class` nếu không có lý do hợp lý.
- Không viết nhiều logic vào Properties. Thay thế bằng Method.
- Không sử dụng C# event. Thay thế bằng Pattern Observer.
- Không viết `partial class`.
- Chỗ nào (class/method) khởi tạo cái gì, chỗ đó chịu trách nhiệm dọn dẹp (destroy/dispose/kill).
- Mỗi class chỉ làm tối thiểu tính năng nhất có thể.
- Tham khảo mô hình MVC. Tách rời giữa Unity (View) & Pure C# Logic (Controller).

### F. Unity API & MonoBehaviour

- Tất cả khai báo Resolve ServiceLocator phải được viết trong Awake().
- Class Pure C# (không phải MonoBehaviour): không được sử dụng trực tiếp ServiceLocator, phải truyền dependencies vào constructor.
- Service không được là MonoBehaviour.
- GetComponent hoặc FindObject: chỉ được sử dụng ở Awake, Start hoặc các function tương đương.
- Không so sánh MonoBehaviour với null.
- Không được sử dụng Coroutine. Không được sử dụng Invoke(). Thay thế bằng UniTask.
- Không được sử dụng `DoTween.Clear()` hoặc tương đương. Object nào tạo Tween, object đó chịu trách nhiệm Kill. Không được Kill All.

---