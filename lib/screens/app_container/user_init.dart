import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/domain/blocs/user/app_user.dart';
import '/domain/blocs/user/user_bloc.dart';
import '/domain/services/language_cubit.dart';
import '/domain/services/user_service.dart';
import '/screens/onboarding/onboarding_bottom_sheet.dart';
import '/utils/command_trigger.dart';
import '/utils/get.dart';
import '/utils/modals.dart';
import '/utils/tx_button.dart';
import '/utils/tx_loader.dart';

class UserInit {
  final AppUser user;

  UserInit({required this.user});

  Future<void> initialize(BuildContext context) async {
    if (user.id.isEmpty || !context.mounted) return;

    if (user.name?.trim().isEmpty ?? true) await _askNameIfNeeded(context);

    if (!context.mounted) return;

    // Initialize onboarding screen if needed
    if (user.goals == null || user.heardFrom == null) {
      await OnboardingBottomSheet.show(context);
    }
  }

  /// The profile has no name. Use the one from the sign-in (Apple, Google)
  /// when there is one; otherwise ask once, and let the user skip it.
  Future<void> _askNameIfNeeded(BuildContext context) async {
    final authName = FirebaseAuth.instance.currentUser?.displayName?.trim() ?? '';
    if (authName.isNotEmpty) {
      await Get.the<UsersService>().update(user.copyWith(name: authName)).catchError(
            (Object e) => debugPrint('Saving the name failed: $e'),
          );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final skippedKey = 'namePromptSkipped_${user.id}';
    if (prefs.getBool(skippedKey) ?? false) return;
    if (!context.mounted) return;

    final saved = await _ChangeUserName.show(context);
    if (saved != true) await prefs.setBool(skippedKey, true);
  }
}

class _ChangeUserName extends StatefulWidget {
  const _ChangeUserName();

  /// true when a name was saved; null when the user skipped or dismissed it.
  static Future<bool?> show(BuildContext context) => Modals.show<bool>(
        context,
        builder: (context) => const _ChangeUserName(),
      );

  @override
  State<_ChangeUserName> createState() => _ChangeUserNameState();
}

class _ChangeUserNameState extends State<_ChangeUserName> with Translation {
  final _usersService = Get.the<UsersService>();
  final _userBloc = Get.the<UserBloc>();

  final _formKey = GlobalKey<FormState>();
  final _txLoader = TxLoader();
  final _actionTrigger = ActionTrigger();

  bool _dirty = false;
  String? _name;

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(tr.nameDialogTitle),
        content: Form(
          key: _formKey,
          child: TextFormField(
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(hintText: tr.yourName),
            autovalidateMode: _dirty ? AutovalidateMode.always : AutovalidateMode.disabled,
            validator: (value) => value?.trim().isEmpty ?? true ? tr.enterName : null,
            onSaved: (value) => _name = value?.trim(),
            onFieldSubmitted: (_) => _actionTrigger.trigger(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr.notNow),
          ),
          TxButton.filled(
            label: Text(tr.save),
            trigger: _actionTrigger,
            onPress: _submit,
            onSuccess: () => Navigator.pop(context, true),
          ),
        ],
      );

  Future<bool> _submit() async {
    if (!_dirty) setState(() => _dirty = true);
    if (!_formKey.currentState!.validate()) return false;
    _formKey.currentState!.save();

    await _txLoader.load(
      () => _usersService.update(_userBloc.state.user.copyWith(name: _name)),
      ensure: () => mounted,
    );
    return true;
  }
}
