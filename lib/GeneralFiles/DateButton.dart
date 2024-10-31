import 'package:flutter/material.dart'; 

import 'package:alpha/GeneralFiles/Button.dart';
import 'package:alpha/GeneralFiles/General.dart';

// ignore: must_be_immutable
class DateButton extends StatefulWidget {
  final DateTime? date;
  final String? text;
  final Color? color;
  final ValueChanged<DateTime>? onchange;

  const DateButton({
    Key? key,
    this.color,
    this.date,
    this.text,
    this.onchange,
  }) : super(key: key);

  @override
  _DateButtonState createState() => _DateButtonState();
}

class _DateButtonState extends State<DateButton> {
  DateTime? x;

  @override
  Widget build(BuildContext context) {
    // Initialize x if it's null
    if (x == null) x = widget.date;

    return Button(
      text: x == null ? widget.text! : dateFormat.format(x!),
      onPressed: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: widget.date ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
        
        // Check if the picked date is different from the current date
        if (picked != null && picked != widget.date) {
          setState(() {
            x = picked; // Update the local date variable
            // Call onchange if it's not null
            if (widget.onchange != null) {
              widget.onchange!(picked);
            }
          });
        }
      },
    );
  }
}
