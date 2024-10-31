import 'package:alpha/GeneralFiles/General.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';

class TransDetails extends StatefulWidget {
  final dynamic? details;
  final double? total;
  const TransDetails({this.total, Key? key, this.details}) : super(key: key);

  @override
  State<TransDetails> createState() => _TransDetailsState();
}

class _TransDetailsState extends State<TransDetails> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: direction,
      child: Scaffold(
        appBar: appBar(title: arEn('بدل مواصلات', 'Transportation allowance')),
        body: Column(
          children: [
            for (var item in widget.details['result'])
              MyTrBlock(
                df: item,
              ),
            Card(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                width: MediaQuery.of(context).size.width,
                height: 35,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      arEn('المجموع : ${fixed(widget.total!)}',
                          'Total : ${fixed(widget.total!)}'),
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: fSize(2)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyTrBlock extends StatefulWidget {
  final dynamic df;
  const MyTrBlock({this.df, Key? key}) : super(key: key);

  @override
  State<MyTrBlock> createState() => _MyTrBlockState();
}

class _MyTrBlockState extends State<MyTrBlock> {
  @override
  Widget build(BuildContext context) {
    return  badges.Badge(
      
      position: badges.BadgePosition.bottomEnd(bottom: 5, end: 5),
      badgeAnimation: badges.BadgeAnimation.fade(
      animationDuration: Duration(seconds: 1),
      ),
      badgeStyle: badges.BadgeStyle(
      elevation: 0,
      shape:  badges.BadgeShape.square,
      badgeColor: Colors.transparent,

      ),
      badgeContent: Text(
        arEn('المبلغ : ${fixed(widget.df['amount'])}',
            'Amount : ${fixed(widget.df['amount'])}'),
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: fSize(2)),
      ),
      child: Card(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          width: MediaQuery.of(context).size.width,
          height: 120,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                arEn(
                    'التاريخ : ${dateFormat2.format(DateTime.parse(widget.df['date']))}',
                    'Date : ${dateFormat2.format(DateTime.parse(widget.df['date']))}'),
              ),
              Text(
                arEn('المدينة : ${widget.df['city']}',
                    'City : ${widget.df['city']}'),
              ),
              Text(
                arEn('المنطقة : ${widget.df['area']}',
                    'Area : ${widget.df['area']}'),
              ),
              Text(
                arEn('العميل : ${widget.df['customer']}',
                    'Customer : ${widget.df['customer']}'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
