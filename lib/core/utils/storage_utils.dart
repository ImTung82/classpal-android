import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageUtils {
  static Future<String> uploadEvidence(XFile file) async {
    final supabase = Supabase.instance.client;

    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User chưa đăng nhập');
    }

    final Uint8List bytes = await file.readAsBytes();
    final String ext = p.extension(file.name);

    final String fileName =
        'evidence_${DateTime.now().millisecondsSinceEpoch}$ext';

    // 🔥 BẮT BUỘC: folder = auth.uid()
    final String path = '${user.id}/expenses/$fileName';

    await supabase.storage
        .from('fund-evidences') // đúng bucket
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            contentType: file.mimeType ?? 'image/jpeg',
            upsert: false,
          ),
        );

    return supabase.storage
        .from('fund-evidences')
        .getPublicUrl(path);
  }
}
