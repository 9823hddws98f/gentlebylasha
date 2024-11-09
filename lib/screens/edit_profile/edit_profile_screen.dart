import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sleeptales/domain/blocs/authentication/auth_repository.dart';
import 'package:sleeptales/domain/blocs/user/user_bloc.dart';
import 'package:sleeptales/utils/command_trigger.dart';
import 'package:sleeptales/utils/firestore_helper.dart';
import 'package:sleeptales/utils/get.dart';
import 'package:sleeptales/utils/tx_button.dart';
import 'package:sleeptales/widgets/app_scaffold/bottom_panel_spacer.dart';

import '/helper/validators.dart';
import '/utils/colors.dart';
import '/utils/global_functions.dart';
import '/widgets/app_scaffold/adaptive_app_bar.dart';
import '/widgets/app_scaffold/app_scaffold.dart';
import '/widgets/input/password_edit_text.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _auth = Get.the<AuthRepository>();
  final _userBloc = Get.the<UserBloc>();

  final _formKey = GlobalKey<FormState>();
  final _trigger = ActionTrigger();

  String? _email;
  String? _name;

  @override
  Widget build(BuildContext context) => AppScaffold(
        appBar: (context, isMobile) => AdaptiveAppBar(title: 'Edit profile'),
        body: (context, isMobile) => BottomPanelSpacer.padding(
          child: BlocProvider.value(
            value: _userBloc,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildNameField(),
                        _buildEmailField(),
                      ],
                    ),
                  ),
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Container(
                    padding: EdgeInsets.only(bottom: 16),
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      width: double.infinity,
                      child: TxButton.filled(
                        onPress: _submit,
                        trigger: _trigger,
                        label: Text('Update'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildNameField() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
            child: Text('Your Name:', style: TextStyle(fontSize: 16)),
          ),
          BlocBuilder<UserBloc, UserState>(
            buildWhen: (previous, current) => previous.user.name != current.user.name,
            builder: (context, state) => TextFormField(
              initialValue: state.user.name,
              decoration: InputDecoration(hintText: 'Enter your name'),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter your name' : null,
              onSaved: (value) => _name = value?.trim(),
            ),
          ),
          SizedBox(height: 16),
        ],
      );

  Widget _buildEmailField() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: Text('Email:', style: TextStyle(fontSize: 16)),
          ),
          BlocBuilder<UserBloc, UserState>(
            buildWhen: (previous, current) => previous.user.email != current.user.email,
            builder: (context, state) => TextFormField(
              initialValue: state.user.email,
              enabled: false, // TODO: Implement
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(hintText: 'Enter your email'),
              validator: AppValidators.emailValidator(context),
              onSaved: (value) => _email = value?.trim(),
            ),
          ),
        ],
      );

  Future<bool> _submit() async {
    if (!_formKey.currentState!.validate()) return false;

    _formKey.currentState!.save();

    // Check if anything changed
    if (_email == _userBloc.state.user.email && _name == _userBloc.state.user.name) {
      showToast('No changes made');
      return false;
    }

    final isEmailUser = await isEmailAndPasswordUserLoggedIn();
    if (!isEmailUser && _email != _auth.currentUser.email) {
      showToast('Only email users can change their email address');
      return false;
    }

    return _showPasswordConfirmation();
  }

  Future<bool> _showPasswordConfirmation() async {
    String? password;
    final passwordFormKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: colorBackground,
        title: Text('Confirm Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Please enter your current password to save changes'),
            SizedBox(height: 16),
            Form(
              key: passwordFormKey,
              child: PasswordEditText(
                onSaved: (value) => password = value,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (!passwordFormKey.currentState!.validate()) return;

              passwordFormKey.currentState!.save();
              if (password?.isNotEmpty ?? false) {
                Navigator.pop(context, true);
              } else {
                showToast('Please enter your password');
              }
            },
            child: Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true || password == null) return false;

    try {
      await _auth.reauthenticate(password!);

      if (_email != _userBloc.state.user.email) {
        await _auth.changeEmail(_email!);
      }

      if (_name != _userBloc.state.user.name) {
        _userBloc.add(UserModified(_userBloc.state.user.copyWith(name: _name)));
      }

      return true;
    } catch (e) {
      showToast(e.toString());
      return false;
    }
  }
}
