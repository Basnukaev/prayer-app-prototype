import 'package:flutter/material.dart';

class TrackingPage extends StatefulWidget {
  final int fajr;
  final int zuhr;
  final int asr;
  final int maghrib;
  final int isha;

  TrackingPage({
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Отслеживание намазов'),
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
            SizedBox(height: 20),
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
              child: Text('Восполнить все намазы'),
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
              child: Text('Добавить все намазы'),
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
              icon: Icon(Icons.remove, color: Colors.green),
              onPressed: () => _updatePrayerCount(prayer, -1),
            ),
            Text(count.toString()),
            IconButton(
              icon: Icon(Icons.add, color: Colors.red),
              onPressed: () => _updatePrayerCount(prayer, 1),
            ),
          ],
        ),
      ],
    );
  }
}
