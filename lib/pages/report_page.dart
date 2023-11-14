//import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:laser_scanner/laser_scanner.dart';
import 'package:laser_scanner/model/scan_result_model.dart';
import 'package:laser_scanner/utils/enum_utils.dart';

import 'package:provider/provider.dart';
import 'package:tvintos_warehouse/models/product_reports_model.dart';
import 'package:tvintos_warehouse/models/report_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({Key? key}) : super(key: key);

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage>
    with SingleTickerProviderStateMixin {
  // late AnimationController controller;
  // late Animation<Size> animation;
  //late Animation<double> animationWe;

  List<DropdownMenuItem<dynamic>> listDMI = [
    const DropdownMenuItem(
      child: Text('Производственный участок №1'),
      value: '000000072',
    ),
    const DropdownMenuItem(
      child: Text('Производственный участок №2'),
      value: '000000071',
    ),
    const DropdownMenuItem(
      child: Text('Производственный участок №3'),
      value: '000000078',
    ),
    const DropdownMenuItem(
      child: Text('Производственный участок №4'),
      value: '000000099',
    )
  ];

  bool isProcessed = false;

  String _scanBarcode = 'Unknown';

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      //print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });
  }

  final _laserScannerPlugin = LaserScanner();

  ScanResultModel scanResultModel = ScanResultModel();

  StreamSubscription? subscription;

  @override
  void dispose() {
    //controller.dispose();
    subscription?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    //Object selectedDivision = '000000071';
    Object selectedDivision = context.read<ReportModel>().division;
    //_controllers.clear();
    //_nodes.clear();
    return WillPopScope(
      onWillPop: (){
        subscription?.cancel();
        return Future.value(true);

      },
      child: Scaffold(
        appBar: AppBar(
          actions: [
            // IconButton(
            //     onPressed: () {
    
            //     },
            //     icon: Icon(Icons.nat_sharp)),
            IconButton(
                onPressed: () async {
                  await scanBarcodeNormal();
                  if (_scanBarcode == '-1') {
                    return;
                  }
    
                  Map result = await context
                      .read<ProductReportsModel>()
                      .getRemainNomenclature(_scanBarcode);
    
                  if (result['result'] == false) {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Column(
                              children: [
                                const Text('Ошибка!',
                                    style: TextStyle(color: Colors.red)),
                                const Divider(
                                  thickness: 2,
                                ),
                                Text(result['answerSrv']),
                              ],
                            ),
                            //content: Text('Наименование: $name'),
                          );
                        });
    
                    return;
                  }
    
                  if (result['code'] == '') {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const AlertDialog(
                            title: Column(
                              children: [
                                Text('Ошибка!',
                                    style: TextStyle(color: Colors.red)),
                                Divider(
                                  thickness: 2,
                                ),
                                Text(
                                    'Номенклатура с данным штрихкодом не найдена в базе!'),
                              ],
                            ),
                            //content: Text('Наименование: $name'),
                          );
                        });
    
                    return;
                  }
    
                  String name = result['name'];
                  String code = result['code'];
                  //String count = result['count'].toString();
    
                  int indexListNomenclature =
                      context.read<ReportModel>().addNomenclature(code, name);
    
                  int lengthNomen =
                      context.read<ReportModel>().listNomenclature.length;
    
                  //setState(() {});
                  fnActive(indexListNomenclature);
                },
                icon: const Icon(Icons.local_see))
          ],
          title: const Text('Отчет'),
        ),
        body: isProcessed
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  Expanded(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [Text(context.read<ReportModel>().date)],
                      )),
                  DropdownButton<dynamic>(
                      borderRadius: BorderRadius.circular(10),
                      hint: const Text('Выберите подразделение'),
                      value: selectedDivision != '' ? selectedDivision : null,
                      items: listDMI,
                      onChanged: (newValue) {
                        context.read<ReportModel>().division =
                            newValue.toString();
                        setState(() {
                          selectedDivision = newValue.toString();
                        });
                      }),
                  const Divider(
                    thickness: 3,
                  ),
                  Expanded(
                    flex: 10,
                    child: ListView.separated(
                      itemCount:
                          context.watch<ReportModel>().listNomenclature.length,
                      itemBuilder: (context, index) {
                        return Slidable(
                          child: Row(
                            children: [
                              Expanded(
                                flex: 5,
                                child: Text(context
                                    .watch<ReportModel>()
                                    .listNomenclature[index]
                                    .name),
                              ),
                              Expanded(
                                  flex: 1,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      //color: Colors.grey,
    
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          width: 2, color: Colors.grey),
                                    ),
                                    child: TextField(
                                      textAlign: TextAlign.center,
                                      decoration: const InputDecoration.collapsed(
                                          hintText: null,
                                          border: InputBorder.none),
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true),
                                      inputFormatters: <TextInputFormatter>[
                                        // FilteringTextInputFormatter.allow(
                                        //     RegExp(r"[0-9.]")),
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      focusNode: context
                                          .read<ReportModel>()
                                          .listNomenclature[index]
                                          .fN,
                                      //.listNode[index],
                                      controller: context
                                          .read<ReportModel>()
                                          .listNomenclature[index]
                                          .tEC,
                                      //.listCtr[index],
                                      onChanged: (count) {
                                        context
                                            .read<ReportModel>()
                                            .listNomenclature[index]
                                            .count = count;
                                        // context
                                        //     .read<ReportModel>()
                                        //     .listCtr[index]
                                        //     .text = count;
                                      },
                                    ),
                                  )),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => const Divider(
                        thickness: 3,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const Divider(
                    thickness: 3,
                  ),
                  Expanded(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                              onPressed: () async {
                                isProcessed = true;
                                setState(() {});
                                //playSound();
                                await context
                                    .read<ReportModel>()
                                    .saveReportIn1c(false);
                                isProcessed = false;
                                setState(() {});
                                Navigator.pop(context, true);
                              },
                              child: const Text('Записать')),
                          TextButton(
                              onPressed: () async {
                                isProcessed = true;
                                setState(() {});
                                //playSound();
                                await context
                                    .read<ReportModel>()
                                    .saveReportIn1c(true);
                                setState(() {});
                                Navigator.pop(context);
                              },
                              child: const Text('Провести'))
                        ],
                      ))
                ],
              ),
      ),
    );
  }

  @override
  void initState() {
 

    super.initState();
    _openScanner();
  }

  fnActive(index) {
    FocusScope.of(context)
        .requestFocus(context.read<ReportModel>().listNomenclature[index].fN);
  }

  Future<void> _openScanner() async {
    await _laserScannerPlugin.openScanner(
      captureImageShow: true,
    );
    _setTrigger();
    _getTrigger();
    await onListenerScanner();
  }

  void _setTrigger() {
    _laserScannerPlugin.setTrigger(triggering: Triggering.HOST);
  }

  void _getTrigger() async {
    await _laserScannerPlugin.getTriggerMode();
  }

  Future<void> onListenerScanner() async {
    subscription = await _laserScannerPlugin.onListenerScanner(
        onListenerResultScanner: (value) async {
      scanResultModel = value ?? ScanResultModel();

      var temp = scanResultModel.barcode;

      isProcessed = true;

      setState(() {});

      Map result = await context
          .read<ProductReportsModel>()
          .getRemainNomenclature(scanResultModel.barcode);

      String name = result['name'];
      //print(name);
      String count = result['count'].toString();
      String code = result['code'];

      context.read<ReportModel>().addNomenclature(code, name);

      isProcessed = false;

      _laserScannerPlugin.stopDecode();
    });
  }
}
