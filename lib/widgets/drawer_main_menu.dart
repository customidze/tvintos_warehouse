import 'package:flutter/material.dart';
import 'package:tvintos_warehouse/pages/settings.dart';

class DraiwerMainMenu extends StatelessWidget {
  const DraiwerMainMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.green),
            child: Center(child: Text('Настройки')),
          ),
          ListTile(
              title: Text('Авторизация'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Settings()));
              }),
        ],
      ),
    );
  }
}
