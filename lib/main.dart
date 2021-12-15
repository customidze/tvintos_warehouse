import 'package:flutter/material.dart';
import 'package:tvintos_warehouse/pages/main_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tvintos WareHouse',
      theme: ThemeData(primarySwatch: Colors.green),
      home: MainPage(),
    );
  }
}
