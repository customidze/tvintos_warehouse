import 'package:flutter/material.dart';
import 'package:tvintos_warehouse/models/product_reports_model.dart';

class ReportModel extends ChangeNotifier {
  String date = '';
  String code = '';
  bool status = false;

  List<Nomenclature> listNomenclature = [];
}
