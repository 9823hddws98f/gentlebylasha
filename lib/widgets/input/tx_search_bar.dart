import 'dart:async';

import 'package:carbon_icons/carbon_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TxSearchBar extends StatefulWidget {
  const TxSearchBar({
    super.key,
    required this.onSearch,
  });

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
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: colors.outline),
    );
    return TextField(
      autofocus: false,
      controller: _controller,
      onChanged: _handleChange,
      style: TextStyle(color: colors.onSurface),
      decoration: InputDecoration(
        hintText: 'Search',
        hintStyle: TextStyle(color: colors.onSurfaceVariant),
        border: border,
        enabledBorder: border,
        filled: true,
        fillColor: colors.onSurfaceVariant.withValues(alpha: 0.1),
        suffixIcon: _loading
            ? const CupertinoActivityIndicator()
            : _controller.text.isEmpty
                ? const Icon(CarbonIcons.search)
                : IconButton(
                    icon: const Icon(CarbonIcons.close),
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
