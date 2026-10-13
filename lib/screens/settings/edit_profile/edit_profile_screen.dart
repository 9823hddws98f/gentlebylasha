import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/domain/blocs/authentication/auth_repository.dart';
import '/domain/blocs/user/user_bloc.dart';
import '/domain/services/language_cubit.dart';
import '/helper/auth_errors.dart';
import '/helper/global_functions.dart';
import '/helper/validators.dart';
import '/utils/app_theme.dart';
import '/utils/command_trigger.dart';
import '/utils/get.dart';
import '/utils/modals.dart';
import '/utils/tx_button.dart';
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

class _EditProfileScreenState extends State<EditProfileScreen> with Translation {
  final _userBloc = Get.the<UserBloc>();
  final _auth = Get.the<AuthRepository>();

  final _formKey = GlobalKey<FormState>();
  final _trigger = ActionTrigger();

  /// Google and Apple accounts get their address from there.
  late final _canChangeEmail = _auth.isPasswordAccount;

  String? _name, _photoPath, _password;

  /// The email as typed; null while untouched.
  String? _email;

  bool get _emailChanged =>
      _canChangeEmail &&
      _email != null &&
      _email!.toLowerCase() != _userBloc.state.user.email.trim().toLowerCase();

  @override
  Widget build(BuildContext context) => AppScaffold(
        appBar: (context, isMobile) => AdaptiveAppBar(title: tr.editProfile),
        body: (context, isMobile) {
          final colors = Theme.of(context).colorScheme;
          return BottomPanelSpacer.padding(
            child: BlocProvider.value(
              value: _userBloc,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 16),
                                _buildPhotoField(colors),
                                _buildNameField(),
                                _buildEmailField(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: AppTheme.sidePadding),
                    child: TxButton.filled(
                      onPress: _submit,
                      trigger: _trigger,
                      onSuccess: () => Navigator.pop(context),
                      label: Text(tr.update),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

  Widget _buildPhotoField(ColorScheme colors) => BlocBuilder<UserBloc, UserState>(
        buildWhen: (previous, current) => previous.user.photoURL != current.user.photoURL,
        builder: (context, state) => FileDropzoneFormField(
          onSelected: (path) => setState(() => _photoPath = path),
          title: tr.profilePhoto,
          initialValue: state.user.photoURL,
          type: FileType.image,
          fieldBuilder: (context, imageUrl, action) => InkWell(
            onTap: action,
            borderRadius: AppTheme.smallBorderRadius,
            child: Ink(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: AppTheme.smallBorderRadius,
                color: colors.surface,
                border: Border.all(
                  color: colors.outline,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  imageUrl?.isNotEmpty ?? false
                      ? Image.network(
                          imageUrl!,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) =>
                              ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: child,
                          ),
                        )
                      : Icon(Icons.person),
                  TxButton.text(
                    label: Text(tr.changeProfilePhoto),
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
            child: Text('${tr.yourName}:', style: TextStyle(fontSize: 16)),
          ),
          BlocBuilder<UserBloc, UserState>(
            buildWhen: (previous, current) => previous.user.name != current.user.name,
            builder: (context, state) => TextFormField(
              initialValue: state.user.name,
              decoration: InputDecoration(hintText: tr.enterYourName),
              validator: (value) => value?.isEmpty ?? true ? tr.enterName : null,
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
            child: Text('${tr.email}:', style: TextStyle(fontSize: 16)),
          ),
          BlocBuilder<UserBloc, UserState>(
            buildWhen: (previous, current) => previous.user.email != current.user.email,
            builder: (context, state) => TextFormField(
              initialValue: state.user.email,
              enabled: _canChangeEmail,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: InputDecoration(
                helperText: _canChangeEmail ? null : tr.emailManagedByProvider,
                helperMaxLines: 3,
              ),
              validator: _canChangeEmail ? AppValidators.emailValidator : null,
              onChanged: (value) => setState(() => _email = value.trim()),
              onSaved: (value) => _email = value?.trim(),
            ),
          ),
          // Changing the address needs the current password.
          AnimatedSize(
            duration: Durations.medium2,
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _emailChanged
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 20, 0, 4),
                        child: Text('${tr.currentPassword}:', style: TextStyle(fontSize: 16)),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Text(
                          tr.currentPasswordForEmail,
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ),
                      PasswordEditText(
                        onSaved: (value) => _password = value,
                        onFieldSubmitted: (_) => _trigger.trigger(),
                      ),
                    ],
                  )
                : SizedBox(width: double.infinity),
          ),
        ],
      );

  Future<bool> _submit() async {
    if (!_formKey.currentState!.validate()) return false;

    _formKey.currentState!.save();

    final user = _userBloc.state.user;
    final nameChanged = _name != null && _name != user.name;
    // _photoPath is only set once a new photo was picked.
    final photoChanged = _photoPath != null && _photoPath != user.photoURL;
    final emailChanged = _emailChanged;
    if (!nameChanged && !photoChanged && !emailChanged) {
      showToast(tr.noChangesMade);
      return false;
    }

    // The email first: a wrong password then stops the whole update.
    if (emailChanged && !await _changeEmail(_email!)) return false;

    try {
      if (nameChanged || photoChanged) {
        _userBloc.add(UserModified(user.copyWith(name: _name, photoURL: _photoPath)));
      }
    } catch (e) {
      debugPrint('Updating the profile failed: $e');
      showToast(tr.somethingWentWrong);
      return false;
    }

    if (emailChanged && mounted) await _showConfirmEmail(_email!);
    return true;
  }

  /// Sends the confirmation link to [email]; false (with a message) when that failed.
  Future<bool> _changeEmail(String email) async {
    try {
      await _auth.changeEmail(email, _password ?? '');
      return true;
    } on FirebaseAuthException catch (e) {
      showToast(switch (e.code) {
        // Reauthentication with a wrong current password.
        'wrong-password' || 'invalid-credential' => tr.currentPasswordWrong,
        _ => authErrorMessage(e.code, tr, fallback: tr.somethingWentWrong) ??
            tr.somethingWentWrong,
      });
      return false;
    } catch (e) {
      debugPrint('Changing the email failed: $e');
      showToast(tr.somethingWentWrong);
      return false;
    }
  }

  /// The address only changes once the link in the email is opened.
  Future<void> _showConfirmEmail(String email) => Modals.show<void>(
        context,
        builder: (context) => AlertDialog(
          title: Text(tr.checkYourInbox),
          content: Text(tr.confirmNewEmail(email)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(tr.ok),
            ),
          ],
        ),
      );
}
