import 'package:flutter/material.dart';

class Check extends StatefulWidget {
  final bool? value;
  final ValueChanged<bool>? onChanged;
  const Check({ Key? key,  this.value,  this.onChanged}) : super(key: key);
  @override
  _CheckState createState() => _CheckState();
}

class _CheckState extends State<Check> {
  bool? min;
  @override
  Widget build(BuildContext context) {
    if (min == null) min = widget.value;
    return Checkbox(
      value: min,
      onChanged: (value) {
        min = value;
        widget.onChanged!(min!);
        setState(() {});
      },
    );
  }
}
