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
  run.bat
```

Download: https://github.com/cookieplus/L2M_PowerScript/archive/refs/heads/main.zip
hoặc click vào nút [<> Code] màu xanh lá cây, sau đó chọn Download Zip.

## Chạy script
- Bật 2 màn hình game account Noka và Ruum. Nếu bạn có account Nobita, Xuka thì copy paste Noka.json thành 2 file Xuka.json và Nobita.json, vẫn trong folder configs.
- Chạy file `run.bat`. Chương trình sẽ yêu cầu quyền admin để thực hiện auto.

Cả 2 account sẽ chuyển vũ khí sang song kiếm. Sau 2 giây sẽ chuyển về vũ khí chính. Sau 298 giây, auto lại lặp lại dance sing.

## Chú ý
Nếu account của bạn tên là Nobita chẳng hạn thì copy/paste file Noka.json thành file Nobita.json trong folder configs.

Có thể thu nhỏ cửa sổ game về taskbar (không để chế độ tiết kiệm điện) mà auto vẫn chạy bình thường.

Ấn Ctrl + C hoặc tắt cửa sổ PowerShell để dừng script.

Nếu không muốn account nào chạy dance sing tự động thì đổi tên file json tương ứng thành tên khác.

Tránh bật cửa sổ đồ trong account đúng thời điểm dance sing chạy trên account do có thể gây lỗi vũ khí không được lựa chọn.

Click vào danh sách buff để biết bao giờ lại dance sing tiếp, hoặc đơn giản nhìn log ở PowerShell. Tự dộng dance sing sau 5 phút kém 2 giây.


Tên file và tên account phải trùng nhau cả chữ hoa chữ thường.

## Cập nhật
### 2026-05-28 
Thêm Count down xem còn bao lâu thì chạy auto tiếp.
Sửa bug xung đột khi nhiều combo chạy đồng thời.
### 2026-05-29 
Thêm thuộc tính `start_delay_seconds`. Nếu không đặt thì giá trị là 0. Nếu đặt thì combo này sẽ khởi động sau các combo khác `start_delay_seconds` giây. Giá trị giây có thể là số thực.
Cho phép người dùng tạo nhiều combo, mỗi combo có thời gian cooldown riêng.
Ví dụ người chơi sau để heal cá nhân ở ô số 1, lặp lại sau 30 giây. Khởi động chậm lại 15s so với các combo thông thường.
```json
[
{
  "loop_seconds": 298,
  "actions": [
    {
      "key": "6",
      "wait_after": 2
    },
    {
      "key": "7",
      "wait_after": 1
    }
  ]
},
{
  "start_delay_seconds": 15,
  "loop_seconds": 30,
  "actions": [
    {
      "key": "1",
      "wait_after": 0.1
    },
    {
      "key": "1",
      "wait_after": 0.1
    }
  ]
}
```
### 2026-05-30 
Thêm file run.bat để thực hiện xin quyền admin trước khi thực thi file auto.ps1.


