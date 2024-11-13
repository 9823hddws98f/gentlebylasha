import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/utils/app_theme.dart';
import '/utils/common_extensions.dart';

import '/domain/services/language_cubit.dart';
import '/utils/get.dart';
import '/widgets/app_scaffold/adaptive_app_bar.dart';
import '/widgets/app_scaffold/app_scaffold.dart';

class ChangeLanguageScreen extends StatefulWidget {
  final String? email;
  const ChangeLanguageScreen({super.key, this.email});

  @override
  State<ChangeLanguageScreen> createState() => _ChangeLanguageScreen();
}

class _ChangeLanguageScreen extends State<ChangeLanguageScreen> with Translation {
  final _languageCubit = Get.the<LanguageCubit>();

  @override
  Widget build(BuildContext context) => AppScaffold(
        appBar: (context, isMobile) => AdaptiveAppBar(
          title: tr.changeLanguage,
        ),
        body: (context, isMobile) => BlocBuilder<LanguageCubit, LanguageState>(
          bloc: _languageCubit,
          builder: (context, state) => ListView(
            padding: EdgeInsets.symmetric(vertical: AppTheme.sidePadding),
            children: AppLanguage.values
                .map<Widget>(
                  (language) => ListTile(
                    title: Text(language.displayName),
                    titleTextStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    trailing: state.locale.languageCode == language.languageCode
                        ? const Icon(Icons.check)
                        : null,
                    iconColor: Theme.of(context).colorScheme.primary,
                    onTap: () => _languageCubit.setLanguage(language),
                  ),
                )
                .toList()
                .interleaveWith(Divider()),
          ),
        ),
      );
}
