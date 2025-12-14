import 'package:intl/intl.dart';

class CurrencyUtils {
  /// Hàm format tiền tệ Việt Nam
  /// Ví dụ: 100000 -> "100.000 đ"
  static String format(int amount) {
    // Locale 'vi_VN' sẽ tự động dùng dấu chấm (.) để phân cách hàng nghìn
    final formatter = NumberFormat.currency(
      locale: 'vi_VN', 
      symbol: 'đ', 
      decimalDigits: 0 // Không hiển thị số thập phân
    );
    return formatter.format(amount);
  }
}