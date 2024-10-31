import 'dart:async';
import 'package:alpha/GeneralFiles/Dialogs.dart';
import 'package:alpha/pages/RequestPages/Clock.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:alpha/GeneralFiles/General.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

enum PermissionStatusx {
  undetermined,
  granted,
  denied,
  restricted,
  permanentlyDenied,
}

class WorkStamp extends StatefulWidget {
  @override
  _WorkStampState createState() => _WorkStampState();
}

class _WorkStampState extends State<WorkStamp> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: direction,
      child: Scaffold(
        bottomNavigationBar: AdPage(),
        appBar: appBar(title: '${arEn('تسجيل دخول / خروج', 'Log In / Out')}'),
        body: Timerx(),
        //bottomSheet: ad10,
      ),
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
  }

  Location location = new Location();
  // ignore: avoid_init_to_null
  LocationData? _locationData = null;

  Future<void> doFingerPrint(int checkin) async {
    if (_locationData == null) {
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        msgBox(
            '${arEn('يرجى تفعيل خاصية تحديد الموقع في جهازك', 'Please activate the location feature on your device')}');
        _btnController.reset();
        _btnController2.reset();
        _btnController3.reset();
        _btnController4.reset();
        await location.requestService();
        return;
      }
      PermissionStatus permission = await location.hasPermission();
      if (permission == PermissionStatus.deniedForever ||
          permission == PermissionStatus.denied) {
        new Dialogs(context, (bool r) async {
          if (r) {
            await location.requestPermission();
          }
        },
                '${arEn('صلاحيات الوصول', 'Access permissions')}',
                '${arEn('يجب منح صلاحيات الوصول الى الموقع قبل المتابعة , هل تريد اعطاء الصلاحيات ؟', 'You must grant access to the location before proceeding. Do you want to grant permissions?')}',
                true)
            .yesOrNo();
        _btnController.reset();
        _btnController2.reset();
        _btnController3.reset();
        _btnController4.reset();
        return;
      }
      _locationData = await location.getLocation();
    }

    wait(context, arEn("يرجى الانتظار ...", "Please wait ..."));

    if (_locationData!.isMock!) {
      done(context);
      msgBox(
          '${arEn('يرجى عدم استخدام موقع وهمي', 'Please do not use a fake location')}');
      _btnController.error();
      _btnController2.error();
      _btnController3.error();
      _btnController4.error();
      return;
    }
    saveToData(checkin, _locationData!.latitude, _locationData!.longitude);
  }

  final RoundedLoadingButtonController _btnController =
      new RoundedLoadingButtonController();
  final RoundedLoadingButtonController _btnController2 =
      new RoundedLoadingButtonController();
  final RoundedLoadingButtonController _btnController3 =
      new RoundedLoadingButtonController();
  final RoundedLoadingButtonController _btnController4 =
      new RoundedLoadingButtonController();

  void saveToData(int checkin, tu, ng) async {
    try {
      await db.excute('Mobile_NewAttendance', {
        "CompNo": '${me?.compNo}',
        "EmpNo": '${me?.empNum}',
        "CheckIn": "$checkin",
        "latitude": '$tu',
        "longitude": '$ng',
        'imei': '$imei',
      }).then((dynamic value) {
        recordedStamps.clear();

        _done(value["result"].toString(), value["error"], checkin);
      });
    } catch (e) {
      _btnController.stop();
      _btnController2.stop();
      _btnController3.stop();
      _btnController4.stop();
      done(context);
    }
  }

  void _done(String msg, bool error, int checkin) async {
    if (msg == "" && error) {
      setState(() {
        // _isBusy = false;
      });
      return;
    }
    msg = msg.replaceAll('[{result: ', '');
    msg = msg.replaceAll('}]', '');
    error = msg == "تم ارسال طلبك" ? false : true;
    msg = translate(msg);
    done(context);
    if (error) {
      checkin == 1 ? _btnController.error() : _btnController2.error();
      checkin == 16 ? _btnController3.error() : _btnController4.error();
    } else if (checkin == 16) {
      _btnController3.success();
    } else if (checkin == 17) {
      _btnController4.success();
    } else {
      checkin == 1 ? _btnController.success() : _btnController2.success();
    }

    new Future.delayed(new Duration(seconds: 0), () async {
      return await showDialog(
          barrierColor: Colors.transparent,
          context: context,
          builder: (BuildContext context) =>
              error ? errorDialog(msg) : successDialog(msg)).then((value) {
        if (!error) {
          setState(() {});
        }
      });
    });
  }

  String hh = '${timeFormat.format(now)}';
  String hh2 = '${dateFormat.format(now)}';
  DateTime currentTime = now;
  int def = 0;
  bool success = false;

  // GoogleMapController _controller;
  // Location _location = Location();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10, right: 10, left: 10),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Column(
            children: [
              Container(
                height: 35,
                decoration: new BoxDecoration(
                    color: primaryColor,
                    borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(20.0),
                      topRight: const Radius.circular(20.0),
                    )),
                child: Container(
                  width: width,
                  child: Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: Text(
                            '$companyName',
                            style: TextStyle(
                              fontSize: fSize(0),
                              color: Colors.white,
                              decorationStyle: TextDecorationStyle.dotted,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 50,
                        child: Center(
                          child: Text(
                            '${me?.compNo}',
                            style: TextStyle(
                              fontSize: fSize(0),
                              color: Colors.white,
                              decorationStyle: TextDecorationStyle.dotted,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    color: Colors.white,
                    height: MediaQuery.of(context).size.width * 0.65,
                    width: MediaQuery.of(context).size.width * 0.30,
                    child: Clock(),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.width * 0.65,
                    width: MediaQuery.of(context).size.width * 0.65,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(31, 37),
                        zoom: 6,
                      ),
                      mapType: MapType.terrain,
                      zoomControlsEnabled: false,
                      indoorViewEnabled: true,
                      onMapCreated: (GoogleMapController _cntlr) async {
                        bool serviceEnabled = await location.serviceEnabled();
                        if (!serviceEnabled) return;
                        PermissionStatus permission =
                            await location.hasPermission();
                        if (permission == PermissionStatus.deniedForever ||
                            permission == PermissionStatus.denied) return;

                        _locationData = await location.getLocation();

                        _cntlr.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                                target: LatLng(_locationData!.latitude!,
                                    _locationData!.longitude!),
                                zoom: 20),
                          ),
                        );
                        _cntlr.dispose();
                      },
                      myLocationEnabled: true,
                      compassEnabled: true,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: new BoxDecoration(
                    color: Colors.white,
                    borderRadius: new BorderRadius.only(
                      bottomLeft: const Radius.circular(20.0),
                      bottomRight: const Radius.circular(20.0),
                    )),
                height: 10,
              ),
            ],
          ),
          Container(
            width: width * 0.9,
            margin: EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: width * .4,
                  child: RoundedLoadingButton(
                    controller: _btnController,
                    borderRadius: 180,
                    onPressed: () {
                      try {
                        doFingerPrint(1);
                      } catch (e) {
                        done(context);
                      }
                    },
                    elevation: 1,
                    animateOnTap: true,
                    height: 60,
                    color: primaryColor,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 25,
                          child: CachedNetworkImage(
                            filterQuality: FilterQuality.high,
                            imageUrl:
                                '$myProtocol$serverURL/images/005-login.png',
                            placeholder: (context, url) => new SizedBox(),
                            errorWidget: (context, url, error) =>
                                new Icon(Icons.error),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          '${arEn('دخول', 'IN')}',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.normal,
                              fontSize: fSize(8)),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: width * .4,
                  child: RoundedLoadingButton(
                    controller: _btnController2,
                    borderRadius: 180,
                    onPressed: () {
                      try {
                        doFingerPrint(15);
                      } catch (e) {
                        done(context);
                      }
                    },
                    elevation: 1,
                    animateOnTap: true,
                    height: 60,
                    color: primaryColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 25,
                          child: CachedNetworkImage(
                            filterQuality: FilterQuality.high,
                            placeholderFadeInDuration:
                                Duration(milliseconds: 300),
                            imageUrl:
                                '$myProtocol$serverURL/images/006-logout.png',
                            placeholder: (context, url) => new SizedBox(),
                            errorWidget: (context, url, error) =>
                                new Icon(Icons.error),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          '${arEn('خروج', 'OUT')}',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.normal,
                              fontSize: fSize(8)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Container(
          //   width: width * 0.9,
          //   margin: EdgeInsets.all(8),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       Container(
          //         width: width * .4,
          //         child: RoundedLoadingButton(
          //           controller: _btnController3,
          //           borderRadius: 180,
          //           onPressed: () {
          //             try {
          //               doFingerPrint(16);
          //             } catch (e) {
          //               done(context);
          //             }
          //           },
          //           elevation: 1,
          //           animateOnTap: true,
          //           height: 60,
          //           color: primaryColor,
          //           child: Row(
          //             mainAxisSize: MainAxisSize.min,
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             crossAxisAlignment: CrossAxisAlignment.center,
          //             children: [
          //               Container(
          //                 height: 25,
          //                 child: CachedNetworkImage(
          //                   filterQuality: FilterQuality.high,
          //                   imageUrl:
          //                       '$myProtocol$serverURL/images/005-login.png',
          //                   placeholder: (context, url) => new SizedBox(),
          //                   errorWidget: (context, url, error) =>
          //                       new Icon(Icons.error),
          //                 ),
          //               ),
          //               SizedBox(
          //                 width: 10,
          //               ),
          //               Text(
          //                 '${arEn('بداية المغادرة', 'Start Leave')}',
          //                 style: TextStyle(
          //                     color: Colors.white,
          //                     fontWeight: FontWeight.normal,
          //                     fontSize: fSize(8)),
          //               ),
          //             ],
          //           ),
          //         ),
          //       ),
          //       Container(
          //         width: width * .4,
          //         child: RoundedLoadingButton(
          //           controller: _btnController4,
          //           borderRadius: 180,
          //           onPressed: () {
          //             try {
          //               doFingerPrint(17);
          //             } catch (e) {
          //               done(context);
          //             }
          //           },
          //           elevation: 1,
          //           animateOnTap: true,
          //           height: 60,
          //           color: primaryColor,
          //           child: Row(
          //             mainAxisSize: MainAxisSize.min,
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             crossAxisAlignment: CrossAxisAlignment.center,
          //             children: [
          //               Container(
          //                 height: 25,
          //                 child: CachedNetworkImage(
          //                   filterQuality: FilterQuality.high,
          //                   imageUrl:
          //                       '$myProtocol$serverURL/images/006-logout.png',
          //                   placeholder: (context, url) => new SizedBox(),
          //                   errorWidget: (context, url, error) =>
          //                       new Icon(Icons.error),
          //                 ),
          //               ),
          //               SizedBox(
          //                 width: 10,
          //               ),
          //               Text(
          //                 '${arEn('نهاية المغادرة', 'ُEnd Leave')}',
          //                 style: TextStyle(
          //                     color: Colors.white,
          //                     fontWeight: FontWeight.normal,
          //                     fontSize: fSize(8)),
          //               ),
          //             ],
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          Expanded(
            child: Container(
              // padding: EdgeInsets.only(bottom: 10, top: 10),
              child: new FutureBuilder(
                future: getStamp(),
                initialData: "${arEn('... يتم التحميل', 'loading ...')}",
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data ==
                        "${arEn('... يتم التحميل', 'loading ...')}") {
                      return Directionality(
                        textDirection: gLang == "2"
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        child: Center(
                          child: Text(
                            "${arEn('يتم التحميل ...', 'loading ...')}",
                            textDirection: direction,
                          ),
                        ),
                      );
                    }
                    return ListView(
                      children: [
                        for (var i = snapshot.data.length - 1; i >= 0; i--)
                          Card(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              height: 50,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    child: Image.asset(
                                      snapshot.data[i]
                                              .toString()
                                              .contains('${arEn('دخول', 'In')}')
                                          ? 'images/enter.png'
                                          : 'images/exit.png',
                                      fit: BoxFit.cover,
                                      width: 20,
                                      height: 20,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text('${snapshot.data[i]}'),
                                ],
                              ),
                            ),
                          ),
                      ],
                    );
                  }
                  return Container();
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
