import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/domain/blocs/user/app_user.dart';
import '/domain/blocs/user/user_bloc.dart';
import '/helper/global_functions.dart';
import '/utils/app_theme.dart';
import '/utils/command_trigger.dart';
import '/utils/get.dart';
import '/utils/tx_button.dart';
import '/widgets/app_scaffold/adaptive_app_bar.dart';
import '/widgets/app_scaffold/app_scaffold.dart';
import '/widgets/app_scaffold/bottom_panel_spacer.dart';
import '/widgets/input/file_dropzone_selector.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _userBloc = Get.the<UserBloc>();

  final _formKey = GlobalKey<FormState>();
  final _trigger = ActionTrigger();

  String? _name, _photoPath;

  @override
  Widget build(BuildContext context) => AppScaffold(
        appBar: (context, isMobile) => AdaptiveAppBar(title: 'Edit profile'),
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
                      label: Text('Update'),
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
                color: colors.surface,
                border: Border.all(
                  color: colors.outline,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  imageUrl != null
                      ? Image.network(
                          imageUrl,
                          width: 72,
                          height: 72,
                          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) =>
                              ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: child,
                          ), // TODO: CHECK
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
              enabled: false, // Email changes not supported
              // keyboardType: TextInputType.emailAddress,
              // decoration: InputDecoration(hintText: 'Enter your email'),
              // validator: AppValidators.emailValidator,
              // onSaved: (value) => _email = value?.trim(),
            ),
          ),
        ],
      );

  Future<bool> _submit() async {
    if (!_formKey.currentState!.validate()) return false;

    _formKey.currentState!.save();

    // Check if anything changed
    if (_name == _userBloc.state.user.name &&
        _photoPath == _userBloc.state.user.photoURL) {
      showToast('No changes made');
      return false;
    }

    try {
      AppUser user = _userBloc.state.user;

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
