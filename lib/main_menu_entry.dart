import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_glass_dispatcher/consts/main_menu.dart';

typedef clickHandlerType(MainMenu titleOfElement);

class MainMenuEntry extends StatefulWidget {
  Color color;
  String imageAssetPath;
  String title;
  clickHandlerType clickHandler;

  MainMenu value;

  MainMenuEntry(
      String this.imageAssetPath, String this.title, Color this.color, clickHandlerType this.clickHandler, this.value);

  @override
  State<MainMenuEntry> createState() {
    return new _MainMenuEntryState();
  }
}

bool isHighlighted = false;

class _MainMenuEntryState extends State<MainMenuEntry> {
  bool isHighlighted = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      hoverColor: widget.color,
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        widget.clickHandler(widget.value);
      },
      child: Container(
        padding: EdgeInsets.all(50),
        child: Column(
          children: [
            Image.asset(
              widget.imageAssetPath,
              height: 150,
              width: 150,
              fit: BoxFit.contain,
            ),
            Text(
              widget.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            )
          ],
        ),
      ),
    );
  }
}
