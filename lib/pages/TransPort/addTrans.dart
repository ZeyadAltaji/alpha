import 'package:alpha/GeneralFiles/Button.dart';
import 'package:alpha/GeneralFiles/General.dart';
import 'package:alpha/models/Modules.dart';
import 'package:flutter/material.dart';

class AddTransPage extends StatefulWidget {
  final TransDF? df;
  final Function(TransDF)? onSave;
  const AddTransPage({Key? key, this.df, this.onSave}) : super(key: key);

  @override
  State<AddTransPage> createState() => _AddTransPageState();
}

class _AddTransPageState extends State<AddTransPage> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: direction,
      child: Scaffold(
        appBar: appBar(
          title: arEn('قسيمة', 'Coupon'),
          actions: [
            TextButton(
              child: Text(arEn('حفظ', 'Save')),
              style: ButtonStyle(
                backgroundColor:
                    WidgetStateProperty.all<Color>(Colors.transparent),
                overlayColor: WidgetStateProperty.all<Color>(
                    Colors.transparent), //splash
                foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
              ),
              onPressed: () {
                if (widget.df!.city == '') {
                  showSnackBar(
                    context,
                    arEn('يرجى ادخال المدينة', 'Enter city please'),
                  );
                  return;
                }
                if (widget.df!.area == '') {
                  showSnackBar(
                    context,
                    arEn('يرجى ادخال المنطقة', 'Enter area please'),
                  );
                  return;
                }
                if (widget.df!.customer == '') {
                  showSnackBar(
                    context,
                    arEn('يرجى ادخال العميل', 'Enter customer please'),
                  );
                  return;
                }
                if (widget.df!.reason == '') {
                  showSnackBar(
                    context,
                    arEn('يرجى ادخال سبب الزيارة', 'Enter reason please'),
                  );
                  return;
                }
                if (widget.df!.amount == 0) {
                  showSnackBar(
                    context,
                    arEn('يرجى ادخال المبلغ', 'Enter amount please'),
                  );
                  return;
                }
                widget.onSave!(widget.df!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: new Form(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: new Container(
                      child: Row(
                        children: <Widget>[
                          Text('${arEn('التاريخ : ', 'Date : ')}'),
                          Button(
                            onPressed: () {
                              selectDate();
                            },
                            text: selectedDate,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: new Container(
                      child: TextFormField(
                        controller: TextEditingController(text: widget.df!.city),
                        keyboardType: TextInputType.text,
                        onChanged: (val) => widget.df!.city = '$val',
                        decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                            border: OutlineInputBorder(),
                            counterText: "",
                            labelText: '${arEn('المدينة : ', 'City : ')}'),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: new Container(
                      child: TextFormField(
                        controller: TextEditingController(text: widget.df!.area),
                        keyboardType: TextInputType.text,
                        onChanged: (val) => widget.df!.area = '$val',
                        decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                            border: OutlineInputBorder(),
                            counterText: "",
                            labelText: '${arEn('المنطقة : ', 'Area : ')}'),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: new Container(
                      child: TextFormField(
                        controller:
                            TextEditingController(text: widget.df!.customer),
                        keyboardType: TextInputType.text,
                        onChanged: (val) => widget.df!.customer = '$val',
                        decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                            border: OutlineInputBorder(),
                            counterText: "",
                            labelText: '${arEn('العميل : ', 'Customer : ')}'),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: new Container(
                      child: TextFormField(
                        controller:
                            TextEditingController(text: widget.df!.reason),
                        maxLines: 5,
                        keyboardType: TextInputType.text,
                        onChanged: (val) => widget.df!.reason = '$val',
                        decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                            border: OutlineInputBorder(),
                            counterText: "",
                            labelText:
                                '${arEn('سبب الزيارة : ', 'Visit reason : ')}'),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: new Container(
                      child: TextFormField(
                        controller: TextEditingController(
                            text: widget.df!.amount.toString()),
                        keyboardType: TextInputType.number,
                        onChanged: (val) =>
                            widget.df!.amount = double.parse(val.toString()),
                        validator: (val) {
                          if (val == "") val = "0";
                          if (double.parse(val!) <= 0) {
                            return '${arEn('يرجى ادخال قيمة صحيحة', 'Please enter a valid value')}';
                          }
                          return null;
                        },
                        maxLength: 10,
                        decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                            border: OutlineInputBorder(),
                            counterText: "",
                            labelText: '${arEn('المبلغ : ', 'Amount : ')}'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String get selectedDate =>
      widget.df!.date.toString().split(' ')[0].replaceAll('-', '/');

  void selectDate() async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: widget.df!.date,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));
    if (picked != null && picked != widget.df!.date)
      setState(() {
        widget.df!.date = picked;
      });
  }
}
