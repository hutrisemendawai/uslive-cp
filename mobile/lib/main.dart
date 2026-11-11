import 'package:flutter/material.dart';

import 'presentation/pages/home_page.dart';

void main() {
  runApp(const UsliveApp());
}

class UsliveApp extends StatelessWidget {
  const UsliveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uslive',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
