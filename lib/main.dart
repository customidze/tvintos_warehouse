import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tvintos_warehouse/models/settings_model.dart';
import 'package:tvintos_warehouse/pages/main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      child: MaterialApp(
        title: 'Tvintos WareHouse',
        theme: ThemeData(primarySwatch: Colors.green),
        home: MainPage(),
      ),
      providers: [
        Provider(
          create: (_) => SettingsModel(),
        ),
      ],
    );
  }
}
