import 'package:alpha/GeneralFiles/General.dart';
import 'package:flutter/material.dart';

class LocationUL extends StatefulWidget {
  const LocationUL({required Key key}) : super(key: key);
  @override
  _LocationULState createState() => _LocationULState();
}

class _LocationULState extends State<LocationUL> {
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: myEmployees!.length,
          itemBuilder: (BuildContext context, int index) {
            var g = myEmployees![index];
            return Container(
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: CheckboxListTile(
                  selected: (g['access'] == 1),
                  title: Row(
                    children: [
                      Expanded(
                        child: Directionality(
                          textDirection: direction,
                          child: Text(g['empName']),
                        ),
                      ),
                    ],
                  ),
                  value: (g['access'] == 1),
                  onChanged: (val) {
                    setState(() {
                     if(val != null){
                       val ? g['access'] = 1 : g['access'] = 0;
                     }
                    });
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
