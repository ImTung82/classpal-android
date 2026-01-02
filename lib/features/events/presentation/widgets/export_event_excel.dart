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

      // Style cho Header bảng
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

      // 1. Thông tin chung
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
      sheetObject.appendRow([TextCellValue('')]);

      // 2. Header bảng dữ liệu
      sheetObject.appendRow([
        TextCellValue('STT'),
        TextCellValue('Họ và Tên'),
        TextCellValue('Trạng thái chi tiết'),
      ]);

      for (var i = 0; i < 3; i++) {
        sheetObject
                .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 4))
                .cellStyle =
            headerStyle;
      }

      int stt = 1;
      _addRowGroup(
        sheetObject,
        "DANH SÁCH THAM GIA",
        event.participants,
        "Đã đăng ký",
        groupStyle,
        stt,
      );
      stt += event.participants.length;
      _addRowGroup(
        sheetObject,
        "DANH SÁCH BÁO VẮNG",
        event.nonParticipants,
        "Không tham gia",
        groupStyle,
        stt,
      );
      stt += event.nonParticipants.length;
      _addRowGroup(
        sheetObject,
        "DANH SÁCH CHƯA PHẢN HỒI",
        event.unconfirmed,
        "Chưa xác nhận",
        groupStyle,
        stt,
      );

      // 3. Lưu và Chia sẻ
      var fileBytes = excel.save();
      if (fileBytes != null) {
        final directory = await getTemporaryDirectory();
        final String fileName =
            'Export_${event.title.replaceAll(' ', '_')}.xlsx';
        final File file = File('${directory.path}/$fileName')
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes);

        await Share.shareXFiles([
          XFile(file.path),
        ], text: 'Dữ liệu sự kiện: ${event.title}');
      }
    } catch (e) {
      throw Exception("Lỗi xuất Excel: $e");
    }
  }

  static void _addRowGroup(
    Sheet sheet,
    String title,
    List students,
    String label,
    CellStyle style,
    int startStt,
  ) {
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
        TextCellValue('Trống'),
        TextCellValue('-'),
      ]);
    } else {
      for (var i = 0; i < students.length; i++) {
        sheet.appendRow([
          IntCellValue(startStt + i),
          TextCellValue(students[i].name),
          TextCellValue(label),
        ]);
      }
    }
    sheet.appendRow([TextCellValue('')]);
  }
}
