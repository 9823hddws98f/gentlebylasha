import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/constants/assets.dart';
import '/domain/blocs/authentication/auth_repository.dart';
import '/domain/blocs/user/app_user.dart';
import '/domain/blocs/user/user_bloc.dart';
import '/helper/validators.dart';
import '/utils/app_theme.dart';
import '/utils/command_trigger.dart';
import '/utils/firestore_helper.dart';
import '/utils/get.dart';
import '/utils/global_functions.dart';
import '/utils/modals.dart';
import '/utils/tx_button.dart';
import '/widgets/app_image.dart';
import '/widgets/app_scaffold/adaptive_app_bar.dart';
import '/widgets/app_scaffold/app_scaffold.dart';
import '/widgets/app_scaffold/bottom_panel_spacer.dart';
import '/widgets/input/file_dropzone_selector.dart';
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

  String? _email, _name, _photoPath;

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
                        SizedBox(height: 16),
                        _buildPhotoField(),
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

  Widget _buildPhotoField() => BlocBuilder<UserBloc, UserState>(
        buildWhen: (previous, current) => previous.user.photoURL != current.user.photoURL,
        builder: (context, state) => FileDropzoneFormField(
          onSelected: (path) => setState(() => _photoPath = path),
          title: 'Profile photo',
          initialValue: state.user.photoURL,
          type: FileType.image,
          fieldBuilder: (context, imageUrl, action) => InkWell(
            onTap: action,
            borderRadius: AppTheme.smallBorderRadius,
            child: Ink(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: AppTheme.smallBorderRadius,
                color: Theme.of(context).colorScheme.surface,
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  imageUrl != null
                      ? AppImage(
                          imageUrl: imageUrl,
                          placeholderAsset: Assets.avatarIcon,
                          width: 72,
                          height: 72,
                          borderRadius: BorderRadius.circular(50),
                          errorWidget: (context, url, error) => Icon(Icons.person),
                        )
                      : Icon(Icons.person),
                  TxButton.text(
                    label: Text('Change profile photo'),
                    showSuccess: false,
                    onPressVoid: action,
                  ),
                ],
              ),
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
              validator: AppValidators.emailValidator,
              onSaved: (value) => _email = value?.trim(),
            ),
          ),
        ],
      );

  Future<bool> _submit() async {
    if (!_formKey.currentState!.validate()) return false;

    _formKey.currentState!.save();

    // Check if anything changed
    if (_email == _userBloc.state.user.email &&
        _name == _userBloc.state.user.name &&
        _photoPath == _userBloc.state.user.photoURL) {
      showToast('No changes made');
      return false;
    }

    final isEmailUser = await isEmailAndPasswordUserLoggedIn();
    if (!isEmailUser && _email != _auth.currentUser!.email) {
      showToast('Only email users can change their email address');
      return false;
    }

    return _showPasswordConfirmation();
  }

  Future<bool> _showPasswordConfirmation() async {
    final trigger = ActionTrigger();
    String? password;
    final passwordFormKey = GlobalKey<FormState>();

    final confirmed = await Modals.show<bool>(
      context,
      dismissible: false,
      builder: (context) => AlertDialog(
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
          TxButton.text(
            trigger: trigger,
            onPressVoid: () {
              if (!passwordFormKey.currentState!.validate()) return;

              passwordFormKey.currentState!.save();
              if (password?.isNotEmpty ?? false) {
                Navigator.pop(context, true);
              } else {
                showToast('Please enter your password');
              }
            },
            label: Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true || password == null) return false;

    try {
      await _auth.reauthenticate(password!);

      AppUser user = _userBloc.state.user;

      if (_email != user.email) {
        await _auth.changeEmail(_email!); // TODO: Implement
      }

      if (_name != user.name) {
        user = user.copyWith(name: _name);
      }

      if (_photoPath != user.photoURL) {
        user = user.copyWith(photoURL: _photoPath);
      }

      _userBloc.add(UserModified(user));
      return true;
    } catch (e) {
      showToast(e.toString());
      return false;
    }
  }
}
