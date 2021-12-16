import 'package:flutter/material.dart';

class ProductRepostsModel extends ChangeNotifier {
  List<ProductRepost> listProductOrders = [];
}

class ProductRepost {
  DateTime data;
  String number;
  String productArea;
  String comment;
  List<Nomenclature> nomenclature = [];

  ProductRepost(
      {required this.data,
      required this.number,
      required this.productArea,
      required this.comment});
}

class Nomenclature {
  String barcode;
  String name;
  String count;

  Nomenclature(
      {required this.barcode, required this.name, required this.count});
}
