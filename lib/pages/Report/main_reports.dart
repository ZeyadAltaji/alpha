import 'package:alpha/GeneralFiles/General.dart';
import 'package:alpha/pages/Report/Absences.dart';
import 'package:alpha/pages/Report/Delays.dart';
import 'package:alpha/pages/Report/ForgetStamps.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({Key? key}) : super(key: key);
  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  @override
  void initState() {
    super.initState();
    absenceData = null;
    delaysData = null;
    forgetStampsData = null;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: direction,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: appBar(
            title: arEn('متابعة الدوام', 'Follow up'),
            bottom: TabBar(
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorWeight: 0.1,
              indicatorColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.4),
              labelPadding: EdgeInsets.zero,
              labelStyle: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                fontFamily: 'TheSans',
              ),
              tabs: [
                badges.Badge(
                  showBadge: false,
                  badgeContent: Padding(
                    padding: const EdgeInsets.all(3),
                    child: Text(
                      '55',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  position: badges.BadgePosition.topEnd(top: 0, end: 30),
                  badgeStyle: badges.BadgeStyle(
                    padding: EdgeInsets.all(2),
                    badgeColor: primaryColor.withAlpha(100),
                  ),
                  child: Container(
                      margin: EdgeInsets.only(right: 5, left: 5),
                      height: 45,
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.assignment_turned_in),
                          Text(
                            arEn('الغيابات', 'Absences'),
                          ),
                        ],
                      )),
                ),
                badges.Badge(
                  showBadge: false,
                  badgeContent: Padding(
                    padding: const EdgeInsets.all(3),
                    child: Text(
                      '55',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  position: badges.BadgePosition.topEnd(top: 0, end: 30),
                  badgeStyle: badges.BadgeStyle(
                    padding: EdgeInsets.all(2),
                    badgeColor: primaryColor.withAlpha(100),
                  ),
                  child: Container(
                      margin: EdgeInsets.only(right: 5, left: 5),
                      height: 45,
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_active),
                          Text(arEn('التاخيرات', 'Delays')),
                        ],
                      )),
                ),
                badges.Badge(
                  showBadge: false,
                  badgeContent: Padding(
                    padding: const EdgeInsets.all(3),
                    child: Text(
                      '55',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  position: badges.BadgePosition.topEnd(top: 0, end: 30),
                  badgeStyle: badges.BadgeStyle(
                    padding: EdgeInsets.all(2),
                    badgeColor: primaryColor.withAlpha(100),
                  ),
                  child: Container(
                      margin: EdgeInsets.only(right: 5, left: 5),
                      height: 45,
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.style),
                          Text(arEn('نسيان ختم', 'Forget stamp')),
                        ],
                      )),
                ),
              ],
            ),
          ),
          body: TabBarView(
            physics: 1 == 0 ? ScrollPhysics() : NeverScrollableScrollPhysics(),
            children: [
              Absences(),
              Delays(),
              ForgetStamps(),
            ],
          ),
        ),
      ),
    );
  }
}
