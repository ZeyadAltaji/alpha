import 'dart:convert';
import 'package:alpha/GeneralFiles/Dialogs.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:http/http.dart' as http;
import 'package:alpha/GeneralFiles/General.dart';
import 'package:alpha/models/Modules.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({Key? key}) : super(key: key);

  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  @override
  Widget build(BuildContext context) {
    Future<List<News>?> loading() async {
      // if (news.isNotEmpty) return news;
      Uri _baseUrl = Uri.parse('$link/General');
      var res = await http.post(
        _baseUrl,
        headers: headers,
        body: {
          "CompNo": '${me?.compNo}',
          "pn": "HRP_Mobile_NewsWithSubStitutes"
        },
      );
      if (res.statusCode == 200) {
        dynamic snapshot = json.decode(utf8.decode(res.bodyBytes));
        List data = snapshot["result"];
        news = data.map((m) => new News.map(m)).toList();
        return news;
      }
      return null;
    }

    return Scaffold(
      appBar:
          appBar(title: arEn('لوحة الاعلانات', 'Notice board'), actions: []),
      body: FutureBuilder(
        future: loading(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData &&
              snapshot.data != null) {
            return ListView(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              children: [
                for (var n in news)
                  Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            width: MediaQuery.of(context).size.width,
                            color: darkTheme
                                ? Colors.black12
                                : const Color(0xfff3f3f3),
                            child: Center(
                              child: Text(
                                n.subject.toString().trim().toUpperCase(),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Linkify(
                            textDirection: TextDirection.ltr,
                            textAlign: TextAlign.start,
                            onOpen: (url) async {
                              new Dialogs(context, (v) async {
                                if (v) {
                                  if (await canLaunchUrl(
                                      Uri.parse(url.url.trim()))) {
                                    await launchUrl(Uri.parse(url.url.trim()));
                                  } else {
                                    // throw 'Could not launch ${n.description}';
                                  }
                                }
                              },
                                      '${arEn('فتح', 'Open')}',
                                      '${arEn('انت على وشك فتح رابط خارجي , هل ترغب بالمتابعة ؟', 'You are about to open an external link, would you like to continue?')}',
                                      false)
                                  .yesOrNo();
                            },
                            text: n.description!,
                          ),
                        ),
                        n.eventImage == "null" || n.eventImage == "AA=="
                            ? SizedBox()
                            : Container(
                                width: width / 2,
                                height: width * .5,
                                child: Image.memory(
                                  base64Decode(n.eventImage!),
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
              ],
            );
          }
          return Center(
            child: circular,
          );
        },
      ),
    );
  }
}
