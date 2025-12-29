import '../models/asset_model.dart';
import '../models/asset_history_model.dart';

class AssetRepository {
  Map<String, int> getSummary() {
    return {'total': 4, 'available': 2, 'borrowed': 2};
  }

  List<AssetModel> getAssets() {
    return [
      AssetModel(
        name: 'Remote Điều hòa',
        assetCode: '#001',
        category: 'Điện tử',
        status: 'borrowed',
        user: 'Nguyễn Văn A',
        time: '09:00, 06/12/2024',
      ),
      AssetModel(
        name: 'Chìa khóa tủ Bảng',
        assetCode: '#002',
        category: 'Văn phòng phẩm',
        status: 'available',
        user: 'Nguyễn Văn A',
        time: '09:00, 06/12/2024',
      ),
      AssetModel(
        name: 'Chìa khóa tủ',
        assetCode: '#003',
        category: 'Văn phòng phẩm',
        status: 'available',
        user: 'Nguyễn Văn D',
        time: '09:00, 06/12/2024',
      ),
    ];
  }

  List<AssetHistoryModel> getHistory() {
    return [
      AssetHistoryModel(
        text: 'Nguyễn Văn A mượn Remote Điều hòa',
        time: '09:00, 06/12/2024',
        type: 'borrow',
      ),
      AssetHistoryModel(
        text: 'Lê Văn C trả Remote Máy chiếu',
        time: '16:00, 04/12/2024',
        type: 'return',
      ),
    ];
  }
}
