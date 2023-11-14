import 'dart:async';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:laser_scanner/laser_scanner.dart';
import 'package:laser_scanner/model/scan_result_model.dart';
import 'package:laser_scanner/utils/enum_utils.dart';
import 'package:provider/provider.dart';
import 'package:tvintos_warehouse/models/product_reports_model.dart';
import 'package:tvintos_warehouse/models/report_model.dart';
import 'package:tvintos_warehouse/pages/report_page.dart';
import 'package:tvintos_warehouse/widgets/drawer_main_menu.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
//import 'package:audioplayers/audioplayers.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

//import 'dart:convert';
import 'package:intl/intl.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final ScrollController scrollController = ScrollController();
  final _laserScannerPlugin = LaserScanner();

  ScanResultModel scanResultModel = ScanResultModel();

  StreamSubscription? subscription;

  void scrollDown() {
    SchedulerBinding.instance?.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });
  }

  _returnFromReport() async {
    //print('object');
    isProcessed = true;
    String dateStart = DateTime.now()
        .subtract(const Duration(hours: 24 * 1))
        .toIso8601String()
        .substring(0, 19);
    String dateEnd = DateTime.now().toIso8601String().substring(0, 19);

    setState(() {});
    await context
        .read<ProductReportsModel>()
        .getProductsReport(dateStart, dateEnd);
    isProcessed = false;
    setState(() {});
    scrollDown();
    //super.initState();
  }

  bool hasConnection = false;

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

  DateTimeRange dateRange = DateTimeRange(
      start: DateTime.now(),
      end: DateTime.now().add(const Duration(hours: 24 * 3)));
  bool isProcessed = false;
  var _code;
  var _name;
  var _count;
  //static const EventChannel _eventChannel = EventChannel('flutter_barcode_scanner_receiver');

  int selectedIndex = 0;

  DateTimeRange _dataTime = DateTimeRange(
      start: DateTime.now(),
      end: DateTime.now().add(const Duration(hours: 24 * 3)));
  DateFormat formatterR = DateFormat('dd-MM-yyyy');
  String _value = DateTime.now().toString();
  // TextEditingController _contrDateField =
  //     TextEditingController(text: DateTime.now().toString().substring(0, 10));
  final TextEditingController _contrDateField = TextEditingController(
      text: DateTime.now()
              .subtract(const Duration(hours: 24 * 1))
              .toIso8601String()
              .substring(0, 10) +
          '  -  ' +
          DateTime.now().toIso8601String().substring(0, 10));
  Future _selectDate() async {
    final _initialDateRange = DateTimeRange(
        end: DateTime.now(),
        start: DateTime.now().subtract(const Duration(hours: 24)));
    final picked = await showDateRangePicker(
        context: context,
        locale: const Locale("ru", "RU"),
        //initialDate: new DateTime.now(),
        firstDate: DateTime(DateTime.now().year - 5),
        lastDate: DateTime(DateTime.now().year + 3),
        initialDateRange: _initialDateRange);

    if (picked != null) {
      isProcessed = true;

      setState(() {});

      String dateStart = picked.start.toIso8601String().substring(0, 19);
      String dateEnd = picked.end.toIso8601String().substring(0, 19);
      Map res = await context
          .read<ProductReportsModel>()
          .getProductsReport(dateStart, dateEnd);

      //print(res);
      isProcessed = false;

      scrollDown();
      if (res['result'] == false) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Column(
                  children: [
                    Text(res['answerSrv']),
                  ],
                ),
                //content: Text('Наименование: $name'),
              );
            });

        //   return;
      }

      setState(() {
        //print('set state');

        _dataTime = picked;
        _value = picked.toString();
        String _start = picked.start.toIso8601String().substring(0, 10);
        String _end = picked.end.toIso8601String().substring(0, 10);
        _contrDateField.text = _start + '  -  ' + _end;
      });
    }
  }

  // @override
  // void didChangeDependencies() {

  //   //subscription == null? _openScanner():null;
  //   if(subscription == null){
  //     _openScanner();
  //   }else{
  //     print('object');
  //   }

  //   super.didChangeDependencies();
  // }

  @override
  void initState() {
    final StreamSubscription<InternetConnectionStatus> listener =
        InternetConnectionChecker().onStatusChange.listen(
      (InternetConnectionStatus status) {
        switch (status) {
          case InternetConnectionStatus.connected:
            // ignore: avoid_print
            AdaptiveTheme.of(context).setLight();
            hasConnection = true;

            break;
          case InternetConnectionStatus.disconnected:
            // ignore: avoid_print
            AdaptiveTheme.of(context).setDark();
            hasConnection = false;

            break;
        }
      },
    );

    String dateStart = DateTime.now()
        .subtract(const Duration(hours: 24 * 1))
        .toIso8601String()
        .substring(0, 19);
    String dateEnd = DateTime.now().toIso8601String().substring(0, 19);

    isProcessed = true;
    setState(() {});
    context.read<ProductReportsModel>().getProductsReport(dateStart, dateEnd);
    isProcessed = false;

    setState(() {});

    scrollDown();
    super.initState();
    _openScanner();
  }

  @override
  void dispose() {
    scrollController.dispose();
    subscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          // hasConnection
          //     ? const Icon(Icons.signal_wifi_4_bar)
          //     : const Icon(Icons.not_interested),
          IconButton(
              onPressed: () async {
                await scanBarcodeNormal();
                isProcessed = true;
                setState(() {});
                Map result = await context
                    .read<ProductReportsModel>()
                    .getRemainNomenclature(_scanBarcode);

                String name = result['name'];
                //print(name);
                String count = result['count'].toString();
                // bool error = result['error'];
                // String errorText = result['errorText'];
                isProcessed = false;
                setState(() {});

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

                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 5.0),
                              child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      border: Border.all(
                                          width: 3, color: Colors.green)),
                                  child: Text('Код: $_scanBarcode')),
                            ),

                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 5.0),
                              child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      border: Border.all(
                                          width: 3, color: Colors.green)),
                                  child: Text('Наименование: $name')),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 5.0),
                              child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      border: Border.all(
                                          width: 3, color: Colors.green)),
                                  child: Text('Количество: $count')),
                            ),
                            //error ? Text(errorText) : SizedBox(),
                          ],
                        ),
                        //content: Text('Наименование: $name'),
                      );
                    });
              },
              icon: const Icon(Icons.local_see)),
        ],
        title: const Text("Склад"),
      ),
      drawer: const DraiwerMainMenu(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          //playSound();
          context.read<ReportModel>().clearModel();
          //dispose();
          subscription?.cancel();
          Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const ReportPage()))
              .then((value) {
                _openScanner();
            _returnFromReport();
          });
        },
      ),
      body: isProcessed
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Expanded(
                    flex: 2,
                    child: Center(
                      child: TextFormField(
                        controller: _contrDateField,
                        readOnly: true,
                        //initialValue: DateTime.now().toString(),onTap: _selectDate,)),
                        onTap: _selectDate,
                        //initialValue: _value,
                      ),
                    )),
                Expanded(
                  flex: 20,
                  child: ListView.separated(
                      controller: scrollController,
                      separatorBuilder: (BuildContext context, int index) =>
                          const Divider(
                            thickness: 3,
                            color: Colors.blue,
                          ),
                      itemCount: context
                          .watch<ProductReportsModel>()
                          .listProductOrders
                          .length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            context.read<ReportModel>().listNomenclature =
                                context
                                    .read<ProductReportsModel>()
                                    .listProductOrders[index]
                                    .nomenclature;

                            context.read<ReportModel>().uid = context
                                .read<ProductReportsModel>()
                                .listProductOrders[index]
                                .uid;
                            context.read<ReportModel>().code = context
                                .read<ProductReportsModel>()
                                .listProductOrders[index]
                                .number;
                            context.read<ReportModel>().division = context
                                .read<ProductReportsModel>()
                                .listProductOrders[index]
                                .division;
                            context.read<ReportModel>().comment = context
                                .read<ProductReportsModel>()
                                .listProductOrders[index]
                                .comment;
                            DateTime dt = context
                                .read<ProductReportsModel>()
                                .listProductOrders[index]
                                .data;

                            DateFormat dateFormat = DateFormat('dd-MM-y');
                            context.read<ReportModel>().date =
                                dateFormat.format(dt);

                            // context.read<ReportModel>().listCtr =
                            //     context.read<ProductReportsModel>().listTEC;
                            // context.read<ReportModel>().listNode =
                            //     context.read<ProductReportsModel>().listNode;

                            Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ReportPage()))
                                .then((value) => _returnFromReport());
                          },
                          child: Row(
                            children: [
                              Container(
                                  child: context
                                          .watch<ProductReportsModel>()
                                          .listProductOrders[index]
                                          .status
                                      ? const Icon(
                                          Icons.done_outline,
                                          color: Colors.green,
                                          size: 20,
                                        )
                                      : const SizedBox(
                                          width: 20,
                                        )),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: Container(
                                  height: 30,
                                  width: MediaQuery.of(context).size.width /
                                      100 *
                                      30,
                                  child: Text(
                                    context
                                        .watch<ProductReportsModel>()
                                        .listProductOrders[index]
                                        .number,
                                    //maxLines: 2,
                                  ),
                                ),
                              ),
                              Container(
                                height: 30,
                                width: MediaQuery.of(context).size.width /
                                    100 *
                                    30,
                                child: Text(context
                                    .watch<ProductReportsModel>()
                                    .listProductOrders[index]
                                    .data
                                    .toString()
                                    .substring(0, 16)),
                              ),
                              SizedBox(
                                height: 30,
                                width: MediaQuery.of(context).size.width /
                                    100 *
                                    30,
                                child: Text(
                                  context
                                      .watch<ProductReportsModel>()
                                      .listProductOrders[index]
                                      .owner,
                                  maxLines: 3,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                ),
              ],
            ),
    );
  }

  buildShowDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
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
      print(temp);
      Map result = await context
          .read<ProductReportsModel>()
          .getRemainNomenclature(scanResultModel.barcode);

      String name = result['name'];
      //print(name);
      String count = result['count'].toString();
      // bool error = result['error'];
      // String errorText = result['errorText'];
      isProcessed = false;
      setState(() {});

      if (result['code'] == '') {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return const AlertDialog(
                title: Column(
                  children: [
                    Text('Ошибка!', style: TextStyle(color: Colors.red)),
                    Divider(
                      thickness: 2,
                    ),
                    Text('Номенклатура с данным штрихкодом не найдена в базе!'),
                  ],
                ),
                //content: Text('Наименование: $name'),
              );
            });

        return;
      }

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(width: 3, color: Colors.green)),
                        child: Text('Код: ${scanResultModel.barcode}')),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(width: 3, color: Colors.green)),
                        child: Text('Наименование: $name')),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(width: 3, color: Colors.green)),
                        child: Text('Количество: $count')),
                  ),
                  //error ? Text(errorText) : SizedBox(),
                ],
              ),
              //content: Text('Наименование: $name'),
            );
          });

      // setState(() {
      //   _code = value;
      // });

      _laserScannerPlugin.stopDecode();
    });
  }
}

class Circ extends StatefulWidget {
  const Circ(BuildContext context, {Key? key}) : super(key: key);

  @override
  State<Circ> createState() => _CircState();
}

class _CircState extends State<Circ> {
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
