# Hướng dẫn sử dụng AI cho Dev

---

# Khái niệm thứ 1: Token

Model sẽ không sử dụng ngôn ngữ phổ thông của con người. Thay vào đó, nó sẽ dịch đoạn hội thoại thành một array các **tokens** để xử lý input/output.

**Tools Tokenizer:** https://platform.openai.com/tokenizer

### Ví dụ convert chuỗi string sang tokens:

| Chuỗi | Tokens |
|---|---|
| `Hello :))` | 3 |
| `Chào :))` | 4 |
| `Con cáo và chùm nho` | 8 |
| `Con cao va chum nho` | 6 |

```
void SomeFunction() {
    // Hello
}
```
→ 10 Tokens

### Tiếng Việt vs Tiếng Anh:

Các kiến thức kỹ thuật hầu như được training trên tài liệu tiếng Anh. Khi user hỏi bằng tiếng Việt, AI sẽ phải dịch qua lại giữa Anh ↔ Việt.

Về cơ bản điều này không ảnh hưởng lớn, nhưng cần lưu ý:
- Tốn token hơn so với tiếng Anh.
- Model có thể hiểu sai ý — tốn thêm prompt và token để giải thích lại.

**Ví dụ dịch thuật:** https://translate.google.com/?sl=vi&tl=en&text=%C4%83n%20c%C6%A1m%20hay%20%C4%83n%20%C4%91%C3%A1%3F&op=translate

---

# Khái niệm thứ 2: Context

Context chia làm 2 phần: **Context của prompt** và **Context của session**.

### Context của prompt

Prompt càng rõ ràng càng tốt:

- ❌ `Cái này bị lỗi` → Model không hiểu "cái này" là gì. Phải suy luận để đoán → tốn processing power, thời gian chờ, output token, và tệ nhất là hiểu sai ý.
- ✅ `Code bị lỗi ở file X dòng Y, đây là log/stacktrace. Các bước để reproduce lỗi này...` → Rõ ràng, dễ xử lý.

### Context của session

Tất cả các message giữa user và AI, nội dung file đính kèm... sẽ được tổng hợp thành một khối gọi là **Session Context**. Mỗi Model có giới hạn maximum context. Nếu vượt quá:
- Thông tin sẽ bị tự động cắt bỏ.
- Chất lượng suy luận giảm đáng kể, dù chưa vượt giới hạn.

Thông thường không nên để session context vượt quá **50–70%** giới hạn của Model.

> **Quy tắc:** Mỗi session chỉ nên thực hiện một task nhỏ, tránh để context phình to.

---

# Khái niệm thứ 3: Hallucination

### Cách một Model được training (giải thích đơn giản hóa — thực tế sẽ phức tạp hơn):

1. Người huấn luyện chuẩn bị dataset, ví dụ:
   - Cờ Việt Nam có màu đỏ
   - Cờ Trung Quốc có màu đỏ
   - Cờ Thuỵ Sĩ có màu đỏ

2. Model học pattern từ dataset. Khi được hỏi, Model suy luận để đoán token tiếp theo:
   - Hỏi: `Cờ Việt Nam...`
   - Model đoán: `màu xanh` → Sai
   - Model đoán: `màu đỏ` → Đúng

3. Sau khi training:
   - `Cờ Việt Nam...` → Model trả lời `màu đỏ` ✅
   - `Cờ Mỹ...` → Model chỉ biết pattern `màu đỏ` từ dataset → trả lời `màu đỏ` ❌

**→ Cờ Mỹ màu đỏ — đây gọi là Hallucination (Model bị ảo giác)**

### Chúng ta nên hiểu như thế nào?

Model chỉ trả lời dựa trên dataset đã được training. Dataset đó có thể sai, hoặc thiếu — dẫn đến câu trả lời có thể sai. Người dùng phải tự kiểm chứng thông tin AI cung cấp.

> Bỏ tư duy: *"AI đã trả lời như vậy, nên chắc chắn đúng."*

### Lưu ý:
- Một số Model hiện đại đã có database riêng để tra cứu dữ liệu.
- Một số Model có khả năng search Internet.
- Một số Model đã được fine-tune để có thể trả lời *"tôi không chắc"* hoặc tự tìm kiếm thêm thông tin — nhưng không đồng nghĩa với việc luôn đúng, vì phụ thuộc vào chất lượng thông tin tìm được.
- Giống như con người: nếu xung quanh toàn thông tin sai lệch, kết quả sai lệch sẽ trở thành niềm tin đúng đắn.

---

# Khái niệm thứ 4: AI Model

Không phải Model nào cũng cho ra output giống nhau. Các Model khác nhau về:
- **Kiến trúc và quy mô training** (các Model thương mại thường không công bố số lượng tham số)
- **Chất lượng và cách tối ưu hóa** cho từng loại task

Model càng chất lượng, giá càng đắt và tốn nhiều processing power hơn.

### Ví dụ một số Model:

| Nhà cung cấp | Model | Pricing |
|---|---|---|
| Google | Gemini 2.5 Pro, Gemini 2.5 Flash | https://ai.google.dev/gemini-api/docs/pricing |
| OpenAI | GPT-5.4 | https://platform.openai.com/docs/pricing |
| Anthropic | Claude Opus 4.6, Claude Sonnet 4.6 | https://claude.com/pricing#api |
| Cộng đồng | Nhiều model khác | https://huggingface.co/models |

### Lưu ý:
- Pricing ở trên là giá **mỗi API Request** để sử dụng Model thông qua nhà cung cấp — vì họ tốn tài nguyên để chạy Model đó.
- Nhiều Model là OpenSource (tên gọi chính xác hơn là **OpenWeight**) — có thể tải về và tự chạy nếu máy đủ mạnh.

---

# Khái niệm thứ 5: Sử dụng AI Agent

### AI Agent là gì?

Khác với AI Model thông thường chỉ nhận input và trả output, **AI Agent** có thể tự thực hiện hành động: đọc file, chạy code, gọi API, và lặp lại nhiều bước để hoàn thành một task phức tạp.

### Một số tools phổ biến:

- **Claude Code** (Anthropic)
- **Codex CLI** (OpenAI / ChatGPT)
- **Gemini CLI** (Google)
- **GitHub Copilot**
- Các tools khác: Cursor, Windsurf, VSCode Copilot...

### Quy tắc cấu trúc project để Agent làm việc hiệu quả (Unity):

**1. Cung cấp context rõ ràng qua `CLAUDE.md`**

Tạo file `CLAUDE.md` ở root project. Agent sẽ tự động đọc file này khi khởi động. Ghi vào đó:
- Cấu trúc folder project
- Convention đặt tên (class, file, prefab...)
- Các pattern đang dùng (DOTween, Addressables, v.v.)
- Những file/folder Agent **không được tự ý sửa**

**2. UI class: serialize đầy đủ các field**

Dùng `[SerializeField]` nhất quán, đặt tên field rõ nghĩa, comment ngắn trên các field phức tạp — giúp Agent đọc code và hiểu dependency mà không cần trace ngược.

**3. Log ra file (đồng thời log ra Console)**

Thay vì dùng `Debug.Log` trực tiếp, ghi log ra file để Agent có thể đọc và monitor. Tự định nghĩa format, lọc theo level (Info / Warning / Error) — dễ parse hơn so với `Editor.log` vốn rất noisy.

**Ví dụ thực tế:** https://github.com/Senspark/dev-sample-unity/commit/d09100f209eb45952718b33d85f6499c7d3c4135
