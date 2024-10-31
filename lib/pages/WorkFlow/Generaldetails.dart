import 'package:alpha/GeneralFiles/General.dart';
import 'package:alpha/models/Modules.dart';
import 'package:flutter/material.dart';

class GeneralDetails extends StatefulWidget {
  final List<Map<String, dynamic>> data; // Specify the type here
  final WorkFlowRecord log;

  const GeneralDetails({Key? key, required this.data, required this.log}) : super(key: key);

  @override
  State<GeneralDetails> createState() => _GeneralDetailsState();
}

class _GeneralDetailsState extends State<GeneralDetails> {
  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> data = widget.data;

    if (data.isEmpty) {
      return Text(arEn('خطأ أثناء تحميل التفاصيل', 'Error while loading details'));
    }

    return Column(
      children: [
        for (var entry in data[0].entries) // Ensure data[0] exists
          Row(
            children: [
              Text('${entry.key} : ${entry.value}'),
            ],
          ),
      ],
    );
  }
}
