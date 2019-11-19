import 'package:flutter/material.dart';
import 'package:janzer/main_screen.dart';
import 'package:janzer/maps_screen.dart';
import 'package:janzer/settings_screen.dart';

class TabItem extends StatefulWidget {
  TabItem(
      {@required this.selected,
        @required this.iconData,
        @required this.index,
        @required this.callbackFunction});

//  var screens = [
//    MainScreen(),
//    //MapsScreen(),
//    SettingsScreen(),
//    SettingsScreen()
//  ];
  int index;
  IconData iconData;
  bool selected;
  Function callbackFunction;

  @override
  _TabItemState createState() => _TabItemState();
}

const double ICON_OFF = -3;
const double ICON_ON = 0;
const double TEXT_OFF = 3;
const double TEXT_ON = 1;
const double ALPHA_OFF = 0;
const double ALPHA_ON = 1;
const int ANIM_DURATION = 300;
const Color PURPLE = Colors.lightBlueAccent;


class _TabItemState extends State<TabItem> {

  double iconYAlign = ICON_ON;
  double textYAlign = TEXT_OFF;
  double iconAlpha = ALPHA_ON;

  @override
  void initState() {
    super.initState();
    _setIconTextAlpha();
  }

  @override
  void didUpdateWidget(TabItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    _setIconTextAlpha();
  }

  _setIconTextAlpha() {
    setState(() {
      iconYAlign = (widget.selected) ? ICON_OFF : ICON_ON;
      textYAlign = (widget.selected) ? TEXT_ON : TEXT_OFF;
      iconAlpha = (widget.selected) ? ALPHA_OFF : ALPHA_ON;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            child: AnimatedAlign(
                duration: Duration(milliseconds: ANIM_DURATION),
                alignment: Alignment(0, textYAlign),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  //child: widget.screens[widget.index],
                )),
          ),
          Container(
            height: double.infinity,
            width: double.infinity,
            child: AnimatedAlign(
              duration: Duration(milliseconds: ANIM_DURATION),
              curve: Curves.easeIn,
              alignment: Alignment(0, iconYAlign),
              child: AnimatedOpacity(
                duration: Duration(milliseconds: ANIM_DURATION),
                opacity: iconAlpha,
                child: IconButton(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  padding: EdgeInsets.all(0),
                  alignment: Alignment(0, 0),
                  icon: Icon(
                    widget.iconData,
                    color: PURPLE,
                  ),
                  onPressed: () {
                    widget.callbackFunction();
                  },
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
