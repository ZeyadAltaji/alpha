import 'dart:convert';

import 'package:alpha/GeneralFiles/General.dart';

class User {
  int? compNo;
  int? empNum;
  final String? username;
  final String? password;
  final bool? defaultDate;
  final String? empName;
  final String? empEngName;
  final bool? isSupervisor;
  final bool? isInterviewer;
  final int? clientNo;
  final bool? isLogin;
  final bool? isResigned;
  final String? socialNo;
  final String? errorMessage;
  final String? img;
  User({
    this.compNo,
    this.empNum,
    this.username,
    this.password,
    this.defaultDate,
    this.empName,
    this.empEngName,
    this.isSupervisor,
    this.isInterviewer,
    this.clientNo,
    this.isLogin,
    this.isResigned,
    this.socialNo,
    this.errorMessage,
    this.img,
  });

  factory User.map(dynamic obj) {
    User emp = new User(
      compNo: int.parse(obj['compNo'].toString()),
      empNum: int.parse(obj['empNum'].toString().trim()),
      username: obj["username"].toString(),
      password: obj["password"].toString(),
      defaultDate: boolParse(obj["defaultDate"]?.toString() ?? "false"),
      empName: obj["empName"].toString(),
      empEngName: obj["empEngName"].toString(),
      isSupervisor: boolParse(obj["isSupervisor"].toString()),
      isInterviewer: boolParse(obj["isInterviewer"].toString()),
      clientNo: int.parse(obj["clientNo"].toString()),
      isLogin: boolParse(obj["isLogin"].toString()),
      isResigned: boolParse(obj["isResigned"].toString()),
      socialNo: obj["socialNo"].toString(),
      errorMessage: obj["errorMessage"].toString(),
      img: obj["img"].toString(),
    );
    return emp;
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["Username"] = username;
    map["Password"] = password;
    map["CompNo"] = compNo;
    map["EmpNum"] = empNum;
    map["DefaultDate"] = defaultDate;
    map["EmpName"] = empName;
    map["EmpEngName"] = empEngName;
    map["IsSupervisor"] = isSupervisor;
    map["IsInterviewer"] = isInterviewer;
    map["ClientNo"] = clientNo;
    map["IsLogin"] = isLogin;
    map["IsResigned"] = isResigned;
    map["SocialNo"] = socialNo;
    map["ErrorMessage"] = errorMessage;
    map["img"] = img;
    return map;
  }
}

class Menu {
  final int? id;
  final String? descr;
  String? get descrEn => getEnglish(descr!);
  Menu({this.id, this.descr});
  factory Menu.map(dynamic obj) {
    Menu emp = new Menu(
      id: int.parse(obj['id'].toString()),
      descr: obj["descr"].toString(),
    );
    return emp;
  }
  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["descr"] = descr;
    return map;
  }
}

class SubMenu {
  final int? id;
  final String? descr;
  String? get descrEn => getEnglish(descr!);
  final String? link;
  final String? img;
  final String? color;
  final int? id2;
  final int? r;
  final int? g;
  final int? b;
  final double? a;
  int? disabled;
  SubMenu({
    this.id,
    this.descr,
    this.link,
    this.img,
    this.color,
    this.id2,
    this.r,
    this.g,
    this.b,
    this.a,
    this.disabled,
  });
  factory SubMenu.map(dynamic obj) {
    SubMenu emp = new SubMenu(
      id: int.parse(obj['id'].toString()),
      id2: int.parse(obj['id2'].toString()),
      descr: obj["descr"].toString(),
      link: obj["link"].toString(),
      img: obj["img"].toString(),
      color: obj["color"].toString(),
      disabled: int.parse('${obj["disabled"] ?? 0}'),
    );
    return emp;
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["id2"] = id2;
    map["descr"] = descr;
    map["link"] = link;
    map["img"] = img;
    map["color"] = color;
    map["disabled"] = disabled;
    return map;
  }
}

class PayCode {
  final int? id;
  final String? codeDesc;

  PayCode({this.id, this.codeDesc});
  factory PayCode.map(dynamic obj) {
    PayCode emp = new PayCode(
      id: int.parse(obj['id'].toString()),
      codeDesc: obj["codeDesc"].toString(),
    );
    return emp;
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["codeDesc"] = codeDesc;
    return map;
  }
}

class DefValue {
  final int? parID;
  final int? parValue;
  final String? parNameAr;
  final String? parNameEn;
  final double? value;

  DefValue(
      {this.parID, this.parValue, this.parNameAr, this.parNameEn, this.value});
  factory DefValue.map(dynamic obj) {
    DefValue emp = new DefValue(
      parID: int.parse(obj['parID'].toString()),
      parValue: double.parse(obj['parValue'].toString()).toInt(),
      value: double.parse(obj['value'].toString()),
      parNameAr: obj["parNameAr"].toString(),
      parNameEn: "${obj['par_NameEn'] ?? ''}",
    );
    return emp;
  }
  factory DefValue.map2(dynamic obj) {
    DefValue emp = new DefValue(
      parID: int.parse(obj['par_ID'].toString()),
      parValue: double.parse(obj['par_Value'].toString()).toInt(),
      value: double.parse(obj['value'].toString()),
      parNameAr: obj["par_NameAr"].toString(),
      parNameEn: "${obj['par_NameEn'] ?? ''}",
    );
    return emp;
  }
  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["parID"] = parID;
    map["parValue"] = parValue;
    map["parNameAr"] = parNameAr;
    map["Value"] = value;
    return map;
  }
}

class LogRecord {
  final int? vRSerial;
  final String? descAr;
  final String? descEn;
  final int? requestType;
  final String? requeridNote;
  final int? statusWF;
  final DateTime? transDate;
  String? notes;
  String? rejected;
  LogRecord({
    this.vRSerial,
    this.descAr,
    this.descEn,
    this.requeridNote,
    this.requestType,
    this.statusWF,
    this.transDate,
    this.notes,
    this.rejected,
  });
  factory LogRecord.map(dynamic obj) {
    LogRecord emp = new LogRecord(
        vRSerial: int.parse(obj['vR_Serial'].toString()),
        descAr: obj['descAr'].toString(),
        notes: '${obj["notes"] ?? ''}',
        rejected: '${obj["rejected"] ?? ''}',
        descEn: obj['descEn'].toString(),
        requestType: int.parse(obj['requestType'].toString()),
        requeridNote: obj['requeridNote'].toString(),
        statusWF: int.parse(obj['statusWF'].toString()),
        transDate: DateTime.parse(obj['transDate'].toString()));
    return emp;
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();

    map["vR_Serial"] = vRSerial;
    map["descAr"] = descAr;
    map["descEn"] = descEn;
    map["requestType"] = requestType;
    map["requeridNote"] = requeridNote;
    map["statusWF"] = statusWF;
    map["transDate"] = transDate;
    return map;
  }
}
class WorkFlowRecord {
  final int? fID;
  final int? vacationOrLeave;
  final int? requestType;
  final String? empName;
  final String? form;
  final String? fDescAr;
  final DateTime? addDate;
  final String? note;
  final String? actionStat; // Fixed the double '?' issue
  dynamic cache;

  WorkFlowRecord({
    this.fID,
    this.vacationOrLeave,
    this.requestType,
    this.empName,
    this.form,
    this.fDescAr,
    this.addDate,
    this.cache,
    this.note,
    this.actionStat,
  });

  factory WorkFlowRecord.map(dynamic obj) {
    return WorkFlowRecord(
      fID: obj['fID'] != null ? int.tryParse(obj['fID'].toString()) : null,
      vacationOrLeave: obj['vacationOrLeave'] != null ? int.tryParse(obj['vacationOrLeave'].toString()) : null,
      requestType: obj['requestType'] != null ? int.tryParse(obj['requestType'].toString()) : null,
      empName: obj['empName']?.toString(),
      form: obj['form']?.toString(),
      fDescAr: obj['fDescAr']?.toString(),
      addDate: obj['addDate'] != null ? DateTime.tryParse(obj['addDate'].toString()) : null,
      actionStat: obj['actionStat']?.toString(),
      note: obj['notes']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fID': fID,
      'vacationOrLeave': vacationOrLeave,
      'requestType': requestType,
      'empName': empName,
      'form': form,
      'fDescAr': fDescAr,
      'addDate': addDate?.toIso8601String(),
      'actionStat': actionStat,
      'notes': note,
    };
  }
}


class Notifications {
  final int? id;
  final int? empNo;
  final String? payEmpDesc;
  String? serviceTypeDesc;
  final String? itemDescription;
  final double? quantity;
  final String? remarksJustification;
  final String? departureDate;
  final String? returnDate;
  final String? routeFrom;
  final String? routeTo;
  final String? travelerName;
  final String? relation;
  final String? passportNumber;
  final String? subEmpDesc;
  final String? wPlaceDesc;
  // ignore: non_constant_identifier_names
  final double? basic_Salary;
  final double? requiredAmount;
  // ignore: non_constant_identifier_names
  final double? aldd_amount;
  final String? dOB;
  final String? dateIssuse;
  final String? dateExpiry;
  final String? placeIssue;
  final String? remarks;
  final String? transDate;
  final String? transTime;
  final int? monthNo;
  final int? requeridHours;
  final int? requeridMinut;
  final String? fileName;
  final String? dateUploded;
  final int? fileSize;
  final String? contentType;
  final String? vacTypeDesc;
  final String? startTime;
  final String? startDate;
  final String? endTime;
  final String? endDate;
  final int? serial;
  Notifications(
      {this.startTime,
      this.endTime,
      this.startDate,
      this.endDate,
      this.vacTypeDesc,
      this.id,
      this.empNo,
      this.payEmpDesc,
      this.serviceTypeDesc,
      this.itemDescription,
      this.quantity,
      this.remarksJustification,
      this.departureDate,
      this.returnDate,
      this.routeFrom,
      this.routeTo,
      this.travelerName,
      this.relation,
      this.passportNumber,
      this.subEmpDesc,
      this.wPlaceDesc,
// ignore: non_constant_identifier_names
      this.basic_Salary,
      this.requiredAmount,
// ignore: non_constant_identifier_names
      this.aldd_amount,
      this.dOB,
      this.dateIssuse,
      this.dateExpiry,
      this.placeIssue,
      this.remarks,
      this.transDate,
      this.transTime,
      this.monthNo,
      this.requeridHours,
      this.requeridMinut,
      this.fileName,
      this.dateUploded,
      this.fileSize,
      this.contentType,
      this.serial});
  factory Notifications.map(dynamic obj) {
    Notifications emp = new Notifications(
      id: int.parse(obj['id'].toString()),
      empNo: int.parse(obj['empNo'].toString()),
      payEmpDesc: obj['payEmpDesc'].toString(),
      vacTypeDesc: obj['vacTypeDesc'].toString(),
      startTime: obj['startTime'].toString(),
      startDate: obj['startDate'].toString(),
      endTime: obj['endTime'].toString(),
      endDate: obj['endDate'].toString(),
      serviceTypeDesc: obj['serviceTypeDesc'].toString(),
      itemDescription: obj['itemDescription'].toString(),
      quantity: double.parse(obj['quantity'].toString()),
      remarksJustification: obj['remarksJustification'].toString(),
      departureDate: obj['departureDate'].toString(),
      returnDate: obj['returnDate'].toString(),
      routeFrom: obj['routeFrom'].toString(),
      routeTo: obj['routeTo'].toString(),
      travelerName: obj['travelerName'].toString(),
      relation: obj['relation'].toString(),
      passportNumber: obj['passportNumber'].toString(),
      subEmpDesc: obj['subEmpDesc'].toString(),
      wPlaceDesc: obj['wPlaceDesc'].toString(),
      basic_Salary: double.parse(obj['basic_Salary'].toString()),
      requiredAmount: double.parse(obj['requiredAmount'].toString()),
      aldd_amount: double.parse(obj['aldd_amount'].toString()),
      dOB: obj['dOB'].toString(),
      dateIssuse: obj['dateIssuse'].toString(),
      dateExpiry: obj['dateExpiry'].toString(),
      placeIssue: obj['placeIssue'].toString(),
      remarks: obj['remarks'].toString(),
      transDate: obj['transDate'].toString(),
      transTime: obj['transTime'].toString(),
      monthNo: int.parse(obj['monthNo'].toString()),
      requeridHours: int.parse(obj['requeridHours'].toString()),
      requeridMinut: int.parse(obj['requeridMinut'].toString()),
      fileName: obj['fileName'].toString(),
      dateUploded: obj['dateUploded'].toString(),
      fileSize: int.parse(obj['fileSize'].toString()),
      contentType: obj['contentType'].toString(),
      serial: int.parse(obj['serial'].toString()),
    );
    return emp;
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['id'] = id;
    map['empNo'] = empNo;
    map['payEmpDesc'] = payEmpDesc;
    map['serviceTypeDesc'] = serviceTypeDesc;
    map['itemDescription'] = itemDescription;
    map['quantity'] = quantity;
    map['remarksJustification'] = remarksJustification;
    map['departureDate'] = departureDate;
    map['returnDate'] = returnDate;
    map['routeFrom'] = routeFrom;
    map['routeTo'] = routeTo;
    map['travelerName'] = travelerName;
    map['relation'] = relation;
    map['passportNumber'] = passportNumber;
    map['subEmpDesc'] = subEmpDesc;
    map['wPlaceDesc'] = wPlaceDesc;
    map['basic_Salary'] = basic_Salary;
    map['requiredAmount'] = requiredAmount;
    map['aldd_amount'] = aldd_amount;
    map['dOB'] = dOB;
    map['dateIssuse'] = dateIssuse;
    map['dateExpiry'] = dateExpiry;
    map['placeIssue'] = placeIssue;
    map['remarks'] = remarks;
    map['transDate'] = transDate;
    map['transTime'] = transTime;
    map['monthNo'] = monthNo;
    map['requeridHours'] = requeridHours;
    map['requeridMinut'] = requeridMinut;
    map['fileName'] = fileName;
    map['dateUploded'] = dateUploded;
    map['fileSize'] = fileSize;
    map['contentType'] = contentType;
    map['serial'] = serial;
    return map;
  }
}

class TimeAttModel {
  final int? empNo;
  final String? empEngName;
  String? empIn;
  String? empOut;
  final int? shiftNo;
  final String? engDesc;
  final DateTime? sDate;
  TimeAttModel(
      {this.empNo,
      this.empEngName,
      this.empIn,
      this.empOut,
      this.shiftNo,
      this.engDesc,
      this.sDate});
  factory TimeAttModel.map(dynamic obj) {
    TimeAttModel emp = new TimeAttModel(
      empNo: int.parse(obj['empNo'].toString()),
      empEngName: obj['empEngName'].toString(),
      empIn: obj['emp_In'].toString(),
      empOut: obj["emp_Out"].toString(),
      shiftNo: int.parse(obj["shiftNo"].toString()),
      engDesc: obj["engDesc"].toString(),
      sDate: DateTime.parse(obj["sDate"].toString()),
    );
    return emp;
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["empNo"] = empNo;
    map["empEngName"] = empEngName;
    map["emp_In"] = empIn;
    map["emp_Out"] = empOut;
    map["shiftNo"] = shiftNo;
    map["engDesc"] = engDesc;
    map["sDate"] = sDate;
    return map;
  }
}

class TimeAtt {
  final int? empNo;
  final String? totLeavesTF;
  String? empIn;
  String? empOut;
  final String? gridVacDesc;
  final String? totOvertTF;
  final double? totOvert;
  final DateTime? sDate;
  bool? registered = false;
  TimeAtt({
    this.empNo,
    this.totLeavesTF,
    this.empIn,
    this.empOut,
    this.gridVacDesc,
    this.totOvertTF,
    this.totOvert,
    this.sDate,
    this.registered,
  });
  factory TimeAtt.map(dynamic obj) {
    TimeAtt emp = new TimeAtt(
        sDate: DateTime.parse('${obj["sDate"]}'),
        empIn: '${obj["emp_IN"]}'.trim(),
        empOut: '${obj["emp_Out"]}'.trim(),
        totLeavesTF: '${obj["tot_LeavesTF"]}'.trim(),
        totOvertTF: '${obj["tot_OvertTF"]}'.trim(),
        totOvert: double.parse('${obj["tot_Overt"]}'),
        gridVacDesc: '${obj["gridVacDesc"] ?? ""}',
        registered: boolParse('${obj["requstedMobile"]}'));
    return emp;
  }
}

class News {
  final int? srl;
  final String? description;
  final String? subject;
  String? eventImage;
  News({
    this.srl,
    this.description,
    this.subject,
    this.eventImage,
  });

  factory News.map(dynamic obj) {
    News emp = new News(
      srl: int.parse(obj["srl"].toString()),
      description: obj['description'].toString(),
      subject: obj["subject"].toString(),
      eventImage: '${obj["eventImage"]}',
    );
    return emp;
  }
}

class Mssage {
  final int? id;
  final String? descr;
  final int? sender;
  final int? reciver;
  int? seen;
  int? refId;
  final DateTime? date;
  Mssage(
      {this.id,
      this.descr,
      this.sender,
      this.reciver,
      this.date,
      this.seen,
      this.refId});
  factory Mssage.map(dynamic obj) {
    Mssage emp = new Mssage(
      id: int.parse(obj['id'].toString()),
      refId: int.parse("${obj['refId'] ?? 0}"),
      seen: int.parse(obj['seen'].toString()),
      sender: int.parse(obj['senderNum'].toString()),
      reciver: int.parse(obj['reciverNum'].toString()),
      date: DateTime.parse(obj['dateTime'].toString()),
      descr: obj["message"].toString(),
    );
    return emp;
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["refId"] = refId;
    map["seen"] = seen;
    map["descr"] = descr;
    map["sender"] = sender;
    map["reciver"] = reciver;
    map["date"] = date;
    return map;
  }
}

class Colleague {
  final int? empnum;
  final int? room;
  final int? sort;
  final String? empname;
  String? image;
  int? get unreaded {
    return conversations.where((x) => x.sender == empnum && x.seen == 0).length;
  }

  Colleague({
    this.empnum,
    this.empname,
    this.image,
    this.sort,
    this.room,
  });
  factory Colleague.map(dynamic obj) {
    Colleague emp = new Colleague(
      empnum: int.parse('${obj['emp_num']}'),
      sort: int.parse('${obj['sort']}'),
      room: int.parse('${obj['room']}'),
      image: obj['image'].toString(),
      empname: obj["empname"].toString(),
    );
    return emp;
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["emp_num"] = empnum;
    map["empname"] = empname;
    map["image"] = image;
    return map;
  }
}

List<KeyValue> nt = [];
List<KeyValue> get noteTypes {
  if (nt.length == 0) {
    nt.add(new KeyValue(value: 'خطأ او مشكلة', valueE: 'Bug or glitch'));
    nt.add(new KeyValue(value: 'اقتراح', valueE: 'Suggestion'));
    nt.add(new KeyValue(value: 'ملاحظة', valueE: 'note'));
  }

  return nt;
}

class KeyValue {
  final String? value;
  final String? valueE;

  KeyValue({
    this.value,
    this.valueE,
  });
}

class KeyListValue {
  int? compNo;
  int? vRSerial;
  int? requestType;
  List? data;
  KeyListValue({
    this.compNo,
    this.vRSerial,
    this.requestType,
    this.data,
  });
}

String? getEnglish(String? arabic) {
  if (arabic == 'طلبات الخدمات المالية') return 'Financial services requests';
  if (arabic == 'طلبات الدوام') return 'Attendance requests';
  if (arabic == 'طلبات اخرى') return 'Other requests';
  if (arabic == 'طلب معونة اجتماعية') return 'Social aid request';
  if (arabic == 'سلفة') return 'Advance payment';
  if (arabic == 'عمل اضافي') return 'OverTime work';
  if (arabic == 'طلب اجازة') return 'Vacation request';
  if (arabic == 'طلب مغادرة') return 'Leave request';
  if (arabic == 'نسيان ختم') return 'Missed records';
  if (arabic == 'تسجيل دوام') return 'Time Recording';
  if (arabic == 'كشف الراتب') return 'Salary Slip';
  if (arabic == 'كشف الدوام') return 'Worksheet';
  if (arabic == 'طلب خدمة صحية') return 'Health service';
  if (arabic == 'طلب خدمة عامة') return 'Public service';
  if (arabic == 'طلب خدمة it') return 'IT service';
  if (arabic == 'رصيد الاجازات') return 'Vacation balance';
  if (arabic == 'الكتب') return 'Letters';
  if (arabic == 'الوثائق') return 'Documents';
  if (arabic == 'متابعة الدوام') return 'Follow up';
  if (arabic == 'طلب مواصلات') return 'Transportation';
  if (arabic == 'مهمة عمل') return 'Job mission';
  if (arabic == "انهاء مهمة عمل") return 'Job accomplishment';
  return '****';
}

class TransDF {
  String? city;
  String? area;
  String? customer;
  String? reason;
  double? amount;
  DateTime? date;

  TransDF(
      {this.area,
      this.customer,
      this.date,
      this.reason,
      this.city,
      this.amount});
  factory TransDF.map(dynamic obj) {
    TransDF emp = new TransDF(
      area: obj['area'],
      customer: obj['customer'],
      date: DateTime.parse(obj['date'].toString()),
      reason: obj['reason'],
      city: obj['city'],
      amount: obj['amount'],
    );
    return emp;
  }

  static Map<String, dynamic> toMap(TransDF data) => {
        'area': data.area,
        'customer': data.customer,
        'date': data.date?.toIso8601String(),
        'reason': data.reason,
        'city': data.city,
        'amount': data.amount,
      };
}

String? encodeTransDF(List<TransDF> data) => json.encode(
      data.map<Map<String, dynamic>>((music) => TransDF.toMap(music)).toList(),
    );
List<TransDF> decodeTransDF(String? data) => (json.decode(data!) as List<dynamic>)
    .map<TransDF>((item) => TransDF.map(item))
    .toList();
