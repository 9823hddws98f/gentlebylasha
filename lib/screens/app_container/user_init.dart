import 'package:flutter/material.dart';

import '/domain/blocs/user/app_user.dart';
import '/domain/blocs/user/user_bloc.dart';
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

    if (user.name?.isEmpty ?? true) {
      await _ChangeUserName.show(context);
    }

    if (!context.mounted) return;

    // Initialize onboarding screen if needed
    if (user.goals == null || user.heardFrom == null) {
      await OnboardingBottomSheet.show(context);
    }
  }
}

class _ChangeUserName extends StatefulWidget {
  const _ChangeUserName();

  static Future<void> show(BuildContext context) async => Modals.show(
        context,
        dismissible: false,
        builder: (context) => _ChangeUserName(),
      );

  @override
  State<_ChangeUserName> createState() => _ChangeUserNameState();
}

class _ChangeUserNameState extends State<_ChangeUserName> {
  final _usersService = Get.the<UsersService>();
  final _userBloc = Get.the<UserBloc>();

  final _formKey = GlobalKey<FormState>();
  final _txLoader = TxLoader();
  final _actionTrigger = ActionTrigger();

  bool _dirty = false;
  String? _name;

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text('Enter your name'),
        content: Form(
          key: _formKey,
          child: TextFormField(
            autovalidateMode:
                _dirty ? AutovalidateMode.always : AutovalidateMode.disabled,
            validator: (value) => value?.isEmpty == true ? 'Name is required' : null,
            onSaved: (value) => _name = value,
            onFieldSubmitted: (_) => _submit(),
          ),
        ),
        actions: [
          TxButton.filled(
            label: Text('Save'),
            trigger: _actionTrigger,
            onPress: _submit,
            onSuccess: () => Navigator.pop(context),
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
