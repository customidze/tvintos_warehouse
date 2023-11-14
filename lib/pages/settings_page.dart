import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:tvintos_warehouse/models/settings_model.dart';
import 'package:tvintos_warehouse/util/network_util.dart';
import 'package:provider/provider.dart';

class Settings extends StatelessWidget {
  Settings({Key? key}) : super(key: key);
  final ctrlAddrServer =
      TextEditingController(text: 'http://192.168.1.118:443');
  final ctrlUserName = TextEditingController(text: 'nburenkovaTSD');
  final ctrlPasswd = TextEditingController(text: 'sc1or6');

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
              //initialValue: 'http://192.168.1.135:443',
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
                  borderSide: const BorderSide(
                    color: Colors.red,
                    width: 1.5,
                  ),
                ),
                hintText: 'https://example.com',
                labelText: 'Адрес сервера',
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: TextFormField(
                //initialValue: 'testapi',
                controller: ctrlUserName,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: const BorderSide(
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
              //initialValue: 'sc1or6',
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
                  borderSide: const BorderSide(
                    color: Colors.red,
                    width: 1.5,
                  ),
                ),
                hintText: 'Введите пароль',
                labelText: 'Пароль',
              ),
            ),
            ElevatedButton(
              child: const Text("Тест соединения"),
              onPressed: () async {
                if (ctrlAddrServer.text == '' ||
                    ctrlUserName.text == '' ||
                    ctrlPasswd.text == '') {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const AlertDialog(
                          title: Text('Заполните все поля'),
                        );
                      });
                  return null;
                } else {}
                ;
                //String res;
                String res = await testConnect(
                    ctrlAddrServer.text, ctrlUserName.text, ctrlPasswd.text);
                print(res);

                if (res == 'ok') {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const AlertDialog(
                          title: Text('Соединение успешно'),
                        );
                      });
                } else {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const AlertDialog(
                          title: Text('Соединение провалено!'),
                        );
                      });
                }

                // await testConnect(
                //         ctrlAddrServer.text, ctrlUserName.text, ctrlPasswd.text)
                //     .then((result) {
                //   print(result);
                // }
                // );
              },
            )
          ],
        ),
      ),
    );
  }
}


// FutureBuilder fb = FutureBuilder(
//   future: testConnect(addrServer, userName, passwd),
//   builder: builder)