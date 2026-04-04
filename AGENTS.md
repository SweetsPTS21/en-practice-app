# Agent Instructions

Mọi thay đổi UI, UX, state flow, và kiến trúc cho tính năng mới trong repo này phải tuân thủ tài liệu [Flutter App Production Design Standard](docs/flutter_app_design_guidelines.md).

## Nguồn chuẩn bắt buộc

- Đọc và áp dụng: `docs/flutter_app_design_guidelines.md`
- Ưu tiên tái sử dụng component nền trong `lib/core/design/widgets`
- Ưu tiên token/theme thay vì hardcode spacing, màu, radius, typography

## Quy tắc thực thi bắt buộc

- Chỉ thêm UI phục vụ trực tiếp mục tiêu chính của màn hình
- Không hiển thị thông tin trùng lặp, debug, kỹ thuật, hoặc label nội bộ trên production UI
- Thiết kế responsive cho đa số điện thoại phổ biến, không phụ thuộc kích thước cố định
- Mọi màn dữ liệu phải tính đến `loading`, `loaded`, `empty`, `error`, và `refreshing`
- Không gọi API trực tiếp trong widget UI và không tạo async work trong `build`
- Dòng dữ liệu mặc định: `UI -> State layer -> Repository -> Data source`
- Không reload dữ liệu hoặc làm mất scroll/state khi điều hướng thông thường nếu chưa thật sự cần
- Chỉ rebuild phần UI bị ảnh hưởng, tránh rebuild toàn màn không cần thiết
- Ưu tiên component dùng chung, API rõ ràng, và hành vi nhất quán toàn app

## Checklist trước khi hoàn tất thay đổi

- Nội dung đã gọn, không dư, không lặp
- CTA chính/phụ rõ ràng, dễ chạm, dễ hiểu
- Spacing/màu/chữ/icon dùng theo hệ thống sẵn có
- Không có layout vỡ, text tràn, hoặc hành vi giật/nháy trên màn hình nhỏ
- Không lộ chi tiết kỹ thuật hoặc business rule trong widget
- Phần thay đổi đạt mức production-ready theo guideline gốc

Nếu có xung đột, ưu tiên tài liệu `docs/flutter_app_design_guidelines.md`.
