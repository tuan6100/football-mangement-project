
<table><thead>
  <tr>
    <th>STT</th>
    <th>Nội dung truy vấn</th>
    <th>Phương pháp tối ưu</th>
    <th>Kiểm nghiệm</th>
    <th>Ghi chú</th>
    <th>Chức năng</th>
  </tr></thead>
<tbody>
  <tr>
    <td>1</td>
    <td>Thêm một trận đấu mới</td>
    <td>Không</td>
    <td><ul><li>- [x] Hoàn thành</li><li>- [ ] Tối ưu</li></ul></td>
    <td><td>
    <td rowspan="6">Thêm, xóa,<br>cập nhật <br>dữ liệu<br></td>
  </tr>
  <tr>
    <td>2</td>
    <td>Cập nhật tỷ sô cho trận đấu</td>
    <td>Không</td>
    <td><ul><li>- [x] Hoàn thành</li><li>- [ ] Tối ưu</li></ul></td>
    <td><td>
  </tr>
  <tr>
      <tr>
    <td>3</td>
    <td>Cập nhật só liệu thống kê thu được trong các trận đấu sau mỗi trận đấu</td>
    <td>Không</td>
    <td><ul><li>- [x] Hoàn thành</li><li>- [ ] Tối ưu</li></ul></td>
    <td><td>
  </tr>
    <tr>
    <td>4</td>
    <td>Cập nhật bxh sau mỗi trận đấu</td>
    <td>Không</td>
    <td><ul><li>- [x] Hoàn thành</li><li>- [ ] Tối ưu</li></ul></td>
    <td><td>
  </tr>
    <tr>
    <td>5</td>
    <td>Xóa trận đấu bị hủy</td>
    <td>Không</td>
    <td><ul><li>- [x] Hoàn thành</li><li>- [ ] Tối ưu</li></ul></td>
    <td><td>
  </tr>
  <tr>
    <td>6</td>
    <td>Cập nhật thông tin chuyển nhượng cầu thủ</td>
    <td>Không</td>
    <td><ul><li>- [x] Hoàn thành</li><li>- [ ] Tối ưu</li></ul></td>
    <td><td>
  </tr>
  <tr>
    <td>7<br></td>
    <td>Thống kê tỷ lệ<br> thắng, hòa, thua<br>của clb<br></td>
    <td>Tạo chỉ mục (index)<br>cho trường club <br>trong bảng home <br>và away<br><br></td>
    <td><ul><li>- [x] Hoàn thành</li><li>- [ ] Tối ưu</li></ul></td>
    <td></td>
    <td rowspan="11"><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>Thống kê <br>và <br>phân tích <br>dữ liệu<br></td>
  </tr>
  <tr>
    <td>8<br></td>
    <td>Thống kê tổng số<br>bàn thắng, kiến tạo <br>của cầu thủ sau<br>từng vòng đấu<br></td>
    <td>Sử dụng thuật toán <br>cộng dồn thay thế<br>cho hàm SUM()<br></td>
    <td><ul><li>- [x] Hoàn thành</li><li>- [ ] Tối ưu</li></ul></td>
    <td></td>
  </tr>
  <tr>
    <td>9<br></td>
    <td>Tím điểm vote từ <br>NHM cho mỗi cầu thủ<br></td>
    <td>Không</td>
    <td><ul><li>- [x] Hoàn thành</li><li>- [ ] Tối ưu</li></ul></td>
    <td>Sắp xếp theo thứ <br>tự giảm dần<br></td>
  </tr>
  <tr>
    <td>10<br><br></td>
    <td>Tìm cầu thủ xuất sắc<br>nhất trong trận đấu<br></td>
    <td>Không</td>
    <td><ul><li>- [x] Hoàn thành</li><li>- [ ] Tối ưu</li></ul></td>
    <td>Tiêu chí đánh giá:<br>Cầu thủ có tổng sô<br>bàn thắng+kiến tạo<br>nhiều nhất &gt; nhận<br>ít thẻ phạt nhất &gt;<br>có điểm vote lớn nhất<br></td>
  </tr>
  <tr>
    <td>11<br></td>
    <td>Trả về nhà vô địch của<br>giải đấu<br><br></td>
    <td>Truy xuất dữ liệu từ<br>materialized view<br>table_stats thay vì<br>viết một query mới<br></td>
    <td><ul><li>- [x] Hoàn thành</li><li>- [ ] Tối ưu</li></ul></td>
    <td>Cập nhật vào trường<br>state trong bảng <br>participation<br></td>
  </tr>
  <tr>
    <td>12<br></td>
    <td>Trả về danh sách các clb<br>tham dự giải đấu<br>UEFA Champion League<br>mùa sau<br></td>
    <td>Truy xuất dữ liệu từ<br>materialized view<br>table_stats thay vì<br>viết một query mới</td>
    <td><ul><li>- [x] Hoàn thành</li><li>- [ ] Tối ưu</li></ul></td>
    <td>Danh sách CLB nằm trong<br>top 4 của bảng xếp hạng<br>Cập nhật vào trường<br>state trong bảng <br>participation</td>
  </tr>
  <tr>
    <td>13</td>
    <td>Trả về danh sách các clb<br>tham dự giải đấu<br>UEFA EUROPA League<br>mùa sau</td>
    <td>Truy xuất dữ liệu từ<br>materialized view<br>table_stats thay vì<br>viết một query mới</td>
    <td><ul><li>- [x] Hoàn thành</li><li>- [ ] Tối ưu</li></ul></td>
    <td>Danh sách CLB đứng<br>vị trí thứ 5 và 6 trong<br>BXH và đội<br>vô địch giải đấu cup<br>quốc gia<br>Cập nhật vào trường<br>state trong bảng <br>participation<br></td>
  </tr>
  <tr>
    <td>14</td>
    <td>Trả về danh sách các clb<br>xuống hạng.<br></td>
    <td>Truy xuất dữ liệu từ<br>materialized view<br>table_stats thay vì<br>viết một query mới</td>
    <td><ul><li>- [x] Hoàn thành</li><li>- [ ] Tối ưu</li></ul></td>
    <td>Danh sách clb nằm trong<br>top 3 từ dưới lên trong <br>BXH<br><br>Cập nhật vào trường<br>state trong bảng <br>participattion</td>
  </tr>
  <tr>
    <td>15</td>
    <td>Trả về cầu thủ xuất sắc <br>nhất giải đấu trong<br>mùa giải<br></td>
    <td></td>
    <td><ul><li>- [x] Hoàn thành</li><li>- [ ] Tối ưu</li></ul></td>
    <td>Cầu thủ có nhiều lần nhận<br>danh hiệu MOTM nhất<br>trong một mùa giải<br></td>
  </tr>
  <tr>
    <td>16</td>
    <td>Trả về vua phá luới của<br>giải đấu trong mùa giải<br></td>
    <td></td>
    <td><ul><li>- [x] Hoàn thành</li><li>- [ ] Tối ưu</li></ul></td>
    <td>Cầu thủ có tổng số bàn <br>thắng lớn nhất trong một<br>mùa giải<br></td>
  </tr>
  <tr>
    <td>17</td>
    <td>Kiểm tra xem cầu&nbsp;&nbsp;thủ<br>có được thi đấu trong <br>trận đấu tiếp theo không<br></td>
    <td></td>
    <td><ul><li>- [x] Hoàn thành</li><li>- [ ] Tối ưu</li></ul></td>
    <td>Cầu thủ không được thi đấu <br>nếu nhận đủ 5 thẻ vàng<br>hoặc nhận thẻ đỏ trong<br>trận đấu trước đó<br></td>
  </tr>

</tbody>
</table>