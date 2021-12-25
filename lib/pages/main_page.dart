import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tvintos_warehouse/models/product_reports_model.dart';
import 'package:tvintos_warehouse/widgets/drawer_main_menu.dart';

//import 'dart:convert';
import 'package:intl/intl.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  DateTimeRange dateRange = DateTimeRange(
      start: DateTime.now(), end: DateTime.now().add(Duration(hours: 24 * 3)));
  bool isProcessed = false;
  var _code;
  var _name;
  var _count;
  static const EventChannel _eventChannel = EventChannel('neo.com/app');

  int selectedIndex = 0;

  DateTimeRange _dataTime = DateTimeRange(
      start: DateTime.now(), end: DateTime.now().add(Duration(hours: 24 * 3)));
  DateFormat formatterR = DateFormat('dd-MM-yyyy');
  String _value = DateTime.now().toString();
  // TextEditingController _contrDateField =
  //     TextEditingController(text: DateTime.now().toString().substring(0, 10));
  final TextEditingController _contrDateField = TextEditingController(
      text: DateTime.now()
              .subtract(Duration(hours: 24 * 1))
              .toIso8601String()
              .substring(0, 10) +
          '  -  ' +
          DateTime.now().toIso8601String().substring(0, 10));
  Future _selectDate() async {
    final initialDateRange = DateTimeRange(
        start: DateTime.now(),
        end: DateTime.now().add(Duration(hours: 24 * 3)));
    final picked = await showDateRangePicker(
        context: context,
        locale: const Locale("ru", "RU"),
        //initialDate: new DateTime.now(),
        firstDate: DateTime(DateTime.now().year - 5),
        lastDate: DateTime(DateTime.now().year + 3),
        initialDateRange: dateRange ?? initialDateRange);

    if (picked != null) {
      isProcessed = true;

      setState(() {});

      String dateStart = picked.start.toIso8601String().substring(0, 19);
      String dateEnd = picked.end.toIso8601String().substring(0, 19);
      await context
          .read<ProductRepostsModel>()
          .getProductsReport(dateStart, dateEnd);

      isProcessed = false;

      setState(() {
        //print('set state');

        _dataTime = picked;
        _value = picked.toString();
        // String _start = picked.toString().substring(0, 11);
        // String _end = picked.toString().substring(25, 37);
        String _start = picked.start.toIso8601String().substring(0, 10);
        String _end = picked.end.toIso8601String().substring(0, 10);

        _contrDateField.text = _start + '  -  ' + _end;
        //_contrDateField.text = picked.toString().substring(0, 49);
      });
    }
    ;
  }

  @override
  void initState() async {
    // DateTime.now()
    //           .subtract(Duration(hours: 24 * 1))
    //           .toIso8601String()
    //           .substring(0, 10) +
    //       '  -  ' +
    //       DateTime.now().toIso8601String().substring(0, 10)
    String dateStart = DateTime.now()
        .subtract(Duration(hours: 24 * 1))
        .toIso8601String()
        .substring(0, 19);
    String dateEnd = DateTime.now().toIso8601String().substring(0, 19);

    isProcessed = true;
    setState(() {});
    await context
        .read<ProductRepostsModel>()
        .getProductsReport(dateStart, dateEnd);
    isProcessed = false;
    setState(() {});
    super.initState();

    _eventChannel.receiveBroadcastStream().listen((value) async {
      //var v = buildShowDialog(context);
      if (isProcessed) {
        // ignore: avoid_returning_null_for_void
        return null;
      }
      isProcessed = true;

      setState(() {});

      Map result = await context
          .read<ProductRepostsModel>()
          .getRemainNomenclature(value);

      String name = result['name'];
      //print(name);
      String count = result['count'].toString();
      // bool error = result['error'];
      // String errorText = result['errorText'];
      isProcessed = false;
      setState(() {});
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
                        child: Text('Код: $value')),
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
    });
  }

  @override
  Widget build(BuildContext context) {
    void onTapHandler(int index) {
      this.setState(() {
        this.selectedIndex = index;
        print(this.selectedIndex);
      });
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                isProcessed = !isProcessed;
                //context.read<ProductRepostsModel>().getProductsReport();
                // Future circ = buildShowDialog(context);
                // print('konec');
                //Widget circ = Circ(context);
                //circ.
                // //await Future.delayed(const Duration(milliseconds: 50), () {
                // // Here you can write your code

                setState(() {
                  // Here you can write your code for open new view
                  //  });
                });
              },
              icon: Icon(Icons.refresh)),
        ],
        title: Text("Склад"),
      ),
      drawer: const DraiwerMainMenu(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {},
      ),
      body: isProcessed
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Expanded(
                    flex: 1,
                    child: Container(
                      child: Center(
                        child: TextFormField(
                          controller: _contrDateField,
                          readOnly: true,
                          //initialValue: DateTime.now().toString(),onTap: _selectDate,)),
                          onTap: _selectDate,
                          //initialValue: _value,
                        ),
                      ),
                    )),
                Expanded(
                  flex: 20,
                  child: ListView.separated(
                      separatorBuilder: (BuildContext context, int index) =>
                          const Divider(
                            thickness: 3,
                            color: Colors.blue,
                          ),
                      itemCount: context
                          .watch<ProductRepostsModel>()
                          .listProductOrders
                          .length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {},
                          child: Row(
                            children: [
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
                                        .watch<ProductRepostsModel>()
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
                                    .watch<ProductRepostsModel>()
                                    .listProductOrders[index]
                                    .data
                                    .toString()
                                    .substring(0, 16)),
                              ),
                              Container(
                                height: 30,
                                width: MediaQuery.of(context).size.width /
                                    100 *
                                    30,
                                child: Text(
                                  context
                                      .watch<ProductRepostsModel>()
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
          return Center(
            child: CircularProgressIndicator(),
          );
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
    return Center(child: CircularProgressIndicator());
  }
}
