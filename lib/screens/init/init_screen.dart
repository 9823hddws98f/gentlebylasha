import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '/constants/assets.dart';
import '/domain/blocs/authentication/app_bloc.dart';
import '/domain/blocs/user/user_bloc.dart';
import '/screens/app_container/app_container.dart';
import '/screens/auth/login_screen.dart';
import '/utils/get.dart';

class InitScreen extends StatelessWidget {
  InitScreen({super.key});

  final _userBloc = Get.the<UserBloc>();
  final _appBloc = Get.the<AppBloc>();

  @override
  Widget build(BuildContext context) => BlocBuilder<AppBloc, AppState>(
        bloc: _appBloc,
        builder: (context, appBlocState) => BlocListener<UserBloc, UserState>(
          bloc: _userBloc,
          listener: (context, state) async {
            final route = FirebaseAuth.instance.currentUser == null
                ? LoginScreen.routeName
                : (state.user.id.isNotEmpty && appBlocState.isAuthenticated)
                    ? AppContainer.routeName
                    : null;
            if (route != null) {
              Navigator.pushNamedAndRemoveUntil(context, route, (_) => false);
            }
          },
          child: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(Assets.logo),
                  const SizedBox(height: 16),
                  const CupertinoActivityIndicator(),
                ],
              ),
            ),
          ),
        ),
      );
}
