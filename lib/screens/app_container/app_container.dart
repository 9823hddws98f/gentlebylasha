import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/domain/blocs/user/user_bloc.dart';
import '/domain/cubits/navigation.dart';
import '/domain/services/audio_panel_manager.dart';
import '/main.dart';
import '/page_manager.dart';
import '/utils/get.dart';
import '/utils/global_functions.dart';
import '/widgets/music/sliding_panel.dart';
import '../onboarding/onboarding_bottom_sheet.dart';
import 'app_bottom_bar.dart';
import 'app_side_bar.dart';

class AppContainer extends StatefulWidget {
  static const routeName = '/dashboard';

  const AppContainer({super.key});

  @override
  AppContainerState createState() => AppContainerState();
}

class AppContainerState extends State<AppContainer> with SingleTickerProviderStateMixin {
  final _audioPanelManager = Get.the<AudioPanelManager>();
  final _userBloc = Get.the<UserBloc>();
  final _pageManager = Get.the<PageManager>();

  final _navigationCubit = NavigationCubit();
  final _allNavItems = AppNavigation.allNavItems;

  late final _audioPlayerAnimCtrl = AnimationController(
    duration: Durations.short4,
    vsync: this,
  );

  @override
  void initState() {
    super.initState();
    _pageManager.init();
    _initDeepLinking();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _initializeUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return BlocProvider.value(
      value: _navigationCubit,
      child: Scaffold(
        body: MyApp.isMobile ? _buildMobile(bottom) : _buildDesktop(),
      ),
    );
  }

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

  void _initDeepLinking() async {
    // Platform messages are asynchronous, so we initialize in an async method.
    try {
      // Request permission to handle incoming links
      final appLinks = AppLinks();
      appLinks.uriLinkStream.listen((Uri? uri) {
        if (uri != null) {
          _handleDeepLink(uri);
        }
      });
    } on PlatformException {
      showToast("Deeplink exception");
    }
  }

  void _handleDeepLink(Uri uri) {
    String trackId = uri.queryParameters['trackId'] ?? '';
    showToast(trackId);
  }

  Future<void> _initializeUser() async {
    final user = _userBloc.state.user;

    // Initialize onboarding screen if needed
    if (user.goals == null || user.heardFrom == null) {
      OnboardingBottomSheet.show(context);
    }
  }
}
