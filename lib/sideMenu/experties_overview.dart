import 'dart:convert';
import 'dart:io';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:google_glass_dispatcher/database/db_experties.dart';
import 'package:google_glass_dispatcher/sideMenu/externaldb_model.dart';

class ExpertiesOverview extends StatefulWidget {
  const ExpertiesOverview({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ExpertiesOverviewState();
  }
}

class _ExpertiesOverviewState extends State<ExpertiesOverview> {
  final _formKey = GlobalKey<FormState>();

  bool errorName = false;
  bool? select;
  bool selection=false;
  bool mergechoose=false;
   List allAddressesText=[];
 List allAddressesText1=[];
 bool ?mergingExpert;
 bool ?popup;

  bool? indicatorMerge;
   bool? indicatorExport;
   bool? indicatorImport;

  @override
  initState() {
    super.initState();
    getAllExpertiesWithSetState();
  }
  List<DataRow> generateListDataRowsFromListExpertiesDO(List<ExpertiesDo> listAddress) {
    return listAddress.map<DataRow>((e) {
      return DataRow(cells: <DataCell>[
        DataCell(
          Row(
            children: [
              InkWell(
                onTap: () {
                  delete(e);
                },
                child: Icon(
                  Icons.delete_forever_sharp,
                  size: 20,
                  color: Colors.red,
                ),
              ),
              
            ],
          ),
        ),
        DataCell(GestureDetector(
          onTap: (){
          },
          child: Text(e.name, ))),
      ]);
    }).toList();
  }
  List<DataRow> generateListDataRowsFromListExpertiesDOTf(List listAddress) {
    return listAddress.map<DataRow>((e) {
      return DataRow(cells: <DataCell>[
        DataCell(
          Row(
            children: [
              InkWell(
                onTap: () {
                  delete(e);
                },
                child: Icon(
                  Icons.delete_forever_sharp,
                  size: 20,
                  color: Colors.red,
                ),
              ),
              
            ],
          ),
        ),
        DataCell(GestureDetector(
          onTap: (){
          },
          child: Text(e.name, ))),
      ]);
    }).toList();
  }


  delete(ExpertiesDo address) {
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
              child: Text(address.name + "\n"),
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    ExpertiesDB.delete(address);
                    getAllExpertiesWithSetState();
                    Navigator.pop(context);
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

  getAllExpertiesWithSetState() async {
    List<ExpertiesDo> allAddresses = await ExpertiesDB.getAllExperties();
    setState(() {
      myDataRows = generateListDataRowsFromListExpertiesDO(allAddresses);
    });
  }

  List<DataRow> myDataRows = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         actions: [
                 
                 PopupMenuButton(
                   itemBuilder: (context){
                     return [
                            PopupMenuItem<int>(
                                value: 0,
                                child: Text("Export".tr),
                            ),

                            PopupMenuItem<int>(
                                value: 1,
                                child: Text("Import".tr),
                            ),

                            PopupMenuItem<int>(
                                value: 2,
                                child: Text("Merge".tr),
                            ),
                        ];
                   },
                  onSelected:(value,){
                      if(value == 0){
                        exportExperties();
                        indicatorExport=true;
                        indicatorImport=false;
                        indicatorMerge=false;
                        showDialog(
                          context: context,
                          builder: (context) => showMessage(),
                         );
                         
                      }else if(value == 1){
                          importExperties();
                         indicatorExport=false;
                        indicatorImport=true;
                        indicatorMerge=false;
                      // allAddressesText1.isNotEmpty? 
                       showDialog(
                          context: context,
                          builder: (context) => showMessage(),
                         );
                        allAddressesText1.clear();

                      }else if(value == 2){
                        indicatorExport=false;
                        indicatorImport=false;
                        indicatorMerge=true;
                       showDialog(
                          context: context,
                          builder: (context) => showMessage(),
                         );

                         popup=true;
                       // add();
                        
                         
                         setState(() {
                           print("<><><><><><><>vvvv>,,,$allAddressesText");
                           allAddressesText.clear();
                           print("<><><><><><><>ffffffff>,,,$allAddressesText");
                          mergingExpert==true? mergeExperties():null;
                        });
                      }
                   }
                  ),

                   
            ],
        
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Experties".tr),
          ],
        ),
      ),
      
     
      body: Column(
        children: [
          selection==true? localAndExternalDb():selection==false&&mergechoose==false?localDb():cont(),
          
          
         ],
      ),
    );
  }
  Widget cont(){
    return Container(child: Center(child: Text(" ",style: TextStyle(fontSize: 39),),),);
  }
  Widget localDb(){
    return  Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        SizedBox(height: 20,),
                        SizedBox(
                          height: 20,
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.red,  ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,

                    
                    children: [
                     DataTable(
                    columns:  <DataColumn>[
                      myDataRows.isNotEmpty?DataColumn(
                        label: Text('available_experties'.tr,style: TextStyle(fontSize: 20),),
                        
                      ):DataColumn(
                        label: Text('add_experties'.tr,style: TextStyle(fontSize: 20,color: Colors.red),),
                        
                      ),
                      DataColumn(
                        label: Text(
                          '',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                    rows: selection==true? generateListDataRowsFromListExpertiesDOTf (allAddressesText):myDataRows,
                  ),
             
                  ],),
                 
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(child: AddExpert(),)
                ],
              )
            ],
          );
        
  }
  Widget localAndExternalDb(){
    return  Column(
      children: [
        Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            SizedBox(height: 20,),
                            SizedBox(
                              height: 20,
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.red,  // red as border color
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,

                        
                        children: [
                         DataTable(
                        columns:  <DataColumn>[
                          myDataRows.isNotEmpty?DataColumn(
                            label: Text('available_experties'.tr,style: TextStyle(fontSize: 20),),
                            
                          ):DataColumn(
                            label: Text('add_experties'.tr,style: TextStyle(fontSize: 20,color: Colors.red),),
                            
                          ),
                          DataColumn(
                            label: Text(
                              '',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ),
                        ],
                        rows: myDataRows,
                      ),
                 
                      ],),
                     
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(child: AddExpert(),)
                    ],
                  )
                ],
              ),
        Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            SizedBox(height: 20,),
                            SizedBox(
                              height: 20,
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.red,  // red as border color
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,

                        
                        children: [
                         DataTable(
                        columns:  <DataColumn>[
                          myDataRows.isNotEmpty?DataColumn(
                            label: Text('available_experties'.tr,style: TextStyle(fontSize: 20),),
                            
                          ):DataColumn(
                            label: Text('add_experties'.tr,style: TextStyle(fontSize: 20,color: Colors.red),),
                            
                          ),
                          DataColumn(
                            label: Text(
                              '',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ),
                        ],
                        rows: generateListDataRowsFromListExpertiesDOTf(allAddressesText1),
                      ),
                 
                      ],),
                     
                    ),
                  ),
                ],
              ),
      
      ],
    );
        
  }
  
  // ignore: non_constant_identifier_names
  Widget AddExpert(){
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Container(
        child: Row(children: [
           ElevatedButton(
            onPressed: () {
               createOrEditNewAddress();
                 
            },
            child: Icon(Icons.add),
          ),
          
        ],),
      ),
    );
  }

  resetErrors() {
    errorName = false;
  }

  createOrEditNewAddress({ExpertiesDo? address}) {
    String newName = "";

    resetErrors();

    if (address != null) {
      newName = address.name;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text("Experties".tr)],
          ),
          children: [
            StatefulBuilder(
              builder: (builder, setState) {
                return Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              initialValue: newName,
                              decoration: InputDecoration(
                                labelText: "Name".tr,
                                errorText: errorName ? "name_warning".tr : null,
                                icon: Icon(Icons.person_rounded),
                              ),
                              onSaved: (String? value) {
                                newName = value ?? "";
                              },
                            ),
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SimpleDialogOption(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      "Abort".tr,
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.red,
                                  ),
                                ),
                                onPressed: () {},
                              ),
                              SimpleDialogOption(
                                child: ElevatedButton(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      "Save".tr,
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.lightGreen,
                                  ),
                                  onPressed: () {
                                    //path();
                                    _formKey.currentState!.save();
                                    if (hasFormErrors(newName, )) {
                                      setState(() {});
                                    } else {
                                      saveExpertiesToDB(newName,);
                                    }
                                  },
                                ),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
  saveExpertiesToDB(String newName, 
      {ExpertiesDo? editAddress = null}) {
    if (editAddress == null) {
      ExpertiesDo address = ExpertiesDo.newExpertiesEntry(newName, );
      ExpertiesDB.saveToBox(address);
    } else {
      editAddress.name = newName;
      ExpertiesDB.replace(editAddress);
    }
    getAllExpertiesWithSetState();
    popup==true?null:
    Navigator.pop(context);
  }

  bool hasFormErrors(String name, ) {
    errorName = name.isEmpty;

    return errorName;
  }
  Future<String> _getPathToDownload() async {
  return ExtStorage.getExternalStoragePublicDirectory(
      ExtStorage.DIRECTORY_DOWNLOADS);
}

  Future exportExperties() async {
  List<ExpertiesDo> allAddresses = await ExpertiesDB.getAllExperties();
  setState(() {
     select=true;
     selection=false;
     mergechoose=false;
  });
  var Grooup2=[];
  String ?jsonUser;
  for (int i=0;i<allAddresses.length;i++){
    Experties user=Experties(allAddresses[i].name.toString(), );
   jsonUser = jsonEncode(user);
   Grooup2.add(jsonUser);
  }
   final String path = await _getPathToDownload();
   File file2 = File("$path/experties.txt");
   await file2.writeAsString(Grooup2.toString());
}
List uniqueStrings=[];
List jsonResult1=[];
bool ?pop;
Future mergeExperties() async { 
  final String path = await _getPathToDownload();
      File file3 = File("$path/experties.txt");
      
       var c=await file3.readAsString(); 
       List jsonResult = jsonDecode( c);
       jsonResult1=jsonResult;
       Experties ?itemCategoryModel;
       for (var value in  jsonResult) {
      itemCategoryModel = Experties.fromJson(value); 
       var name1=[];
        List<ExpertiesDo> jtechDBCount = await ExpertiesDB.getAllExperties();
        for(int i=0;i<jtechDBCount.length;i++){ 
         name1.add(jtechDBCount[i].name);
          
        }
        if(name1.contains(itemCategoryModel.name)){
          print("not added");
        }else{ 
          saveExpertiesToDB(itemCategoryModel.name,  );
        } 
        
       uniqueStrings.add(itemCategoryModel);
      
    }
    uniqueStrings.join('');
    setState(() {
      allAddressesText=uniqueStrings;
      select=false;
      selection=false;
      pop=true;
      mergingExpert=false;
    });
    allAddressesText=uniqueStrings;
}
List merge=[];
List uniqueStrings1=[];
List jsonResult2=[];
Future importExperties() async { 
  final String path = await _getPathToDownload();
      File file3 = File("$path/experties.txt");
      
       var c=await file3.readAsString(); 
       List jsonResult = jsonDecode( c);
       jsonResult2=jsonResult;
       print("><><<>mmmmm><><><><>$jsonResult");
       Experties ?itemCategoryModel;
       for (var value in  jsonResult) {
      itemCategoryModel = Experties.fromJson(value);
      
      var c=itemCategoryModel.name;
       uniqueStrings1.remove(itemCategoryModel);
       uniqueStrings1.add(itemCategoryModel);
      //uniqueStrings.toSet().toList();
      
      // print("><<><>innnnnnnner><c>ImportScreen<<<<$allAddressesText");
      
    }
    uniqueStrings1.join('');
      //uniqueStrings.isNotEmpty?uniqueStrings.remove(itemCategoryModel):  uniqueStrings.add(itemCategoryModel);
      setState(() {
        allAddressesText1=uniqueStrings1;
        print("><<><><>><allAddressesText><>><<><><><,,,,,,$allAddressesText");
        // select=false;
        mergingExpert=true;
        selection=true;
        //box.write("import", selection);
      });

       allAddressesText1=uniqueStrings1;
     
}
Widget showMessage(){
    return Dialog(
      shape: RoundedRectangleBorder(
        
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(),
    );
  }
  Widget contentBox(){
   return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: Constants.padding,top: Constants.avatarRadius
              + Constants.padding, right: Constants.padding,bottom: Constants.padding
          ),
          margin: EdgeInsets.only(top: Constants.avatarRadius),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(Constants.padding),
            boxShadow: [
              BoxShadow(color: Colors.black,offset: Offset(0,10),
              blurRadius: 10
              ),
            ]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("Experties".tr,style: TextStyle(fontSize: 22,fontWeight: FontWeight.w600),),
              SizedBox(height: 15,),
            indicatorMerge==true?  Text("merge_success".tr,style: TextStyle(fontSize: 14),textAlign: TextAlign.center,):indicatorExport==true?Text("export_success".tr,style: TextStyle(fontSize: 14),textAlign: TextAlign.center,):indicatorImport==true?Text("import_success".tr,style: TextStyle(fontSize: 14),textAlign: TextAlign.center,):Text(""),
              SizedBox(height: 22,),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                    onPressed: (){
                      // Navigator.of(context).pop();
                      Navigator.pop(context);
                    },
                    child: Text("Ok".tr,style: TextStyle(fontSize: 18),)),
              ),
            ],
          ),
        ),
        Positioned(
          left: Constants.padding,
            right: Constants.padding,
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: Constants.avatarRadius,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(Constants.avatarRadius)),
                  child: Image.asset("assets/images/technician.png")
              ),
            ),
        ),
      ],
    );
  }

}
class Constants{
  Constants._();
  static const double padding =20;
  static const double avatarRadius =45;
}
