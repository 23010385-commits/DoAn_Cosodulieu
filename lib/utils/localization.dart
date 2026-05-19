enum NgonNgu { viet, anh }

class Strings {
  static String get(StringsEnum key, NgonNgu nn) {
    switch (key) {
      case StringsEnum.appTitle:
        return nn == NgonNgu.viet ? '📚 Thư viện sách' : '📚 Book library App';
      case StringsEnum.tuSach:
        return nn == NgonNgu.viet ? 'Tủ sách cá nhân' : 'My Library';
      case StringsEnum.caiDat:
        return nn == NgonNgu.viet ? 'Cài đặt' : 'Settings';
      case StringsEnum.thongTin:
        return nn == NgonNgu.viet ? 'Thông tin cá nhân' : 'Profile';
      case StringsEnum.quayLai:
        return nn == NgonNgu.viet ? 'Quay lại' : 'Back';
      case StringsEnum.veManHinhChinh:
        return nn == NgonNgu.viet ? 'Về màn hình chính' : 'Home';
      case StringsEnum.gioiThieuCaiDat:
        return nn == NgonNgu.viet ? 'Tùy chỉnh ngôn ngữ' : 'Customize language';
      case StringsEnum.trangChu:
        return nn == NgonNgu.viet ? 'Trang chủ' : 'Home';
      case StringsEnum.chuDe:
        return nn == NgonNgu.viet ? 'Chủ đề' : 'Categories';
      case StringsEnum.dangNhap:
        return nn == NgonNgu.viet
            ? 'Vui lòng đăng nhập để xem tủ sách'
            : 'Please login to view library';
      case StringsEnum.dangXuat:
        return nn == NgonNgu.viet ? 'Đăng xuất' : 'Logout';
    }
  }
}

enum StringsEnum {
  appTitle,
  tuSach,
  caiDat,
  thongTin,
  quayLai,
  veManHinhChinh,
  gioiThieuCaiDat,
  trangChu,
  chuDe,
  dangNhap,
  dangXuat,
}
