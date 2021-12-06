import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class DrawingArea {
  Offset? point;
  Paint? areaPaint;

  DrawingArea({this.point, this.areaPaint});
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<dynamic> points = [];
  Color? selectedColor;
  double? strokeWidth;

  @override
  void initState() {
    selectedColor = Colors.black;
    strokeWidth = 2.0;
    super.initState();
  }

  void selectColor() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Color Chooser'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: selectedColor!,
              onColorChanged: (color) {
                setState(() {
                  selectedColor = color;
                });
              },
            ),
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Get.back();
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(138, 35, 135, 1.0),
                Color.fromRGBO(233, 64, 87, 1.0),
                Color.fromRGBO(242, 113, 33, 1.0),
              ],
            ),
          ),
        ),
        Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: Get.width * 0.9,
                height: Get.height * 0.8,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ]),
                child: GestureDetector(
                  onPanDown: (details) {
                    setState(() {
                      points.add(DrawingArea(
                          point: details.localPosition,
                          areaPaint: Paint()
                            ..strokeCap = StrokeCap.round
                            ..isAntiAlias = true
                            ..color = selectedColor!
                            ..strokeWidth = strokeWidth!));
                    });
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      points.add(DrawingArea(
                          point: details.localPosition,
                          areaPaint: Paint()
                            ..strokeCap = StrokeCap.round
                            ..isAntiAlias = true
                            ..color = selectedColor!
                            ..strokeWidth = strokeWidth!));
                    });
                  },
                  onPanEnd: (details) {
                    setState(() {
                      points.add(null);
                    });
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CustomPaint(
                      painter: MyCustomPainter(
                          points: points, color: selectedColor!, strokeWidth: strokeWidth!),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: Get.width * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.color_lens,
                      ),
                      onPressed: () {
                        selectColor();
                      },
                    ),
                    Expanded(
                        child: Slider(
                      min: 1.0,
                      max: 7.0,
                      activeColor: selectedColor,
                      value: strokeWidth!,
                      onChanged: (value) {
                        this.setState(() {
                          strokeWidth = value;
                        });
                      },
                    )),
                    IconButton(
                      icon: const Icon(
                        Icons.layers_clear,
                      ),
                      onPressed: () {
                        setState(() {
                          if (points.isNotEmpty) {
                            points.removeLast();
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  List<dynamic> points;
  Color color;
  double strokeWidth;
  MyCustomPainter({required this.points, required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    Paint background = Paint()..color = Colors.white;
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, background);

    for (int x = 0; x < points.length - 1; x++) {
      if (points[x] != null && points[x + 1] != null) {
        Paint paint = points[x].areaPaint!;
        canvas.drawLine(points[x].point!, points[x + 1].point!, paint);
      } else if (points[x] != null && points[x + 1] == null) {
        Paint paint = points[x].areaPaint!;
        canvas.drawPoints(PointMode.points, [points[x].point!], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
    throw UnimplementedError();
  }
}
