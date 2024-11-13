import 'package:flutter/material.dart';

class DaySelector extends StatelessWidget {
  final String dayInitial;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  const DaySelector({
    super.key,
    required this.dayInitial,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return IconButton(
      onPressed: () => onSelected(!isSelected),
      style: IconButton.styleFrom(
        backgroundColor: isSelected ? colors.secondary : colors.surfaceContainerLow,
        fixedSize: const Size(40, 40),
      ),
      icon: Text(
        dayInitial,
        style: TextStyle(
          color: isSelected ? colors.onSecondary : colors.onSurface,
          fontSize: 18,
        ),
      ),
    );
  }
}
