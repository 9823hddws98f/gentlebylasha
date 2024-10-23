import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/styles.dart';
import '/utils/colors.dart';

class CustomeEditText extends StatelessWidget {
  String? Function(String value) validator;
  //final TextEditingController controller;
  final TextInputType inputType;
  int? length = 50;
  final void Function(String value) onchange;
  String hint;

  CustomeEditText(
      {super.key,
      this.length,
      required this.validator,
      //required this.controller,
      required this.inputType,
      required this.onchange,
      required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        validator: (value) {
          return validator(value.toString());
        },
        onChanged: onchange,
        cursorColor: Colors.white,
        textAlign: TextAlign.left,
        //controller: controller,
        style: textFieldStyle,
        keyboardType: inputType,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: decorationInputStyle(hint));
  }
}

class CustomeEditTextFullName extends StatelessWidget {
  String? Function(String value) validator;
  // final TextEditingController controller;
  final TextInputType inputType;
  int? length = 50;
  final void Function(String value) onchange;
  String hint;

  CustomeEditTextFullName(
      {super.key,
      this.length,
      required this.validator,
      //required this.controller,
      required this.inputType,
      required this.onchange,
      required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        validator: (value) {
          return validator(value.toString());
        },
        onChanged: onchange,
        cursorColor: Colors.white,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]")),
        ],
        textAlign: TextAlign.left,
        // controller: controller,
        style: textFieldStyle,
        keyboardType: inputType,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: decorationInputStyle(hint));
  }
}

class CustomeEditTextName extends StatelessWidget {
  String? Function(String value) validator;
  // final TextEditingController controller;
  final TextInputType inputType;
  int? length = 50;
  final void Function(String value) onchange;

  CustomeEditTextName({
    super.key,
    this.length,
    required this.validator,
    // required this.controller,
    required this.inputType,
    required this.onchange,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        validator: (value) {
          return validator(value.toString());
        },
        onChanged: onchange,
        cursorColor: Colors.white,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]")),
        ],
        textAlign: TextAlign.left,
        //controller: controller,
        style: textFieldStyle,
        keyboardType: inputType,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          fillColor: lightBlueColor,
          filled: true,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: lightBlueColor, width: 2),
            borderRadius: BorderRadius.circular(8.h),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.h),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.purple, width: 2),
            borderRadius: BorderRadius.circular(8.h),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: lightBlueColor, width: 2),
            borderRadius: BorderRadius.circular(8.h),
          ),
        ));
  }
}

class PasswordEditText extends StatelessWidget {
  String? Function(String value) validator;
  //final TextEditingController controller;
  final void Function(String value) onchange;
  final void Function() onTap;
  final bool isHide;

  PasswordEditText(
      {super.key, required this.validator,
      //required this.controller,
      required this.onchange,
      required this.onTap,
      required this.isHide});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: (value) {
        return validator(value.toString());
      },
      onChanged: onchange,
      cursorColor: Colors.white,
      obscureText: isHide,
      enableSuggestions: false,
      autocorrect: false,
      textAlign: TextAlign.left,
      // controller: controller,
      style: textFieldStyle,
      keyboardType: TextInputType.text,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: decorationPasswordHintStyle(
        ".............",
        "images/ic_lock.png",
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Icon(
              isHide ? Icons.visibility_off : Icons.visibility,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
