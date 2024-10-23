import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'command_trigger.dart';
import 'enums.dart';
import 'tx_color_extensions.dart';

enum TxButtonType {
  filled,
  text,
  outlined,
  elevated;

  bool get isFilled => this == TxButtonType.filled;
  bool get isText => this == TxButtonType.text;
  bool get isOutlined => this == TxButtonType.outlined;
  bool get isElevated => this == TxButtonType.elevated;
}

enum TxButtonStage {
  idle,
  loading,
  success,
  error;

  bool get isIdle => this == TxButtonStage.idle;
  bool get isLoading => this == TxButtonStage.loading;
  bool get isSuccess => this == TxButtonStage.success;
  bool get isError => this == TxButtonStage.error;
}

class TxButton extends StatefulWidget {
  final TxButtonType type;
  final Widget? label;
  final RoleColor color;
  final bool showSuccess;
  final IconData? icon;
  final double? iconSize;
  final ActionTrigger? trigger;
  final FutureOr<bool> Function()? onPress;
  final FutureOr<void> Function()? onPressVoid;
  final void Function()? onSuccess;

  const TxButton({
    required this.type,
    this.label,
    this.color = RoleColor.primary,
    this.showSuccess = true,
    this.icon,
    this.iconSize,
    this.trigger,
    this.onPress,
    this.onPressVoid,
    this.onSuccess,
    super.key,
  }) : assert(onPress == null || onPressVoid == null);

  const TxButton.filled({
    this.label,
    this.color = RoleColor.primary,
    this.showSuccess = true,
    this.icon,
    this.iconSize,
    this.trigger,
    this.onPress,
    this.onPressVoid,
    this.onSuccess,
    super.key,
  })  : type = TxButtonType.filled,
        assert(onPress == null || onPressVoid == null);

  const TxButton.text({
    this.label,
    this.color = RoleColor.primary,
    this.showSuccess = true,
    this.icon,
    this.iconSize,
    this.trigger,
    this.onPress,
    this.onPressVoid,
    this.onSuccess,
    super.key,
  })  : type = TxButtonType.text,
        assert(onPress == null || onPressVoid == null);

  const TxButton.outlined({
    this.label,
    this.color = RoleColor.primary,
    this.showSuccess = true,
    this.icon,
    this.iconSize,
    this.trigger,
    this.onPress,
    this.onPressVoid,
    this.onSuccess,
    super.key,
  })  : type = TxButtonType.outlined,
        assert(onPress == null || onPressVoid == null);

  const TxButton.elevated({
    this.label,
    this.color = RoleColor.primary,
    this.showSuccess = true,
    this.icon,
    this.iconSize,
    this.trigger,
    this.onPress,
    this.onPressVoid,
    this.onSuccess,
    super.key,
  })  : type = TxButtonType.elevated,
        assert(onPress == null || onPressVoid == null);

  @override
  State<TxButton> createState() => _TxButtonState();
}

class _TxButtonState extends State<TxButton> {
  TxButtonStage _stage = TxButtonStage.idle;

  @override
  void initState() {
    super.initState();
    widget.trigger?.setAction(_handlePress);
  }

  @override
  Widget build(BuildContext context) => switch (widget.type) {
        TxButtonType.filled => _buildFilledButton(),
        TxButtonType.text => _buildTextButton(),
        TxButtonType.outlined => _buildOutlinedButton(),
        TxButtonType.elevated => _buildElevatedButton(),
      };

  FilledButton _buildFilledButton() {
    final (icon, style) = _getIconAndStyle();
    return icon != null && widget.label != null
        ? FilledButton.icon(
            onPressed: _handlePress,
            style: style,
            icon: icon,
            label: widget.label!,
          )
        : FilledButton(
            onPressed: _handlePress,
            style: style,
            child: icon ?? widget.label!,
          );
  }

  TextButton _buildTextButton() {
    final (icon, style) = _getIconAndStyle();
    return icon != null && widget.label != null
        ? TextButton.icon(
            onPressed: _handlePress,
            style: style,
            icon: icon,
            label: widget.label!,
          )
        : TextButton(
            onPressed: _handlePress,
            style: style,
            child: icon ?? widget.label!,
          );
  }

  OutlinedButton _buildOutlinedButton() {
    final (icon, style) = _getIconAndStyle();
    return icon != null && widget.label != null
        ? OutlinedButton.icon(
            onPressed: _handlePress,
            style: style,
            icon: icon,
            label: widget.label!,
          )
        : OutlinedButton(
            onPressed: _handlePress,
            style: style,
            child: icon ?? widget.label!,
          );
  }

  ElevatedButton _buildElevatedButton() {
    final (icon, style) = _getIconAndStyle();
    return icon != null && widget.label != null
        ? ElevatedButton.icon(
            onPressed: _handlePress,
            style: style,
            icon: icon,
            label: widget.label!,
          )
        : ElevatedButton(
            onPressed: _handlePress,
            style: style,
            child: icon ?? widget.label!,
          );
  }

  (Widget?, ButtonStyle) _getIconAndStyle() {
    final theme = Theme.of(context);
    final roleColor = _getRoleColor(theme);
    final fgColor = _getForegroundColor(theme);
    final iconColor =
        widget.type.isFilled || widget.type.isElevated ? fgColor : roleColor;

    final style = switch (widget.type) {
      TxButtonType.filled => FilledButton.styleFrom(
          backgroundColor: roleColor,
          foregroundColor: fgColor,
        ),
      TxButtonType.elevated => ElevatedButton.styleFrom(
          backgroundColor: roleColor,
          foregroundColor: fgColor,
        ),
      TxButtonType.text => TextButton.styleFrom(foregroundColor: roleColor),
      TxButtonType.outlined => OutlinedButton.styleFrom(
          foregroundColor: roleColor,
          side: BorderSide(color: roleColor),
        ),
    };

    final size = widget.iconSize;

    final icon = switch (_stage) {
      TxButtonStage.loading =>
        CupertinoActivityIndicator(color: iconColor, radius: (size ?? 24) / 2),
      TxButtonStage.success => Icon(Icons.check, color: iconColor, size: size),
      TxButtonStage.error => Icon(Icons.close, color: iconColor, size: size),
      _ => widget.icon != null ? Icon(widget.icon, color: iconColor, size: size) : null,
    };

    return (icon, style);
  }

  Color _getRoleColor(ThemeData theme) {
    final colors = theme.colorScheme;
    if (_stage.isSuccess) return theme.tx.success;
    if (_stage.isError) return colors.error;
    return switch (widget.color) {
      RoleColor.primary => colors.primary,
      RoleColor.secondary => widget.type.isFilled || widget.type.isElevated
          ? colors.secondary
          : theme.hintColor,
      RoleColor.tertiary => colors.tertiary,
      RoleColor.danger => colors.error,
      RoleColor.success => theme.tx.success,
      RoleColor.warning => theme.tx.warning,
      RoleColor.info => theme.tx.info,
      RoleColor.mono => theme.tx.mono,
    };
  }

  Color _getForegroundColor(ThemeData theme) {
    final colors = theme.colorScheme;
    if (_stage.isSuccess) return theme.tx.onSuccess;
    if (_stage.isError) return colors.onError;
    return switch (widget.color) {
      RoleColor.primary => colors.onPrimary,
      RoleColor.secondary => colors.onSecondary,
      RoleColor.tertiary => colors.onTertiary,
      RoleColor.danger => colors.onError,
      RoleColor.success => theme.tx.onSuccess,
      RoleColor.warning => theme.tx.onWarning,
      RoleColor.info => theme.tx.onInfo,
      RoleColor.mono => theme.tx.onMono,
    };
  }

  void _handlePress() async {
    if (!_stage.isIdle || widget.onPress == null && widget.onPressVoid == null) return;
    _setStage(TxButtonStage.loading);

    try {
      if (widget.onPressVoid != null) {
        await widget.onPressVoid!();
        _setResult(true);
      } else {
        _setResult(await widget.onPress!());
      }
    } catch (_) {
      _setResult(false);
      rethrow;
    }
  }

  void _setResult(bool success) {
    if (success && !widget.showSuccess) {
      _setStage(TxButtonStage.idle);
      widget.onSuccess?.call();
      return;
    }
    _setStage(success ? TxButtonStage.success : TxButtonStage.error);
    Future.delayed(Durations.extralong4).then((_) {
      _setStage(TxButtonStage.idle);
      if (success) widget.onSuccess?.call();
    });
  }

  void _setStage(TxButtonStage stage) {
    if (mounted) setState(() => _stage = stage);
  }
}
