import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/event_models.dart';

class ExportEventExcel {
  // [CẬP NHẬT] Thêm tham số className vào hàm execute
  static Future<void> execute(ClassEvent event, String className) async {
    try {
      var excel = Excel.createExcel();

      // Xóa sheet mặc định và tạo sheet mới tên ClassPal Report
      String sheetName = "ClassPal Report";
      if (excel.sheets.containsKey('Sheet1')) {
        excel.rename('Sheet1', sheetName);
      }
      // Đảm bảo sheet được tạo nếu rename thất bại
      if (excel[sheetName] == null) {
        excel.copy(sheetName, sheetName);
      }

      Sheet sheet = excel[sheetName];

      // --- 1. CẤU HÌNH STYLE ---
      ExcelColor primaryColor = ExcelColor.fromHexString('#155DFC');
      ExcelColor whiteColor = ExcelColor.fromHexString('#FFFFFF');
      ExcelColor headerBg = ExcelColor.fromHexString('#E0E7FF');

      // Style Tiêu đề lớn
      CellStyle titleStyle = CellStyle(
        fontFamily: getFontFamily(FontFamily.Arial),
        fontSize: 18,
        bold: true,
        fontColorHex: primaryColor,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );

      // Style Label (Sự kiện, Thời gian...)
      CellStyle infoLabelStyle = CellStyle(
        bold: true,
        fontColorHex: ExcelColor.fromHexString('#4B5563'), // Xám đậm
      );

      // Style Header Bảng (STT, Họ tên...)
      CellStyle tableHeaderStyle = CellStyle(
        backgroundColorHex: primaryColor,
        fontColorHex: whiteColor,
        bold: true,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );

      // Style Group Header
      CellStyle groupHeaderStyle = CellStyle(
        backgroundColorHex: headerBg,
        fontColorHex: primaryColor,
        bold: true,
        underline: Underline.Single,
      );

      // --- 2. THIẾT LẬP ĐỘ RỘNG CỘT (ĐÃ SỬA LỖI) ---
      // [FIX] Sử dụng setColumnWidth thay vì setColWidth
      // [FIX] Tăng độ rộng cột 0 lên 20 để hiển thị đủ "Thời gian:", "Địa điểm:"
      sheet.setColumnWidth(0, 20.0);
      sheet.setColumnWidth(1, 15.0); // Mã SV
      sheet.setColumnWidth(2, 30.0); // Họ và Tên
      sheet.setColumnWidth(3, 25.0); // Tổ/Đội
      sheet.setColumnWidth(4, 20.0); // Trạng thái

      // --- 3. PHẦN TIÊU ĐỀ BÁO CÁO ---
      sheet.merge(CellIndex.indexByString("A1"), CellIndex.indexByString("E1"));
      var titleCell = sheet.cell(CellIndex.indexByString("A1"));

      // [CẬP NHẬT] Đổi tên tiêu đề theo yêu cầu
      titleCell.value = TextCellValue("ClassPal - Báo cáo sự kiện");
      titleCell.cellStyle = titleStyle;

      // --- 4. THÔNG TIN SỰ KIỆN ---
      int currentRow = 2;

      // [CẬP NHẬT] Thêm dòng Tên Lớp
      _addInfoRow(
        sheet,
        currentRow++,
        "Tên lớp:",
        className.toUpperCase(),
        infoLabelStyle,
      );

      _addInfoRow(
        sheet,
        currentRow++,
        "Tên sự kiện:",
        event.title.toUpperCase(),
        infoLabelStyle,
      );
      _addInfoRow(
        sheet,
        currentRow++,
        "Thời gian:",
        "${event.timeDisplay} - ${event.dateDisplay}",
        infoLabelStyle,
      );
      _addInfoRow(
        sheet,
        currentRow++,
        "Địa điểm:",
        event.location,
        infoLabelStyle,
      );

      // Thống kê nhanh
      currentRow++;
      sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
        CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: currentRow),
      );
      var statTitle = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
      );
      statTitle.value = TextCellValue(
        "THỐNG KÊ TỔNG QUAN: ${event.totalCount} SINH VIÊN",
      );
      statTitle.cellStyle = groupHeaderStyle;
      currentRow++;

      _addInfoRow(
        sheet,
        currentRow++,
        "• Đã đăng ký:",
        "${event.registeredCount} sinh viên",
        infoLabelStyle,
      );
      _addInfoRow(
        sheet,
        currentRow++,
        "• Vắng/Hủy:",
        "${event.nonParticipants.length} sinh viên",
        infoLabelStyle,
      );
      _addInfoRow(
        sheet,
        currentRow++,
        "• Chưa phản hồi:",
        "${event.unconfirmed.length} sinh viên",
        infoLabelStyle,
      );

      currentRow++; // Dòng trống

      // --- 5. HEADER BẢNG DỮ LIỆU ---
      List<String> headers = [
        'STT',
        'Mã Sinh Viên',
        'Họ và Tên',
        'Tổ/Đội',
        'Trạng thái',
      ];
      for (var i = 0; i < headers.length; i++) {
        var cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: currentRow),
        );
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = tableHeaderStyle;
      }
      currentRow++;

      // --- 6. ĐỔ DỮ LIỆU ---
      if (event.participants.isNotEmpty) {
        currentRow = _addSectionHeader(
          sheet,
          currentRow,
          "I. DANH SÁCH THAM GIA (${event.participants.length})",
          groupHeaderStyle,
        );
        currentRow = _addStudentList(
          sheet,
          currentRow,
          event.participants,
          "Đã đăng ký",
          true,
        );
      }

      if (event.nonParticipants.isNotEmpty) {
        currentRow = _addSectionHeader(
          sheet,
          currentRow,
          "II. DANH SÁCH VẮNG / HỦY (${event.nonParticipants.length})",
          groupHeaderStyle,
        );
        currentRow = _addStudentList(
          sheet,
          currentRow,
          event.nonParticipants,
          "Vắng mặt",
          false,
        );
      }

      if (event.unconfirmed.isNotEmpty) {
        currentRow = _addSectionHeader(
          sheet,
          currentRow,
          "III. CHƯA PHẢN HỒI (${event.unconfirmed.length})",
          groupHeaderStyle,
        );
        currentRow = _addStudentList(
          sheet,
          currentRow,
          event.unconfirmed,
          "Chờ xác nhận",
          false,
        );
      }

      // --- 7. LƯU & SHARE ---
      var fileBytes = excel.save();
      if (fileBytes != null) {
        final directory = await getTemporaryDirectory();
        final String safeTitle = event.title
            .replaceAll(RegExp(r'[^\w\s]+'), '')
            .replaceAll(' ', '_');
        final String fileName = 'ClassPal_$safeTitle.xlsx';

        final File file = File('${directory.path}/$fileName')
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes);

        await Share.shareXFiles([
          XFile(file.path),
        ], text: 'Báo cáo ClassPal: ${event.title}');
      }
    } catch (e) {
      throw Exception("Lỗi xuất Excel: $e");
    }
  }

  static void _addInfoRow(
    Sheet sheet,
    int rowIndex,
    String label,
    String value,
    CellStyle labelStyle,
  ) {
    var labelCell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
    );
    labelCell.value = TextCellValue(label);
    labelCell.cellStyle = labelStyle;

    var valueCell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex),
    );
    valueCell.value = TextCellValue(value);

    // Merge cột giá trị để hiển thị dài hơn
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex),
      CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex),
    );
  }

  static int _addSectionHeader(
    Sheet sheet,
    int rowIndex,
    String title,
    CellStyle style,
  ) {
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
      CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex),
    );
    var cell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
    );
    cell.value = TextCellValue(title);
    cell.cellStyle = style;
    return rowIndex + 1;
  }

  static int _addStudentList(
    Sheet sheet,
    int startRow,
    List<Student> students,
    String statusLabel,
    bool isPositive,
  ) {
    CellStyle centerStyle = CellStyle(horizontalAlign: HorizontalAlign.Center);
    CellStyle leftStyle = CellStyle(horizontalAlign: HorizontalAlign.Left);

    CellStyle statusStyle = CellStyle(
      horizontalAlign: HorizontalAlign.Center,
      fontColorHex: isPositive
          ? ExcelColor.fromHexString('#16A34A')
          : ExcelColor.fromHexString('#DC2626'),
      bold: true,
    );

    for (var i = 0; i < students.length; i++) {
      var s = students[i];
      int r = startRow + i;

      var c0 = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: r),
      );
      c0.value = IntCellValue(i + 1);
      c0.cellStyle = centerStyle;

      var c1 = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: r),
      );
      c1.value = TextCellValue(s.studentCode);
      c1.cellStyle = centerStyle;

      var c2 = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: r),
      );
      c2.value = TextCellValue(s.name);
      c2.cellStyle = leftStyle;

      var c3 = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: r),
      );
      c3.value = TextCellValue(s.teamName);
      c3.cellStyle = centerStyle;

      var c4 = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: r),
      );
      c4.value = TextCellValue(statusLabel);
      c4.cellStyle = statusStyle;
    }
    return startRow + students.length;
  }
}
