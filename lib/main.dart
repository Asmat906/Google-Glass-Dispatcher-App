// ignore_for_file: unnecessary_const

import 'dart:io' show Platform;

import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_glass_dispatcher/address_overview.dart';
import 'package:google_glass_dispatcher/consts/main_menu.dart';
import 'package:google_glass_dispatcher/database/db_address.dart';
import 'package:google_glass_dispatcher/database/db_experties.dart';
import 'package:google_glass_dispatcher/database/db_experts.dart';
import 'package:google_glass_dispatcher/database/db_order.dart';
import 'package:google_glass_dispatcher/database/db_technicican.dart';
import 'package:google_glass_dispatcher/expers_overview.dart';
import 'package:google_glass_dispatcher/sideMenu/experties_overview.dart';
import 'package:google_glass_dispatcher/main_menu_entry.dart';
import 'package:google_glass_dispatcher/new_order_form.dart';
import 'package:google_glass_dispatcher/search/hit.dart';
import 'package:google_glass_dispatcher/technician_overview.dart';
import 'package:google_glass_dispatcher/time_technician_overview.dart';
import 'package:google_glass_dispatcher/translations/translation_file.dart';
import 'package:google_glass_dispatcher/translations/my_controller.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'database/db_experts.dart';



String version ="";
String appBuild ="";
void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TechnicianDOAdapter());
  Hive.registerAdapter(OrderDOAdapter());
  Hive.registerAdapter(AddressDOAdapter());
  Hive.registerAdapter(ExpertDoAdapter());
  Hive.registerAdapter(ExpertiesDoAdapter());
  // Hive.registerAdapter(ExpertiesDoAdapter());
  Hive.registerAdapter(HitAdapter());
  await AddressDB.initBox();
  await ExpertDB.initBox();
  await ExpertiesDB.initBox();
  await OrderDB.initBox();
  await TechnicianDB.initBox();
  TechnicianDB.getAllTechnician();
  WidgetsFlutterBinding.ensureInitialized();
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  version = packageInfo.version;
  appBuild = packageInfo.buildNumber;

  if (!kIsWeb) {
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      DesktopWindow.setWindowSize(Size(1000, 800));
    }
  }
  initializeDateFormatting().then((_) => runApp(MyApp()));
// runApp( MyApp());
}

class MyApp extends StatelessWidget {
   MyApp({Key? key}) : super(key: key);
  MyController myController=Get.put(MyController());

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      translations: Messages(),
      locale:  Locale('de','DE'),
      fallbackLocale: Locale('en','US'),
      
      debugShowCheckedModeBanner: false,
      title: 'HWG 4.0 Dispatcher',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      //home: const MyHomePage(title: 'HWG 4.0 Dispatcher'),
      routes: {
        "/": (context) => MyHomePage(title: 'HWG 4.0 Dispatcher'),
        "/newOrder": (context) => NewOrderForm(),
        "/technician": (context) => TechnicianOverview(),
        "/expert": (context) => ExpertOverview(),
        "/address": (context) => AddressOverview(),
        "/technicianTime": (context) => TimeTechnicianOverview(),
        "/experties": (context) => ExpertiesOverview(),
      },
      initialRoute: "/",
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  MyController myController=Get.put(MyController());

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: SideDrawer(),
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MainMenuEntry(
                "assets/images/technician.png",
                "Techniker".tr,
                Colors.lightBlue,
                clickHandler,
                MainMenu.TECHNICIAN,
              ),
              MainMenuEntry(
                "assets/images/timetable.png",
                "Techniker1".tr,
                Colors.yellow,
                clickHandler,
                MainMenu.CALENDAR,
              ),
              MainMenuEntry(
                "assets/images/technician.png",
                "Experten".tr,
                Colors.lightBlue,
                clickHandler,
                MainMenu.Expert,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MainMenuEntry(
                "assets/images/new_order.png",
                "Neuer_Auftrag".tr,
                Colors.red,
                clickHandler,
                MainMenu.NEW_ORDER,
              ),
              MainMenuEntry(
                "assets/images/address_book.png",
                "Kunden".tr,
                Colors.lightGreenAccent,
                clickHandler,
                MainMenu.ADDRESS,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(5),
                child: InkWell(
                  onTap: showInfo,
                  child: Row(
                    children: const [
                      Icon(
                        Icons.copyright_sharp,
                        size: 20,
                      ),
                      Text(
                        "Tillerstack GmbH 2021",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const [
              Padding(
                  padding: EdgeInsets.all(8),
                  child:(
                  Text("Version: 1.0.6",// + version,
                style:
                TextStyle(
                fontWeight: FontWeight.bold,
              ),)))
              ]
              ),
            ],
          )
      );
  }
  var myList = ['Experties'.tr, ];
  Widget SideDrawer(){
    return  Container(
      width: MediaQuery.of(context).size.width / 2,
      child: Drawer(
          child: CustomScrollView(
        slivers: [
         SliverAppBar(
              expandedHeight: 100.0,
              floating: true,
              pinned: false,
              snap: false,
              flexibleSpace:  FlexibleSpaceBar(
                title: Text('Seetings'.tr),
              ),
              actions: <Widget>[
                // IconButton(
                //   icon: const Icon(Icons.add_circle),
                //   tooltip: 'Add new entry',
                //   onPressed: () {},
                // ),
              ]),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Column(
                  children: [
              //            ListTile(
              //   //leading: Icon(Icons.message),
              //   title: Text('hello'.tr,style: TextStyle(color: Colors.black,fontSize: 28),),
              // ),
              // GestureDetector(
              //   onTap: (){
              //     myController.changeLanguage('en','US');
                  
              //   },
              //   child: ListTile(
              //     //leading: Icon(Icons.message),
              //     title: Text('English',style: TextStyle(color: Colors.black,fontSize: 28),),
              //   ),
              // ),
              // GestureDetector(
              //   onTap: (){
              //     myController.changeLanguage('hi','IN');
              //   },
              //   child: ListTile(
              //     //leading: Icon(Icons.message),
              //     title: Text('Urdu',style: TextStyle(color: Colors.black,fontSize: 28),),
              //   ),
              // ),
                    Column(
                      children: [
                        // ListView.builder(
                        //   shrinkWrap: true,
                        //   itemCount: myList.length,
                        //   itemBuilder: (BuildContext context, int index) {
                           // return         
                            Card(
              shape: const RoundedRectangleBorder(
                        side: BorderSide(
                          color: Colors.grey,
                        ),
                        // borderRadius: BorderRadius.all(8),
              ),
              child: GestureDetector(
                onTap: () {
                  Get.to(ExpertiesOverview());
                  // var selection = myList[index]; 
                  // switch(selection) { 
                  //       case "Experties".tr{  Get.to(ExpertiesOverview()); } 
                  //       break; 
     
                        // case "English": { 
                        
                        //   //  Get.to(const ExportExperties());
                        //   myController.changeLanguage('en','US');
                        //     } 
                        // break; 
     
                        // case "Import": {
                        //       //Get.to(const ImportExperties());
                        //       myController.changeLanguage('hi','IN');
                        //        } 
                        // break; 
     
                        // case "D": {  print("Poor"); } 
                        // break; 
     
                        // default: { print("Invalid choice"); } 
                        // break; 
                  },
                           // clickHandler; 
                         //   myList[index]=="Experties"? Get.to(ExpertiesOverview()):null;
                            
                child: ListTile(
                          leading:  Text('Experties'.tr,style: TextStyle(color: Colors.black,fontSize: 28))),
              ),),
            
                        
                        GestureDetector(
                onTap: (){
                  myController.changeLanguage('en','US');
                  
                },
                child: Card(
              shape: const RoundedRectangleBorder(
                          side: BorderSide(
                            color: Colors.grey,
                          ),),
                  child: ListTile(
                    //leading: Icon(Icons.message),
                    title: Text('English'.tr,style: TextStyle(color: Colors.black,fontSize: 28),),
                  ),
                ),
              ),
              GestureDetector(
                onTap: (){
                  myController.changeLanguage('de','DE');
                },
                child: Card(
              shape: const RoundedRectangleBorder(
                          side: BorderSide(
                            color: Colors.grey,
                          ),),
                  child: ListTile(
                    //leading: Icon(Icons.message),
                    title: Text('German'.tr,style: TextStyle(color: Colors.black,fontSize: 28),),
                  ),
                ),
              ),
               GestureDetector(
                onTap: (){
                  myController.changeLanguage('fr','FR');
                },
                child: Card(
              shape: const RoundedRectangleBorder(
                          side: BorderSide(
                            color: Colors.grey,
                          ),),
                  child: ListTile(
                    //leading: Icon(Icons.message),
                    title: Text('French'.tr,style: TextStyle(color: Colors.black,fontSize: 28),),
                  ),
                ),
              ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                height: 80,
                 color: Colors.grey,
                child: const Center(
                  child: const Text(
                    '',
                    style: const TextStyle(color: Colors.white, letterSpacing: 4),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
       
        ),
    );
  }

  clickHandler(MainMenu value) {
    //here i have to handle where to go next
    switch (value) {
      case MainMenu.NEW_ORDER:
        Navigator.pushNamed(context, "/newOrder");
        break;
      case MainMenu.TECHNICIAN:
        Navigator.pushNamed(context, "/technician");
        break;
      case MainMenu.Expert:
        Navigator.pushNamed(context, "/expert");
        break;
      case MainMenu.ADDRESS:
        Navigator.pushNamed(context, "/address");
        break;
      case MainMenu.Experties:
        Navigator.pushNamed(context, "/experties");
        break;
      case MainMenu.CALENDAR:
        Navigator.pushNamed(context, "/technicianTime");
    }
  }

  showInfo() {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            contentPadding: EdgeInsets.all(10),
            title: null,
            children: [
              Center(
                child: Image.asset("assets/images/hwg_overview.png"),
              ),
            ],
          );
        });
  }
}
