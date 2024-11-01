import 'package:alpha/GeneralFiles/General.dart';
import 'package:alpha/models/DBHelper.dart';
import 'package:alpha/models/Modules.dart';
import 'package:alpha/pages/ChatBox.dart';
import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:bubble/bubble.dart';
import 'package:alpha/auth.dart';
import 'package:scroll_to_index/scroll_to_index.dart'; 

// ignore: must_be_immutable
class ChatPage extends StatefulWidget {
  Mssage? rMSG;
  @override
  _ChatPageState createState() => _ChatPageState();
}

final controller = AutoScrollController(
    viewportBoundaryGetter: () =>
        Rect.fromLTRB(0, 0, 0, MediaQuery.of(cont!).padding.bottom),
    axis: Axis.vertical,
    suggestedRowHeight: 200);
// String myMSG = '';
int? empnum;
void setSeen(int empNo2) {
  db.excute('General', {
    "CompNo": '${me?.compNo}',
    "EmpNo": '${me?.empNum}',
    "EmpNo2": '$empNo2',
    "pn": "HRP_Mobile_SetSeen"
  });
}

void sendMSG(String msg, int refId, ValueChanged<bool> sendingDone) async {
  if (msg == '') {
    sendingDone(false);
    return;
  }
  await db.excute('Conversations', {
    "DateTime": '$now',
    "ReciverNum": '$empnum',
    "SenderNum": '${me?.empNum}',
    "CompNo": '${me?.compNo}',
    "Message": '$msg',
    "seen": '0',
    "GroupId": '0',
    "refId": '$refId'
  }).then((dynamic value) {
    int msgId = int.parse('${value["id"]}');
    conversations.add(new Mssage(
        date: now,
        descr: msg,
        id: msgId,
        reciver: empnum,
        sender: me?.empNum,
        seen: 0,
        refId: refId));
    sendingDone(true);
  });
}

class _ChatPageState extends State<ChatPage> implements AuthStateListener {
  _ChatPageState() {
    provider.subscribe(this);
  }

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      controller.scrollToIndex(mcon(empnum!).length,
          preferPosition: AutoScrollPosition.end,
          duration: Duration(milliseconds: 10));
    });
  }

  @mustCallSuper
  @protected
  void dispose() {
    setSeen(empnum!);
    chatwith = 0;
    provider.dispose(this);
    super.dispose();
  }

  List<Mssage> mcon(int empnum) {
    return conversations
        .where((x) => x.reciver == empnum || x.sender == empnum)
        .toList();
  }
 
  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context)?.settings.arguments as Map;
    String t = arguments['empname'].toString();
    String image = arguments['image'].toString();
    empnum = int.parse(arguments['emp_num'].toString());
    chatwith = empnum!;
    setSeen(empnum!);
    for (var c in conversations.where(
        (x) => x.sender == empnum && x.reciver == me?.empNum && x.seen == 0)) {
      c.seen = 1;
    }
    new DBHelper().update(empnum!);
    return Directionality(
      textDirection: direction,
      child: Scaffold(
        bottomNavigationBar: AdPage(),
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: twoColors,
            ),
          ),
          title: Row(
            children: [
              //
              OpenContainer(
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
                      appBar: appBar(title: '$t'),
                      body: Center(
                        child: Container(
                          child: CachedNetworkImage(
                            imageUrl: '$image',
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
                      imageUrl: '$image',
                      placeholder: (context, url) => circular,
                      errorWidget: (context, url, error) =>
                          new Icon(Icons.error),
                    ),
                    backgroundColor: Colors.transparent,
                  );
                },
              ),

              //
              SizedBox(
                width: 10,
              ),
              Text(
                t,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        body: Container(
          padding: EdgeInsets.only(bottom: 50),
          child: Column(
            children: [
              Expanded(
                child: NotificationListener<OverscrollIndicatorNotification>(
                  onNotification: (overscroll) {
                    overscroll.disallowIndicator();
                    return true;
                  },
                  child: ListView.builder(
                    controller: controller,
                    itemCount: mcon(empnum!).length,
                    itemBuilder: (context, index) {
                      return AutoScrollTag(
                        key: ValueKey(index),
                        controller: controller,
                        index: index,
                        highlightColor: Colors.blue,
                        child: Bubble(
                          style: mcon(empnum!)[index].sender == me?.empNum
                              ? styleMe
                              : styleSomebody,
                          child: Container(
                            key: Key('${mcon(empnum!)[index].id}'),
                            padding: EdgeInsets.only(right: 10),
                            child: PopupMenuButton(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    child: mcon(empnum!)[index].refId != 0
                                        ? GestureDetector(
                                            onTap: () {
                                              var refM = mcon(empnum!)
                                                  .where((x) =>
                                                      x.id ==
                                                      mcon(empnum!)[index].refId)
                                                  .first;
                                              controller.scrollToIndex(
                                                  mcon(empnum!).indexOf(refM),
                                                  preferPosition:
                                                      AutoScrollPosition
                                                          .begin,
                                                 );
                                                                                        },
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Container(
                                                  height: 70,
                                                  width: width * .74,
                                                  child: Container(
                                                    decoration:
                                                        new BoxDecoration(
                                                            color: Color(
                                                                0xfff7f7f7),
                                                            borderRadius:
                                                                new BorderRadius
                                                                    .only(
                                                              topLeft: const Radius
                                                                      .circular(
                                                                  10.0),
                                                              bottomLeft:
                                                                  const Radius
                                                                          .circular(
                                                                      10.0),
                                                            )),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                            child: Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      5),
                                                          color:
                                                              Color(0xfff7f7f7),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                getMSG(mcon(empnum!)[index].refId!).sender ==me?.empNum
                                                                    ? '${arEn('انا', 'I')}'
                                                                    : t,
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              Text(truncate(
                                                                  getMSG(mcon(empnum!)[index].refId!).descr!,
                                                                  100)),
                                                            ],
                                                          ),
                                                        ))
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : Container(
                                            width: 0,
                                          ),
                                  ),
                                  Text(
                                    mcon(empnum!)[index].descr!,
                                    textDirection: direction,
                                  ),
                                ],
                              ),
                              onSelected: (selection) {
                                switch (selection) {
                                  case 1:
                                    FlutterClipboard.copy(
                                        mcon(empnum!)[index].descr!);
                                    break;
                                  case 2:
                                    setState(() {
                                      widget.rMSG = mcon(empnum!)[index];
                                    });
                                    break;
                                }
                              },
                              itemBuilder: (BuildContext context) {
                                return [
                                  PopupMenuItem(
                                    value: 1,
                                    child: Text("${arEn('نسخ', 'Copy')}"),
                                  ),
                                  // PopupMenuItem(
                                  //   value: 2,
                                  //   child: Text("${arEn('رد', 'Reply')}"),
                                  // ),
                                ];
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomSheet: ChatBox(
          onSend: (String v) {
            sendMSG(v, widget.rMSG == null ? 0 : widget.rMSG!.id!, (bool x) {
              if (x == true) {
                setState(() {
                  v = '';
                  widget.rMSG = null;
                });
                 controller.scrollToIndex(mcon(empnum!).length, preferPosition: AutoScrollPosition.begin);

              }
            });
          },
        ),
      ),
    );
  }

  @override
  void onNewNotification() {
    setState(() {
      // controller.scrollToIndex(mcon(empnum!).length,
      //     preferPosition: AutoScrollPosition.begin, offset: 0);
      controller.scrollToIndex(mcon(empnum!).length, preferPosition: AutoScrollPosition.begin);

    });
  }
}

Mssage getMSG(int id) {
  if (conversations.where((x) => x.id == id).length == 0) {
    return new Mssage(
      date: now,
      descr: '',
      id: id,
      reciver: me?.empNum,
      refId: 0,
      seen: 0,
      sender: me?.empNum,
    );
  }
  return conversations.where((x) => x.id == id).first;
}
