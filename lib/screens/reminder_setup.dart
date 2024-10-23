import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;

import '/utils/colors.dart';
import '/utils/global_functions.dart';
import '/widgets/custom_btn.dart';
import '/widgets/topbar_widget.dart';
import '../main.dart';

class ReminderSetupScreen extends StatefulWidget {
  final String heading;
  final int type;
  final int reminderID;
  final String notificationDescription;
  final String description;
  final String description2;

  const ReminderSetupScreen({
    super.key,
    required this.heading,
    required this.type,
    required this.reminderID,
    required this.description,
    required this.description2,
    required this.notificationDescription,
  });

  @override
  State<ReminderSetupScreen> createState() => _ReminderSetupScreen();
}

class _ReminderSetupScreen extends State<ReminderSetupScreen> {
  TimeOfDay _selectedTime = TimeOfDay.now();
  List<bool> selectedDays = List.filled(7, false);
  bool switchValue = false;

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? selectedTime;

    if (Theme.of(context).platform == TargetPlatform.iOS) {
      // Use Cupertino-style time picker dialog for iOS
      selectedTime = await showCupertinoModalPopup<TimeOfDay>(
        context: context,
        builder: (BuildContext context) {
          return Container(
              decoration: const BoxDecoration(
                color: colorBackground,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              height: 357.h,
              child: Column(
                children: [
                  Center(
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Icon(
                        Icons.expand_more,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 216.h,
                    child: CupertinoTheme(
                      data: CupertinoThemeData(
                        textTheme: CupertinoTextThemeData(
                          dateTimePickerTextStyle: TextStyle(
                            color: Colors.white, // Set your desired text color here
                          ),
                        ),
                      ),
                      child: CupertinoDatePicker(
                        use24hFormat: true,
                        mode: CupertinoDatePickerMode.time,
                        onDateTimeChanged: (DateTime dateTime) {
                          _selectedTime = TimeOfDay.fromDateTime(dateTime);
                          setState(() {});
                        },
                      ),
                    ),
                  ),

                  // Close the modal
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                      child: CustomButton(
                        title: 'Set time',
                        onPress: () {
                          Navigator.of(context).pop();
                        },
                        color: Colors.white,
                        textColor: textColor,
                      ))
                ],
              ));
        },
      );
    } else {
      // Use Material-style time picker dialog for Android and other platforms
      selectedTime = await showTimePicker(
        context: context,
        initialTime: _selectedTime,
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          );
        },
      );
    }

    if (selectedTime != null) {
      setState(() {
        _selectedTime = selectedTime!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
              child: Padding(
                  padding: EdgeInsets.all(10.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TopBar(
                          heading: widget.heading,
                          onPress: () {
                            Navigator.pop(context);
                          }),
                      SizedBox(
                        height: 60.h,
                      ),
                      Center(
                        child: Text(
                          widget.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16.sp, height: 1.5),
                        ),
                      ),
                      SizedBox(
                        height: 48.h,
                      ),
                      Center(
                        child: Text(
                          widget.description2,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16.sp),
                        ),
                      ),
                      SizedBox(
                        height: 40.h,
                      ),
                      Center(
                          child: SizedBox(
                        height: 40.h,
                        child: ElevatedButton.icon(
                          style: ButtonStyle(
                            padding: WidgetStateProperty.all<EdgeInsets>(
                                EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w)),
                            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.w),
                            )),
                            backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                              (Set<WidgetState> states) {
                                if (states.contains(WidgetState.pressed)) {
                                  return lightBlueColor;
                                }
                                return lightBlueColor;
                              },
                            ),
                          ),
                          onPressed: () {
                            if (switchValue) {
                              showToast("Please turn off Get Reminders option first");
                            } else {
                              _selectTime(context);
                            }
                          },
                          icon: const Icon(
                            Icons.alarm,
                            color: Colors.white,
                          ),
                          label: Text(
                            "${_selectedTime.hour}:${_selectedTime.minute}",
                          ),
                        ),
                      )),
                      SizedBox(
                        height: 48.h,
                      ),
                      if (widget.type == 1) ...[
                        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                          DaySelector(
                            dayInitial: "S",
                            isSelected: selectedDays[6],
                            onSelected: (bool selected) {
                              if (!switchValue) {
                                setState(() {
                                  selectedDays[6] = selected;
                                });
                              } else {
                                showToast(
                                    "Please turn off reminder first to make changes");
                              }
                            },
                          ),
                          DaySelector(
                            dayInitial: "M",
                            isSelected: selectedDays[0],
                            onSelected: (bool selected) {
                              if (!switchValue) {
                                setState(() {
                                  selectedDays[0] = selected;
                                });
                              } else {
                                showToast(
                                    "Please turn off reminder first to make changes");
                              }
                            },
                          ),
                          DaySelector(
                            dayInitial: "T",
                            isSelected: selectedDays[1],
                            onSelected: (bool selected) {
                              if (!switchValue) {
                                setState(() {
                                  selectedDays[1] = selected;
                                });
                              } else {
                                showToast(
                                    "Please turn off reminder first to make changes");
                              }
                            },
                          ),
                          DaySelector(
                            dayInitial: "W",
                            isSelected: selectedDays[2],
                            onSelected: (bool selected) {
                              if (!switchValue) {
                                setState(() {
                                  selectedDays[2] = selected;
                                });
                              } else {
                                showToast(
                                    "Please turn off reminder first to make changes");
                              }
                            },
                          ),
                          DaySelector(
                            dayInitial: "T",
                            isSelected: selectedDays[3],
                            onSelected: (bool selected) {
                              if (!switchValue) {
                                setState(() {
                                  selectedDays[3] = selected;
                                });
                              } else {
                                showToast(
                                    "Please turn off reminder first to make changes");
                              }
                            },
                          ),
                          DaySelector(
                            dayInitial: "F",
                            isSelected: selectedDays[4],
                            onSelected: (bool selected) {
                              if (!switchValue) {
                                setState(() {
                                  selectedDays[4] = selected;
                                });
                              } else {
                                showToast(
                                    "Please turn off reminder first to make changes");
                              }
                            },
                          ),
                          DaySelector(
                            dayInitial: "S",
                            isSelected: selectedDays[5],
                            onSelected: (bool selected) {
                              if (!switchValue) {
                                setState(() {
                                  selectedDays[5] = selected;
                                });
                              } else {
                                showToast(
                                    "Please turn off reminder first to make changes");
                              }
                            },
                          ),
                        ]),
                        SizedBox(
                          height: 80.h,
                        ),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Get reminders",
                              style: TextStyle(fontSize: 18.sp),
                            ),
                          ),
                          (Platform.isIOS)
                              ? CupertinoSwitch(
                                  value: switchValue,
                                  onChanged: (value) {
                                    if (value) {
                                      if (widget.type == 1) {
                                        if (selectedDays.every((day) => day == false)) {
                                          showToast("Please select at least 1 day");
                                        } else {
                                          setState(() {
                                            switchValue = value;
                                          });
                                          setWeeklyReminderNotification(
                                              widget.heading,
                                              widget.notificationDescription,
                                              selectedDays,
                                              _selectedTime);

                                          saveReminderValue(widget.heading, value);
                                        }
                                      } else {
                                        setState(() {
                                          switchValue = value;
                                        });
                                        setReminderNotification(
                                            widget.heading,
                                            widget.notificationDescription,
                                            _selectedTime);
                                        saveReminderValue(widget.heading, value);
                                      }
                                    } else {
                                      cancelReminderNotification(widget.reminderID);
                                      saveReminderValue(widget.heading, value);
                                      setState(() {
                                        switchValue = false;
                                      });
                                    }
                                  })
                              : Switch(
                                  value: switchValue,
                                  onChanged: (value) {
                                    if (value) {
                                      if (widget.type == 1) {
                                        if (selectedDays.every((day) => day == false)) {
                                          showToast("Please select at least 1 day");
                                        } else {
                                          setState(() {
                                            switchValue = value;
                                          });
                                          setWeeklyReminderNotification(
                                              widget.heading,
                                              widget.notificationDescription,
                                              selectedDays,
                                              _selectedTime);

                                          saveReminderValue(widget.heading, value);
                                        }
                                      } else {
                                        setState(() {
                                          switchValue = value;
                                        });
                                        setReminderNotification(
                                            widget.heading,
                                            widget.notificationDescription,
                                            _selectedTime);
                                        saveReminderValue(widget.heading, value);
                                      }
                                    } else {
                                      if (widget.type == 1) {
                                        cancelReminderNotificationWeekly(
                                            widget.reminderID);
                                      } else {
                                        cancelReminderNotification(widget.reminderID);
                                      }
                                      saveReminderValue(widget.heading, value);
                                      setState(() {
                                        switchValue = false;
                                      });
                                    }
                                  }),
                        ],
                      ),
                      SizedBox(
                        height: 24.h,
                      ),
                      CustomButton(
                          title: "Save settings",
                          onPress: () {
                            if (widget.type == 1) {
                              if (selectedDays.every((day) => day == false)) {
                                showToast("Please select at least one day");
                              } else {
                                saveTimeOfDay(widget.heading, _selectedTime);
                                saveDaysOfWeek(selectedDays);
                                showToast("Settings saved");
                              }
                            } else {
                              saveTimeOfDay(widget.heading, _selectedTime);
                              showToast("Settings saved");
                            }
                          },
                          color: Colors.white,
                          textColor: Colors.black)
                    ],
                  ))),
        ),
      ),
    );
  }

  bool areAllDaysFalse(List<bool> days) {
    for (var day in days) {
      if (day) {
        return true;
      }
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    getSwitchValue();
    getTimeOfDaySaved();
    if (widget.type == 1) {
      getDaysOfWeek();
    }
  }

  void getSwitchValue() async {
    switchValue = await getReminderValue(widget.heading);
    setState(() {});
  }

  Future<void> getDaysOfWeek() async {
    selectedDays = await getSelectedDays();
    setState(() {});
  }

  void getTimeOfDaySaved() async {
    _selectedTime = await getTimeOfDay(widget.heading);
    setState(() {});
  }

// Define a method to show the daily reminder notification
  Future<void> setReminderNotification(
      String title, String reminderDescription, TimeOfDay time) async {
    // Initialize the timezone database
    String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('daily_reminder', 'Daily Reminder',
            importance: Importance.max,
            playSound: true,
            priority: Priority.high,
            vibrationPattern: Int64List.fromList([0, 500, 500, 1000]));

// iOS notification details
    final DarwinNotificationDetails initializationSettingsDarwin =
        DarwinNotificationDetails();
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: initializationSettingsDarwin);
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      widget.reminderID,
      title,
      reminderDescription,
      scheduledDate,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'Daily notification',
    );
  }

  Future<void> setWeeklyReminderNotification(
    String title,
    String reminderDescription,
    List<bool> daysOfWeek,
    TimeOfDay time,
  ) async {
    // Initialize the timezone database
    String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('weekly_reminder', 'Weekly Reminder',
            importance: Importance.max,
            playSound: true,
            priority: Priority.high,
            vibrationPattern: Int64List.fromList([0, 500, 500, 1000]));
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    for (int i = 0; i < daysOfWeek.length; i++) {
      if (daysOfWeek[i]) {
        var now = tz.TZDateTime.now(tz.local);
        var scheduledDate = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day + (i - now.weekday) % 7,
          time.hour,
          time.minute,
        );

        // Calculate the days to add for the next occurrence of the selected day
        // var daysToAdd = (i - now.weekday + 7) % 7;

        // Add the days to the scheduled date
        //scheduledDate = scheduledDate.add(Duration(days: daysToAdd));

        // Check if the scheduled date is in the past, if so, add another week
        // if (scheduledDate.isBefore(now)) {
        //   scheduledDate = scheduledDate.add(Duration(days: 7));
        // }

        await flutterLocalNotificationsPlugin.zonedSchedule(
          widget.reminderID, // Unique ID for each day's reminder
          title,
          reminderDescription,
          scheduledDate,
          platformChannelSpecifics,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: 'Weekly notification - Day $i',
        );
      }
    }
  }

  // Future<void> scheduleWeeklyReminder(List<bool> selectedDays) async {
  //   // Cancel all previously scheduled notifications
  //   await flutterLocalNotificationsPlugin.cancelAll();
  //
  //   // Define the notification details
  //   const AndroidNotificationDetails androidPlatformChannelSpecifics =
  //   AndroidNotificationDetails(
  //     'weekly_reminder_channel',
  //     'Weekly Reminder',
  //     importance: Importance.max,
  //     priority: Priority.high,
  //   );
  //   const NotificationDetails platformChannelSpecifics =
  //   NotificationDetails(android: androidPlatformChannelSpecifics);
  //
  //   // Map the boolean values to their corresponding day indices
  //   const List<int> dayIndices = [DateTime.sunday, DateTime.monday, DateTime.tuesday, DateTime.wednesday, DateTime.thursday, DateTime.friday, DateTime.saturday];
  //   final List<int> selectedDayIndices = [];
  //   for (int i = 0; i < selectedDays.length; i++) {
  //     if (selectedDays[i]) {
  //       selectedDayIndices.add(dayIndices[i]);
  //     }
  //   }
  //
  //   // Schedule notifications for selected days of the week
  //   final time = Time(8, 0); // Set the desired time (e.g., 8 AM)
  //   for (final selectedDayIndex in selectedDayIndices) {
  //     await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
  //       selectedDayIndex,
  //       'Weekly Reminder',
  //       'This is your weekly reminder',
  //       dayIndices[selectedDayIndex - 1],
  //       time,
  //       platformChannelSpecifics,
  //       payload: 'payload',
  //     );
  //   }
  // }

  Future<void> cancelReminderNotification(int reminderID) async {
    await flutterLocalNotificationsPlugin.cancel(reminderID);
  }

  Future<void> cancelReminderNotificationWeekly(int reminderID) async {
    for (int i = 0; i < 7; i++) {
      await flutterLocalNotificationsPlugin.cancel(reminderID);
    }
  }
}

class DaySelector extends StatelessWidget {
  final String dayInitial;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  const DaySelector({
    super.key,
    required this.dayInitial,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onSelected(!isSelected);
      },
      child: Container(
        width: 40.w,
        height: 40.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? lightBlueColor : whiteWithOpacity,
        ),
        child: Center(
          child: Text(
            dayInitial,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
            ),
          ),
        ),
      ),
    );
  }
}
