import 'package:flutter/material.dart';
import 'package:prayer_app/tracking_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstLaunch', false);
    await prefs.setInt('fajr', int.tryParse(_fajrController.text) ?? 0);
    await prefs.setInt('zuhr', int.tryParse(_zuhrController.text) ?? 0);
    await prefs.setInt('asr', int.tryParse(_asrController.text) ?? 0);
    await prefs.setInt('maghrib', int.tryParse(_maghribController.text) ?? 0);
    await prefs.setInt('isha', int.tryParse(_ishaController.text) ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF73C8A9),
        title: const Text(
          'Ввод пропущенных намазов',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF73C8A9), // светлый зеленый
              Color(0xFF373B44), // темный серо-синий
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildPrayerInputField('Фаджр', _fajrController),
              _buildPrayerInputField('Зухр', _zuhrController),
              _buildPrayerInputField('Аср', _asrController),
              _buildPrayerInputField('Магриб', _maghribController),
              _buildPrayerInputField('Иша', _ishaController),
              _buildPrayerInputField('Каждый намаз', _allController, onChanged: (value) {
                setState(() {
                  _fajrController.text = value;
                  _zuhrController.text = value;
                  _asrController.text = value;
                  _maghribController.text = value;
                  _ishaController.text = value;
                });
              }),
              const SizedBox(height: 20),
              _buildActionButton(
                text: 'Рассчитать пропущенные намазы',
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              const SizedBox(height: 20),
              _buildActionButton(
                text: 'Продолжить',
                onPressed: () async {
                  await _savePreferences();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const TrackingPage()),
                  );
                },
              ),
              const SizedBox(height: 10), // небольшой отступ снизу
            ],
          ),
        ),
      ),
    );
  }

  // Метод для создания полей ввода
  Widget _buildPrayerInputField(String label, TextEditingController controller,
      {ValueChanged<String>? onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Colors.white30,
          ),
          // светло-зеленый для label
          filled: true,
          fillColor: Colors.white.withOpacity(0.8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF73C8A9), width: 2),
          ),
        ),
        keyboardType: TextInputType.number,
        onChanged: onChanged,
      ),
    );
  }

  // Метод для создания кнопок
  Widget _buildActionButton({
    required String text,
    required VoidCallback onPressed,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        backgroundColor: const Color(0xFFF4A261), // Светло-оранжевый цвет для кнопки
      ),
      onPressed: onPressed,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 18,
          color: Colors.white,
        ),
      ),
    );
  }
}
