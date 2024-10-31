import 'dart:math' as math;
import 'package:alpha/GeneralFiles/General.dart';
import 'package:alpha/GeneralFiles/Trans.dart' as trans;
import 'package:alpha/pages/ChangePW.dart';
import 'package:alpha/pages/mainPage.dart';
import 'package:alpha/pages/Settings.dart';
import 'package:flutter/material.dart';
import 'package:alpha/pages/login.page.dart';
import 'package:alpha/routs.dart';
import 'package:alpha/pages/Presenter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with WidgetsBindingObserver
    implements GeneralListener {
  SplashScreenState() {
    var authStateProvider = new Provider();
    authStateProvider.subscribe(this);
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    // WidgetsBinding.instance
    //     .addPostFrameCallback((_) async => await loadNewsAndEvents());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void setState(fn) {
    super.setState(fn);
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        // print('appLifeCycleState inactive');
        break;
      case AppLifecycleState.resumed:
        // print('appLifeCycleState resumed');
        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.reload();
        if (preferences.containsKey('refreshData')) refreshData();

        break;
      case AppLifecycleState.paused:
        // print('appLifeCycleState paused');
        break;
      case AppLifecycleState.detached:
        // print('appLifeCycleState detached');
        break;
      case AppLifecycleState.hidden:
        // TODO: Handle this case.
    }
  }

  @override
  Widget build(BuildContext context) {
    cont = context;

    return MaterialApp(
      restorationScopeId: 'root',
      localizationsDelegates: [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        Locale("ar", "JO"),
        Locale("en", "US"),
      ],
      locale: local,
      title: trans.appTitle,
      color: Colors.black,
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: 'TheSans',
        scaffoldBackgroundColor: Colors.grey[100],
        primaryColor: primaryColor,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          backgroundColor: primaryColor,
        ),
        pageTransitionsTheme: PageTransitionsTheme(builders: {
          TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
        }),
        textTheme: TextTheme(
          displayLarge: TextStyle(
              fontSize: fSize(86),
              color: Colors.black,
              fontWeight: FontWeight.normal,
              letterSpacing: -1.5),
          displayMedium: TextStyle(
              color: Colors.black,
              fontSize: fSize(50),
              fontWeight: FontWeight.normal,
              letterSpacing: -0.5),
          displaySmall: TextStyle(
              color: Colors.black,
              fontSize: fSize(38),
              fontWeight: FontWeight.normal,
              letterSpacing: 0),
          headlineMedium: TextStyle(
              color: Colors.black,
              fontSize: fSize(24),
              fontWeight: FontWeight.normal,
              letterSpacing: 0.25),
          headlineSmall: TextStyle(
              color: Colors.black,
              fontSize: fSize(14),
              fontWeight: FontWeight.normal,
              letterSpacing: 0),
          titleLarge: TextStyle(
              color: Colors.black,
              fontSize: fSize(10),
              fontWeight: FontWeight.normal,
              letterSpacing: 0.15),
          titleMedium: TextStyle(
              color: Colors.black,
              fontSize: fSize(2),
              fontWeight: FontWeight.normal,
              letterSpacing: 0.15),
          titleSmall: TextStyle(
              color: Colors.black,
              fontSize: fSize(2),
              fontWeight: FontWeight.normal,
              letterSpacing: 0.1),
          bodyLarge: TextStyle(
              color: Colors.black,
              fontSize: fSize(2),
              fontWeight: FontWeight.normal,
              letterSpacing: 0.5),
          bodyMedium: TextStyle(
              color: Colors.black,
              fontSize: fSize(1),
              fontWeight: FontWeight.normal,
              letterSpacing: 0.25),
          labelLarge: TextStyle(
              color: Colors.black,
              fontSize: fSize(4),
              fontWeight: FontWeight.normal,
              letterSpacing: 1.25),
          bodySmall: TextStyle(
              color: Colors.black,
              fontSize: fSize(2),
              fontWeight: FontWeight.normal,
              letterSpacing: 0.4),
          labelSmall: TextStyle(
              color: Colors.black,
              fontSize: fSize(1),
              fontWeight: FontWeight.normal,
              letterSpacing: 1.5),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        splashFactory: CustomSplashFactory(),
        fontFamily: 'TheSans',
        primaryColor: primaryColor,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          backgroundColor: primaryColor,
        ),
        pageTransitionsTheme: PageTransitionsTheme(builders: {
          TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
        }),
        textTheme: TextTheme(
          displayLarge: TextStyle(
              fontSize: fSize(86),
              fontWeight: FontWeight.normal,
              letterSpacing: -1.5),
          displayMedium: TextStyle(
              fontSize: fSize(50),
              fontWeight: FontWeight.normal,
              letterSpacing: -0.5),
          displaySmall: TextStyle(
              fontSize: fSize(38),
              fontWeight: FontWeight.normal,
              letterSpacing: 0),
          headlineMedium: TextStyle(
              fontSize: fSize(24),
              fontWeight: FontWeight.normal,
              letterSpacing: 0.25),
          headlineSmall: TextStyle(
              fontSize: fSize(14),
              fontWeight: FontWeight.normal,
              letterSpacing: 0),
          titleLarge: TextStyle(
              fontSize: fSize(10),
              fontWeight: FontWeight.normal,
              letterSpacing: 0.15),
          titleMedium: TextStyle(
              fontSize: fSize(2),
              fontWeight: FontWeight.normal,
              letterSpacing: 0.15),
          titleSmall: TextStyle(
              fontSize: fSize(2),
              fontWeight: FontWeight.normal,
              letterSpacing: 0.1),
          bodyLarge: TextStyle(
              fontSize: fSize(2),
              fontWeight: FontWeight.normal,
              letterSpacing: 0.5),
          bodyMedium: TextStyle(
              fontSize: fSize(1),
              fontWeight: FontWeight.normal,
              letterSpacing: 0.25),
          labelLarge: TextStyle(
              fontSize: fSize(4),
              fontWeight: FontWeight.normal,
              letterSpacing: 1.25),
          bodySmall: TextStyle(
              fontSize: fSize(2),
              fontWeight: FontWeight.normal,
              letterSpacing: 0.4),
          labelSmall: TextStyle(
              fontSize: fSize(1),
              fontWeight: FontWeight.normal,
              letterSpacing: 1.5),
        ),
      ),
      themeMode: darkTheme ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: (serverURL == null || myCompanyNumber == '')
          ? SettingPage()
          : (me == null || remember == false)
              ? LoginScreen()
              : goThere,
      routes: routes,
    );
  }

  @override
  void onChangeLanguage() {
    setState(() {});
  }
}

Widget get goThere {
  //macAddress = await GetMac.macAddress;
  if (weakPasswords.contains(password_)) {
    return ChangePW();
  }
  return MainPage();
}

const Duration _kUnconfirmedSplashDuration = const Duration(milliseconds: 250);
const Duration _kSplashFadeDuration = const Duration(milliseconds: 250);
const double _kSplashInitialSize = 0.0;
const double _kSplashConfirmedVelocity = 1;

class CustomSplash extends InteractiveInkFeature {
  static const InteractiveInkFeatureFactory splashFactory =
      CustomSplashFactory();

  CustomSplash({
    required MaterialInkController controller,
    required RenderBox referenceBox,
    Offset? position,
    Color? color, 
    bool containedInkWell = false,
    RectCallback? rectCallback,
    BorderRadius? borderRadius,
    double? radius,
    VoidCallback? onRemoved,
  })  : _position = position!,
        _borderRadius = borderRadius ?? BorderRadius.zero,
        _targetRadius = radius ?? _getTargetRadius(
            referenceBox, containedInkWell, rectCallback!, position),
        _clipCallback = _getClipCallback(referenceBox, containedInkWell, rectCallback!),
        _repositionToReferenceBox = !containedInkWell,
        super(controller: controller, referenceBox: referenceBox, color: color!) { // Pass the color parameter here
    assert(_borderRadius != null);
    controller.addInkFeature(this);

    _radiusController = AnimationController(
      duration: _kUnconfirmedSplashDuration,
      vsync: controller.vsync,
    )..addListener(controller.markNeedsPaint)
      ..forward();

    _alphaController = AnimationController(
      duration: _kSplashFadeDuration,
      vsync: controller.vsync,
    )..addListener(controller.markNeedsPaint)
      ..addStatusListener(_handleAlphaStatusChanged);

    _radius = Tween<double>(
      begin: _kSplashInitialSize,
      end: _targetRadius,
    ).animate(_radiusController);

    _alpha = IntTween(
      begin: color?.alpha ?? 0,
      end: 0,
    ).animate(_alphaController);
  }

  final Offset _position;
  final BorderRadius _borderRadius;
  final double _targetRadius;
  final RectCallback? _clipCallback;
  final bool _repositionToReferenceBox;

  late final Animation<double> _radius; // Kept as late
  late final AnimationController _radiusController; // Kept as late

  late final Animation<int> _alpha; // Kept as late
  late final AnimationController _alphaController;

  @override
  void confirm() {
    final int duration = (_targetRadius / _kSplashConfirmedVelocity).floor();
    _radiusController
      ..duration = Duration(milliseconds: duration)
      ..forward();
    _alphaController.forward();
  }

  @override
  void cancel() {
    _alphaController.forward();
  }

  void _handleAlphaStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) dispose();
  }

  @override
  void dispose() {
    _radiusController.dispose();
    _alphaController.dispose();
    super.dispose();
  }


  RRect _clipRRectFromRect(Rect rect) {
    return new RRect.fromRectAndCorners(
      rect,
      topLeft: _borderRadius.topLeft,
      topRight: _borderRadius.topRight,
      bottomLeft: _borderRadius.bottomLeft,
      bottomRight: _borderRadius.bottomRight,
    );
  }

  void _clipCanvasWithRect(Canvas canvas, Rect rect, {Offset? offset}) {
    Rect clipRect = rect;
    if (offset != null) {
      clipRect = clipRect.shift(offset);
    }
    if (_borderRadius != BorderRadius.zero) {
      canvas.clipRRect(_clipRRectFromRect(clipRect));
    } else {
      canvas.clipRect(clipRect);
    }
  }

  @override
  void paintFeature(Canvas canvas, Matrix4 transform) {
    final Paint paint = new Paint()..color = color.withAlpha(_alpha.value);
    Offset? center = _position;
    if (_repositionToReferenceBox)
      center = Offset.lerp(center, referenceBox.size.center(Offset.zero),
          _radiusController.value);
    final Offset? originOffset = MatrixUtils.getAsTranslation(transform);
    if (originOffset == null) {
      canvas.save();
      canvas.transform(transform.storage);
      if (_clipCallback != null) {
        _clipCanvasWithRect(canvas, _clipCallback!());
      }
      canvas.drawCircle(center!, _radius.value, paint);
      canvas.restore();
    } else {
      if (_clipCallback != null) {
        canvas.save();
        _clipCanvasWithRect(canvas, _clipCallback!(), offset: originOffset);
      }
      canvas.drawCircle(center! + originOffset, _radius.value, paint);
      if (_clipCallback != null) canvas.restore();
    }
  }
}

double _getTargetRadius(RenderBox referenceBox, bool containedInkWell,
    RectCallback rectCallback, Offset position) {
  if (containedInkWell) {
    final Size size =
        rectCallback != null ? rectCallback().size : referenceBox.size;
    return _getSplashRadiusForPositionInSize(size, position);
  }
  return Material.defaultSplashRadius;
}

double _getSplashRadiusForPositionInSize(Size bounds, Offset position) {
  final double d1 = (position - bounds.topLeft(Offset.zero)).distance;
  final double d2 = (position - bounds.topRight(Offset.zero)).distance;
  final double d3 = (position - bounds.bottomLeft(Offset.zero)).distance;
  final double d4 = (position - bounds.bottomRight(Offset.zero)).distance;
  return math.max(math.max(d1, d2), math.max(d3, d4)).ceilToDouble();
}

RectCallback? _getClipCallback(
    RenderBox ?referenceBox, bool ?containedInkWell, RectCallback? rectCallback) {
  if (rectCallback != null) {
    assert(containedInkWell!);
    return rectCallback;
  }
  if (containedInkWell!) return () => Offset.zero & referenceBox!.size;
  return null;
}

class CustomSplashFactory extends InteractiveInkFeatureFactory {
  const CustomSplashFactory();
  @override
  InteractiveInkFeature create(
      {MaterialInkController? controller,
      RenderBox? referenceBox,
      Offset? position,
      Color? color,
      TextDirection ?textDirection,
      bool containedInkWell = false,
      rectCallback,
      BorderRadius? borderRadius,
      ShapeBorder? customBorder,
      double? radius,
      onRemoved}) {
    return new CustomSplash(
      controller: controller!,
      referenceBox: referenceBox!,
      position: position!,
      color: color!,
      containedInkWell: containedInkWell,
      rectCallback: rectCallback!,
      borderRadius: borderRadius!,
      radius: radius!,
      onRemoved: onRemoved!,
    );
  }
}
