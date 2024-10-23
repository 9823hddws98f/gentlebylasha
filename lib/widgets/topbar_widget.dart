import 'package:flutter/material.dart';

import '/utils/colors.dart';
import '/widgets/circle_icon_button.dart';

class TopBar extends StatelessWidget {
  final String heading;
  final void Function() onPress;
  const TopBar({super.key, required this.heading, required this.onPress});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // if(Platform.isIOS)
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 0, 5),
              child: CircleIconButton(
                icon: Icons.arrow_back_ios_new,
                onPressed: () {
                  Navigator.pop(context);
                },
                backgroundColor: transparentWhite,
                size: 32,
                iconSize: 20,
              )),
        ),

        Align(
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                child: Text(
                  heading,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
