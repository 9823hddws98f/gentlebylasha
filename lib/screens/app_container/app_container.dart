import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gentle/domain/services/deep_linking_service.dart';

import '/domain/blocs/user/user_bloc.dart';
import '/domain/cubits/navigation.dart';
import '/domain/services/audio_panel_manager.dart';
import '/main.dart';
import '/screens/app_container/user_init.dart';
import '/utils/get.dart';
import '/widgets/music/sliding_panel.dart';
import '../../domain/services/audio_manager.dart';
import 'app_bottom_bar.dart';
import 'app_side_bar.dart';

class AppContainer extends StatefulWidget {
  static const routeName = '/dashboard';

  const AppContainer({super.key});

  @override
  State<AppContainer> createState() => _AppContainerState();
}

class _AppContainerState extends State<AppContainer> with SingleTickerProviderStateMixin {
  final _audioPanelManager = Get.the<AudioPanelManager>();
  final _userBloc = Get.the<UserBloc>();
  final _pageManager = Get.the<AudioManager>();
  final _deepLinkingService = Get.the<DeepLinkingService>();

  final _navigationCubit = NavigationCubit();
  final _allNavItems = AppNavigation.allNavItems;

  late final _audioPlayerAnimCtrl = AnimationController(
    duration: Durations.short4,
    vsync: this,
  );

  @override
  void initState() {
    super.initState();
    _audioPlayerAnimCtrl.duration = Durations.short4;
    _pageManager.init();
    // Initialize after the frame is rendered to ensure the user is set
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _deepLinkingService.initialize();
      UserInit(user: _userBloc.state.user).initialize(context);
    });
  }

  @override
  void dispose() {
    _audioPlayerAnimCtrl.dispose();
    _pageManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider.value(
        value: _navigationCubit,
        child: Scaffold(
          body: MyApp.isMobile
              ? _buildMobile(MediaQuery.paddingOf(context).bottom)
              : _buildDesktop(),
        ),
      );

  Widget _buildMobile(double bottom) => Stack(
        children: [
          for (final item in AppNavigation.mobileNavItems)
            _buildNavigationScreen(item, true),
          SlidingPanel(controller: _audioPlayerAnimCtrl),
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedBuilder(
              animation: _audioPlayerAnimCtrl,
              builder: (context, child) => Transform.translate(
                offset: Offset(
                  0,
                  _audioPlayerAnimCtrl.value * (AppBottomBar.height + bottom),
                ),
                child: child,
              ),
              child: AppBottomBar(),
            ),
          )
        ],
      );

  Widget _buildDesktop() => AppSideBar(
        child: Stack(
          children: AppNavigation.desktopNavItems
              .map((item) => _buildNavigationScreen(item, false))
              .toList(),
        ),
      );

  Widget _buildNavigationScreen(NavItem item, bool isMobile) =>
      BlocBuilder<NavigationCubit, NavItem>(
        builder: (context, state) {
          _handleBadRoute(isMobile, state, context);
          return Offstage(
            offstage: state.index != item.index,
            child: PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) async {
                if (_audioPanelManager.panelController.panelPosition > 0.5) {
                  _audioPanelManager.minimize();
                  return;
                }
                final navigator = item.navigatorKey.currentState;
                if (navigator?.canPop() ?? false) {
                  navigator?.pop();
                }
              },
              child: Navigator(
                key: item.navigatorKey,
                onGenerateRoute: (routeSettings) => MaterialPageRoute(
                  builder: (context) => item.screen!,
                ),
              ),
            ),
          );
        },
      );

  // hack
  void _handleBadRoute(bool isMobile, NavItem state, BuildContext context) {
    if (isMobile && AppNavigation.mobileNavItems.contains(_allNavItems[state.index]) ||
        !isMobile && AppNavigation.desktopNavItems.contains(_allNavItems[state.index])) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<NavigationCubit>().select(_allNavItems[0]);
    });
  }
}
