import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class SettingsModel extends ChangeNotifier {
  String addrServer = '';
  String userName = '';
  String passwd = '';
  var url;

  //SettingsModel({required this.addrServer, required this.userName, required this.passwd});

  Future testConnect(String addrServer, String userName, String passwd) async {
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$userName:$passwd'));
    if (addrServer.substring(0, 5) == 'https') {
      url = Uri.https(addrServer.replaceFirst('https://', ''),
          '/uppnewPgSql/hs/storage/get-nomenclature');
    } else if (addrServer.substring(0, 4) == 'http') {
      url = Uri.http(addrServer.replaceFirst('http://', ''),
          '/uppnewPgSql/hs/storage/get-nomenclature');
    } else {
      Map answServ = {'result': false, 'answerSrv': 'Не верный адрес сервера!'};
      print('error');
      return answServ;
    }

    try {
      final response = await http.post(url,
          body: '{"barcode":"4213123"}',
          headers: <String, String>{
            'authorization': basicAuth
          }).then((response) {
        // print(response.statusCode);

        // print(utf8.decode(response.bodyBytes));

        if (response.statusCode == 200) {
          saveSettingsInBD(addrServer, userName, passwd);
          
          return response.statusCode;
        } else {
          return false;
        }
      });
    } catch (e) {
      return false;
     
    }
  }

  void saveSettingsInBD(
      String addrServer, String userName, String passwd) async {
    var settingsBox = await Hive.openBox('settingsBox');
    settingsBox.put('settings',
        {'addrServer': addrServer, 'userName': userName, 'passwd': passwd});
  }

  Future getSettingsFromDB() async {
    var settingsBox = await Hive.openBox('settingsBox');
    var settings = settingsBox.get('settingsBox');
    return settings;
  }
}
