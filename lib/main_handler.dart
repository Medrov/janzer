import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:janzer/screens/bluetooth_screen.dart';
import 'package:janzer/screens/settings_screen.dart';
import 'package:janzer/utils/bottom_animation.dart';
import 'package:janzer/screens/database_screen.dart';
import 'package:janzer/screens/maps_screen.dart';



class MainHandler extends StatefulWidget {
  @override
  _MainHandlerState createState() => _MainHandlerState();
}

class _MainHandlerState extends State<MainHandler>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  BottomNavigationBarType _type = BottomNavigationBarType.shifting;
  List<NavigationIconView> _navigationViews;
  var screens = [
    DatabaseScreen(),
    MapsDefaultScreen(),
    BluetoothScreen()
  ];

  @override
  void initState() {
    super.initState();
    _navigationViews = <NavigationIconView>[
      NavigationIconView(
        icon: const Icon(Icons.home),
        title: 'Главная',
        color: Colors.blueAccent,
        vsync: this,
      ),
      NavigationIconView(
        icon: const Icon(Icons.map),
        title: 'Карта',
        color: Color(0xFF121212),
        vsync: this,
      ),
      NavigationIconView(
        icon: const Icon(Icons.settings),
        title: 'Настройки',
        color: Colors.blueAccent,
        vsync: this,
      )
    ];

    _navigationViews[_currentIndex].controller.value = 1.0;
  }

  @override
  void dispose() {
    for (NavigationIconView view in _navigationViews) view.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final BottomNavigationBar botNavBar = BottomNavigationBar(
      items: _navigationViews
          .map<BottomNavigationBarItem>(
              (NavigationIconView navigationView) => navigationView.item)
          .toList(),
      currentIndex: _currentIndex,
      type: _type,
      //iconSize: 4.0,
      onTap: (int index) {
        setState(() {
          _navigationViews[_currentIndex].controller.reverse();
          _currentIndex = index;
          _navigationViews[_currentIndex].controller.forward();
        });
      },
    );
    return Scaffold(

        body: Center(
          child: screens[_currentIndex],
        ),
        bottomNavigationBar: botNavBar,
      );
  }
}
