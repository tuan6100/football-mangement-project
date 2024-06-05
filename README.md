<div align="center">
  <h1>THIẾT KẾ CƠ SỞ DỮ LIỆU LƯU TRỮ DỮ LIỆU BÓNG ĐÁ    
  </h1>
  <p>
    <strong>Bộ môn Thực hành Cơ sở dữ liệu <br> Nhóm thực hiện: 07</strong>
  </p>
</div>

<details>
  <summary><b>Mục lục</b></summary> 
  
   <ol>
      <li><a href="#gioi-thieu">Giới thiệu để tài</a></li>
      <li><a href="#mo-hinh">Thiết kế mô hình dữ liệu</a></li>
      <li><a href="#xay-dung">Xây dựng hệ thống</a></li>
   </ol>

</details>

![football](https://www.instituteforgovernment.org.uk/sites/default/files/styles/16_9_desktop_2x/public/2023-03/premier-league-football-1504x846px.webp?h=dd1b06b1&itok=iUiWNX_U)

<h1 id="gioi-thieu">1. Giới thiệu đề tài</h1>

Thiết kế hệ quản trị cơ sở dữ liệu quản lý, lưu trữ và truy vấn thông tin về các
yếu tố liên quan đến những giải đấu bóng đá hàng đầu Châu Âu trong bối
cảnh nhu cầu tra cứu thông tin từ người hâm mộ bóng đá trên thế giới.
  - Về mục đích xây dựng: Giúp ban quản lý giải đấu, cầu thủ, huấn luyện
viên, người hâm mộ,... theo dõi thông tin một cách nhanh chóng và tiện
lợi.
  - Về chức năng nghiệp vụ: Hệ thống được xây dựng với chức năng chính là
lưu trữ và hỗ trợ truy vấn những thông tin về giải đấu, đội bóng, cầu thủ,
lịch sử đối đầu,... (mô phỏng dựa theo Wikipedia). Bên cạnh đó hệ thống
còn hỗ trợ tính toán điểm số, thống kê thứ hạng tự động với sự hỗ trợ của
ngôn ngữ truy vấn cấu trúc và một số ngôn ngữ lập trình khác.
  - Về yêu cầu: Xây dựng hệ thống một cách khoa học, tối ưu, trực quan,
đáp ứng đầy đủ nhu cầu của người dùng. Đồng thời cần có nguồn dữ liệu
chính xấc được kiểm chứng trên trang chủ của các đội bóng cũng như của
giải đấu và có sự cập nhật thường xuyên.

<h1 id="mo-hinh">2. Thiết kế mô hình dữ liệu
<h2>2.1 Mô hình thực thể - liên kết</h2>
  
![descritable](https://raw.githubusercontent.com/tuan6100/football-mangement-project/main/img/image.png?token=GHSAT0AAAAAACSFWEYHNLWUKG437UDPX2MSZSNTODA)

>## Danh sách thực thể:
>  - Quốc gia: Lưu trữ thông tin đến các quốc gia là quê hương của các cầu thủ cũng như là nơi tổ chức các giải đấu
>  - Giải đấu: Lưu trữ thông tinh của các giải đấu bóng đá
>  - Đội bóng: Lưu trữ thông tin của các đội bóng tham gia giải đấu
>  - Cầu thủ: Lưu trữ thông tin của các cầu thủ trong đội bóng
>  - Huấn luyện viên: Lưu trữ thông tin của huấn luyện viên trong đội bóng
>  - Trận đấu: Lưu trữ thông tin được thống kê từ các trận đấu.

<h2>2.2 Sơ đò quan hệ</h2>

![erd](https://github.com/tuan6100/football-mangement-project/blob/main/img/drawSQL-image-export-2024-05-22.png?raw=true)

<h1 id="xay-dung">3. Xây dựng hệ thống</h1>

<h2>3.1 Thiết kế truy vấn dữ liệu</h2>

Danh sách các bảng xem ![tại đây](Data/tablelist.sql)

Danh sách các câu truy vấn:

<ul>
  <li > Nhóm truy vấn thông tin về giải đấu, câu lạc bộ: </li>
</ul>
    <ol start=1>
     <li> In ra bảng xếp hạng của giải đấu ... trong mùa giải ... </li>
     <li> Danh sách các clb trong giải đấu ... ở mùa giải 2023-2024 được tham gia vào giải đấu cup "UEFA Champion League" </li>
     <li> Danh sách các clb trONg giải đấu ... ở mùa giải 2023-2024 được tham gia vào giải đấu cup "UEFA Europe League" </li>
     <li> Danh sách các clb đã vô địch ở các giải đấu trong mùa giải ... </li>
     <li> Danh sách số trận thắng, hòa, thua và tính điểm số mà clb ... nhận được trong mùa giải ... ở giải đấu ... </li>
     <li> Thứ hạng trung bình của clb ... trong giải đấu ... từ mùa giải ... đến nay. </li>
     <li> danh sách tên các clb ... đã thi đấu trong ngày ... </li>   
     </ol>
  
  
 <ul><li > Nhóm truy vấn thông tin về trận đấu  </li></ul>
   <ol start="9">
      <li> Liệt kê tỉ số của các trận diễn ra trong vòng đấu ... của giải đấu ... trong mùa giải ...</li>
      <li> Liệt kê tỉ số của các trận diễn ra trong ngày ... <br>
      <li> lịch sử đối đấu giữa 2 đội bóng ... và ... từ năm ... đến năm ... <br>
      <li> Thống kê trận đấu có tổng số bàn thắng 2 đội ghi được nhiều nhất trong giải đấu ... ở mùa giải ... </li>
      <li> Thống kê trận đấu có tỉ số thắng - thua đậm nhất trong giải đấu ... ở mùa giải ... </li>
      <li> Trung bình số bàn thắng ghi được trong 1 trận của giải đấu ... ở mùa giải ... </li>    
   </ol>

   
<ul><li> Nhóm truy vấn thông tin về cầu thủ, huấn luyện viên </li></ul>

  <ol start="15">
   <li> Liệt kê danh sách cầu thủ thuộc biên chế trong clb ... </li>
   <li> Liệt kê danh sách cầu thủ có quốc tịch ... và thi đấu ở giải đấu ... </li>
   <li> Liệt kê số bàn thắng và kiến tạo mà cầu thủ ... có được trong mùa giải ... </li>
   <li> Thông tin của vua phá lưới của giải đấu ... trong mùa giải ...</li>
   <li> Thông tin cầu thủ xuất sắc nhất giải đấu ... trong mùa giải ... </li>
  <li> Thông tin cầu thủ có nhiều bàn thắng nhất trong các giẩi đấu ... trong mùa giải ...</li>
   <li> Tổng số bàn thắng và số kiến tạo của cac cầu thủ trong màu áo của clb ... trong thời gian thi đấu </li>
   <li> Thông tin cầu thủ có điểm rating cao nhất trong vòng đấu ... của giải đấu .. ở mùa giải .. </li>
   <li> Số trận đấu mà cầu thủ ... thi đấu cho clb ... từ năm ... đến nay. </li>
   <li> Thông tin cầu thủ thi đấu nhiều trận nhất trong giải đấu ... ở mùa giải ... </li>
   <li> Top 10 cầu thủ có chiều cao lớn nhất trong giải đấu ... </li>
   <li> Danh sách cầu thủ có số lần vô địch giải đấu ... nhiều nhất </li>
  </ol>

<h2>3.2 Demo hệ thống</h2>

<h3>3.2.1 Thiết kế giao diện website</h3>

Đang cập nhật ...

<h3>3.2.2 Giao diện dòng lệnh</h3>

Cài đặt CMAKE:
[cmake](https://cmake.org/download/)
```
git clone https://github.com/tuan6100/football-mangement-project 
cd football-mangement-project/CLI
mkdir build && cd build
cmake ..
make
./football
```