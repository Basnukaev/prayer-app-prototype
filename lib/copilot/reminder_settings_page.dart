import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

import 'main.dart';

class ReminderSettingsPage extends StatefulWidget {
  const ReminderSettingsPage({super.key});

  @override
  _ReminderSettingsPageState createState() => _ReminderSettingsPageState();
}

class _ReminderSettingsPageState extends State<ReminderSettingsPage> {
  int _remindersPerDay = 1;
  List<TimeOfDay> _reminderTimes = [const TimeOfDay(hour: 12, minute: 0)];
  final List<bool> _selectedDays = List.generate(7, (_) => false);

  void _updateReminderTimes(int count) {
    setState(() {
      if (count > _reminderTimes.length) {
        _reminderTimes.addAll(List.generate(
            count - _reminderTimes.length, (_) => const TimeOfDay(hour: 12, minute: 0)));
      } else {
        _reminderTimes = _reminderTimes.sublist(0, count);
      }
    });
  }

  Future<void> _requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  void _scheduleDailyNotification() async {
    await _requestNotificationPermission();

    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'daily_reminder_channel',
      'Daily Reminders',
      channelDescription: 'Channel for daily prayer reminders',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    for (int i = 0; i < _remindersPerDay; i++) {
      for (int j = 0; j < 7; j++) {
        if (_selectedDays[j]) {
          await flutterLocalNotificationsPlugin.zonedSchedule(
            j * _remindersPerDay + i,
            'Prayer Reminder',
            'Don\'t forget to pray',
            _nextInstanceOfTime(_reminderTimes[i]),
            platformChannelSpecifics,
            androidScheduleMode: AndroidScheduleMode.alarmClock,
            uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          );
        }
      }
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Напоминания настроены')),
      );
    }
  }

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    final tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    return scheduledDate.isBefore(now) ? scheduledDate.add(const Duration(days: 1)) : scheduledDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки напоминаний'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Количество напоминаний в день: $_remindersPerDay'),
            Slider(
              value: _remindersPerDay.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: _remindersPerDay.toString(),
              onChanged: (double value) {
                setState(() {
                  _remindersPerDay = value.toInt();
                  _updateReminderTimes(_remindersPerDay);
                });
              },
            ),
            const SizedBox(height: 20),
            ...List.generate(_remindersPerDay, (index) {
              return Row(
                children: [
                  Text('Напоминание ${index + 1}:'),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: _reminderTimes[index],
                          builder: (BuildContext context, Widget? child) {
                            return MediaQuery(
                              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null && picked != _reminderTimes[index]) {
                          setState(() {
                            _reminderTimes[index] = picked;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(10.0),
                        ),
                        child: Text(_reminderTimes[index].format(context)),
                      ),
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 20),
            const Text('Выберите дни недели для напоминаний:'),
            ToggleButtons(
              isSelected: _selectedDays,
              onPressed: (int index) {
                setState(() {
                  _selectedDays[index] = !_selectedDays[index];
                });
              },
              children: const [
                Text('Пн'),
                Text('Вт'),
                Text('Ср'),
                Text('Чт'),
                Text('Пт'),
                Text('Сб'),
                Text('Вс'),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _scheduleDailyNotification,
              child: const Text('Настроить напоминания'),
            ),
          ],
        ),
      ),
    );
  }
}