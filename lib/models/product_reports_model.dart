import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductRepostsModel extends ChangeNotifier {
  List<ProductRepost> listProductOrders = [];

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
          print(response.statusCode);
          //print(utf8.decode(response.bodyBytes));

          if (response.statusCode == 200) {
            print(utf8.decode(response.bodyBytes));
            var body = (utf8.decode(response.bodyBytes));

            Map<String, dynamic> res = jsonDecode(body);

            print(body);

            remainNomenclature = {
              'name': res['productNameFull'],
              'count': res['count'],
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
        });
      } catch (e) {
        print(e);
        remainNomenclature = {
          'name': '',
          'count': '',
          'result': false,
          'answerSrv': 'Не соединения с сервером'
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

  getProductsReport() async {
    Map productRepots = {};
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
        productRepots = {
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
            body:
                '{"DateStart":"2021-10-01T00:00:00","DateEnd":"2021-11-01T00:00:00"}',
            headers: <String, String>{
              'authorization': basicAuth
            }).then((response) {
          print(response.statusCode);
          //print(utf8.decode(response.bodyBytes));

          if (response.statusCode == 200) {
            print(utf8.decode(response.bodyBytes));
            var body = (utf8.decode(response.bodyBytes));

            Map<String, dynamic> res = jsonDecode(body);

            print(body);

            productRepots = res;
          } else {
            productRepots = {
              'name': '',
              'count': '',
              'result': false,
              'answerSrv': 'Не соединения с сервером, не 200 код!'
            };
          }
        });
      } catch (e) {
        print(e);
        productRepots = {
          'name': '',
          'count': '',
          'result': false,
          'answerSrv': 'Не соединения с сервером'
        };
      }
    } else {
      productRepots = {
        'name': '',
        'count': '',
        'result': false,
        'answerSrv': 'Не заполнены настройки соединения'
      };
    }
    for (var i in productRepots['ProductionShiftReport']) {
      listProductOrders.add(ProductRepost(
          number: i['number'],
          data: DateTime.parse(i['date']),
          comment: '',
          productArea: '',
          owner: i['owner']));
      print(i);
      //print(productRepots['ProductionShiftReport'][i]);
    }

    notifyListeners();

    return productRepots;
  }
}

class ProductRepost {
  DateTime data;
  String number;
  String productArea;
  String comment;
  String owner;
  List<Nomenclature> nomenclature = [];

  ProductRepost(
      {required this.data,
      required this.number,
      required this.productArea,
      required this.comment,
      required this.owner});
}

class Nomenclature {
  String barcode;
  String name;
  String count;

  Nomenclature(
      {required this.barcode, required this.name, required this.count});
}
