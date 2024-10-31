import 'dart:async';
import 'package:flutter/material.dart';
import 'package:alpha/GeneralFiles/General.dart';

class Clock extends StatefulWidget {
  @override
  _ClockState createState() => _ClockState();
}

class _ClockState extends State<Clock> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: direction,
      child: Timerx(),
    );
  }
}

class Timerx extends StatefulWidget {
  @override
  _TimerxState createState() => _TimerxState();
}

class _TimerxState extends State<Timerx> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  void dispose() {
    if (timer != null) timer!.cancel();
    super.dispose();
  }

  Future<void> initPlatformState() async {
    await db.excute('Now', {}).then((dynamic value) {
      updateCurrentTime(value["result"], value["error"]);
    });
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (currentTime != null) {
            currentTime = DateTime.now().add(new Duration(minutes: def * -1));
            hh = timeFormat.format(currentTime);
            hh2 = dateFormat.format(currentTime);
          }
        },
      ),
    );
  }

  String hh = '${timeFormat.format(now)}';
  String hh2 = '${dateFormat.format(now)}';
  DateTime currentTime = now;
  int def = 0;
  bool success = false;
  Timer? timer;
  updateCurrentTime(String v, bool x) async {
    DateTime n = DateTime.parse(v);

    def = DateTime.now().difference(n).inMinutes;
    setState(() {
      currentTime = DateTime.now().add(new Duration(minutes: def * -1));
      hh = timeFormat.format(currentTime);
      hh2 = dateFormat.format(currentTime);
      startTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          padding: EdgeInsets.only(bottom: 20),
          decoration: new BoxDecoration(
              // color: Colors.white,
              borderRadius: new BorderRadius.only(
            bottomLeft: const Radius.circular(20.0),
            bottomRight: const Radius.circular(20.0),
          )),
          width: width * .9,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Directionality(
                textDirection:
                    gLang == "2" ? TextDirection.rtl : TextDirection.ltr,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      hh.contains('AM') ? arEn('ص', 'AM') : arEn('م', 'PM'),
                      style: TextStyle(
                          fontSize: fSize(7), color: Color(0xff444444)),
                      textDirection: direction,
                    ),
                    Text(
                      hh.replaceAll('AM', '').replaceAll('PM', ''),
                      style: TextStyle(
                          fontSize: fSize(10),
                          fontWeight: FontWeight.bold,
                          color: Color(0xff444444)),
                      textDirection: direction,
                    ),
                  ],
                ),
              ),
              Text(
                '${dayName(currentTime)}',
                style: TextStyle(fontSize: fSize(2), color: Color(0xff444444)),
              ),
              Text(
                '${hh2.replaceAll('-', '/')}',
                style: TextStyle(fontSize: fSize(2), color: Color(0xff444444)),
              ),
              Center(
                child: Text(
                  '${arEn(me!.empName!, me!.empEngName!)}',
                  style:
                      TextStyle(fontSize: fSize(-1), color: Color(0xff444444)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '"${me!.empNum}"',
                  style: TextStyle(fontSize: fSize(0), color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
