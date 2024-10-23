import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';

import '/language_constants.dart';
import '/screens/home_screen.dart';
import '/screens/login_layout.dart';
import '/utils/colors.dart';
import '/utils/global_functions.dart';
import '/widgets/custom_socialmedia_btn.dart';
import '/widgets/login_footer.dart';
import '../models/user_model.dart';
import '../widgets/custom_asset_button.dart';
import 'authentication.dart';
import 'my_bottom_sheet.dart';

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key});

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {
  bool isDisable = true;
  void changeBottomSheetDisable(bool disable) {
    setState(() {
      isDisable = disable;
    });
  }

  // Call the callback and pass the result when needed
  void callbackSignup() {
    showModalBottomSheet<void>(
        enableDrag: false,
        isDismissible: isDisable,
        isScrollControlled: true,
        backgroundColor: colorBackground,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        context: context,
        builder: (BuildContext context) {
          return MyBottomSheet(
            currentPage: 0,
            callBackLogin: callbackLogin,
          );
        });
  }

  // Call the callback and pass the result when needed
  void callbackLogin() {
    showModalBottomSheet<void>(
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: colorBackground,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24), topRight: Radius.circular(24))),
      context: context,
      builder: (BuildContext context) {
        return Form(child: Builder(builder: (cxt) {
          return Container(
              height: MediaQuery.of(context).size.height * 0.89,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24), topRight: Radius.circular(24))),
              child: LoginScreen(
                callback: callbackSignup,
              ));
        }));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(children: [
        SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Image.asset(
            "images/launch_screen_background.jpg",
            fit: BoxFit.fill,
          ),
        ),
        Padding(
            padding: EdgeInsets.only(top: 102),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    "Gentle",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 118,
                ),
                Center(
                  child: Text(
                    translation(context).welcomeToSleepytales,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Center(
                  child: Text(
                    translation(context).launchScreenMessage,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 100),
                  child: Center(
                    child: Text(
                      translation(context).createYourAccount,
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: CustomSocialButton(
                      title: translation(context).signupWithEmail,
                      onPress: () {
                        showModalBottomSheet<void>(
                            enableDrag: false,
                            isDismissible: isDisable,
                            isScrollControlled: true,
                            backgroundColor: colorBackground,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20))),
                            context: context,
                            builder: (BuildContext context) {
                              return MyBottomSheet(
                                currentPage: 0,
                                callBackLogin: callbackLogin,
                              );
                            });
                      },
                      color: Colors.white,
                      textColor: Colors.black,
                      icon: Icon(
                        Icons.email_outlined,
                        size: 24,
                      ),
                    )),
                Padding(
                    padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: CustomSocialButton(
                      title: translation(context).continueWithApple,
                      onPress: () async {
                        showLoaderDialog(
                            context, "${translation(context).authThrough} Apple");
                        Auth auth = Auth();
                        UserCredential? userCredential = await auth.signInWithApple();
                        if (userCredential == null) {
                          showToast("${translation(context).unableToAuth} Apple");
                          Navigator.pop(context);
                        } else {
                          if (userCredential.additionalUserInfo!.isNewUser) {
                            Navigator.pop(context);
                            showModalBottomSheet<void>(
                                enableDrag: false,
                                isScrollControlled: true,
                                backgroundColor: colorBackground,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20))),
                                context: context,
                                builder: (BuildContext context) {
                                  return MyBottomSheet(
                                    currentPage: 1,
                                    userCredential: userCredential,
                                  );
                                });
                          } else {
                            showLoaderDialog(
                                context, "${translation(context).signingIn}...");
                            UserModel? user =
                                await auth.getUserFromServer(userCredential);
                            if (user == null) {
                              showToast(translation(context).unableToSignIn);
                              Navigator.pop(context);
                            } else {
                              await saveUser(user);
                              showToast(translation(context).signInSuccess);
                              Navigator.pop(context);
                              pushRemoveAll(context, HomeScreen());
                            }
                          }
                        }
                      },
                      color: Colors.white,
                      textColor: Colors.black,
                      icon: Icon(
                        Icons.apple,
                        size: 24,
                      ),
                    )),
                Padding(
                    padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: CustomAssetButton(
                      title: translation(context).continueWithFacebook,
                      onPress: () async {
                        showToast("Facebook Signup TODO");

                        // PaymentService service = PaymentService.instance;
                        // List<IAPItem> list  = await service.products;
                        // debugPrint(list.toString());

                        //Auth auth =  Auth();
                        // UserCredential? userCredential = await auth.signInWithFacebook();
                      },
                      color: Colors.white,
                      textColor: textColor,
                      assetPath: 'assets/facebook_icon.svg',
                      assetSize: 24,
                    )),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: CustomAssetButton(
                    title: translation(context).continueWithGoogle,
                    onPress: () async {
                      showLoaderDialog(
                          context, "${translation(context).authThrough} Google");
                      Auth auth = Auth();
                      UserCredential? userCredential = await auth.signInWithGoogle();
                      if (userCredential == null) {
                        showToast("${translation(context).unableToAuth} Google");
                        Navigator.pop(context);
                      } else {
                        Navigator.pop(context);
                        if (userCredential.additionalUserInfo!.isNewUser) {
                          Navigator.pop(context);
                          showModalBottomSheet<void>(
                              enableDrag: false,
                              isScrollControlled: true,
                              backgroundColor: colorBackground,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20))),
                              context: context,
                              builder: (BuildContext context) {
                                return MyBottomSheet(
                                  currentPage: 1,
                                  userCredential: userCredential,
                                );
                              });
                        } else {
                          showLoaderDialog(
                              context, "${translation(context).signingIn}...");
                          UserModel? user = await auth.getUserFromServer(userCredential);
                          if (user == null) {
                            showToast(translation(context).unableToSignIn);
                            Navigator.pop(context);
                          } else {
                            await saveUser(user);
                            showToast(translation(context).signInSuccess);
                            Navigator.pop(context);
                            pushRemoveAll(context, HomeScreen());
                          }
                        }
                        // showLoaderDialog(context, "Siggning in...");
                      }
                    },
                    color: Colors.white,
                    textColor: Colors.black,
                    assetPath: "assets/google_icon.svg",
                    assetSize: 24,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                LoginFotter(
                    alignment: MainAxisAlignment.center,
                    sentenceText: "${translation(context).haveAnAccount}?",
                    loginSingUpText: translation(context).login,
                    onPress: () {
                      showModalBottomSheet<void>(
                        enableDrag: false,
                        isScrollControlled: true,
                        backgroundColor: colorBackground,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(24),
                                topRight: Radius.circular(24))),
                        context: context,
                        builder: (BuildContext context) {
                          return Form(child: Builder(builder: (cxt) {
                            return Container(
                                height: MediaQuery.of(context).size.height * 0.89,
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(24),
                                        topRight: Radius.circular(24))),
                                child: LoginScreen(
                                  callback: callbackSignup,
                                ));
                          }));
                        },
                      );
                    }),
              ],
            )),
      ]),
    );
  }

  Future<Null> buyProduct(IAPItem item) async {
    try {
      await FlutterInappPurchase.instance.requestSubscription(item.productId!);
    } catch (error) {}
  }
}
