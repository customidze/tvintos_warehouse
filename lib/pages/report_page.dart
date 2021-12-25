import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tvintos_warehouse/models/report_model.dart';

class ReportPage extends StatefulWidget {
  const ReportPage(int index, {Key? key}) : super(key: key);

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  List<TextEditingController> _controllers = [];
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
        title: const Text('Отчет'),
      ),
      body: Column(
        children: [
          Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [Text('Номер'), Text('Дата')],
              )),
          Divider(
            thickness: 3,
          ),
          Expanded(
            flex: 10,
            child: ListView.separated(
              itemCount: context.watch<ReportModel>().listNomenclature.length,
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
                  TextButton(onPressed: () {}, child: const Text('Записать')),
                  TextButton(onPressed: () {}, child: const Text('Провести'))
                ],
              ))
        ],
      ),
    );
  }
}
