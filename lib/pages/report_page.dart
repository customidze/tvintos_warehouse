import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:provider/provider.dart';
import 'package:tvintos_warehouse/models/product_reports_model.dart';
import 'package:tvintos_warehouse/models/report_model.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({Key? key}) : super(key: key);

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
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

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });
  }

  List<TextEditingController> _controllers = [];
  bool isProcessed = false;
  static const EventChannel _eventChannel = EventChannel('it-apriori.ru');

  @override
  void dispose() {
    for (TextEditingController c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () async {
                await scanBarcodeNormal();

                Map result = await context
                    .read<ProductReportsModel>()
                    .getRemainNomenclature(_scanBarcode);

                String name = result['name'];
                String code = result['code'];
                String count = result['count'].toString();

                context.read<ReportModel>().addNomenclature(code, name);
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
                      children: [Text('Номер'), Text('Дата')],
                    )),
                const Divider(
                  thickness: 3,
                ),
                Expanded(
                  flex: 10,
                  child: ListView.separated(
                    itemCount:
                        context.watch<ReportModel>().listNomenclature.length,
                    itemBuilder: (context, index) {
                      _controllers.add(TextEditingController(
                          text: context
                              .read<ReportModel>()
                              .listNomenclature[index]
                              .count));
                      return Row(
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
                              child: TextField(
                                controller: _controllers[index],
                                onChanged: (count) {
                                  context
                                      .read<ReportModel>()
                                      .listNomenclature[index]
                                      .count = count;
                                },
                              )),
                        ],
                      );
                    },
                    separatorBuilder: (context, index) => const Divider(
                      thickness: 3,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Divider(
                  thickness: 3,
                ),
                Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                            onPressed: () {
                              context.read<ReportModel>().saveReportIn1c(true);
                            },
                            child: const Text('Записать')),
                        TextButton(
                            onPressed: () {
                              context.read<ReportModel>().saveReportIn1c(false);
                            },
                            child: const Text('Провести'))
                      ],
                    ))
              ],
            ),
    );
  }

  @override
  void initState() {
    _eventChannel.receiveBroadcastStream().listen((value) async {
      //var v = buildShowDialog(context);
      if (isProcessed) {
        // ignore: avoid_returning_null_for_void
        return null;
      }
      isProcessed = true;

      setState(() {});

      Map result = await context
          .read<ProductReportsModel>()
          .getRemainNomenclature(value);

      String name = result['name'];
      //print(name);
      String count = result['count'].toString();
      String code = result['productCode'];

      context
          .read<ReportModel>()
          .listNomenclature
          .add(Nomenclature(code: code, name: name, count: '1'));
      // bool error = result['error'];
      // String errorText = result['errorText'];
      isProcessed = false;
      setState(() {});

      // setState(() {
      //   _code = value;
      // });
    });

    super.initState();
  }
}
