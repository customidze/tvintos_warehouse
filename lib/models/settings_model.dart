import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SettingsModel extends ChangeNotifier {
  String _addrServer = '';
  String _userName = '';
  String _passwd = '';
  var url;

  testConnect(String addrServer, String userName, passwd) async {
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$userName:$passwd'));
    if (addrServer.substring(0, 5) == 'https') {
      url = Uri.https(addrServer.replaceFirst('https://', ''),
          '/copy-upp-api/hs/storage/get-nomenclature');
    } else if (addrServer.substring(0, 4) == 'http') {
      url = Uri.http(addrServer.replaceFirst('http://', ''),
          '/copy-upp-api/hs/storage/get-nomenclature');
    } else {
      Map answServ = {'result': false, 'answerSrv': 'Не верный адрес сервера!'};
      print('error');
      return answServ;
    }

    try {
      final response = await http.post(url, headers: <String, String>{
        'authorization': basicAuth
      }).then((response) {
        print(response.statusCode);

        print(utf8.decode(response.bodyBytes));
      });
    } catch (e) {}
  }
}
