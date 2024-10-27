import 'package:flutter/material.dart';

import '/domain/services/language_constants.dart';
import '/helper/validators.dart';

class PasswordEditText extends StatefulWidget {
  const PasswordEditText({
    super.key,
    this.onSaved,
    this.onFieldSubmitted,
    this.textInputAction = TextInputAction.go,
  });

  final void Function(String? value)? onSaved;
  final void Function(String? value)? onFieldSubmitted;
  final TextInputAction textInputAction;

  @override
  State<PasswordEditText> createState() => _PasswordEditTextState();
}

class _PasswordEditTextState extends State<PasswordEditText> with Translation {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) => TextFormField(
        validator: AppValidators.passwordValidator(context),
        obscureText: _obscureText,
        enableSuggestions: false,
        autocorrect: false,
        keyboardType: TextInputType.text,
        textInputAction: widget.textInputAction,
        onSaved: widget.onSaved,
        onFieldSubmitted: widget.onFieldSubmitted,
        decoration: InputDecoration(
          hintText: tr.password,
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
