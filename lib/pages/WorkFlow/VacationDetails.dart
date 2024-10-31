import 'package:alpha/GeneralFiles/General.dart';
import 'package:alpha/models/Modules.dart';
import 'package:flutter/material.dart';

class VacationDetails extends StatefulWidget {
  final List<Map<String, dynamic>> data; // Specify the expected type here
  final WorkFlowRecord log;

  const VacationDetails({Key? key, required this.data, required this.log}) : super(key: key);

  @override
  State<VacationDetails> createState() => _VacationDetailsState();
}

class _VacationDetailsState extends State<VacationDetails> {
  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> data = widget.data;

    if (data.isEmpty) {
      return Text(arEn('خطأ أثناء تحميل التفاصيل', 'Error while loading details'));
    }

    // Assuming you want to display details for the first entry
    var firstEntry = data[0];

    return Column(
      children: [
        for (var entry in firstEntry.entries) // Accessing entries of the first entry
          Row(
            children: [
              Text('${entry.key} : ${entry.value}'),
            ],
          ),
      ],
    );
  }
}
