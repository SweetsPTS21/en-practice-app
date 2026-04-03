# Flutter App Production Design Standard

Tài liệu này là bộ quy chuẩn dành cho AI Agent, designer và developer khi thiết kế hoặc triển khai ứng dụng Flutter theo định hướng production. Mục tiêu là tạo ra sản phẩm ổn định, mượt, hiện đại, dễ mở rộng, và nhất quán trên phần lớn thiết bị phổ biến.

Tài liệu này chỉ chứa các nguyên tắc có giá trị thực thi. Không đưa vào các ghi chú mang tính giải thích nội bộ, nội dung trùng lặp, hoặc hướng dẫn chỉ hữu ích cho người đã biết bối cảnh kỹ thuật.

`Chú thích`: Flutter SDK tại `C:\Users\sonpt1\flutter-sdk\bin`

---

## 1. Mục tiêu bắt buộc

Mọi màn hình, luồng thao tác và thành phần giao diện phải đáp ứng đồng thời các tiêu chí sau:

- Hiển thị gọn, rõ, ưu tiên nội dung chính.
- Không tạo cảm giác chật chội hoặc dư thừa thông tin.
- Phản hồi nhanh, chuyển trạng thái mượt, không giật khựng.
- Không tải lại dữ liệu hoặc dựng lại giao diện khi không cần thiết.
- Hoạt động ổn định trên đa số thiết bị có kích thước màn hình khác nhau.
- Giữ tính nhất quán về khoảng cách, màu sắc, kiểu chữ, hành vi và điều hướng.
- Sẵn sàng cho môi trường production: dễ kiểm soát, dễ bảo trì, dễ mở rộng.

---

## 2. Nguyên tắc thiết kế tổng quát

### 2.1 Ưu tiên nội dung chính

- Mỗi màn hình chỉ nên phục vụ một mục tiêu chính.
- Nội dung quan trọng phải xuất hiện sớm, trong vùng nhìn thấy đầu tiên nếu có thể.
- Không hiển thị dữ liệu lặp lại giữa tiêu đề, thẻ thông tin và nội dung chính.
- Không đưa thông tin kỹ thuật, debug, trạng thái nội bộ hoặc nhãn không cần thiết ra giao diện production.

### 2.2 Tối ưu không gian hiển thị

- Mọi khoảng trắng phải có chủ đích.
- Không nhồi quá nhiều thành phần trên cùng một vùng nhìn.
- Dùng phân cấp thị giác rõ ràng để giảm tải nhận thức.
- Tránh các block lớn, dài, dày đặc nếu có thể chia nhóm hoặc rút gọn.

### 2.3 Hiện đại và dễ dùng

- Giao diện phải sạch, sáng sủa, cân bằng, ít nhiễu.
- Hành vi tương tác phải dễ đoán.
- Mọi thao tác chính phải rõ ràng, dễ chạm, dễ quay lại.
- Trạng thái loading, empty, error phải rõ nhưng không gây cản trở.

---

## 3. Quy chuẩn UI bắt buộc

### 3.1 Bố cục

- Dùng lưới và hệ khoảng cách nhất quán.
- Ưu tiên spacing theo thang 4, 8, 12, 16, 20, 24, 32.
- Không đặt các thành phần sát viền nếu không có lý do rõ ràng.
- Không hardcode kích thước làm vỡ bố cục trên máy nhỏ hoặc quá loãng trên máy lớn.

### 3.2 Mật độ thông tin

- Chỉ hiển thị thông tin phục vụ quyết định hoặc hành động của người dùng.
- Ẩn hoặc rút gọn nội dung phụ, thay vì hiển thị toàn bộ ngay từ đầu.
- Một item trong danh sách chỉ nên có các thông tin thật sự cần cho việc quét nhanh.
- Không hiển thị hai thành phần khác nhau nhưng cùng diễn đạt một ý.

### 3.3 Kiểu chữ

- Dùng hệ typography thống nhất toàn app.
- Giới hạn số cấp chữ ở mức đủ dùng để tránh rối.
- Văn bản phải dễ đọc trên màn hình nhỏ.
- Không dùng chữ quá nhỏ, quá dày hoặc khoảng cách dòng quá sít.

### 3.4 Màu sắc

- Màu phải được điều khiển bởi theme hoặc token thống nhất.
- Không lạm dụng màu nhấn.
- Màu phải thể hiện đúng ngữ nghĩa: chính, phụ, cảnh báo, lỗi, thành công.
- Đảm bảo độ tương phản đủ tốt trong điều kiện sử dụng thông thường.

### 3.5 Thành phần tương tác

- Vùng bấm phải đủ lớn và dễ chạm.
- Thành phần có thể tương tác phải có phản hồi trực quan rõ ràng.
- Không đặt quá nhiều CTA ngang cấp trên cùng một màn.
- Hành động chính và phụ phải được phân biệt rõ bằng thứ bậc thị giác.

### 3.6 Responsive

- Thiết kế phải thích ứng tốt với đa số điện thoại phổ biến.
- Không phụ thuộc vào một kích thước màn hình cố định.
- Nội dung phải co giãn hợp lý khi chiều ngang hoặc chiều cao thay đổi.
- Không để text tràn, nút bị đè, danh sách bị cắt hoặc khoảng cách mất cân đối.

---

## 4. Quy chuẩn UX bắt buộc

### 4.1 Điều hướng

- Luồng di chuyển phải ngắn, rõ, ít bước thừa.
- Người dùng luôn biết mình đang ở đâu và có thể quay lại bằng cách tự nhiên.
- Không tạo các bước trung gian chỉ để hiển thị thông tin có thể gộp.

### 4.2 Trạng thái màn hình

Mỗi màn hình dữ liệu phải định nghĩa rõ các trạng thái sau:

- Loading
- Loaded
- Empty
- Error
- Refreshing

Yêu cầu:

- Mỗi trạng thái phải có hiển thị rõ ràng, gọn, không chiếm dụng quá nhiều không gian.
- Loading không được làm nhấp nháy hoặc thay đổi bố cục đột ngột.
- Empty state phải hướng người dùng tới hành động phù hợp.
- Error state phải ngắn gọn, hữu ích, không lộ thông tin kỹ thuật.

### 4.3 Refresh dữ liệu

- Không tự động reload toàn bộ màn hình khi người dùng chuyển qua lại nếu dữ liệu chưa cần cập nhật.
- Mặc định ưu tiên giữ state và hiển thị dữ liệu sẵn có.
- Làm mới dữ liệu theo hành vi có chủ đích như kéo xuống để tải lại, thao tác cập nhật, hoặc khi dữ liệu đã hết hạn.
- Không làm mất vị trí cuộn hoặc ngắt mạch sử dụng nếu không cần thiết.

### 4.4 Phản hồi thao tác

- Mọi hành động quan trọng phải có phản hồi rõ ràng.
- Thành công, thất bại và đang xử lý phải được thể hiện nhất quán.
- Không dùng thông báo dài dòng, mơ hồ hoặc lặp lại với cùng một hành động.

---

## 5. Quy chuẩn kiến trúc production

### 5.1 Phân lớp rõ ràng

Ứng dụng phải tách rõ các lớp:

- Presentation
- State / ViewModel / Controller
- Repository
- Data source
- Core / Shared

Yêu cầu:

- UI không chứa business logic.
- UI không gọi API trực tiếp.
- Business rule không nằm rải rác trong widget.
- Truy xuất dữ liệu phải đi qua repository hoặc lớp trung gian tương đương.

### 5.2 Pattern khuyến nghị

Các pattern phù hợp cho production:

- MVVM
- Repository Pattern
- Clean Architecture theo mức độ vừa đủ
- State management có kiểm soát như Riverpod, Bloc/Cubit hoặc Provider nếu cấu trúc nhỏ

Mục tiêu của pattern là:

- Giảm coupling
- Dễ test
- Dễ thay đổi nguồn dữ liệu
- Tránh reload và side effect không kiểm soát

### 5.3 Quản lý state

- State phải có vòng đời rõ ràng.
- Không để state quan trọng phụ thuộc hoàn toàn vào vòng đời ngắn của widget nếu cần giữ lại khi điều hướng.
- Tách state hiển thị khỏi dữ liệu thô và logic tải dữ liệu.
- Chỉ rebuild phần giao diện bị ảnh hưởng.

### 5.4 Dòng dữ liệu

Dòng dữ liệu chuẩn:

`UI -> State layer -> Repository -> Remote/Local data source`

Quy tắc:

- UI chỉ đọc state và gửi intent.
- State layer xử lý logic trình bày và điều phối.
- Repository chịu trách nhiệm thống nhất nguồn dữ liệu, cache và chiến lược refresh.

---

## 6. Quy chuẩn hiệu năng

### 6.1 Không tải lại không cần thiết

- Không tạo API call hoặc Future trực tiếp trong quá trình build UI.
- Không fetch lại dữ liệu chỉ vì widget được dựng lại.
- Không reset state chỉ vì người dùng đổi tab, back về màn trước hoặc chuyển route ngắn hạn.

### 6.2 Cache và giữ state

- Dữ liệu danh sách hoặc dữ liệu đọc nhiều phải có chiến lược cache phù hợp.
- Ưu tiên hiển thị dữ liệu sẵn có trước, sau đó cập nhật có kiểm soát nếu cần.
- Giữ state và vị trí cuộn cho các màn có khả năng quay lại thường xuyên.

### 6.3 Dựng danh sách và thành phần dài

- Dùng cơ chế dựng lười cho danh sách dài.
- Tách item thành widget độc lập nếu cần tối ưu rebuild.
- Không render toàn bộ danh sách nếu số lượng lớn.

### 6.4 Ảnh và tài nguyên

- Dùng kích thước tài nguyên phù hợp mục đích hiển thị.
- Không tải ảnh lớn vượt quá nhu cầu thực tế.
- Có placeholder hợp lý khi nội dung tải chậm.

### 6.5 Chuyển động

- Animation chỉ dùng khi tăng chất lượng trải nghiệm.
- Không dùng animation làm chậm thao tác chính.
- Thời lượng chuyển động phải ngắn, mượt, nhất quán.

---

## 7. Quy chuẩn nội dung hiển thị

### 7.1 Chỉ hiển thị nội dung hữu ích

- Mọi text trên màn hình phải có mục đích rõ ràng.
- Loại bỏ mô tả dư thừa nếu người dùng đã hiểu ngữ cảnh từ bố cục hoặc nhãn.
- Không hiển thị tên trường nội bộ, mã hệ thống, key kỹ thuật hoặc cấu trúc dành riêng cho developer.

### 7.2 Không trùng lặp

- Không lặp cùng một thông tin ở nhiều khu vực.
- Không vừa hiển thị tiêu đề lớn vừa lặp lại y nguyên ở mô tả ngắn bên dưới.
- Không dùng nhiều nhãn khác nhau cho cùng một khái niệm trong cùng một luồng.

### 7.3 Ngôn ngữ giao diện

- Ngắn, rõ, trực tiếp.
- Ưu tiên câu hành động đơn giản.
- Tránh câu mơ hồ, quá kỹ thuật hoặc thiên về mô tả hệ thống.

---

## 8. Quy chuẩn component

### 8.1 Tái sử dụng

- Thành phần dùng lặp lại phải được chuẩn hóa thành component dùng chung.
- Không sao chép cùng một kiểu giao diện nhiều nơi với khác biệt nhỏ nhưng không kiểm soát.

### 8.2 Đồng nhất

- Cùng loại dữ liệu phải có cùng cách hiển thị.
- Cùng loại hành động phải có cùng vị trí và cách phản hồi.
- Cùng loại thẻ, ô nhập, nút bấm phải thống nhất về hình thức và hành vi.

### 8.3 Khả năng mở rộng

- Component phải dễ cấu hình nhưng không quá linh hoạt tới mức mất chuẩn.
- Ưu tiên API rõ ràng, có giới hạn, dễ dùng đúng.

---

## 9. Quy chuẩn production readiness

Một màn hình hoặc tính năng chỉ được coi là đạt chuẩn production khi thỏa mãn các điều kiện sau:

- Không hiển thị thông tin thừa.
- Không hiển thị thông tin trùng lặp.
- Không lộ chi tiết dành riêng cho developer hoặc hệ thống nội bộ.
- Có đầy đủ trạng thái loading, empty, error, loaded khi phù hợp.
- Không reload dữ liệu vô ích khi điều hướng thông thường.
- Không có layout vỡ trên phần lớn thiết bị mục tiêu.
- Không có hành vi gây giật, nháy, đứng hoặc đơ trong luồng chính.
- Màu sắc, chữ, spacing, icon, component và điều hướng nhất quán với toàn app.

---

## 10. Anti-pattern tuyệt đối tránh

- Gọi API trực tiếp trong widget UI.
- Tạo dữ liệu bất đồng bộ ngay trong build.
- Nhồi quá nhiều thông tin lên một màn.
- Dùng text mô tả dài để bù cho bố cục kém rõ.
- Hiển thị dữ liệu trùng lặp ở nhiều nơi.
- Hiển thị thông tin kỹ thuật chỉ để developer dễ debug.
- Hardcode spacing, màu, font, radius thiếu hệ thống.
- Rebuild toàn màn khi chỉ một phần nhỏ thay đổi.
- Làm mất state hoặc vị trí cuộn khi người dùng quay lại màn trước.
- Tự động refresh gây gián đoạn trải nghiệm mà không có lý do rõ ràng.

---

## 11. Checklist bắt buộc cho AI Agent

Trước khi đề xuất hoặc sinh ra UI, code hoặc luồng tương tác, AI Agent phải tự kiểm tra:

- Giao diện này đã tối ưu nội dung chính chưa?
- Có thành phần hoặc đoạn text nào dư thừa không?
- Có thông tin nào đang bị lặp lại không?
- Thiết kế này có phù hợp với đa số điện thoại phổ biến không?
- Có phụ thuộc vào kích thước cố định không?
- Trạng thái loading, empty, error đã được tính tới chưa?
- Dữ liệu có bị reload vô ích khi điều hướng không?
- State có được giữ hợp lý không?
- Kiến trúc có đủ rõ để dùng trong production không?
- Thành phần này có nhất quán với phần còn lại của app không?

Nếu một câu trả lời là không rõ ràng hoặc không đạt, phải ưu tiên chỉnh lại theo hướng gọn hơn, rõ hơn, ổn định hơn.

---

## 12. Kết luận

Chuẩn thiết kế production cho Flutter không chỉ là đẹp, mà còn phải đúng về cấu trúc, hiệu năng và trải nghiệm sử dụng thực tế.

Mọi quyết định thiết kế và triển khai phải ưu tiên:

- Ít nhưng đủ
- Rõ hơn nhiều hơn
- Mượt hơn phô trương
- Nhất quán hơn tùy hứng
- Production-ready hơn minh họa nội bộ

Chuẩn cuối cùng cần đạt là: giao diện hiện đại, tối ưu không gian, vận hành mượt, không thừa, không lặp, không rò rỉ chi tiết kỹ thuật, và đủ bền vững để đi vào production thực tế.
