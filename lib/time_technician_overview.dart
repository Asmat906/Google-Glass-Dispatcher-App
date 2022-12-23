import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:google_glass_dispatcher/database/db_order.dart';
import 'package:google_glass_dispatcher/database/db_technicican.dart';
import 'package:google_glass_dispatcher/mail/mail.dart';
import 'package:google_glass_dispatcher/time_gantt.dart';
import 'package:table_calendar/table_calendar.dart';

extension MyDateUtils on DateTime {
  DateTime copyWith(
      {int? year,
      int? month,
      int? day,
      int? hour,
      int? minute,
      int? second,
      int? millisecond,
      int? microsecond}) {
    return DateTime(
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
      millisecond ?? this.millisecond,
      microsecond ?? this.microsecond,
    );
  }

  DateTime copyWithHourAndMinuteOnly({int? hour, int? minute}) {
    return DateTime(
      year,
      month,
      day,
      hour ?? this.hour,
      minute ?? this.minute,
      0,
      0,
      0,
    );
  }
}

class TimeTechnicianOverview extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TimeTechnicianOverviewState();
  }
}

class _TimeTechnicianOverviewState extends State<TimeTechnicianOverview> {
  static List<TechnicianDO> techies = [];

  OrderDO? newOrderToAddTechnician;

  CalendarFormat currentFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  bool alreadyFetchedFromRoute = false;

  final _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    techies = TechnicianDB.getAllTechnician(sorted: true);
  }

  @override
  Widget build(BuildContext context) {
    if (!alreadyFetchedFromRoute) {
      final argument = ModalRoute.of(context)!.settings.arguments;
      if (argument != null) {
        if (argument is DateTime) {
          this._selectedDay = argument as DateTime;
          this._focusedDay = argument as DateTime;
        } else if (argument is OrderDO) {
          newOrderToAddTechnician = argument as OrderDO;
        }
      }
      // newOrderToAddTechnician = ModalRoute.of(context)!.settings.arguments as OrderDO?;
      alreadyFetchedFromRoute = true;
    }

    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text("calandar_overview".tr)),
      body: getOverview(),
    );
  }

  Widget getOverview() {
    List<Widget> techRows = [];

    List<OrderDO> dayOrders = OrderDB.getAllOrdersForDay(_selectedDay);

    for (var technician in techies) {
      List<OrderDO> ordersByTechnicianForADay =
          OrderDB.filterOrdersByTechnician(dayOrders, technician);

      List<OrderDO> normalizedOrdersByTechnicianForADay = normalize(
        ordersByTechnicianForADay,
        _selectedDay.copyWithHourAndMinuteOnly(hour: 6, minute: 0),
        _selectedDay.copyWith(hour: 22, minute: 0),
        technician,
      );

      techRows.add(
          getTechnicianRow(normalizedOrdersByTechnicianForADay, technician));
    }

    Widget w = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [ 
                SizedBox(
                  height: 200,
                  width: 800,
                  child: TableCalendar(
                    availableCalendarFormats:  {
                      // CalendarFormat.month: 'Month',
                      CalendarFormat.twoWeeks: 'week_2'.tr,
                      CalendarFormat.week: 'week'.tr,
                    },
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    // onTodayButtonTap: () {
                    //   setState(() {
                    //     _focusedDay = DateTime.now();
                    //     _selectedDay = _focusedDay;
                    //   });
                    // },
                    calendarFormat: currentFormat,
                    firstDay: DateTime.utc(2021, 1, 1),
                    lastDay: DateTime.utc(2030, 1, 1),
                    focusedDay: _focusedDay,
                    onFormatChanged: (format) {
                      setState(() {
                        currentFormat = format;
                      });
                    },
                    headerVisible: true,
                    //locale: 'de_DE',
                    locale: 'time'.tr,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(
          width: 800,
          height: 450,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Scrollbar(
                isAlwaysShown: true,
                controller: _scrollController,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: techRows,
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );

    return w;
  }

  int getTimeOfDayInMinutes(DateTime dt) {
    return (dt.hour * 60) + dt.minute;
  }

  ///adds the empty timeslots into the day
  List<OrderDO> normalize(
    List<OrderDO> sortedListOfOrders,
    DateTime startTime,
    DateTime endTime,
    TechnicianDO technician,
  ) {
    if (sortedListOfOrders.isEmpty) {
      return [
        OrderDO.getEmptyOrder(
          getTimeOfDayInMinutes(endTime) - getTimeOfDayInMinutes(startTime),
          startTime,
          technician,
        )
      ];
    }

    OrderDO firstOrder = sortedListOfOrders.first;

    ///checking if i need to add an empty time slot before the first job
    ///e.g. if starts working at 8am but the first job is at 9am
    int startTimeInMinutes = getTimeOfDayInMinutes(startTime);
    int firstOrderStartTimeInMinutes =
        getTimeOfDayInMinutes(firstOrder.startTime);
    if (startTimeInMinutes < firstOrderStartTimeInMinutes) {
      int duration = firstOrderStartTimeInMinutes - startTimeInMinutes;
      OrderDO emptyOrder =
          OrderDO.getEmptyOrder(duration, startTime, technician);
      sortedListOfOrders.insert(0, emptyOrder);
    }

    for (int i = 0; i < sortedListOfOrders.length; ++i) {
      OrderDO currentOrder = sortedListOfOrders[i];
      int endTimeInMinutes =
          getTimeOfDayInMinutes(currentOrder.startTime) + currentOrder.duration;

      ///check if it is not the last element in the list
      if (i < (sortedListOfOrders.length - 1)) {
        int nextElementStartTimeInMinutesOfDay =
            getTimeOfDayInMinutes(sortedListOfOrders[i + 1].startTime);
        if (endTimeInMinutes < nextElementStartTimeInMinutesOfDay) {
          DateTime nextElementStartTime = sortedListOfOrders[i + 1].startTime;
          OrderDO emptyOrderForInsert = OrderDO.getEmptyOrder(
            nextElementStartTimeInMinutesOfDay - endTimeInMinutes,
            nextElementStartTime.copyWith(
              hour: endTimeInMinutes ~/ 60,
              minute: endTimeInMinutes % 60,
              second: 0,
              microsecond: 0,
              millisecond: 0,
            ),
            technician,
          );
          sortedListOfOrders.insert(i + 1, emptyOrderForInsert);
        }
      }
    }
    OrderDO lastOrder = sortedListOfOrders.last;
    int lastOrderEndTime =
        getTimeOfDayInMinutes(lastOrder.startTime) + lastOrder.duration;
    if (lastOrderEndTime < getTimeOfDayInMinutes(endTime)) {
      sortedListOfOrders.add(
        OrderDO.getEmptyOrder(
          getTimeOfDayInMinutes(endTime) - lastOrderEndTime,
          lastOrder.startTime.copyWithHourAndMinuteOnly(
            hour: lastOrderEndTime ~/ 60,
            minute: lastOrderEndTime % 60,
          ),
          technician,
        ),
      );
    }
    // check last element if it is going till the end
    return sortedListOfOrders;
  }

  fetchOrders() {
    DateTime dt = DateTime.now();
    List<OrderDO> ordersForDay = OrderDB.getAllOrdersForDay(dt);
  }

  void orderClickHandler(OrderDO clickedEmptyOrder, String technicianID) {
    if (newOrderToAddTechnician == null) {
      return;
    } else if (clickedEmptyOrder.duration < newOrderToAddTechnician!.duration) {
      return;
    }
    showDialog(
      context: context,
      builder: (context) {
        double valSliderValue =
            getTimeOfDayInMinutes(clickedEmptyOrder.startTime).toDouble();
        return SimpleDialog(
          title: Text("Select_start_time".tr),
          children: [
            StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) => Column(
                children: [
                  SizedBox(
                    width: 500,
                    child: Slider(
                      autofocus: true,
                      min: getTimeOfDayInMinutes(clickedEmptyOrder.startTime)
                          .toDouble(),
                      max: getTimeOfDayInMinutes(clickedEmptyOrder.startTime)
                              .toDouble() +
                          clickedEmptyOrder.duration -
                          newOrderToAddTechnician!.duration,
                      value: valSliderValue.toDouble(),
                      divisions: (clickedEmptyOrder.duration -
                              newOrderToAddTechnician!.duration) ~/
                          15,
                      onChanged: (double value) {
                        setState(() {
                          valSliderValue = value;
                        });
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(getTimeValue(valSliderValue)),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (newOrderToAddTechnician != null) {
                            addOrderToTechnician(
                                technicianID,
                                clickedEmptyOrder.startTime
                                    .copyWithHourAndMinuteOnly(
                                  hour: valSliderValue ~/ 60,
                                  minute: (valSliderValue % 60).toInt(),
                                ));
                            Navigator.pop(context, true);
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                '/', (Route<dynamic> route) => false);
                            Navigator.of(context).pushNamed('/technicianTime',
                                arguments: clickedEmptyOrder.startTime);
                          }
                        },
                        child: Text("OK"),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        );
      },
    );
    // this order has been clicked and also the new Order needs to be checked
  }

  addOrderToTechnician(String technicianID, DateTime startTimeOfNewTicket) {
    newOrderToAddTechnician!
      ..technicianId = technicianID
      ..startTime = startTimeOfNewTicket;

    TechnicianDO tech = TechnicianDB.getTechnicianById(technicianID);
    OrderDB.saveToBox(newOrderToAddTechnician!);
    // Mail().imapExample();
    if(tech.shortcut!="none") {
      Mail().sendEmail(
          newOrderToAddTechnician!.toJson(),
          newOrderToAddTechnician!.startTime,
          tech, "intern");
    }
    Mail().sendEmail(
        newOrderToAddTechnician!.toHtmlExtern(tech.email),
        newOrderToAddTechnician!.startTime,
        tech,"extern");
    setState(() {});
  }

  String getTimeValue(double val) {
    int hours = val ~/ 60;
    int minutes = (val % 60).toInt();

    return hours.toString() + ":" + (minutes == 0 ? "00" : minutes.toString());
  }

  // Widget getTechnicianRow(TechnicianDO tech) {
  Widget getTechnicianRow(List<OrderDO> orders, TechnicianDO technician) {
    return Row(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: Image.asset(
            "assets/images/technician.png",
            height: 50,
            width: 50,
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(
          width: 100,
          child: Text(
            technician.name,
            style: const TextStyle(fontSize: 20),
          ),
        ),
        TimeGantt(
            orders, orderClickHandler, newOrderToAddTechnician, refreshHandler),
      ],
    );
  }

  refreshHandler() {
    setState(() {});
  }
}
