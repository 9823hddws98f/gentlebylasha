import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sleeptales/utils/common_extensions.dart';
import 'package:uuid/uuid.dart';

import '/widgets/input/file_dropzone_selector.dart';

class StorageService {
  StorageService._();

  static final StorageService instance = StorageService._();

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  static const _thumbnailsPath = 'track/thumbnails';

  Future<String> uploadThumbnail(
    FileInfo file, {
    void Function(double)? onProgress,
  }) =>
      _uploadFile(_thumbnailsPath, file, onProgress: onProgress);

  String _generateUniqueFileName(String originalPath) {
    final uuid = _uuid.v4();
    final extension = originalPath.split('.').last;
    return '$uuid.$extension';
  }

  Future<String> _uploadFile(
    String uploadPath,
    FileInfo file, {
    void Function(double)? onProgress,
  }) async {
    try {
      if (file.bytes == null) {
        throw Exception('File bytes are null');
      }

      final uniqueFileName = _generateUniqueFileName(file.path);
      final ref = _storage.ref().child(uploadPath).child(uniqueFileName);

      final uploadTask = ref.putData(
        file.bytes!,
        SettableMetadata(
          contentType: switch (file.type) {
            FileType.audio => 'audio/mpeg',
            FileType.image => 'image/jpeg',
            _ => 'application/octet-stream',
          },
        ),
      );

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress?.call(progress);
      });

      await uploadTask;
      return await ref.getDownloadURL();
    } catch (e) {
      ('Upload error: $e').logDebug();
      throw Exception('File upload failed: $e');
    }
  }
}
