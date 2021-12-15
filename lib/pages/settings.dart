import 'package:flutter/material.dart';

class Settings extends StatelessWidget {
  Settings({Key? key}) : super(key: key);
  final ctrlAddrServer = TextEditingController();
  final ctrlUserName = TextEditingController();
  final ctrlPasswd = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            TextFormField(
              controller: ctrlAddrServer,
              decoration: InputDecoration(
                // focusedBorder: OutlineInputBorder(
                //   borderRadius: BorderRadius.circular(15.0),
                //   borderSide: BorderSide(
                //     color: Colors.red,
                //   ),
                // ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide(
                    color: Colors.red,
                    width: 1.5,
                  ),
                ),
                hintText: 'Введите адрес сервера',
                labelText: 'Адрес сервера',
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: TextFormField(
                controller: ctrlUserName,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide(
                      color: Colors.red,
                      width: 1.5,
                    ),
                  ),
                  hintText: 'Введите имя пользователя',
                  labelText: 'имя пользователя',
                ),
              ),
            ),
            TextFormField(
              controller: ctrlPasswd,
              decoration: InputDecoration(
                // focusedBorder: OutlineInputBorder(
                //   borderRadius: BorderRadius.circular(15.0),
                //   borderSide: BorderSide(
                //     color: Colors.red,
                //   ),
                // ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide(
                    color: Colors.red,
                    width: 1.5,
                  ),
                ),
                hintText: 'Введите пароль',
                labelText: 'Пароль',
              ),
            ),
            ElevatedButton(
              child: Text("Тест соединения"),
              onPressed: () {},
            )
          ],
        ),
      ),
    );
  }
}
