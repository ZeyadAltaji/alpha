import 'package:alpha/JobTasks/FinishJobTask.dart';
import 'package:alpha/JobTasks/JobTask.dart';
import 'package:alpha/pages/ChangePW.dart';
import 'package:alpha/pages/ChatPage.dart';
import 'package:alpha/pages/InOutLog.dart';
import 'package:alpha/pages/InOutLog2.dart';
import 'package:alpha/pages/InfoPage.dart';
import 'package:alpha/pages/KickOut.dart';
import 'package:alpha/pages/LocationUsers.dart';
import 'package:alpha/pages/News.dart';
import 'package:alpha/pages/Report/main_reports.dart';
import 'package:alpha/pages/RequestPages/Archives.dart';
import 'package:alpha/pages/RequestPages/Letters.dart';
import 'package:alpha/pages/RequestPages/MissingFingerPrints.dart';
import 'package:alpha/pages/StartWorkRequest/StartWork.dart';
import 'package:alpha/pages/TeamPage.dart';
import 'package:alpha/pages/TransPort/Transportation.dart';
import 'package:alpha/pages/TransPort/addTrans.dart';
import 'package:alpha/pages/UnBlock.dart';
import 'package:alpha/pages/Vacations.dart';
import 'package:alpha/pages/workflowReport.dart';
import 'package:flutter/material.dart';
import 'package:alpha/pages/MyLog.dart';
import 'package:alpha/pages/RequestPages/AdvancePayment.dart';
import 'package:alpha/pages/RequestPages/ExtraWork.dart';
import 'package:alpha/pages/RequestPages/GeneralRequest.dart';
import 'package:alpha/pages/RequestPages/ITRequest.dart';
import 'package:alpha/pages/RequestPages/Insurance.dart';
import 'package:alpha/pages/RequestPages/LeaveRequest.dart';
import 'package:alpha/pages/RequestPages/SalaryIncrease.dart';
import 'package:alpha/pages/RequestPages/WorkStamp.dart';
import 'package:alpha/pages/RequestPages/VacationRequest.dart';
import 'package:alpha/pages/SalarySlip.dart';
import 'package:alpha/pages/WorkFlow/WorkFlowPage.dart';
import 'package:alpha/pages/login.page.dart';
import 'package:alpha/pages/MainPage.dart';
import 'package:alpha/pages/Settings.dart';
import 'package:alpha/pages/Sheet.dart';
import 'package:alpha/pages/MySettings.dart';

get routes => {
      '/login': (BuildContext c) => new LoginScreen(),
      '/home': (BuildContext c) => new MainPage(),
      '/settings': (BuildContext c) => new SettingPage(),
      '/vacation': (BuildContext c) => new VacationRequest(),
      '/leave': (BuildContext c) => new LeaveRequest(),
      '/fingerprint': (BuildContext c) => new MissingFingerPrints(),
      '/extrawork': (BuildContext c) => new ExtraWorkPage(),
      '/advancepayment': (BuildContext c) => new AdvancePaymentPage(),
      '/salaryincrease': (BuildContext c) => new SalaryIncreasePage(),
      '/mylog': (BuildContext c) => new MyLogPage(),
      '/insurance': (BuildContext c) => new InsuranceJoin(),
      '/generalrequest': (BuildContext c) => new GeneralRequest(),
      '/itrequest': (BuildContext c) => new ITRequest(),
      '/workflow': (BuildContext c) => new MainWorkFlow(),
      '/workrequest': (BuildContext c) => new WorkStamp(),
      '/salaryslip': (BuildContext c) => new SalarySlip(),
      '/sheet': (BuildContext c) => new SheetPage(),
      '/info': (BuildContext c) => new BubblesPage(),
      '/locationUsers': (BuildContext c) => new LocationUsers(),
      '/InOutLog': (BuildContext c) => new InOutLog(), // /routs.dart:61:44
      '/InOutLog2': (BuildContext c) => new InOutLog2(),
      '/Vacations': (BuildContext c) => new VacationsPage(),
      '/myTeam': (BuildContext c) => new TeamPage(),
      '/chat': (BuildContext c) => new ChatPage(),
      '/MySettings': (BuildContext c) => new MySettings(),
      '/Letters': (BuildContext c) => new EmpLetters(),
      '/Archives': (BuildContext c) => new Archives(),
      '/UnBlock': (BuildContext c) => new UnBlock(),
      '/KickOut': (BuildContext c) => new KickOut(),
      '/News': (BuildContext c) => new NewsPage(),
      '/ReportPage': (BuildContext c) => new ReportPage(),
      '/WorkFlowReport': (BuildContext c) => new WorkFlowReport(),
      '/Transportation': (BuildContext c) => new Transportation(),
      '/ChangePW': (BuildContext c) => new ChangePW(),
      '/AddTransPage': (BuildContext c) => new AddTransPage(),
      '/JobTask': (BuildContext c) => new JobTask(),
      '/FinishJobTask': (BuildContext c) => new FinishJobTask(),
      '/StartWork': (BuildContext c) => new StartWork(),
    };
