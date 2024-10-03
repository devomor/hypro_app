import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hypro/game/circle_and_aviator_controller.dart';
import 'package:get/get.dart';

class AviatorGameScreen extends StatefulWidget {
  @override
  _AviatorGameScreenState createState() => _AviatorGameScreenState();
}

class _AviatorGameScreenState extends State<AviatorGameScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _moveController;
  late AnimationController _verticalController;
  late Animation<double> _animation;
  late Animation<double> _animation1;
  late Animation<double> _verticalAnimation;
  final gameController = Get.put(CirleAndAviatorContoller());
  TextEditingController inputController = TextEditingController();

  bool isFading = false;
  bool _isDelayActive = false;
  bool _isGameInit = false;
  bool _startGame = false;

  List<double> datalist = [
    0.100,
    0.200,
    0.300,
    0.400,
    0.500,
    0.600,
    0.700,
    0.800,
  ];

  double getRandomValue(List<double> list) {
    final random = Random();
    int index = random.nextInt(list.length);
    return list[index];
  }

  @override
  void initState() {
    super.initState();
    gameController.getBalance();
    gameController.min_amount.value = 100;
    inputController.text = gameController.min_amount.value.toString();

    // Initialize the main animation controller
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 6),
    );

    // Initialize the move animation controller
    _moveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    // Initialize the vertical animation controller
    _verticalController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(reverse: true); // Repeat the animation in reverse

    // Main animation for moving the plane getRandomValue(datalist)
    _animation = Tween<double>(begin: 0, end: getRandomValue(datalist)).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
        reverseCurve: Curves.easeInOut,
      ),
    )..addListener(() {
        setState(() {});
      });

    // Define the move animation
    _animation1 = Tween<double>(begin: 0, end: 500).animate(
      CurvedAnimation(
        parent: _moveController,
        curve: Curves.linear,
      ),
    )..addListener(() {
        setState(() {});
      });

    // Define the vertical animation
    _verticalAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _verticalController,
        curve: Curves.easeInOut,
      ),
    )..addListener(() {
        setState(() {});
      });

    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          isFading = true;
          _startGame = false;
          _moveController.forward();
          _verticalController.stop();
        });
        // double calculatedValue = (_animation.value * 5 + 1);
        //
        // gameController.initAviatorGameClose(amount: 1, gameId: 1);
        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _isDelayActive = true;
            });
          }
        });
      }
    });

    Timer.periodic(Duration(seconds: 23), (Timer timer) {
      setState(() {
        _isGameInit == true ? _startGame = true : _startGame = false;
        _isGameInit = false;
        _isDelayActive = false;
        isFading = false;
      });
      _controller.reset();
      _moveController.reset();
      _verticalController.reset();
      _controller.forward();

      _animation =
          Tween<double>(begin: 0, end: getRandomValue(datalist)).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.ease,
          reverseCurve: Curves.elasticOut,
        ),
      );

      // Define the move animation
      // _animation1 = Tween<double>(begin: 0, end: 500).animate(
      //   CurvedAnimation(
      //     parent: _moveController,
      //     curve: Curves.linear,
      //   ),
      // );
      //
      // // Define the vertical animation
      // _verticalAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      //   CurvedAnimation(
      //     parent: _verticalController,
      //     curve: Curves.easeInOut,
      //   ),
      // );
    });
  }

  @override
  void dispose() {
    _moveController.dispose();
    _controller.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF0D0101),
        title: Text(
          "Aviator",
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        actions: [
          Obx(() {
            if (gameController.isLoadings.value) {
              return Container(
                height: 10,
                width: 10,
                child: CircularProgressIndicator(color: Colors.white),
              );
            } else {
              return Padding(
                padding: EdgeInsets.only(right: 40),
                child: Text(
                  "Balance: \$${gameController.balance}",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              );
            }
          }),
        ],
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0D0101),
              Color(0xFF1B1C1D),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                double screenWidth = MediaQuery.of(context).size.width;
                double screenHeight = MediaQuery.of(context).size.height;
                return Stack(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      // margin: EdgeInsets.only(left: screenWidth * 0.01),
                      padding: EdgeInsets.only(
                          bottom: screenHeight * 0.03,
                          left: screenWidth * 0.05),
                      height: screenHeight * 0.3, // Adjust height
                      width: double.infinity, // Adjust width
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                              'assets/aviator_game/960x540 Background.gif'),
                          opacity: 0.8,
                          fit: BoxFit.contain,
                        ),
                      ),
                      child: isFading != true
                          ? CustomPaint(
                              painter: GraphPainter(
                                  progress: _animation.value.clamp(0.0, 1.0),
                                  // progres1: (double.parse(
                                  //             (_animation.value * 5 + 1)
                                  //                 .toStringAsFixed(2)) >=
                                  //         3.00
                                  //     ? _verticalAnimation.value * 0.5
                                  //     : 0.3),
                                  progres1: 0.500),
                              size: Size.infinite,
                            )
                          : Container(
                              // alignment: Alignment(30, 30),
                              height: screenHeight * 0.3, // Adjust height
                              width: double.infinity,
                              decoration:
                                  BoxDecoration(color: Colors.transparent),
                              child: Stack(
                                children: [
                                  _isDelayActive != true
                                      ? Positioned(
                                          top: screenHeight *
                                              0.070, // Positioning the multiplier based on screen height
                                          left: screenWidth * 0.250,
                                          child: Text(
                                            "Flew away!",
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 30),
                                          ))
                                      : Positioned(
                                          // top: screenHeight *
                                          //     0.070, // Positioning the multiplier based on screen height
                                          // left: screenWidth * 0.050,
                                          child: Image.asset(
                                            "assets/aviator_game/Loading New.gif",
                                          ),
                                        )
                                ],
                              ),
                            ),
                    ),
                    Positioned(
                      left: _animation.value *
                          screenWidth *
                          0.8, // Move left based on animation value
                      bottom: (_animation.value * screenHeight * 0.02)
                          .clamp(0.0, screenHeight * 0.08),
                      child: AnimatedBuilder(
                        animation: _animation1,
                        builder: (context, child) {
                          // Apply horizontal movement
                          final movement = Offset(_animation1.value, 1);
                          return Transform.translate(
                            offset: movement,
                            child: child,
                          );
                        },
                        child: Transform.rotate(
                          angle: -4700,
                          child: Image.asset(
                            'assets/aviator_game/Airborne-plane-animation.gif',
                            height: screenHeight * 0.18,
                            width: screenHeight * 0.18,
                          ),
                        ),
                      ),
                    ),
                    _isDelayActive != true
                        ? Positioned(
                            top: screenHeight *
                                0.118, // Positioning the multiplier based on screen height
                            left: screenWidth *
                                0.360, // Positioning multiplier based on screen width
                            child: Text(
                              '${(_animation.value * 5 + 1).toStringAsFixed(2)}x',
                              style: const TextStyle(
                                fontSize:
                                    36, // Adjust font size relative to screen height
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : SizedBox(),
                  ],
                );
              },
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Container(
                  height: 50,
                  width: 250,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () async {
                          gameController.drecrimentAmount();
                          setState(() {
                            inputController.text =
                                gameController.min_amount.value.toString();
                          });
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border:
                                  Border.all(width: 2, color: Colors.white)),
                          child: Icon(
                            Icons.remove,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 9,
                      ),
                      Expanded(
                        child: Container(
                          height: 50,
                          width: 50,
                          // margin: const EdgeInsets.only(bottom: 16.0),
                          child: TextField(
                            controller: inputController,
                            cursorColor: Colors.white,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white), // Text color set to white
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                    color: Colors
                                        .white), // Border color set to white
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                    color: Colors.white,
                                    width: 2.0), // Enabled border color white
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                    color: Colors.white,
                                    width: 2.0), // Focused border color white
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 18.0, vertical: 14.0),
                              filled: true,
                              fillColor: Colors.transparent,
                              // Transparent background
                              hintText: 'Amount',
                              hintStyle: TextStyle(
                                  color: Colors
                                      .white70), // Hint text color set to a lighter white
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 9,
                      ),
                      InkWell(
                        onTap: () async {
                          gameController.incrimentAmount();
                          setState(() {
                            inputController.text =
                                gameController.min_amount.value.toString();
                          });
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border:
                                  Border.all(width: 2, color: Colors.white)),
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                _startGame == true
                    ? InkWell(
                        onTap: () async {
                          setState(() {
                            _startGame = false;
                          });
                          double calculatedValue = (_animation.value * 5 + 1);
                          double formattedValue =
                              double.parse(calculatedValue.toStringAsFixed(2));
                          print(formattedValue);
                          await gameController.initAviatorGameCashOut(
                              multiplynumber: formattedValue);

                          // if (_isDelayActive == true) {
                          //   setState(() {
                          //     _isGameInit = !_isGameInit;
                          //   });
                          // }
                          print("init not");

                          // showTopSnackBar(context,
                          //     'Bet Widrow ${calculatedValue.toStringAsFixed(2)}');
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 50,
                          width: 120,
                          decoration: BoxDecoration(
                              color: Colors.greenAccent,
                              borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            children: [
                              Text(
                                "CashOut",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                  "${(_animation.value * 5 + 1).toStringAsFixed(2)} INR",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 20)),
                            ],
                          ),
                        ),
                      )
                    : InkWell(
                        onTap: () async {
                          if (_isDelayActive == true) {
                            setState(() {
                              _isGameInit = !_isGameInit;
                            });

                            if (_isGameInit == true) {
                              await gameController.initAviatorGame(
                                  amount: gameController.min_amount.value);
                            } else {
                              gameController.initAviatorGameCancel();
                            }
                          }
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 50,
                          width: 120,
                          decoration: BoxDecoration(
                              color: _isGameInit == true
                                  ? Colors.red
                                  : Colors.green,
                              borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            children: [
                              Text(
                                _isGameInit == true ? "Cancel" : "Bet",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text("1000 INR",
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      )
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              height: 350,
              width: double.infinity,
              child: ListView.builder(
                  itemCount: 20,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        "Tanvir Ahmed",
                        style: TextStyle(color: Colors.white),
                      ),
                      leading: Image.asset("assets/images/aviator_game.png"),
                      subtitle: Text("UserName",
                          style: TextStyle(color: Colors.white)),
                      trailing: Text("100 INR",
                          style: TextStyle(color: Colors.white)),
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }

  void showTopSnackBar(BuildContext context, String message) {
    final overlay = Overlay.of(context); // Access the Overlay

    // Create the Snackbar widget
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10, // Position near the top
        left: 10,
        right: 10,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blueAccent, // Background color
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                // IconButton(
                //   icon: Icon(Icons.close, color: Colors.white),
                //   onPressed: () {
                //
                //      overlayEntry.remove();  // Close the Snackbar
                //   },
                // ),
              ],
            ),
          ),
        ),
      ),
    );

    // Insert the Snackbar into the Overlay
    overlay?.insert(overlayEntry);

    // Automatically remove after a few seconds
    Future.delayed(Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }
}

class GraphPainter extends CustomPainter {
  final double progress;
  final double progres1;

  GraphPainter({required this.progress, required this.progres1});

  @override
  void paint(Canvas canvas, Size size) {
    // Paint for the fill color with shadow
    Paint paint = Paint()
      ..color = Colors.red.withOpacity(0.5) // Fill color with opacity
      ..style = PaintingStyle.fill; // Fill the path

    // Create the graph path
    Path path = Path();
    path.moveTo(0, size.height); // Start from bottom-left
    path.quadraticBezierTo(
      size.width * progress, // Control point X
      size.height * (1 - progress * progres1), // Control point Y
      size.width * progress, // End point X
      size.height * (1 - progress * progres1), // End point Y
    );
    path.lineTo(size.width * progress, size.height);
    path.close(); // Close the path for the fill

    // Draw the shadow with the same path
    canvas.drawShadow(path, Colors.black, 6.0, false);

    // Draw the filled path
    canvas.drawPath(path, paint);

    // Paint for the border (left and top only)
    Paint borderPaint = Paint()
      ..color = Colors.red // Border color
      ..style = PaintingStyle.stroke // Stroke style for the border
      ..strokeWidth = 6; // Border width

    // Path for the border (only on left and top)
    Path borderPath = Path();
    borderPath.moveTo(0, size.height); // Start from bottom-left
    borderPath.quadraticBezierTo(
      size.width * progress, // Control point X
      size.height * (1 - progress * progres1),
      size.width * progress, // End point X
      size.height * (1 - progress * progres1), // End point Y
    );

    // Draw the border on the left and top only
    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant GraphPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
