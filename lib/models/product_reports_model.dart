import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductReportsModel extends ChangeNotifier {
  //String dateStart;
  //String dateEnd;
  List<ProductReport> listProductOrders = [];
  List<TextEditingController> listTEC = [];
  List<FocusNode> listNode = [];

  getRemainNomenclature(barcode) async {
    Map remainNomenclature = {};
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
            '/copy-upp-api/hs/storage/get-nomenclature');
      } else if (addrServer.substring(0, 4) == 'http') {
        url = Uri.http(addrServer.replaceFirst('http://', ''),
            '/copy-upp-api/hs/storage/get-nomenclature');
      } else {
        remainNomenclature = {
          'name': '',
          'count': '',
          'result': false,
          'answerSrv': 'Не верный адрес сервера!'
        };
        //print('error');
        //return RemainNomenclature;
      }

      try {
        final response = await http.post(url,
            body: '{"barcode":"$barcode"}',
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

            remainNomenclature = {
              'name': res['productNameFull'],
              'count': res['count'],
              'code': res['productCode'],
              'result': true,
              'answerSrv': res['error']
            };
          } else {
            remainNomenclature = {
              'name': '',
              'count': '',
              'result': false,
              'answerSrv': 'Не соединения с сервером, не 200 код!'
            };
          }
        }).timeout(const Duration(minutes: 1));
      } catch (e) {
        //print(e);
        remainNomenclature = {
          'name': '',
          'count': '',
          'result': false,
          'answerSrv': 'Сервер 1с не доступен'
        };
      }
    } else {
      remainNomenclature = {
        'name': '',
        'count': '',
        'result': false,
        'answerSrv': 'Не заполнены настройки соединения'
      };
    }
    return remainNomenclature;
  }

  getProductsReport(dateStart, dateEnd) async {
    Map productReports = {};
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
            '/copy-upp-api/hs/storage/getProductsReport');
      } else if (addrServer.substring(0, 4) == 'http') {
        url = Uri.http(addrServer.replaceFirst('http://', ''),
            '/copy-upp-api/hs/storage/getProductsReport');
      } else {
        productReports = {
          'name': '',
          'count': '',
          'result': false,
          'answerSrv': 'Не верный адрес сервера!'
        };
        //print('error');
        //return RemainNomenclature;
      }

      try {
        //print('{"DateStart":$dateStart,"DateEnd":$dateEnd}');
        Map body = {"DateStart": dateStart, "DateEnd": dateEnd};

        String jsonBody = jsonEncode(body);

        final response = await http.post(url,
            //body: '{"DateStart":$dateStart,"DateEnd":$dateEnd}',
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

            productReports = res;
          } else {
            productReports = {
              'name': '',
              'count': '',
              'result': false,
              'answerSrv': 'Не соединения с сервером, не 200 код!'
            };
          }
        }).timeout(const Duration(minutes: 1));
      } catch (e) {
        print(e);
        productReports = {
          'name': '',
          'count': '',
          'result': false,
          'answerSrv': 'Сервер 1с не доступен'
        };
        return productReports;
      }
    } else {
      productReports = {
        'name': '',
        'count': '',
        'result': false,
        'answerSrv': 'Не заполнены настройки соединения'
      };
    }
    //List pl = productReports['ProductionShiftReport'];

    if (productReports['ProductionShiftReport'].length == 0) {
      //print('0');
      listProductOrders.clear();
      listTEC.clear();
      listNode.clear();
    }

    listProductOrders.clear();
    listTEC.clear();
    listNode.clear();

    for (var i in productReports['ProductionShiftReport']) {
      ProductReport productRep = ProductReport(
        number: i['number'],
        data: DateTime.parse(i['date']),
        comment: '',
        productArea: '',
        owner: i['owner'],
        uid: i['uid'],
        status: i['status'],
      );

      for (var nom in i['nomenclatureList']) {
        productRep.nomenclature.add(Nomenclature(
          code: nom['code'],
          name: nom['nomenclatureFullName'],
          count: nom['count'].toString(),
          tEC: TextEditingController(text: nom['count'].toString()),
          fN: FocusNode(),
        ));
      }
      listProductOrders.add(productRep);

      // listProductOrders.add(ProductReport(
      //     number: i['number'],
      //     data: DateTime.parse(i['date']),
      //     comment: '',
      //     productArea: '',
      //     owner: i['owner']));

      //print(i);
      //print(productRepots['ProductionShiftReport'][i]);
    }

    notifyListeners();

    return productReports;
  }
}

class ProductReport {
  DateTime data;
  String number;
  String productArea;
  String comment;
  String owner;
  String uid;
  bool status;
  List<Nomenclature> nomenclature = [];

  ProductReport(
      {required this.data,
      required this.number,
      required this.productArea,
      required this.comment,
      required this.owner,
      required this.uid,
      required this.status});
}

class Nomenclature {
  String code;
  //String barcode;

  String name;
  String count;
  TextEditingController tEC;
  FocusNode fN;

  Nomenclature(
      {required this.code,
      required this.name,
      required this.count,
      required this.tEC,
      required this.fN});
}
