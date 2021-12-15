import 'package:flutter/material.dart';
import 'package:tvintos_warehouse/widgets/drawer_main_menu.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Склад"),
      ),
      drawer: DraiwerMainMenu(),
      body: Text('nnn'),
    );
  }
}
