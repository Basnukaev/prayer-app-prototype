import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF73C8A9), // светлый зеленый оттенок
              Color(0xFF373B44), // темный серо-синий оттенок
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'إنَّ أوَّلَ ما يُحاسَبُ بِهِ العبدُ يومَ القيامةِ من عملِه صلاتُهُ',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'Simplified Arabic', // Проверь, добавлен ли шрифт
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Первое, за что человек будет спрошен в День суда из своих дел — это молитва.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                const Text(
                  'Добро пожаловать!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: Color(0xFFF4A261), // Светло-оранжевый цвет для кнопки
                  ),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/input');
                  },
                  child: const Text(
                    'Начнем',
                    style: TextStyle(fontSize: 18, color: Colors.white), // Белый текст
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
