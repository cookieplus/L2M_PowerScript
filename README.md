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
configs\
  Noka.json
  Ruum.json
auto.ps1  

Download: https://github.com/cookieplus/L2M_PowerScript/archive/refs/heads/main.zip
hoặc click vào nút [<> Code] màu xanh lá cây, sau đó chọn Download Zip.

## Chạy script
- Bật 2 màn hình game account Noka và Ruum.
- Tìm ứng dụng PowerShell, kéo thành icon trên taskbar.
- Chuột phải vào PowerShell, chọn Run as Administrator. Windows sẽ hiển thị popup yêu cầu người dùng đồng ý.
- Trong PowerShell, gõ lệnh cd <đường dẫn tới folder script>
Ví dụ ở unzip ở folder C:\temp\auto thì gõ
cd C:\temp\auto

- Gõ lệnh 
.\auto.ps1
để thực thi auto.

Cả 2 account sẽ chuyển vũ khí sang song kiếm, sau 2 giây sẽ chuyển về vũ khí chính.

Lặp lại bước trên sau 298 giây.
