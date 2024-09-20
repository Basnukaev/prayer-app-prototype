import 'package:flutter/material.dart';
import 'package:prayer_app/copilot/tracking_page.dart';
import 'calculator_page.dart';

class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  _InputPageState createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  final TextEditingController _fajrController = TextEditingController();
  final TextEditingController _zuhrController = TextEditingController();
  final TextEditingController _asrController = TextEditingController();
  final TextEditingController _maghribController = TextEditingController();
  final TextEditingController _ishaController = TextEditingController();
  final TextEditingController _allController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ввод пропущенных намазов'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _fajrController,
              decoration: const InputDecoration(labelText: 'Фаджр'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _zuhrController,
              decoration: const InputDecoration(labelText: 'Зухр'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _asrController,
              decoration: const InputDecoration(labelText: 'Аср'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _maghribController,
              decoration: const InputDecoration(labelText: 'Магриб'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _ishaController,
              decoration: const InputDecoration(labelText: 'Иша'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _allController,
              decoration: const InputDecoration(labelText: 'Все намазы'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _fajrController.text = value;
                  _zuhrController.text = value;
                  _asrController.text = value;
                  _maghribController.text = value;
                  _ishaController.text = value;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CalculatorPage()),
                );
                if (result != null) {
                  setState(() {
                    _allController.text = result.toString();
                    _fajrController.text = result.toString();
                    _zuhrController.text = result.toString();
                    _asrController.text = result.toString();
                    _maghribController.text = result.toString();
                    _ishaController.text = result.toString();
                  });
                }
              },
              child: const Text('Рассчитать пропущенные намазы'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TrackingPage(
                      fajr: int.tryParse(_fajrController.text) ?? 0,
                      zuhr: int.tryParse(_zuhrController.text) ?? 0,
                      asr: int.tryParse(_asrController.text) ?? 0,
                      maghrib: int.tryParse(_maghribController.text) ?? 0,
                      isha: int.tryParse(_ishaController.text) ?? 0,
                    ),
                  ),
                );
              },
              child: const Text('Продолжить'),
            ),
          ],
        ),
      ),
    );
  }
}