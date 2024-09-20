import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart'; // Подключаем permission_handler

import 'main.dart';

class TrackingPage extends StatefulWidget {
  final int fajr;
  final int zuhr;
  final int asr;
  final int maghrib;
  final int isha;

  const TrackingPage({super.key,
    required this.fajr,
    required this.zuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  @override
  _TrackingPageState createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  late int _fajr;
  late int _zuhr;
  late int _asr;
  late int _maghrib;
  late int _isha;

  @override
  void initState() {
    super.initState();
    _fajr = widget.fajr;
    _zuhr = widget.zuhr;
    _asr = widget.asr;
    _maghrib = widget.maghrib;
    _isha = widget.isha;
  }

  void _updatePrayerCount(String prayer, int change) {
    setState(() {
      switch (prayer) {
        case 'fajr':
          _fajr += change;
          break;
        case 'zuhr':
          _zuhr += change;
          break;
        case 'asr':
          _asr += change;
          break;
        case 'maghrib':
          _maghrib += change;
          break;
        case 'isha':
          _isha += change;
          break;
      }
    });
  }

  void _resetAllPrayers() {
    setState(() {
      _fajr = 0;
      _zuhr = 0;
      _asr = 0;
      _maghrib = 0;
      _isha = 0;
    });
  }

  Future<void> _requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  void _scheduleMinuteNotification() async {
    // Сначала проверим и запросим разрешение на уведомления
    await _requestNotificationPermission();

    // После получения разрешения настраиваем уведомления
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'minute_reminder_channel',
      'Minute Reminders',
      channelDescription: 'Channel for minute reminders',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.periodicallyShow(
      0,
      'Ежеминутное уведомление',
      'Это уведомление приходит раз в минуту',
      RepeatInterval.everyMinute,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Отслеживание намазов'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildPrayerRow('Фаджр', _fajr, 'fajr'),
            _buildPrayerRow('Зухр', _zuhr, 'zuhr'),
            _buildPrayerRow('Аср', _asr, 'asr'),
            _buildPrayerRow('Магриб', _maghrib, 'maghrib'),
            _buildPrayerRow('Иша', _isha, 'isha'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _fajr--;
                  _zuhr--;
                  _asr--;
                  _maghrib--;
                  _isha--;
                });
              },
              child: const Text('Восполнить все намазы'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _fajr++;
                  _zuhr++;
                  _asr++;
                  _maghrib++;
                  _isha++;
                });
              },
              child: const Text('Добавить все намазы'),
            ),
            ElevatedButton(
              onPressed: _resetAllPrayers,
              child: const Text('Сбросить все данные'),
            ),
            ElevatedButton(
              onPressed: _scheduleMinuteNotification,
              child: const Text('Запустить ежеминутные уведомления'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerRow(String title, int count, String prayer) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove, color: Colors.green),
              onPressed: () => _updatePrayerCount(prayer, -1),
            ),
            Text(count.toString()),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.red),
              onPressed: () => _updatePrayerCount(prayer, 1),
            ),
          ],
        ),
      ],
    );
  }
}
