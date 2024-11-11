import 'package:carbon_icons/carbon_icons.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:sleeptales/utils/get.dart';

import '/domain/services/storage_service.dart';
import '/utils/app_theme.dart';

class FileInfo {
  final String path;
  final FileType type;
  final Uint8List? bytes;

  FileInfo({required this.path, required this.type, this.bytes});
}

class FileDropzoneFormField extends FormField<String> {
  FileDropzoneFormField({
    super.key,
    String? title,
    double height = 100,
    double width = double.infinity,
    required void Function(String path) onSelected,
    required FileType type,
    super.autovalidateMode,
    super.validator,
    super.initialValue,
    super.onSaved,
    Widget Function(
            BuildContext context, String? imageUrl, Future<void> Function() action)?
        fieldBuilder,
  }) : super(
          builder: (FormFieldState<String> field) {
            final state = field as _FileDropzoneFormFieldState;

            if (fieldBuilder != null) {
              return fieldBuilder(
                field.context,
                state.value,
                () => _showFilePicker(type, (path) {
                  field.didChange(path);
                  onSelected(path);
                }),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FileDropzoneSelector(
                  title: title,
                  height: height,
                  width: width,
                  type: type,
                  onSelected: (path) {
                    field.didChange(path);
                    onSelected(path);
                  },
                  selectedPath: state.value,
                ),
                if (field.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 12),
                    child: Text(
                      field.errorText!,
                      style: TextStyle(
                        color: Theme.of(field.context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            );
          },
        );

  @override
  FormFieldState<String> createState() => _FileDropzoneFormFieldState();

  static Future<void> _showFilePicker(
    FileType type,
    void Function(String path) onSelected,
  ) async {
    final result = await FilePicker.platform.pickFiles(type: type);
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      final fileInfo = FileInfo(
        path: file.name,
        type: type,
        bytes: await file.xFile.readAsBytes(),
      );

      final downloadUrl = await Get.the<StorageService>().uploadThumbnail(
        fileInfo,
      );

      onSelected(downloadUrl);
    }
  }
}

class _FileDropzoneFormFieldState extends FormFieldState<String> {}

class FileDropzoneSelector extends StatefulWidget {
  const FileDropzoneSelector({
    super.key,
    this.title,
    this.height = 100,
    this.width = double.infinity,
    required this.onSelected,
    required this.type,
    this.selectedPath,
  });

  final String? title;
  final double height;
  final double width;
  final void Function(String) onSelected;
  final FileType type;
  final String? selectedPath;

  @override
  State<FileDropzoneSelector> createState() => _FileDropzoneSelectorState();
}

class _FileDropzoneSelectorState extends State<FileDropzoneSelector> {
  final _storageService = Get.the<StorageService>();

  bool _uploading = false;
  double _uploadProgress = 0;

  bool get _hasSelection => widget.selectedPath != null;

  Future<String?> _handleFileSelection(FileInfo file) async {
    if (widget.type == FileType.image) {
      final compressed = await FlutterImageCompress.compressWithList(
        file.bytes!,
        quality: 80,
        format: CompressFormat.jpeg,
      );

      file = FileInfo(path: file.path, type: file.type, bytes: compressed);
    }

    setState(() {
      _uploading = true;
      _uploadProgress = 0;
    });

    try {
      final downloadUrl = switch (widget.type) {
        FileType.image => await _storageService.uploadThumbnail(
            file,
            onProgress: (progress) => setState(() => _uploadProgress = progress),
          ),
        _ => throw Exception('Unsupported file type'),
      };
      widget.onSelected(downloadUrl);
      return downloadUrl;
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(1),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showFilePicker(),
          borderRadius: AppTheme.largeBorderRadius,
          overlayColor: WidgetStatePropertyAll(colors.primary.withAlpha(20)),
          child: Ink(
            height: widget.height,
            width: widget.width,
            color: colors.surfaceContainerLow,
            child: Center(
              child: _buildPreview(colors),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreview(ColorScheme colors) {
    if (_uploading) return _buildUploadingIndicator(colors);
    if (_hasSelection) return _buildSelectedPreview();
    return _buildDefaultPreview();
  }

  Widget _buildUploadingIndicator(ColorScheme colors) => SizedBox(
        height: widget.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const CupertinoActivityIndicator(),
            const SizedBox(height: 8),
            SizedBox(
              width: 100,
              child: LinearProgressIndicator(
                value: _uploadProgress.isFinite ? _uploadProgress : 0,
                valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _uploadProgress.isFinite
                  ? '${(_uploadProgress * 100).toStringAsFixed(0)}%'
                  : '0%',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );

  Widget _buildSelectedPreview() {
    if (widget.type == FileType.image) {
      return ClipRRect(
        borderRadius: AppTheme.smallBorderRadius,
        child: Image.network(widget.selectedPath!),
      );
    }
    throw Exception('Unsupported file type');
  }

  Widget _buildDefaultPreview() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(width: 16),
        Icon(CarbonIcons.upload),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            widget.selectedPath ?? 'Drop ${widget.title ?? 'file'} here',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  void _showFilePicker() async {
    final result = await FilePicker.platform.pickFiles(type: widget.type);
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      await _handleFileSelection(FileInfo(
        path: file.name,
        type: widget.type,
        bytes: await file.xFile.readAsBytes(),
      ));
    }
  }
}
