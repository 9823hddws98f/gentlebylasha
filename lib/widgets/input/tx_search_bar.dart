import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '/domain/services/language_cubit.dart';

class TxSearchBar extends StatefulWidget {
  const TxSearchBar({
    super.key,
    required this.onSearch,
  });

  final Future<void> Function(String) onSearch;

  @override
  State<TxSearchBar> createState() => _TxSearchBarState();
}

class _TxSearchBarState extends State<TxSearchBar> with Translation {
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
        hintText: tr.search,
        hintStyle: TextStyle(color: colors.onSurfaceVariant),
        border: border,
        enabledBorder: border,
        filled: true,
        fillColor: colors.onSurfaceVariant.withValues(alpha: 0.1),
        suffixIcon: _loading
            ? const CupertinoActivityIndicator()
            : _controller.text.isEmpty
                ? const Icon(Icons.search_rounded)
                : IconButton(
                    icon: const Icon(Icons.close_rounded),
                    tooltip: tr.clearSearch,
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
