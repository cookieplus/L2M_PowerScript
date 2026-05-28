# L2M_PowerScript
Tự động dance sing khi chạy Lineage2M trên PC.

## Chuẩn bị
Giả sử đang chạy L2 bằng Purple trên PC. Có 2 account là Noka và Ruum. Cả 2 account này đều đã mua 2 hoặc 3 bài dance của Song kiếm và đều để sẵn là Auto.

Trên mỗi account, tạo phím tắt cho vũ khí như sau:
- vũ khí song kiếm, đặt vào ô số 6 (ô đầu tiên số 1).
- vũ khí chính, đặt vào ô số 7

## Download
Download project này về dưới dạng file zip. Unzip ở folder, ví dụ C:\temp\auto
Cấu trúc thư mục như sau

```text
auto\
  configs\
    Noka.json
    Ruum.json
  auto.ps1  
```

Download: https://github.com/cookieplus/L2M_PowerScript/archive/refs/heads/main.zip
hoặc click vào nút [<> Code] màu xanh lá cây, sau đó chọn Download Zip.

## Chạy script
- Bật 2 màn hình game account Noka và Ruum. Nếu bạn có account Nobita, Xuka thì copy paste Noka.json thành 2 file Xuka.json và Nobita.json, vẫn trong folder configs.
- Tìm ứng dụng PowerShell, kéo thành icon trên taskbar.
- Chuột phải vào PowerShell, chọn Run as Administrator. Windows sẽ hiển thị popup yêu cầu người dùng đồng ý.
- Trong PowerShell, gõ lệnh ``` cd <đường dẫn tới folder script>```
Ví dụ ở unzip ở folder ``` C:\temp\auto ``` thì gõ
```cd C:\temp\auto ```

- Gõ lệnh sau để unblock file auto.ps1 Lệnh này chỉ cần chạy 1 lần duy nhất.
```
Unblock-File -Path .\auto.ps1
```

Sau đó chạy lệnh sau. Mỗi lần bật lại Auto đều phải chạy lại lệnh này.
```
.\auto.ps1
```
để thực thi auto.

Cả 2 account sẽ chuyển vũ khí sang song kiếm, sau 2 giây sẽ chuyển về vũ khí chính.

Lặp lại bước trên sau 298 giây.

## Chú ý
Nếu account của bạn tên là Nobita chẳng hạn thì copy/paste file Noka.json thành file Nobita.json trong folder configs.

Có thể thu nhỏ cửa sổ game về taskbar (không để chế độ tiết kiệm điện) mà auto vẫn chạy bình thường.

Ấn Ctrl + C hoặc tắt cửa sổ PowerShell để dừng script.

Nếu không muốn account nào chạy dance sing tự động thì đổi tên file json tương ứng thành tên khác.

Tránh bật cửa sổ đồ trong account đúng thời điểm dance sing chạy trên account do có thể gây lỗi vũ khí không được lựa chọn.

Click vào danh sách buff để biết bao giờ lại dance sing tiếp, hoặc đơn giản nhìn log ở PowerShell. Tự dộng dance sing sau 5 phút kém 2 giây.


Tên file và tên account phải trùng nhau cả chữ hoa chữ thường.

