import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class CustomAssetButton extends StatelessWidget {
  final String title;
  final void Function() onPress;
  final Color color;
  final Color textColor;
  final String assetPath;
  final double assetSize;
  const CustomAssetButton({Key? key, required this.title, required this.onPress,required this.color, required this.textColor,required this.assetPath,required this.assetSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 48.h,
      child:ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: color,
          foregroundColor: textColor,
          shape:  RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.h)),
          ),
        ),
        onPressed: onPress, child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            assetPath,
            width: assetSize,
            height: assetSize,
          ),
          Padding(padding: EdgeInsets.only(left: 10.w),
            child:   Text(title,style: TextStyle(color: textColor, fontSize:18.sp),),
          )
        ],
      ),
      ) ,
    );
  }
}
