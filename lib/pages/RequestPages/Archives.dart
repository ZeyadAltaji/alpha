import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:alpha/GeneralFiles/General.dart';
import 'package:alpha/ShadowText.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class Archives extends StatefulWidget {
  const Archives({Key? key}) : super(key: key);

  @override
  _ArchivesState createState() => _ArchivesState();
}

Future<void> prepareFile(Uint8List list, String filen) async {
  wait(cont!);
  final tempDir = await getTemporaryDirectory();
  final tempDocumentPath = '${tempDir.path}/' + filen;
  final file = await File(tempDocumentPath).create(recursive: true);
  file.writeAsBytesSync(list);
  OpenFile.open(tempDocumentPath);
  done(cont!);
}

Future<void> openFile(int archiveCode, BigInt serial) async {
  wait(cont!);
  await db.excute('OpenFile', {
    "CompNo": '${me!.compNo}',
    "EmpNo": '${me!.empNum}',
    "serial": '$serial',
    "ArchiveCode": '$archiveCode',
  }).then((dynamic value) async {
    Uint8List list = base64Decode(value['fileData']);
    prepareFile(list, value['fileName']);
    done(cont!);
  });
}

Future<void> doUploadFile(ValueChanged<bool> donex) async {
  wait(cont!);
  await db.excute('UploadDocument', {
    "CompNo": '${me!.compNo}',
    "EmpNo": '${me!.empNum}',
    "FileName": fileName,
    "Base64": base64Image,
    "Description": description,
    "ArchiveCode": '$codeKey',
    "ContentType": contentType,
    "lang": "$gLang",
  }).then((dynamic value) async {
    // ignore: unused_local_variable
    bool error = value['error'];
    String msg = "${value['result']}";
    await showDialog(
        barrierColor: Colors.transparent,
        context: cont!,
        builder: (BuildContext context) => error
            ? errorDialog(msg.replaceAll('error - ', ''))
            : successDialog(msg)).then((value) {
      if (!error) {
        donex(true);
        Navigator.pop(cont!);
      }
    });
  });
}

Future<dynamic> callAsyncFetch(int code) async {
  var res =
      await http.post(Uri.parse('$link/General'), headers: headers, body: {
    "EmpNo": "${me!.empNum}",
    "CompNo": '${me!.compNo}',
    "code": "$code",
    "pn": "HRP_Mobile_Archives"
  });

  if (res.statusCode == 200) {
    return json.decode(utf8.decode(res.bodyBytes));
  }
  return null;
}

Image getFileImage(String ext) {
  String s = 'file';
  if (ext == ".docx" || ext == '.doc') s = 'doc';
  if (ext == ".xls" || ext == '.xlsx') s = 'xls';
  if (ext == ".jpg" || ext == '.jpeg' || ext == '.png' || ext == '.bmp')
    s = 'png';
  if (ext == ".pdf") s = 'pdf';
  if (ext == ".txt") s = 'txt';
  return new Image(
    image: AssetImage('images/$s.png'),
    width: 50,
    height: 50,
  );
}

File ?selectedImage;
bool image = false;
String base64Image = '';
int codeKey = 0;
void startUpload(int code, ValueChanged<bool> donex) async {
  codeKey = code;
  fileName = '';
  description = '';
  showDialog(
    barrierColor: Colors.transparent,
    context: cont!,
    builder: (BuildContext context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
        child: Directionality(
          textDirection: direction,
          child: AlertDialog(
            elevation: 10,
            titlePadding: EdgeInsets.zero,
            actionsPadding: EdgeInsets.zero,
            buttonPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            title: Container(
              padding: EdgeInsets.only(right: 30, top: 10, left: 30),
              child: Text(
                arEn('اختر مصدر البيانات', 'choose data source'),
                style: TextStyle(fontSize: fSize(7)),
              ),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 10),
            content: Builder(
              builder: (context) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  width: width,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: width,
                        child: Text(arEn('اختر مصدر البيانات لرفع الصور',
                            'choose data source to upload your files')),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                );
              },
            ),
            actions: [
              Directionality(
                textDirection:
                    gLang == "1" ? TextDirection.ltr : TextDirection.rtl,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 5,
                      ),
                      greenOK('${arEn('الكاميرا', 'CAMERA')}', () {
                        Navigator.pop(context);
                        doUpload(context, code, true, donex);
                      }),
                      SizedBox(
                        width: 5,
                      ),
                      greenOK('${arEn('الاستوديو', 'GALLERY')}', () {
                        Navigator.pop(context);
                        doUpload(context, code, false, donex);
                      }),
                      SizedBox(
                        width: 5,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> doUpload(BuildContext context, int code, bool camera,
    ValueChanged<bool> donex) async {
  ImagePicker _picker = ImagePicker();
  ImageSource source = ImageSource.gallery;
  if (camera) source = ImageSource.camera;

  final pickedFile = await _picker.pickImage(
    source: source,
    maxWidth: 2000,
    maxHeight: 2000,
    imageQuality: 70,
  );
  if (pickedFile == null) return;
  File sFILE;
  sFILE = File(pickedFile.path);
  if (sFILE.lengthSync() > maxSize) {
    toast(
        '${arEn('لا يمكن اختيار ملف بهذا الحجم', 'A file of this size cannot be selected')}');
    return;
  } else {
    selectedImage = sFILE;
    image = true;
    List<int> imageBytes = selectedImage!.readAsBytesSync();
    contentType = p.extension(pickedFile.path);
    base64Image = base64Encode(imageBytes);
    sendRequest(donex);
  }
}

String fileName = '';
String description = '';
String contentType = '';
void sendRequest(ValueChanged<bool> donex) {
  showDialog(
    barrierColor: Colors.transparent,
    context: cont!,
    builder: (BuildContext context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
        child: Directionality(
          textDirection: direction,
          child: AlertDialog(
            elevation: 10,
            titlePadding: EdgeInsets.zero,
            actionsPadding: EdgeInsets.zero,
            buttonPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            title: Container(
              padding: EdgeInsets.only(right: 30, top: 10, left: 30),
              child: Text(
                arEn('معلومات الملف', 'File information'),
                style: TextStyle(fontSize: fSize(7)),
              ),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 10),
            content: Builder(
              builder: (context) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  width: width,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        onChanged: (value) {
                          fileName = value;
                        },
                        textDirection: direction,
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 0),
                            border: new OutlineInputBorder(),
                            hintText: arEn('اسم الملف', 'File name')),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        onChanged: (value) {
                          description = value;
                        },
                        textDirection: direction,
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 0),
                            border: new OutlineInputBorder(),
                            hintText: arEn('الوصف', 'Description')),
                      ),
                    ],
                  ),
                );
              },
            ),
            actions: [
              Directionality(
                textDirection:
                    gLang == "1" ? TextDirection.ltr : TextDirection.rtl,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 5,
                      ),
                      greenOK('${arEn('رفع', 'Upload')}', () {
                        if (fileName == '') {
                          toast(arEn('يرجى ادخال اسم الملف .',
                              'Type file name please .'));
                          return;
                        }
                        if (description == '') {
                          toast(arEn('يرجى ادخال وصف الملف .',
                              'Type file description .'));
                          return;
                        }
                        Navigator.pop(cont!);
                        doUploadFile(donex);
                      }),
                      SizedBox(
                        width: 5,
                      ),
                      greenCancel('${arEn('الغاء', 'Cancel')}', () {
                        Navigator.pop(context);
                      }),
                      SizedBox(
                        width: 5,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

FutureBuilder loadData(ValueChanged<bool> donex) {
  return FutureBuilder(
    future: callAsyncFetch(0),
    builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
      if (snapshot.connectionState == ConnectionState.done &&
          snapshot.hasData &&
          snapshot.data != null) {
        List list = snapshot.data["result"];
        List dlist = list.where((x) => x["g"] == 1).toList();
        list = list.where((x) => x["g"] == 0).toList();
        return Container(
          decoration: new BoxDecoration(
            gradient: new LinearGradient(colors: [
              primaryColor.withOpacity(0.01),
              primaryColor.withOpacity(0.01),
            ]),
          ),
          //padding: EdgeInsets.only(bottom: 50),
          child: ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 10),
            itemCount: list.length,
            itemBuilder: (context, i) {
              return GestureDetector(
                onTap: () {
                  //   toast('msg');
                },
                child: Card(
                  elevation: 4,
                  clipBehavior: Clip.hardEdge,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Container(
                          // color: primaryColor,
                          margin: EdgeInsets.only(bottom: 5),
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: ShadowText(
                                    arEn(
                                      list[i]["arch_Desc"],
                                      list[i]["arch_EngDesc"]
                                          .toString()
                                          .toUpperCase(),
                                    ),
                                    style: TextStyle(
                                        fontSize: fSize(3),
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              TextButton.icon(
                                  onPressed: () {
                                    startUpload(
                                        int.parse('${list[i]["code"]}'), donex);
                                  },
                                  icon: Icon(Icons.add),
                                  label: Text(''))
                            ],
                          ),
                        ),
                        Divider(
                          color: primaryColor.withOpacity(0.35),
                        ),
                        Column(
                          children: [
                            for (var item in dlist
                                .where((x) => x["code"] == list[i]["code"])
                                .toList())
                              InkWell(
                                onTap: () {
                                  int co = int.parse("${item["code"]}");
                                  BigInt serial =
                                      BigInt.parse("${item["serial"]}");
                                  openFile(co, serial);
                                },
                                child: Card(
                                  child: Container(
                                    width: width,
                                    padding: EdgeInsets.all(10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                            child: getFileImage(
                                                item["contentType"])),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${item["fileName"]}',
                                              ),
                                              Text(
                                                '${item["date"]}',
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                            child: Column(
                                          children: [
                                            Text(
                                              item["date"],
                                              style: TextStyle(
                                                  fontSize: fSize(-2)),
                                            ),
                                            Text(''),
                                          ],
                                        )),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) {
              return SizedBox(

                  // color: primaryColor.withOpacity(0.35),
                  );
            },
          ),
        );
      }
      return Center(
        child: circular,
      );
    },
  );
}

class _ArchivesState extends State<Archives> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: direction,
      child: Scaffold(
        bottomNavigationBar: AdPage(),
        appBar: appBar(title: arEn("الوثائق", "Documents")),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: loadData((bool c) {
            if (c) {
              setState(() {
                //
              });
            }
          }),
        ),
      ),
    );
  }
}
