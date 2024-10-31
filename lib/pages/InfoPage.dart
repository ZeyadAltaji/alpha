import 'dart:math';
import 'package:alpha/GeneralFiles/Trans.dart' as trans;
import 'package:alpha/GeneralFiles/General.dart';
import 'package:alpha/GeneralFiles/ShowUp.dart';
import 'package:flutter/material.dart';

class BubblesPage extends StatefulWidget {
  BubblesPage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<BubblesPage> with TickerProviderStateMixin {
  // Animation controllers
 late AnimationController bubbleController;
  late AnimationController _backgroundController;
  late AnimationController alignmentController;

  // Animation for bubble and background
  late Animation<double?> bubbleAnimation;
  late Animation<Color?> backgroundAnimation;

  // List of bubble widgets shown on screen
  final List<Widget> bubbleWidgets = [];
  late Animation<Alignment> alignmentTopAnimation;
  late Animation<Alignment> alignmentBottomAnimation;
  // Flag to check if the bubbles are already present or not
  bool areBubblesAdded = false;

  // Color animations based on the theme
  final Animatable<Color?> backgroundDark = TweenSequence<Color?>([
    TweenSequenceItem(
      weight: 0.5,
      tween: ColorTween(
        begin: Colors.blue[800]?.withAlpha(50),
        end: Colors.lightBlue.withAlpha(50),
      ),
    ),
    TweenSequenceItem(
      weight: 0.5,
      tween: ColorTween(
        begin: Colors.lightBlue.withAlpha(50),
        end: Colors.blue[800]?.withAlpha(50),
      ),
    ),
  ]);

  final Animatable<Color?> backgroundNormal = TweenSequence<Color?>([
    TweenSequenceItem(
      weight: 0.5,
      tween: ColorTween(
        begin: Colors.blue[500]?.withAlpha(50),
        end: Colors.lightBlue.withAlpha(50),
      ),
    ),
    TweenSequenceItem(
      weight: 0.5,
      tween: ColorTween(
        begin: Colors.lightBlue.withAlpha(50),
        end: Colors.blue[500]?.withAlpha(50),
      ),
    ),
  ]);
 final Animatable<Color?> backgroundLight = TweenSequence<Color?>([
    TweenSequenceItem(
      weight: 0.5,
      tween: ColorTween(
        begin: darkTheme ? Colors.blue[200]?.withAlpha(50) : Colors.blue[200],
        end: darkTheme ? Colors.yellow[200]?.withAlpha(50) : Colors.yellow[200],

      ),
    ),
    TweenSequenceItem(
      weight: 0.5,
      tween: ColorTween(
         begin:
            darkTheme ? Colors.yellow[200]?.withAlpha(50) : Colors.yellow[200],
        end: darkTheme ? Colors.blue[200]?.withAlpha(50) : Colors.blue[200],

      ),
    ),
  ]);

  AlignmentTween alignmentTop =
      AlignmentTween(begin: Alignment.topRight, end: Alignment.topLeft);
  AlignmentTween alignmentBottom =
      AlignmentTween(begin: Alignment.bottomRight, end: Alignment.bottomLeft);

  @override
  void initState() {
    super.initState();
    alignmentController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    backgroundAnimation = (darkTheme ? backgroundDark : backgroundNormal).animate(_backgroundController);
    alignmentTopAnimation = alignmentTop.animate(alignmentController);
    alignmentBottomAnimation = alignmentBottom.animate(alignmentController);
    bubbleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    bubbleAnimation = CurvedAnimation(
      parent: bubbleController, curve: Curves.easeIn)
    ..addListener(() {})
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          addBubbles(animation: bubbleAnimation, topPos: -1.001, bubbles: 2);
          bubbleController.reverse();
        });
      }
      if (status == AnimationStatus.dismissed) {
        setState(() {
          addBubbles(animation: bubbleAnimation, topPos: -1.001, bubbles: 4);
          bubbleController.forward();
        });
      }
    });

    bubbleAnimation = CurvedAnimation(
        parent: bubbleController, curve: Curves.easeIn)
      ..addListener(() {})
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            addBubbles(animation: bubbleAnimation, topPos: -1.001, bubbles: 2);
            bubbleController.reverse();
          });
        }
        if (status == AnimationStatus.dismissed) {
          setState(() {
            addBubbles(animation: bubbleAnimation, topPos: -1.001, bubbles: 4);
            bubbleController.forward();
          });
        }
      });

    bubbleController.forward();
  }

  int delayAmount = 500;
  @override
  Widget build(BuildContext context) {
    // Add below to add bubbles intially.
    if (!areBubblesAdded) {
      addBubbles(animation: bubbleAnimation);
    }
    return AnimatedBuilder(
      animation: backgroundAnimation,
      builder: (context, child) {
        return Scaffold(
          // bottomNavigationBar: AdPage(),
          body: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Stack(
              children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: alignmentTopAnimation.value,
                      end: alignmentBottomAnimation.value,
                          colors: [
                            backgroundAnimation.value ?? Colors.blue[800]!,
                            backgroundAnimation.value ?? Colors.lightBlue,
                            backgroundAnimation.value ?? Colors.blue[200]!,
                          ],

                        ),
                      ),
                    ),
                  ] +
                  bubbleWidgets +
                  [
                    Container(
                      child: Directionality(
                        textDirection: trans.direction,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Center(
                              child: Center(
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 15),
                                  child: Column(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            30, 0, 30, 0),
                                        child: new Image(
                                          image: AssetImage(
                                              'images/ic_launcher.png'),
                                          width: 110,
                                          height: 110,
                                        ),
                                      ),
                                      ShowUp(
                                        child: Text(
                                          trans.appTitle,
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.white),
                                        ),
                                        delay: delayAmount,
                                      ),
                                      ShowUp(
                                        child: Text(
                                          "${trans.version} : $appVersion",
                                          style: TextStyle(fontSize: 10),
                                        ),
                                        delay: delayAmount,
                                      ),
                                      ShowUp(
                                        child: Center(
                                          child: Text(trans.info1),
                                        ),
                                        delay: delayAmount + 500,
                                      ),
                                      ShowUp(
                                        child: Center(
                                          child: Container(
                                            height: 100,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 70,
                                                      vertical: 0),
                                              child: new Image(
                                                image: AssetImage(
                                                    'images/login_background.png'),
                                                width: double.infinity,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    .2,
                                              ),
                                            ),
                                          ),
                                        ),
                                        delay: delayAmount + 1500,
                                      ),
                                      ShowUp(
                                        child: Center(
                                          child: Text(trans.info2),
                                        ),
                                        delay: delayAmount + 2500,
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      ShowUp(
                                        child: Column(
                                          children: <Widget>[
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(20.0),
                                              child: Text(
                                                trans.info3,
                                                textAlign: TextAlign.justify,
                                              ),
                                            ),
                                          ],
                                        ),
                                        delay: delayAmount + 3500,
                                      ),
                                      for (var n in whatsNew)
                                        ShowUp(
                                          delay: delayAmount +
                                              3500 +
                                              (1000 *
                                                  (whatsNew.indexOf(n) + 1)),
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height: 20,
                                              ),
                                              whatsNew.indexOf(n) == 0
                                                  ? Container(
                                                      padding: EdgeInsets.only(
                                                          left: 25, right: 25),
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      child: Text('$n'))
                                                  : Container(
                                                      padding: EdgeInsets.only(
                                                          left: 25, right: 25),
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      child: Text(
                                                          '   ${arEn("👈", "👉")}  $n')),
                                            ],
                                          ),
                                        )
                                    ],
                                  ),
                                ),
                              ),
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

  @override
  void dispose() {
    bubbleController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  void addBubbles({animation, topPos = 0, leftPos = 0, bubbles = 30}) {
    for (var i = 0; i < bubbles; i++) {
      var range = Random();
      var minSize = range.nextInt(30).toDouble();
      var maxSize = range.nextInt(30).toDouble();
      var left = leftPos == 0
          ? range.nextInt(MediaQuery.of(context).size.width.toInt()).toDouble()
          : leftPos;
      var top = topPos == 0
          ? range.nextInt(MediaQuery.of(context).size.height.toInt()).toDouble()
          : topPos;

      var bubble = new Positioned(
          left: left,
          top: top,
          child: AnimatedBubble(
              animation: animation, startSize: minSize, endSize: maxSize));

      setState(() {
        areBubblesAdded = true;
        bubbleWidgets.add(bubble);
        bubbleWidgets.add(bubble);
      });
    }
  }
}

class AnimatedBubble extends AnimatedWidget {
  final Matrix4 transform = Matrix4.identity();

  final double? startSize;
  final double? endSize;

  AnimatedBubble({
    Key? key,
    required Animation<double> animation, // Use required
    this.startSize,
    this.endSize,
  }) : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    // Cast the listenable to Animation<double>
    final animation = listenable as Animation<double>;
    final _sizeTween = Tween<double>(begin: startSize, end: endSize);

    // Translate the bubble slightly upwards
    transform.translate(0.0, 0.5, 0.0);

    return Opacity(
      opacity: 0.2,
      child: Transform(
        transform: transform,
        child: Container(
          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          height: _sizeTween.evaluate(animation),
          width: _sizeTween.evaluate(animation),
        ),
      ),
    );
  }
}

