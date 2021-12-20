import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

Future<String> testConnect(
    String addrServer, String userName, String passwd) async {
  var url;
  String result = 'false';

  String basicAuth = 'Basic ' + base64Encode(utf8.encode('$userName:$passwd'));
  if (addrServer.substring(0, 5) == 'https') {
    url = Uri.https(addrServer.replaceFirst('https://', ''),
        '/copy-upp-api/hs/storage/get-nomenclature');
  } else if (addrServer.substring(0, 4) == 'http') {
    url = Uri.http(addrServer.replaceFirst('http://', ''),
        '/copy-upp-api/hs/storage/get-nomenclature');
  } else {
    Map answServ = {'result': false, 'answerSrv': 'Не верный адрес сервера!'};
    //print('error');
    return 'answServ';
  }

  try {
    final response = await http.post(url,
        body: '{"barcode":"4213123"}',
        headers: <String, String>{'authorization': basicAuth}).then((response) {
      print(response.statusCode);

      //print(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        saveSettingsInBD(addrServer, userName, passwd);
        //print('200000');
        result = 'ok';
      } else {
        return 'false';
      }
    });
  } catch (e) {
    result = 'false';
  }
  return result;
}

void saveSettingsInBD(String addrServer, String userName, String passwd) async {
  var settingsBox = await Hive.openBox('settingsBox');
  settingsBox.put('settings',
      {'addrServer': addrServer, 'userName': userName, 'passwd': passwd});
}
