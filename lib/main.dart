import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:janzer/main_handler.dart';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget with WidgetsBindingObserver{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Janzer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: const Color(0xFF121212)
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(milliseconds: 1500), navigationPage);
  }
  void navigationPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainHandler()),
    );
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Container(
              decoration: new BoxDecoration(
                color: Color(0xff1488CC),
                gradient: new LinearGradient(
                    colors: [new Color(0xff2B32B2), new Color(0xff1488CC)],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight),
              ),
            ),
            GestureDetector(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 90.0,
                    child: new Icon(
                      Icons.all_inclusive,
                      color: Colors.deepOrange,
                      size: 72.0,
                    ),
                  ),
                  SizedBox(
                    height: 24.0,
                  ),
                  Text(
                    'Janzer',
                    style: new TextStyle(color: Colors.white, fontSize: 24.0),
                  )
                ],
              ),
              onTap: (){
                navigationPage();
              },
            ),
          ],
        ),
      ),
    );
  }
}






