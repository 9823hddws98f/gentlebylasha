import 'package:flutter/material.dart';
import 'package:sleeptales/helper/validators.dart';
import 'package:sleeptales/language_constants.dart';

class PasswordEditText extends StatefulWidget {
  final void Function(String? value)? onSaved;

  const PasswordEditText({
    super.key,
    this.onSaved,
  });

  @override
  State<PasswordEditText> createState() => _PasswordEditTextState();
}

class _PasswordEditTextState extends State<PasswordEditText> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) => TextFormField(
        validator: AppValidators.passwordValidator(context),
        obscureText: _obscureText,
        enableSuggestions: false,
        autocorrect: false,
        keyboardType: TextInputType.text,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onSaved: widget.onSaved,
        decoration: InputDecoration(
          hintText: translation(context).password,
          suffixIcon: InkWell(
            onTap: () => setState(() => _obscureText = !_obscureText),
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
              ),
            ),
          ),
        ),
      );
}
