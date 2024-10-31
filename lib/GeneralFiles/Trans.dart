import 'dart:ui';
import 'package:alpha/GeneralFiles/General.dart';

TextDirection get direction =>
    gLang == '1' ? TextDirection.rtl : TextDirection.ltr;

TextAlign get textAlign => gLang == "1" ? TextAlign.right : TextAlign.left;
String get appTitle => gLang == '1' ? 'الخدمة الذاتية' : 'SELF SERVICE';
String get version => gLang == '1' ? 'الاصدار' : 'version';
String get rejected => gLang == '1' ? 'مرفوض' : 'rejected';
String get approved => gLang == '1' ? 'موافق' : 'approved';
String get pending => gLang == '1' ? 'في الانتظار' : 'pending';
String get search => gLang == '1' ? 'بحث' : 'Search';
String get save => gLang == '1' ? 'حفظ' : 'Save';
String get attendanceRegistration =>
    gLang == '1' ? 'تسجيل الدوام' : 'Attendance registration';
String get saveDialog => gLang == '1'
    ? 'هل انت متأكد من حفظ هذه المعلومات ؟'
    : 'Are you sure to save this data?';
String get info1 => gLang == '1'
    ? 'تم تصميم التطبيق من قِبل'
    : 'The application was designed by';
String get info2 => gLang == '1'
    ? 'الشركة العامة للبرمجيات - المملكة الاردنية الهاشمية'
    : 'GCE Soft - The Hashemite Kingdom of Jordan';

String get info3 => gLang == '1'
    ? 'ليكون مكملا لنظام الموارد البشرية، حيث يمكن النظام الموظفين من الوصول الى جميع بياناتهم المالية والادارية وتقديم طلباتهم المتعلقة بجميع شؤونهم وفق نظام موافقات الكتروني.'
    : 'To be a complement to the human resources system, as the system enables employees to access all their financial and administrative data and submit their requests related to all their affairs according to an electronic approval system.';
String get username => gLang == '1' ? 'اسم المستخدم' : 'User name';
String get password => gLang == '1' ? 'كلمة المرور' : 'Password';
String get changePassword =>
    gLang == '1' ? 'تغيير كلمة المرور' : 'Change password';
String get confirmPassword =>
    gLang == '1' ? 'تأكيد كلمة المرور' : 'Confirm password';
String get newPassword => gLang == '1' ? 'كلمة المرور الجديدة' : 'New password';
String get currentPassword =>
    gLang == '1' ? 'كلمة المرور الحالية' : 'Current password';
String get remmemberData => gLang == '1' ? 'حفظ المعلومات' : 'Remember data';
String get connect => gLang == '1' ? 'اتــصــال' : 'Connect';
String get cancel => gLang == '1' ? 'الغاء' : 'Cancel';
String get login => gLang == '1' ? 'تسجيل الدخول' : 'Login';
String get demo => gLang == '1' ? 'شركة تجريبية' : 'Demo company';
String get demoUserName =>
    gLang == '1' ? '**  اسم المستخدم : admin' : '**  User name : admin';
String get demoPassword =>
    gLang == '1' ? '**  كلمة المرور : admin' : '**  Password : admin';
String get demoMessage => gLang == '1'
    ? 'لن تستطيع تغيير البيانات , لان هذه الشركة للعرض فقط'
    : 'You will not be able to change the data, because this company is for display only';
String get exit => gLang == '1' ? 'خروج' : 'Exit';
String get exitMessage =>
    gLang == '1' ? 'هل حقا تريد الخروج ؟' : 'Do you really want to exit?';
String get err1 => gLang == '1'
    ? 'نعتذر : لا يمكن تشغيل البرنامج على المحاكي'
    : 'Sorry, it is not possible to run the program on the emulator';
String get err2 => gLang == '1'
    ? 'يجب ادخال رقم الشركة'
    : 'The company number must be entered';
String get err3 =>
    gLang == '1' ? 'الرقم غير صحيح' : 'The company number is incorrect';
String get err4 =>
    gLang == '1' ? 'يجب ادخال اسم مستخدم' : 'Username must be entered';
String get err5 => gLang == '1' ? 'كلمة مرور غير صحيحة' : 'Incorrect password';
String get err6 =>
    gLang == '1' ? 'لا يوجد عنوان خادم' : 'There is no server addresss';
String get err7 =>
    gLang == '1' ? 'لا يوجد عنوان بروتوكول' : 'No protocol address';

String get companyNo => gLang == '1' ? 'رقم الشركة' : 'Company No';
String get myTeam => gLang == '1' ? 'مجموعة العمل' : 'Work team';
String get workflow => gLang == '1' ? 'الموافقات' : 'workflow';
String get news => gLang == '1' ? 'الاعلانات' : 'news';
String get colors => gLang == '1' ? 'الالوان' : 'Colors';
String get photo => gLang == '1' ? 'الصورة' : 'Profile photo';
String get change => gLang == '1' ? 'تغيير' : 'Change';
String get fontSize => gLang == '1' ? 'حجم الخط' : 'Font size';
String get darkTheme => gLang == '1' ? 'الوضع الداكن' : 'Dark theme';
String get refresh => gLang == '1' ? 'تحديث' : 'refresh';
String get refreshDone =>
    gLang == '1' ? 'تم تحديث البيانات' : 'Data has been updated';

String get vacationBalance =>
    gLang == '1' ? 'رصيد الإجازة' : 'Vacation balance';
String get drawer2 =>
    gLang == '1' ? 'اعتماد الدخول والخروج' : 'Confirm log in and out';
String get drawer8 => gLang == '1' ? 'سجل تسجيل الدوام' : 'Time recording log';
String get drawer3 => gLang == '1' ? 'رصيد اجازاتي' : 'My vacation balance';
String get drawer4 => gLang == '1' ? 'سجل طلباتي' : 'My requests log';
String get drawer5 => gLang == '1' ? 'خيارات' : 'Options';
String get drawer6 => gLang == '1' ? 'حول التطبيق' : 'About';
String get drawer7 => gLang == '1' ? 'تسجيل الخروج' : 'Log out';
String get typeCompanyNo =>
    gLang == '1' ? 'ادخل رقم الشركة' : 'Type company no';

String get logOutMessage => gLang == '1'
    ? 'ستحتاج الى كلمة المرور , هل تريد تسجيل الخروج؟'
    : 'You will need the password. Do you want to log out?';

String get welcomeText => gLang == '1'
    ? '''


** يرجى ادخال رقم الشركة الخاصة بك.
** اذا كنت ترغب بترجربة النظام فقط , انقر زر Demo.
** لا تتردد بالاتصال بنا عبر البريد الالكتروني :
m.alshara@gcesoft.com.jo
                  '''
    : '''


** Please enter your company number.
** If you only want to try the system, click the Demo button.
** Do not hesitate to contact us via email:
m.alshara@gcesoft.com.jo
                  ''';

String arEn(String ar, String en) => gLang == "1" ? ar : en;
