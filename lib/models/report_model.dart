import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:tvintos_warehouse/models/product_reports_model.dart';
import 'package:http/http.dart' as http;

class ReportModel extends ChangeNotifier {
  String date = '';
  String code = '';
  bool status = false;
  String uid = '';

  List<Nomenclature> listNomenclature = [];
  // List<TextEditingController> listCtr = [];
  // List<FocusNode> listNode = [];

  void clearModel() {
    date = '';
    code = '';
    uid = '';
    status = false;
    listNomenclature.clear();
    //listCtr.clear();
    // listCtr.forEach((element) {
    //   element.dispose();
    // });
    notifyListeners();
  }

  void deleteNomenclature(index) {
    //Nomenclature nom = listNomenclature[index];
    listNomenclature.removeAt(index);
    // listCtr.removeAt(index);
    // listNode.removeAt(index);
    notifyListeners();
  }

  addNomenclature(String code, String name) {
    if (listNomenclature.isEmpty) {
      listNomenclature.add(Nomenclature(
        code: code,
        name: name,
        count: '1',
        tEC: TextEditingController(text: '1'),
        fN: FocusNode(),
      ));
      // listCtr.add(TextEditingController(text: '1'));
      // listNode.add(FocusNode());
      notifyListeners();
      return 0;
    }

    for (var i = 0; i < listNomenclature.length; i++) {
      if (listNomenclature[i].code == code) {
        int count = int.parse(listNomenclature[i].count) + 1;
        listNomenclature[i].count = count.toString();
        listNomenclature[i].tEC.text = count.toString();
        notifyListeners();
        return i;
      }
    }
    listNomenclature.add(Nomenclature(
      code: code,
      name: name,
      count: '1',
      tEC: TextEditingController(text: '1'),
      fN: FocusNode(),
    ));
    // listCtr.add(TextEditingController(text: '1'));
    // listNode.add(FocusNode());
    notifyListeners();
    return listNomenclature.length - 1;
  }

  saveReportIn1c(bool save) async {
    //print(listNomenclature);

    var url;

    var settingsBox = await Hive.openBox('settingsBox');
    Map settings = await settingsBox.get('settings');

    if (settings.isNotEmpty || settings == null) {
      String addrServer = settings['addrServer'];
      String userName = settings['userName'];
      String passwd = settings['passwd'];

      String basicAuth =
          'Basic ' + base64Encode(utf8.encode('$userName:$passwd'));
      if (addrServer.substring(0, 5) == 'https') {
        url = Uri.https(addrServer.replaceFirst('https://', ''),
            '/copy-upp-api/hs/storage/creatingProductsReport');
      } else if (addrServer.substring(0, 4) == 'http') {
        url = Uri.http(addrServer.replaceFirst('http://', ''),
            '/copy-upp-api/hs/storage/creatingProductsReport');
      } else {
        //print('error');
        //return RemainNomenclature;
      }

      try {
        String status;
        if (save == true) {
          status = 'save';
        } else {
          status = 'sign';
        }

        List<Map> tableMap = [];

        listNomenclature.forEach((element) {
          tableMap.add({'code': element.code, 'count': element.count});
        });

        Map bodyMap = {
          'uid': uid,
          'status': save,
          'division': '000000071',
          'nomenclatureList': tableMap
        };

        var jsonBody = jsonEncode(bodyMap);

        final response = await http.post(url,
            body: jsonBody,
            headers: <String, String>{
              'authorization': basicAuth
            }).then((response) {
          //print(response.statusCode);
          //print(utf8.decode(response.bodyBytes));

          if (response.statusCode == 200) {
            //print(utf8.decode(response.bodyBytes));
            var body = (utf8.decode(response.bodyBytes));

            Map<String, dynamic> res = jsonDecode(body);

            //print(body);

          } else {}
        });
      } catch (e) {
        //print(e);
      }
    } else {}
  }
}
