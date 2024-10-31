// import 'package:alpha/GeneralFiles/General.dart';
// // import 'package:alpha/auth.dart';
// import 'package:alpha/models/Modules.dart';
// import 'package:alpha/models/viewModel/viewModel.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:signalr_client/signalr_client.dart';

// bool imBusy = false;

// class WorkFlowModel extends ViewModel {
//   HubConnection _hc;
//   String _serverUrl;
//   String workFlowName = "AlphaHrWorkFlow";

//   bool connectionST() {
//     if (_hc != null && _hc.state == HubConnectionState.Connected) {
//       return true;
//     }
//     return false;
//   }

//   bool get connectionIsOpen => connectionST();

//   Future<void> openConnection() async {
//     if (connectionIsOpen == true || imBusy == true) {
//       return;
//     }
//     imBusy = true;
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     if (preferences.containsKey('sVR')) {
//       _serverUrl =
//           Uri.encodeFull("$myProtocol${preferences.getString('sVR')}/Chat");
//     } else {
//       return;
//     }
//     if (_hc == null) {
//       _hc = HubConnectionBuilder().withUrl(_serverUrl).build();

//       _hc.onclose((error) {});
//       _hc.on("onNewRequest", _newACTION);
//       _hc.on("newAlert", _newAlert);
//       _hc.on("NewConversation", _newConversation);
//       _hc.on("newGAlert", _newGAlert);
//     }
//     if (_hc.state == HubConnectionState.Disconnected) {
//       try {
//         await _hc.start();
//       } catch (e) {
//         //toast(e.toString());
//       }
//     }
//     imBusy = false;
//   }

//   Future<void> closeConnection() async {
//     if (_hc != null && _hc.state == HubConnectionState.Connected) {
//       await _hc.stop();
//     }
//   }

//   Future<void> _newGAlert(List<Object> args) async {
//     final preferences = await SharedPreferences.getInstance();
//     preferences.reload();
//     int _compNo = preferences.getInt('compNo');
//     int _empNum = preferences.getInt('empNum');
//     int empNo = args[0];
//     int compNo = args[1];
//     if (empNo == _empNum && compNo == _compNo) {
//       String ti = args[2];
//       String message = args[3];
//       String rout = args[4];
//       newAlert(ti, message, rout);
//     }
//   }

//   Future<void> _newConversation(List<Object> args) async {
//     final preferences = await SharedPreferences.getInstance();
//     preferences.reload();
//     int _compNo = preferences.getInt('compNo');
//     int _empNum = preferences.getInt('empNum');
//     int id = args[0];
//     DateTime dateTime = DateTime.parse(args[1]);
//     int reciverNum = args[2];
//     int senderNum = args[3];
//     int compNo = args[4];
//     String message = args[5];
//     int seen = args[6];
//     // int groupId = args[7];
//     int refId = args[8];
//     if (_compNo == compNo && _empNum == reciverNum) {
//       conversations.add(new Mssage(
//         date: dateTime,
//         descr: message,
//         id: id,
//         reciver: reciverNum,
//         seen: seen,
//         sender: senderNum,
//         refId: refId,
//       ));

//       var preferences = await SharedPreferences.getInstance();
//       int c = preferences.getInt('ColleagueCount');
//       if (c == null) c = 0;
//       for (var i = 0; i < c; i++) {
//         if (preferences.getInt('ColleagueEmpnum$i') == senderNum) {
//           preferences.setInt('ColleagueSort$i', id);
//         }
//       }
//       if (provider.subs == 0) {
//         WorkFlowRecord n = new WorkFlowRecord(
//             addDate: dateTime,
//             empName: _empNum.toString(),
//             fID: 1,
//             fDescAr: message,
//             form: 'form',
//             requestType: 1,
//             vacationOrLeave: 1);
//         notify(n, false);
//       } else {
//         provider.newWF();
//       }
//     }
//   }

//   Future<void> _newAlert(List<Object> args) async {
//     final preferences = await SharedPreferences.getInstance();
//     preferences.reload();
//     int _compNo = preferences.getInt('compNo');
//     int _empNum = preferences.getInt('empNum');
//     final int reciverID = args[0];
//     final int compNo = args[3];
//     // ignore: unused_local_variable
//     final String empName = args[1];
//     final int fID = args[2];
//     final int requestType = args[4];
//     final int vacationOrLeave = args[5];
//     final String fDescAr = args[6];
//     final DateTime addDate = DateTime.parse(args[7].toString());
//     final String form = args[9];
//     final int actionStat = int.parse('${args[10] ?? 0}');
//     if (_compNo == compNo && _empNum == reciverID) {
//       WorkFlowRecord n = new WorkFlowRecord(
//           addDate: addDate,
//           empName: fDescAr,
//           fID: fID,
//           fDescAr: (actionStat == -1) ? 'تم رفض طلبك' : 'تم قبول طلبك',
//           form: form,
//           requestType: requestType,
//           vacationOrLeave: vacationOrLeave);
//       notify(n, false);
//       provider.newWF();
//     }
//   }

//   Future<void> _newACTION(List<Object> args) async {
//     final preferences = await SharedPreferences.getInstance();
//     preferences.reload();
//     int _compNo = preferences.getInt('compNo');
//     int _empNum = preferences.getInt('empNum');
//     final int reciverID = args[0];
//     final int compNo = args[3];
//     final String empName = args[1];
//     final int fID = args[2];
//     final int requestType = args[4];
//     final int vacationOrLeave = args[5];
//     final String fDescAr = args[6];
//     final DateTime addDate = DateTime.parse(args[7].toString());
//     final String form = args[9];

//     if (wFrecords != null) {
//       // ignore: unused_local_variable
//       int ex = wFrecords
//           .where((x) =>
//               x.fID == fID &&
//               x.requestType == requestType &&
//               x.empName == empName)
//           .length;
//       // if (ex != 0) return;
//     }

//     if (_compNo == compNo && _empNum == reciverID) {
//       WorkFlowRecord n = new WorkFlowRecord(
//           addDate: addDate,
//           empName: empName,
//           fID: fID,
//           fDescAr: fDescAr,
//           form: form,
//           requestType: requestType,
//           vacationOrLeave: vacationOrLeave);
//       notify(n);
//       wFrecords.add(n);
//       wFTypes = [];
//       for (var record in wFrecords) {
//         wFTypes.add(record.fDescAr);
//       }
//       wFTypes = wFTypes.toSet().toList();
//       provider.newWF();
//     }
//   }
// }
