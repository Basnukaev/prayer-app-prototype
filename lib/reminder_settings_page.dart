import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool _isLoading = true;  // Добавлено

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _remindersPerDay = prefs.getInt('remindersPerDay') ?? 1;
      _selectedDays.asMap().forEach((index, _) {
        _selectedDays[index] = prefs.getBool('selectedDay_$index') ?? false;
      });
      _reminderTimes = List.generate(_remindersPerDay, (index) {
        final hour = prefs.getInt('reminderTime_${index}_hour') ?? 12;
        final minute = prefs.getInt('reminderTime_${index}_minute') ?? 0;
        return TimeOfDay(hour: hour, minute: minute);
      });
      _isLoading = false;  // Устанавливаем в false после завершения загрузки
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('remindersPerDay', _remindersPerDay);
    for (int i = 0; i < _selectedDays.length; i++) {
      await prefs.setBool('selectedDay_$i', _selectedDays[i]);
    }
    for (int i = 0; i < _reminderTimes.length; i++) {
      await prefs.setInt('reminderTime_${i}_hour', _reminderTimes[i].hour);
      await prefs.setInt('reminderTime_${i}_minute', _reminderTimes[i].minute);
    }
  }

  void _updateReminderTimes(int count) {
    setState(() {
      if (count > _reminderTimes.length) {
        _reminderTimes.addAll(List.generate(
            count - _reminderTimes.length, (_) => const TimeOfDay(hour: 12, minute: 0)));
      } else {
        _reminderTimes = _reminderTimes.sublist(0, count);
      }
      _saveSettings();
    });
  }

  void _toggleSelectedDay(int index) {
    setState(() {
      _selectedDays[index] = !_selectedDays[index];
      _saveSettings();
    });
  }

  Future<void> _requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
      await _requestExactAlarmPermissionsDialog();
    }
  }

  Future<void> _scheduleDailyNotification() async {
    await _requestNotificationPermission();
    await _saveSettings();
    await _requestExactAlarmPermissionsDialog();
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
            _nextInstanceOfTime(_reminderTimes[i], j + 1),
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

  Future<void> _requestExactAlarmPermissionsDialog() async {
    if (!await Permission.scheduleExactAlarm.isGranted) {
      bool shouldRequest = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Permission Required'),
                content: const Text('Exact alarms permission is required for notifications.'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          ) ??
          false;

      if (shouldRequest) {
        var isGranted = await Permission.scheduleExactAlarm.request().isGranted;
        if (!isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permission denied. Notifications will not work.')),
          );
        }
      }
    }
  }

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time, int dayOfWeek) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    int daysUntilNext = (dayOfWeek - now.weekday) % 7;
    if (daysUntilNext <= 0 && scheduledDate.isBefore(now)) {
      daysUntilNext += 7;
    }
    scheduledDate = scheduledDate.add(Duration(days: daysUntilNext));

    return scheduledDate;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),  // Показать индикатор загрузки
      );
    }

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
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
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
                              _saveSettings();
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
                ),
              );
            }),
            const SizedBox(height: 20),
            const Text('Выберите дни недели для напоминаний:'),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ToggleButtons(
                    isSelected: _selectedDays,
                    onPressed: (int index) {
                      _toggleSelectedDay(index);
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
                ],
              ),
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
  }}
