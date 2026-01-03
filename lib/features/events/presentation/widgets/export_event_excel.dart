import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/event_models.dart';

class ExportEventExcel {
  static Future<void> execute(ClassEvent event) async {
    try {
      var excel = Excel.createExcel();
      String sheetName = "Báo cáo sự kiện";
      excel.rename('Sheet1', sheetName);
      Sheet sheetObject = excel[sheetName];

      // 1. Định dạng Style
      CellStyle headerStyle = CellStyle(
        backgroundColorHex: ExcelColor.fromHexString('#155DFC'),
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
        bold: true,
        horizontalAlign: HorizontalAlign.Center,
      );

      CellStyle groupStyle = CellStyle(
        backgroundColorHex: ExcelColor.fromHexString('#F3F4F6'),
        bold: true,
      );

      // 2. Thông tin chung sự kiện
      sheetObject.appendRow([
        TextCellValue('SỰ KIỆN:'),
        TextCellValue(event.title.toUpperCase()),
      ]);
      sheetObject.appendRow([
        TextCellValue('THỜI GIAN:'),
        TextCellValue(event.dateDisplay),
      ]);
      sheetObject.appendRow([
        TextCellValue('ĐỊA ĐIỂM:'),
        TextCellValue(event.location),
      ]);

      // [YÊU CẦU] Thêm dòng TỔNG SINH VIÊN
      sheetObject.appendRow([
        TextCellValue('TỔNG SINH VIÊN:'),
        IntCellValue(event.totalCount),
      ]);

      sheetObject.appendRow([TextCellValue('')]); // Dòng trống

      // 3. Tiêu đề bảng (Header dữ liệu)
      sheetObject.appendRow([
        TextCellValue('STT'),
        TextCellValue('Mã Sinh Viên'),
        TextCellValue('Họ và Tên'),
        TextCellValue('Tổ/Đội'),
        TextCellValue('Trạng thái chi tiết'),
      ]);

      // Apply style cho header (Dòng này nằm ở index 5 do có thêm dòng Tổng sinh viên)
      int headerRowIndex = sheetObject.maxRows - 1;
      for (var i = 0; i < 5; i++) {
        sheetObject
                .cell(
                  CellIndex.indexByColumnRow(
                    columnIndex: i,
                    rowIndex: headerRowIndex,
                  ),
                )
                .cellStyle =
            headerStyle;
      }

      // 4. Đổ dữ liệu theo nhóm - [YÊU CẦU] Reset STT về 1 cho mỗi nhóm

      // Nhóm 1: Đã đăng ký
      _addRowGroup(
        sheetObject,
        "DANH SÁCH ĐÃ ĐĂNG KÝ (${event.participants.length})",
        event.participants,
        "Tham gia",
        groupStyle,
      );

      // Nhóm 2: Chưa đăng ký (Báo vắng)
      _addRowGroup(
        sheetObject,
        "DANH SÁCH CHƯA ĐĂNG KÝ (${event.nonParticipants.length})",
        event.nonParticipants,
        "Không tham gia",
        groupStyle,
      );

      // Nhóm 3: Chưa phản hồi
      _addRowGroup(
        sheetObject,
        "DANH SÁCH CHƯA PHẢN HỒI (${event.unconfirmed.length})",
        event.unconfirmed,
        "Chưa xác nhận",
        groupStyle,
      );

      // 5. Lưu file và thực hiện chia sẻ
      var fileBytes = excel.save();
      if (fileBytes != null) {
        final directory = await getTemporaryDirectory();
        final String fileName =
            'Bao_cao_${event.title.replaceAll(' ', '_')}.xlsx';
        final File file = File('${directory.path}/$fileName')
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes);

        await Share.shareXFiles([
          XFile(file.path),
        ], text: 'Báo cáo sự kiện: ${event.title}');
      }
    } catch (e) {
      throw Exception("Lỗi xuất Excel: $e");
    }
  }

  static void _addRowGroup(
    Sheet sheet,
    String title,
    List<Student> students,
    String label,
    CellStyle style,
  ) {
    // Dòng tiêu đề nhóm (Đã kèm số lượng từ tham số truyền vào)
    sheet.appendRow([TextCellValue(title)]);
    sheet
            .cell(
              CellIndex.indexByColumnRow(
                columnIndex: 0,
                rowIndex: sheet.maxRows - 1,
              ),
            )
            .cellStyle =
        style;

    if (students.isEmpty) {
      sheet.appendRow([
        TextCellValue('-'),
        TextCellValue('-'),
        TextCellValue('Trống'),
        TextCellValue('-'),
        TextCellValue('-'),
      ]);
    } else {
      // [YÊU CẦU] STT luôn bắt đầu từ 1 cho mỗi khi hàm này được gọi
      for (var i = 0; i < students.length; i++) {
        sheet.appendRow([
          IntCellValue(i + 1), // Reset STT về 1, 2, 3...
          TextCellValue(students[i].studentCode),
          TextCellValue(students[i].name),
          TextCellValue(students[i].teamName),
          TextCellValue(label),
        ]);
      }
    }
    sheet.appendRow([TextCellValue('')]); // Dòng trống ngăn cách các nhóm
  }
}
