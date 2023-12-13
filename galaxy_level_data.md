# Hệ thống lưu trữ Level Data của Galaxy Shooter

Vì số lượng data trong 1 level của Galaxy Shooter rất nhiều và ko trực quan để Edit.  
Cho nên sẽ chỉ public những chỉ số phù hợp lên Google Sheet.  
Các dữ liệu còn lại sẽ chỉ cho phép edit bằng Level Editor (Web hoặc Unity).

### Level Data sẽ chia làm 2 loại và 2 nhóm:
2 Loại:
  - `BASE` level data (gồm các data về loại quái & vị trí, đường bay của chúng, các chỉ số mặc định)
  - `OVERRIDE` level data (gồm các data đã public trên Sheet)

2 Nhóm:
  - Test: (Device test sẽ có option để test loại data này)
  - Production: data áp dụng cho toàn bộ user hoặc nhóm user (A/B test, ...)

### Ý tưởng chung:
- Toàn bộ các data trên đều được lưu trữ thành file trên Cloud.  
- Dùng Remote Config để điều chỉnh sẽ áp dụng những file Level data nào.

## Google Sheet:
Link: https://docs.google.com/spreadsheets/d/1VlwUzIuH7E4cTdk0pLLxsjEAgQ7D3b5DbiCac2DmmBk/edit#gid=0  
(chưa move file về Drive của công ty)

Lưu ý:
- Chỉ cho phép sửa chỉ số trên Sheet.
- Thêm, xóa dòng, xoá cột, thay đổi cấu trúc file sẽ dẫn đến lỗi data (file OVERRIDE và file BASE có thể ko match với nhau).  
- Những chỉnh sửa phức tạp sẽ chỉnh trên Level Editor.

### Cách hoạt động:
Menu > Senspark > Import CSV sẽ xoá toàn bộ Sheet data & convert file từ Cloud -> Sheet  
Menu > Senspark > Export CSV sẽ soạn file CSV override để tải về  

## Cloud Storage:
Cấu trúc:
```
level_data
  L__ test
    L__ v1
      L__ lv1.csv (file data export ra từ Level Editor)
      ___ lv2.csv (file data export ra từ Level Editor)
      ___ lv1_2023_12_24.csv (giống file lv1 nhưng đã được chỉnh sửa ngày 24/12/2023)
      ___ override_level_data_2023_12_24.csv (file data export ra từ Google Sheet)
    L__ v2
      L__ ... (như cấu trúc trên, nhưng chỉ phát sinh trong trường hợp có thay đổi hoàn toàn về cấu trúc file Level data)
  L__ prod
    L__ ... (cấu trúc tương tự, nhưng chỉ dành cho production)
```

## Remote Config:
key: `level_data_v1_test` & `level_data_v1_prod`  
value: `string`

Cấu trúc:
```csv
lv, fileName
1, lv1.csv
2, lv2_2023_12_24.csv
...
override, override_level_data_2023_12_24.csv
```

## Cách Game khởi tạo level:
Các bước:
1. Đọc data từ Remote Config để lấy danh sách các file cần tải về
2. Trường hợp tải thất bại (vd: No internet) thì lấy file `DEFAULT` lưu sẵn ở device
3. Khởi tạo Level từ data trong file `BASE`
4. Chỉnh sửa lại chỉ số của Enemies trong file `OVERRIDE`
5. Hiển thị màn chơi

## Web Level Editor:
Sẽ build trang Web cho phép edit level, sắp xếp vị trí, vẽ đường bay, thêm/ xoá/ sửa quái, mô phỏng đường bay, chỉnh sửa Wave, ...  
Level Data sẽ được đọc từ Cloud & lưu vào Cloud sau khi edit xong.  
Mục đích là cho phép Design review sơ level, edit nhanh level ko cần Unity.  
