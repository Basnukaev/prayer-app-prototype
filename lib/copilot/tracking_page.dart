import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'reminder_settings_page.dart';

class TrackingPage extends StatefulWidget {
  final int fajr;
  final int zuhr;
  final int asr;
  final int maghrib;
  final int isha;

  const TrackingPage({
    super.key,
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
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _fajr = widget.fajr;
    _zuhr = widget.zuhr;
    _asr = widget.asr;
    _maghrib = widget.maghrib;
    _isha = widget.isha;
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _fajr = _prefs.getInt('fajr') ?? _fajr;
      _zuhr = _prefs.getInt('zuhr') ?? _zuhr;
      _asr = _prefs.getInt('asr') ?? _asr;
      _maghrib = _prefs.getInt('maghrib') ?? _maghrib;
      _isha = _prefs.getInt('isha') ?? _isha;
    });
  }

  Future<void> _savePreferences() async {
    await _prefs.setInt('fajr', _fajr);
    await _prefs.setInt('zuhr', _zuhr);
    await _prefs.setInt('asr', _asr);
    await _prefs.setInt('maghrib', _maghrib);
    await _prefs.setInt('isha', _isha);
  }

  void _updatePrayerCount(String prayer, int change) {
    setState(() {
      switch (prayer) {
        case 'fajr':
          _fajr = (_fajr + change).clamp(0, double.infinity).toInt();
          break;
        case 'zuhr':
          _zuhr = (_zuhr + change).clamp(0, double.infinity).toInt();
          break;
        case 'asr':
          _asr = (_asr + change).clamp(0, double.infinity).toInt();
          break;
        case 'maghrib':
          _maghrib = (_maghrib + change).clamp(0, double.infinity).toInt();
          break;
        case 'isha':
          _isha = (_isha + change).clamp(0, double.infinity).toInt();
          break;
      }
      _savePreferences();
    });
  }

  void _resetAllPrayers() {
    setState(() {
      _fajr = 0;
      _zuhr = 0;
      _asr = 0;
      _maghrib = 0;
      _isha = 0;
      _savePreferences();
    });
  }

  void _addAllPrayers() {
    setState(() {
      _fajr++;
      _zuhr++;
      _asr++;
      _maghrib++;
      _isha++;
      _savePreferences();
    });
  }

  void _compensateAllPrayers() {
    setState(() {
      _fajr = (_fajr - 1).clamp(0, double.infinity).toInt();
      _zuhr = (_zuhr - 1).clamp(0, double.infinity).toInt();
      _asr = (_asr - 1).clamp(0, double.infinity).toInt();
      _maghrib = (_maghrib - 1).clamp(0, double.infinity).toInt();
      _isha = (_isha - 1).clamp(0, double.infinity).toInt();
      _savePreferences();
    });
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
              onPressed: _compensateAllPrayers,
              child: const Text('Восполнить все намазы'),
            ),
            ElevatedButton(
              onPressed: _addAllPrayers,
              child: const Text('Добавить все намазы'),
            ),
            ElevatedButton(
              onPressed: _resetAllPrayers,
              child: const Text('Сбросить все данные'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReminderSettingsPage()),
                );
              },
              child: const Text('Настроить напоминания'),
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