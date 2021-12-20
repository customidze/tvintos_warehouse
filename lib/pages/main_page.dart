import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tvintos_warehouse/models/product_reports_model.dart';
import 'package:tvintos_warehouse/widgets/drawer_main_menu.dart';

import 'dart:convert' as convert;

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  var _code;
  var _name;
  var _count;
  static const EventChannel _eventChannel = EventChannel('neo.com/app');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _eventChannel.receiveBroadcastStream().listen((value) async {
      Map result = await context
          .read<ProductRepostsModel>()
          .getRemainNomenclature(value);

      String name = result['name'];
      print(name);
      String count = result['count'].toString();
      // bool error = result['error'];
      // String errorText = result['errorText'];

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(width: 3, color: Colors.green)),
                        child: Text('Код: $value')),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(width: 3, color: Colors.green)),
                        child: Text('Наименование: $name')),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(width: 3, color: Colors.green)),
                        child: Text('Количество: $count')),
                  ),
                  //error ? Text(errorText) : SizedBox(),
                ],
              ),
              //content: Text('Наименование: $name'),
            );
          });

      // setState(() {
      //   _code = value;
      // });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(onPressed: () {}, icon: Icon(Icons.refresh)),
          ],
          title: Text("Склад"),
        ),
        drawer: DraiwerMainMenu(),
        body: Column(
          children: [Text('_version：'), Text('code：$_code')],
        ));
  }
}
