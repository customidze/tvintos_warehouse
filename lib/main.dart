import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tvintos_warehouse/models/product_reports_model.dart';
import 'package:tvintos_warehouse/models/settings_model.dart';
import 'package:tvintos_warehouse/pages/main_page.dart';
import 'package:tvintos_warehouse/pages/settings_page.dart';

Future<void> main() async {
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
        localizationsDelegates: [GlobalMaterialLocalizations.delegate],
        supportedLocales: [const Locale('en'), const Locale('ru')],
        title: 'Tvintos WareHouse',
        theme: ThemeData(primarySwatch: Colors.green),
        home: MainPage(),
      ),
      providers: [
        ChangeNotifierProvider(
          create: (context) => SettingsModel(),
          child: Settings(),
        ),
        ChangeNotifierProvider(
          create: (context) => ProductRepostsModel(),
          child: MainPage(),
        ),
      ],
    );
  }
}
