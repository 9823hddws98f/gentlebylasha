import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:supa_carbon_icons/supa_carbon_icons.dart';

import '/constants/assets.dart';
import '/domain/blocs/authentication/auth_repository.dart';
import '/domain/cubits/navigation.dart';
import '/utils/get.dart';

class AppSideBar extends StatefulWidget {
  const AppSideBar({super.key, required this.child});

  final Widget child;

  @override
  State<AppSideBar> createState() => _AppSideBarState();
}

class _AppSideBarState extends State<AppSideBar> {
  static const _duration = Durations.medium4;

  bool _isExpanded = true;

  void _select(NavItem item) {
    context.read<NavigationCubit>().select(item);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Stack(
      children: [
        Row(
          children: [
            TweenAnimationBuilder(
              duration: _duration,
              tween: Tween<double>(begin: 1, end: _isExpanded ? 1 : 0),
              curve: Easing.standard,
              builder: (context, animation, child) => Container(
                color: colors.surface,
                width: lerpDouble(66, 240, animation),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 24),
                    Opacity(
                      opacity: animation,
                      child: SvgPicture.asset(Assets.logo),
                    ),
                    SizedBox(height: 24),
                    Divider(),
                    SizedBox(height: 8),
                    BlocBuilder<NavigationCubit, NavItem>(
                      builder: (context, state) => Padding(
                        padding: EdgeInsetsTween(
                          begin: const EdgeInsets.symmetric(horizontal: 8),
                          end: const EdgeInsets.symmetric(horizontal: 15),
                        ).transform(animation),
                        child: Column(
                          children: AppNavigation.desktopNavItems
                              .map(
                                (item) => _buildButton(
                                  item.index,
                                  label: item.title,
                                  icon: item.icon,
                                  selected: state.index == item.index,
                                  colorScheme: colors,
                                  animation: animation,
                                  onPressed: () => _select(item),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Divider(),
                    SizedBox(height: 8),
                    Padding(
                      padding: EdgeInsetsTween(
                        begin: const EdgeInsets.symmetric(horizontal: 8),
                        end: const EdgeInsets.symmetric(horizontal: 15),
                      ).transform(animation),
                      child: _buildButton(
                        -1,
                        label: 'Logout',
                        icon: CarbonIcons.logout,
                        selected: false,
                        colorScheme: colors,
                        animation: animation,
                        onPressed: () => Get.the<AuthRepository>().logOut(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildBody(colors),
          ],
        ),
        _buildCollapseButton(colors),
      ],
    );
  }

  Widget _buildBody(ColorScheme colors) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Material(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: colors.outline),
              ),
              child: widget.child,
            ),
          ),
        ),
      );

  Widget _buildCollapseButton(ColorScheme colors) => TweenAnimationBuilder(
        duration: _duration,
        tween: Tween<double>(begin: 1, end: _isExpanded ? 1 : 0),
        curve: Easing.standard,
        builder: (context, animation, child) => Padding(
          padding: EdgeInsets.only(left: lerpDouble(15, 220, animation)!, top: 30),
          child: Transform.rotate(
            angle: lerpDouble(0, pi, animation)!,
            child: child!,
          ),
        ),
        child: IconButton(
          style: IconButton.styleFrom(
            backgroundColor: colors.surface,
            side: BorderSide(color: colors.outline),
          ),
          icon: const Icon(CarbonIcons.chevron_right),
          onPressed: () => setState(() => _isExpanded = !_isExpanded),
        ),
      );

  Widget _buildButton(
    int index, {
    required String label,
    required IconData icon,
    required bool selected,
    required ColorScheme colorScheme,
    required double animation,
    required void Function() onPressed,
  }) =>
      Container(
        height: 56,
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: FilledButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: selected ? colorScheme.primary : colorScheme.surface,
            foregroundColor: selected ? colorScheme.onPrimary : colorScheme.onSurface,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Row(
            children: [
              Icon(icon),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 18),
                  child: Opacity(
                    opacity: animation,
                    child: Text(
                      label,
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
