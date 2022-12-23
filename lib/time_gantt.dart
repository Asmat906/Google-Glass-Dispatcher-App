import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:google_glass_dispatcher/database/db_address.dart';
import 'package:google_glass_dispatcher/database/db_order.dart';
import 'package:google_glass_dispatcher/database/db_technicican.dart';

import 'mail/mail.dart';

class TimeGantt extends StatefulWidget {
  int startTime = 6;
  int endTime = 22;

  static const double pixelWidth = 500;
  static const double entryHeight = 60;

  List<OrderDO> orders = [];
  Function(OrderDO emptyOrder, String technicianID) handler;
  OrderDO? newOrder;
  Function() refreshHandler;

  TimeGantt(this.orders, this.handler, this.newOrder, this.refreshHandler);

  @override
  State<StatefulWidget> createState() {
    return _TimeGanttState();
  }
}

class _TimeGanttState extends State<TimeGantt> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: SizedBox(
        width: TimeGantt.pixelWidth,
        height: TimeGantt.entryHeight,
        child: Row(
          children: getTimeSlots(),
        ),
      ),
    );
  }

  List<Widget> getTimeSlots() {
    List<Widget> returnWidgetList = [];

    this.widget.orders.forEach((order) {
      returnWidgetList.add(createTimeSlotEntry(
        tooltipText:
            order.isEmptyOrder ? getEmptyToolTip(order.duration, this.widget.newOrder) : getTooltipTextForOrder(order),
        color: order.isEmptyOrder ? Colors.white : Colors.blue,
        minutes: order.duration,
        order: order,
        technicianID: order.technicianId,
      ));
    });

    return returnWidgetList;
  }

  String getEmptyToolTip(int durationInMinutes, OrderDO? newOrder) {
    if (newOrder == null || newOrder.duration <= durationInMinutes) {
      return "Leer - ${durationInMinutes}min";
    } else {
      return "Leer - ${durationInMinutes}min\nZeit reicht nicht aus";
    }
  }

  String getTooltipTextForOrder(OrderDO order) {
    String returnString = "Startzeit: " +
        order.startTime.hour.toString() +
        ":" +
        (order.startTime.minute == 0 ? "00" : order.startTime.minute.toString()) +
        "\n";
    returnString += "Dauer: " + order.duration.toString() + " Minuten\n";

    AddressDO? address = AddressDB.getMatchingAddressByID(order.addressId);
    if (address != null) {
      returnString += address.name + "\n";
      returnString += address.address + "\n\n";
    }
    returnString += order.todo;

    return returnString;
  }

  Offset _menuPosition = Offset(0, 0);

  Widget createTimeSlotEntry({
    String tooltipText = "Leer",
    Color color = Colors.white,
    int minutes = 1,
    OrderDO? order = null,
    String technicianID = "",
  }) {
    return GestureDetector(
    /*onLongPressDown: (details) {
        _menuPosition = details.globalPosition;
      },*/
        onDoubleTapDown: (details) {
          _menuPosition = details.globalPosition;
        },
        onDoubleTap: (){
        if (order != null && !order.isEmptyOrder) {
          showMenu(
            position: RelativeRect.fromLTRB(
              _menuPosition.dx,
              _menuPosition.dy,
              _menuPosition.dx,
              _menuPosition.dy,
            ),
            items: [
              PopupMenuItem(
                child: Text("edit".tr),
                value: <String, OrderDO>{"edit": order},
              ),
              PopupMenuItem(
                value: <String, OrderDO>{"delete": order},
                child: Text("Extinguish".tr),
              )
            ],
            context: context,
          ).then((value) {
            if (value != null) {
              value as Map<String, OrderDO>;
              switch (value.keys.first) {
                case "delete":
                  delete(value.values.first);
                  break;
                case "edit":
                print(".........<>><<>><><><<${value.values.first}");
                  //OrderDB.delete(value.values.first);
                  Navigator.of(context).pushNamedAndRemoveUntil("/", (route) => false);
                  Navigator.of(context).pushNamed("/newOrder", arguments: value.values.first);
                  break;
              }
            }
          });
        }
      },
      child: InkWell(
        onTap: () {
          if (order!.isEmptyOrder) {
            this.widget.handler(order, technicianID);
          }
        },
        onHover: (value) => setState(() {
            hovered = value;
        }
        ),
        child: SizedBox(
          width: calcWidth(minutes / 60.0),
          child: Tooltip(
            textStyle: TextStyle(
              fontSize: 20,
              color: Colors.white,
            ),
            message: tooltipText,
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: color,
                border: Border.all(),
                borderRadius: BorderRadius.circular(4),
                gradient: getBackgroundGradient(hovered, order!.isEmptyOrder, minutes, this.widget.newOrder),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(2, 2),
                    color: Colors.grey,
                    blurRadius: 1,
                    spreadRadius: 1,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  delete(OrderDO order) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(
            "permanent_del".tr,
            textAlign: TextAlign.center,
          ),
          titlePadding: EdgeInsets.all(20),
          children: [
            Center(
              child: Text(order.todo),
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    TechnicianDO tech = TechnicianDB.getTechnicianById(order.technicianId);
                    Mail().sendEmail(order.toJson(),order.startTime,tech,"delete");
                    OrderDB.delete(order);
                    setState(() {});
                    this.widget.refreshHandler.call();
                  },
                  child: Text("Yes".tr),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateColor.resolveWith((states) => Colors.green),
                  ),
                ),
                SizedBox(width: 70),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateColor.resolveWith((states) => Colors.red),
                  ),
                  child: Text("no".tr),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  LinearGradient? getBackgroundGradient(
    bool hovered,
    bool isEmptyOrder,
    int ownDuration,
    OrderDO? newOrder,
  ) {
    if (hovered) {
      if (isEmptyOrder) {
        if (newOrder == null || newOrder.duration <= ownDuration) {
          return LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.lightGreenAccent,
              darken(
                Colors.lightGreenAccent,
              )
            ],
          );
        } else {
          //empty slot is not big enough for new order slot
          return const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment(-0.4, -0.8),
            stops: [0.0, 0.5, 0.5, 1],
            colors: [
              Colors.green,
              Colors.green,
              Colors.black38,
              Colors.black12,
            ],
            tileMode: TileMode.repeated,
          );
        }
      } else {
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.red,
            darken(
              Colors.red,
            )
          ],
        );
      }
    } else {
      if (isEmptyOrder) {
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black12,
            darken(
              Colors.black12,
            )
          ],
        );
      }
    }
  }

  double calcWidth(double hours) {
    return (TimeGantt.pixelWidth / (widget.endTime - widget.startTime)) * hours - 2;
  }

  Color darken(Color color, [double amount = .4]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
