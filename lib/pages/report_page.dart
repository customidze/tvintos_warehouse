import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

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
  late AnimationController controller;
  late Animation<Size> animation;
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
    )
  ];

  // _ReportPageState() {
  //   List<Map<String, String>> listDivision = [
  //     {
  //       '000000053': 'Производственный участок №1',
  //       '000000046': 'Производственный участок №2',
  //       '000000057': 'Производственный участок №3'
  //     }
  //   ];

  //   listDivision.map((items) {
  //     items.cast().forEach((key, value) {
  //       listDMI.add(DropdownMenuItem(child: Text(value), value: key));
  //     });
  //   });
  // }

  bool isProcessed = false;
  void playSound() {
    final player = AudioCache();
    player.play('audio/zvuk41.mp3');
  }

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

  // final List<TextEditingController> _controllers = [];
  // final List<FocusNode> _nodes = [];

  static const EventChannel _eventChannel = EventChannel('it-apriori.ru');

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Object selectedDivision = '000000071';
    Object selectedDivision = context.read<ReportModel>().division;
    //_controllers.clear();
    //_nodes.clear();
    return Scaffold(
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
                        return AlertDialog(
                          title: Column(
                            children: const [
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
                      children: [
                        AnimatedBuilder(
                            animation: animation,
                            builder: (ctx, ch) {
                              return Container(
                                color: Colors.red,
                                width: animation.value.width,
                                height: animation.value.height,
                                //child: Text('11'),
                              );
                            }),

                        // SizedBox(
                        //     // height: 15,
                        //     // width: 90,
                        //     //height: animationHi.value,
                        //     //width: animationWe.value,
                        //     child: FadeTransition(
                        //         opacity: animation,
                        //         child: Text(context.read<ReportModel>().code))),
                        Text('Дата')
                      ],
                    )),
                DropdownButton(
                    hint: const Text('Выберите подразделение'),
                    value: selectedDivision != '' ? selectedDivision : null,
                    items: listDMI,
                    onChanged: (newValue) {
                      print(newValue);
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
                      // _controllers.add(TextEditingController(
                      //     text: context
                      //         .read<ReportModel>()
                      //         .listNomenclature[index]
                      //         .count));
                      //_nodes.add(FocusNode());
                      return Slidable(
                        actionPane: const SlidableDrawerActionPane(),
                        secondaryActions: [
                          IconSlideAction(
                            caption: 'Удалить',
                            color: Colors.red,
                            icon: Icons.delete,
                            onTap: () {
                              //_controllers[index].dispose();
                              //var i = _controllers.removeAt(index);
                              //i.clear();
                              //i.dispose();
                              //_nodes.removeAt(index);
                              //_controllers.clear();
                              //_nodes.clear();
                              context
                                  .read<ReportModel>()
                                  .deleteNomenclature(index);

                              //_nodes[index].dispose();
                            },
                          )
                        ],
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
                              playSound();
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
                              playSound();
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

      context.read<ReportModel>().addNomenclature(code, name);

      isProcessed = false;
    });

    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    animation = Tween<Size>(begin: const Size(95, 15), end: const Size(150, 40))
        .animate(CurvedAnimation(parent: controller, curve: Curves.bounceIn));

    controller.addStatusListener((AnimationStatus status) {
      print(status);
      if (status == AnimationStatus.completed) {
        print(status);
        controller.repeat();
      }
    });
  }

  fnActive(index) {
    FocusScope.of(context)
        .requestFocus(context.read<ReportModel>().listNomenclature[index].fN);

    // int count = int.parse(_controllers[index].text) + 1;
    // _controllers[index].text = count.toString();
    // if (index == _controllers.length - 1) {
    //   _controllers[index].text = '1';
    // }
    // _nodes[index].requestFocus();
  }
}
