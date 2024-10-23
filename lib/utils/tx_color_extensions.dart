import 'package:flutter/material.dart';

class TxColorExtensions extends ThemeExtension<TxColorExtensions> {
  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color info;
  final Color onInfo;
  final Color mono;
  final Color onMono;

  TxColorExtensions._({
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.info,
    required this.onInfo,
    required this.mono,
    required this.onMono,
  });

  TxColorExtensions.light()
      : success = const Color(0xFF198754),
        onSuccess = Colors.white,
        warning = const Color(0xFFFFC107),
        onWarning = Colors.black,
        info = const Color(0xFF0DCAF0),
        onInfo = Colors.black,
        mono = const Color(0xFF212529),
        onMono = Colors.white;

  TxColorExtensions.dark()
      : success = const Color(0xFF198754),
        onSuccess = Colors.white,
        warning = const Color(0xFFFFC107),
        onWarning = Colors.black,
        info = const Color(0xFF0DCAF0),
        onInfo = Colors.black,
        mono = const Color(0xFFF8F9FA),
        onMono = Colors.black;

  @override
  ThemeExtension<TxColorExtensions> copyWith({
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? info,
    Color? onInfo,
    Color? mono,
    Color? onMono,
  }) =>
      TxColorExtensions._(
        success: success ?? this.success,
        onSuccess: onSuccess ?? this.onSuccess,
        warning: warning ?? this.warning,
        onWarning: onWarning ?? this.onWarning,
        info: info ?? this.info,
        onInfo: onInfo ?? this.onInfo,
        mono: mono ?? this.mono,
        onMono: onMono ?? this.onMono,
      );

  @override
  TxColorExtensions lerp(TxColorExtensions? other, double t) {
    if (other == null) return this;
    return TxColorExtensions._(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      mono: Color.lerp(mono, other.mono, t)!,
      onMono: Color.lerp(onMono, other.onMono, t)!,
    );
  }
}

extension ThemeDataExtension on ThemeData {
  TxColorExtensions get tx => extension<TxColorExtensions>()!;
}
