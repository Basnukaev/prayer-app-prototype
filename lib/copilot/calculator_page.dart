import 'package:flutter/material.dart';

class CalculatorPage extends StatefulWidget {
  @override
  _CalculatorPageState createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final TextEditingController _yearsController = TextEditingController();
  final TextEditingController _monthsController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();

  void _calculateMissedPrayers() {
    // Логика для расчета пропущенных намазов
    int years = int.tryParse(_yearsController.text) ?? 0;
    int months = int.tryParse(_monthsController.text) ?? 0;
    int days = int.tryParse(_daysController.text) ?? 0;

    int totalDays = (years * 365) + (months * 30) + days;
    int totalPrayers = totalDays * 5;

    Navigator.pop(context, totalPrayers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Калькулятор пропущенных намазов'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _yearsController,
              decoration: InputDecoration(labelText: 'Годы'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _monthsController,
              decoration: InputDecoration(labelText: 'Месяцы'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _daysController,
              decoration: InputDecoration(labelText: 'Дни'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculateMissedPrayers,
              child: Text('Рассчитать'),
            ),
          ],
        ),
      ),
    );
  }
}