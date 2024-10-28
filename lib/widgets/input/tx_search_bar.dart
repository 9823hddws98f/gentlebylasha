import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

@immutable
class TxSearchBarSettings {
  const TxSearchBarSettings({
    this.filled,
    this.border,
  });

  final bool? filled;
  final InputBorder? border;
}

class TxSearchBar extends StatefulWidget {
  const TxSearchBar({
    super.key,
    TxSearchBarSettings? settings,
    required this.onSearch,
  }) : overrides = settings;

  static TxSearchBarSettings? settings;
  final TxSearchBarSettings? overrides;
  final Future<void> Function(String) onSearch;

  @override
  State<TxSearchBar> createState() => _TxSearchBarState();
}

class _TxSearchBarState extends State<TxSearchBar> {
  static const _debounceDuration = Durations.long4;
  final _controller = TextEditingController();

  bool _loading = false;
  int _operation = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final settings = widget.overrides ?? TxSearchBar.settings;
    return TextField(
      autofocus: true,
      controller: _controller,
      onChanged: _handleChange,
      style: TextStyle(color: colors.onSurface),
      decoration: InputDecoration(
        hintText: 'Search',
        hintStyle: TextStyle(color: colors.onSurfaceVariant),
        border: settings?.border,
        filled: settings?.filled,
        fillColor: colors.onSurfaceVariant.withValues(alpha: 0.1),
        suffixIcon: _loading
            ? const CupertinoActivityIndicator()
            : _controller.text.isEmpty
                ? const Icon(Icons.search)
                : IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: 'Clear search',
                    onPressed: () {
                      _timer?.cancel();
                      _controller.clear();
                      _triggerSearch('');
                    },
                  ),
      ),
    );
  }

  void _handleChange(String query) {
    _timer?.cancel();
    _timer = Timer(_debounceDuration, () => _triggerSearch(query));
  }

  Future<void> _triggerSearch(String query) async {
    final op = ++_operation;
    setState(() => _loading = true);
    try {
      await widget.onSearch(query);
    } finally {
      if (op == _operation && mounted) {
        setState(() => _loading = false);
      }
    }
  }
}
