# Cơ bản về NodeJS

## Nodejs là gì:
Website: https://nodejs.org/en
Tutorial: https://nodejs.org/en/learn/getting-started/introduction-to-nodejs

## Cách cài đặt
Cài đặt nvm: https://github.com/nvm-sh/nvm

## Ngôn ngữ sử dụng: Javascript | ECMAScript | ES
Mặc dù là Javascript nhưng môi trường sử dụng của NodeJS là Desktop Application.
Cho nên sẽ có vài sự khác biệt so với môi trường Web Browser.
CommonJS & ES Modules
Các đặc điểm của Javascript:
- Tên Javascript nhưng không có gì liên quan đến Java.
- Vốn là ngôn ngữ để viết script chạy trên web page. Trước đây là ngôn ngữ interpreted (phiên dịch), nhưng sau này đã được các trình duyệt web phát triển engine để compile (biên dịch). Cho nên performance tốt.
- Cú pháp tương đối giống các ngôn ngữ C/C++/C#
- Tương tự các ngôn ngữ hiện đại, Javascript có version của ngôn ngữ, các version sau bổ sung thêm nhiều tính năng.
- Vì lý do lịch sử, Javascript sẽ có nhiều Gotchas (các yếu tố bất ngờ) dễ gây ra lỗi mà lập trình viên ko ngờ tới.

### Typescript:
NodeJS ko support sẵn Typescript, nó cần được transpile sang Javascript trước khi chạy.

## Cách run javascript file
```bash
node <path_to_js_file>
```

## Npm
Là package manager mặc định của NodeJS. Có nhiều package manager khác được phát triển: yarn, ...
Nơi đây tổng hợp các thư viện mã nguồn mở do cộng đồng đóng góp.
```bash
npm init # Tạo file package.json

npm install # Cài đặt tất cả các package được khai báo trong file package.json
npm install <package_name> # Cài đặt package cụ thể
npm install <package_name>@<version> # Cài đặt package cụ thể với version nhất định
npm install -D <package_name> # Cài đặt package cụ thể vào mục devDependencies
npm install --save-dev <package_name> # Tương tự như trên

npm uninstall <package_name> # Gỡ cài đặt package cụ thể

npm update # Cập nhật tất cả các package
npm update <package_name> # Cập nhật package cụ thể

npm run <script_name> # Chạy script cụ thể trong file package.json
```

## Tạo project NodeJS
```bash
mkdir demo
cd demo
npm init
```

- Thư mục node_modules: Do NodeJS tạo ra. NodeJS sẽ tải source code của các thư viện mà người dùng yêu cầu vào đây. Thư mục này được ignore ko push lên git.
- File package.json: Lập trình viên khai báo thông tin của project, các package cần cài đặt, các scripts hỗ trợ, ...
- File package-lock.json: Do NodeJS tạo ra từ file package.json. Để giữ versions của các packages không bị thay đổi trong quá trình develop.

### package.json:
```json
{
  "name": "demo",
  "main": "index.js",
  "engines": {
    "node": ">=20.11.x"
  },
  "type": "module",
  "scripts": {
    "start": "node index.js"
  },
  "dependencies": {},
  "devDependencies": {}
}
```
- name: Tên display của project.
- main: File khởi động của project.
- engines: Khai báo cấu hình bắt buộc của hệ thống để chạy project này.
- type: Tuỳ chọn giữa "commonjs" & "module". Luôn luôn chọn "module".
- scripts: Khai báo các lệnh tuỳ ý.
- dependencies: Các package cần cài đặt.
- devDependencies: Các package cần cài đặt trong quá trình develop (Production ko cần, Test thì cần).

## HTTP Method:
HTTP định nghĩa các phương thức sau:
Thường thấy:
- GET: Có mục đích request data, không thay đổi state của server. Có thể sử dụng trực tiếp trên text box của trình duyệt web.
- POST: Có mục đích thay đổi state của server.
- OPTIONS:

Ko thường thấy:
- HEAD, PUT, DELETE, CONNECT, TRACE, PATCH

Có thể tạo các Request trên bằng: Postman, cURL, viết script, ...

## HTTP request và các thành phần chính:
- Headers
- Payload body

Code ví dụ, ko phải code có thể áp dụng được cho 1 project hoàn chỉnh:
```javascript
// npm install @types/node --save-dev
import {createServer} from 'node:http';

const server = createServer((req, res) => {
    let body = '';

    req.on('data', chunk => {
        body += chunk.toString();
    });

    req.on('end', () => {
        console.log(`Method: ${req.method}`);
        console.log(`Url: ${req.url}`);
        console.log('Headers:');
        console.log(req.headers);
        console.log('Body:');
        console.log(body);

        res.writeHead(200, {'Content-Type': 'application/json'});
        res.end(JSON.stringify({ message: 'Hello' }));
    });
});

server.listen(3000, '127.0.0.1', () => {
    console.log('Listening on 127.0.0.1:3000');
});
```

## Env
Mục đích để cấu hình các biến cho từng môi trường khác nhau (Test & Production).  
Tạo file `.env` Ví dụ:
```env
SECRET="123456"
```
Sửa file `package.json`
```json
{
  "scripts": {
    "start": "node --env-file=.env index.js"
  }
}
```
File `index.js`
```javascript
const secret = process.env.SECRET;
console.log(secret);
```

## Cross-Origin Resource Sharing (CORS):
Document: https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS

Tạo file `index.html` & run file ở port khác 3000 (ví dụ port 5000):
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CORS Test</title>
</head>
<body>
<script>
    fetch('http://localhost:3000')
        .then(response => response.json())
        .then(data => console.log(data))
        .catch(error => console.error('Error:', error));
</script>
</body>
</html>
```
Để cho phép website khác origin (ví dụ ở 127.0.0.1:5000) truy cập vào server:
- Server phải response thêm Header: `'Access-Control-Allow-Origin': 'http://127.0.0.1:5000'`