import 'dart:convert';
import 'package:alpha/GeneralFiles/General.dart';
import 'package:alpha/models/Modules.dart';
import 'package:animations/animations.dart';
import 'package:badges/badges.dart' as badges;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:alpha/auth.dart';

// ignore: must_be_immutable
class TeamPage extends StatefulWidget {
  String filter = '';
  @override
  _TeamPageState createState() => _TeamPageState();
}

Future<List<Colleague>> _fetchExpences() async {
  List<Colleague> myList = await getColleagues();
  if (myList.length > 0) {
    return myList;
  }
  String _baseUrl = Uri.encodeFull('$link/General');
  final response = await http.post(
    Uri.parse(_baseUrl),
    headers: headers,
    body: {
      "CompNo": '${me?.compNo}',
      "Emp_num": '${me?.empNum}',
      "pn": "HRP_Mobile_MyTeam",
    },
  );

  if (response.statusCode == 200) {
    dynamic snapshot = json.decode(utf8.decode(response.bodyBytes));
    List data = snapshot["result"];
    List<Colleague> f = data.map((m) => new Colleague.map(m)).toList();
    for (var item in f /*.where((x) => x.room == 1)*/) {
      if (myList.where((element) => element.empnum == item.empnum).length ==
          0) {
        myList.add(new Colleague(
          empname: item.empname,
          empnum: item.empnum,
          image: item.image,
          room: item.room,
          sort: item.sort,
        ));
      }
    }
    for (var c in myList) {
      c.image =
          '$myProtocol$serverURL/files/employees/${me?.compNo}/${c.empnum}/profile.png';
    }

    return myList;
  } else {
    throw Exception('${arEn('خطأ في تحميل المعلومات', 'Loading data error')}');
  }
}

ListView _expencesListView(
    List<Colleague> data, ValueChanged<bool> chatPageDone) {
  data.sort((a, b) => b.sort!.compareTo(a.sort!));
  return ListView.separated(
    padding: EdgeInsets.symmetric(vertical: 0),
    itemCount: data.length,
    itemBuilder: (context, index) {
      return badges.Badge(
        badgeStyle: badges.BadgeStyle(
        padding: EdgeInsets.all(7),
        badgeColor: Colors.green,
      ),
       showBadge: conversations.where((x) =>
      x.sender == data[index].empnum &&
      x.seen == 0 &&
      x.reciver == me?.empNum).length > 0,
        badgeContent: Text(
          '${data[index].unreaded}',
          style: TextStyle(color: white),
        ),
        
      position: badges.BadgePosition.custom(end: -12),
        child: ListTile(
          onTap: () async {
            await Navigator.pushNamed(
              context,
              '/chat',
              arguments: {
                'empname': '${data[index].empname}',
                'emp_num': '${data[index].empnum}',
                'image':
                    '$myProtocol$serverURL/files/employees/${me?.compNo}/${data[index].empnum}/profile.png',
              },
            ).then((value) => chatPageDone(true));
          },
          title: Text(
            '${data[index].empname}',
          ),
          leading: OpenContainer(
            closedColor: Colors.white,
            openColor: Colors.white,
            closedElevation: 0.0,
            openElevation: 0.0,
            transitionType: ContainerTransitionType.fadeThrough,
            closedShape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(50.0)),
            ),
            tappable: true,
            transitionDuration: Duration(milliseconds: 300),
            openBuilder: (BuildContext context, VoidCallback _) {
              return Directionality(
                textDirection: direction,
                child: Scaffold(
                  bottomNavigationBar: AdPage(),
                  appBar: AppBar(
                    title: Text(
                      '${data[index].empname}',
                      style: TextStyle(fontSize: fSize(4)),
                    ),
                  ),
                  body: Center(
                    child: Container(
                      child: CachedNetworkImage(
                        imageUrl: '${data[index].image}',
                        placeholder: (context, url) => circular,
                        errorWidget: (context, url, error) =>
                            new Icon(Icons.error),
                      ),
                    ),
                  ),
                ),
              );
            },
            closedBuilder: (BuildContext context, void Function() action) {
              return CircleAvatar(
                child: CachedNetworkImage(
                  imageUrl: '${data[index].image}',
                  placeholder: (context, url) => circular,
                  errorWidget: (context, url, error) => new Icon(Icons.error),
                ),
                backgroundColor: Colors.transparent,
              );
            },
          ),
        ),
      );
    },
    separatorBuilder: (context, index) {
      return Divider();
    },
  );
}

class _TeamPageState extends State<TeamPage> implements AuthStateListener {
  _TeamPageState() {
    provider.subscribe(this);
  }
  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    WidgetsBinding.instance.addPostFrameCallback((_) async {});
  }

  @mustCallSuper
  @protected
  void dispose() {
    provider.dispose(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: direction,
      child: Scaffold(
        bottomNavigationBar: AdPage(),

        appBar: appBar(title: '${arEn('مجموعة العمل', 'Work team')}'),
        body: Container(
          // padding: EdgeInsets.only(bottom: 50),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                // color: primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Center(
                  child: TextField(
                    style: TextStyle(
                        // color: Colors.black,
                        ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.search,
                        // color: Colors.black,
                      ),
                      labelText: '${arEn('بحث', 'Search')}',
                    ),
                    onChanged: (value) {
                      setState(() {
                        widget.filter = value;
                      });
                    },
                  ),
                ),
              ),
              Divider(),
              Expanded(
                child: FutureBuilder<List<Colleague>>(
                  future: _fetchExpences(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<Colleague> data = snapshot.data!;
                      if (data.length == 0) return noData;
                      //setColleagues(data);
                      return _expencesListView(
                          data
                              .where((x) => x.empname!.contains(widget.filter))
                              .toList(), (bool c) {
                        setState(() {});
                      });
                    } else if (snapshot.hasError) {
                      return Text("${snapshot.error}");
                    }
                    return Center(
                      child: Container(
                        width: 50,
                        height: 50,
                        child: circular,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        ////bottomSheet: ad13,
      ),
    );
  }

  @override
  void onNewNotification() {
    setState(() {});
  }
}
