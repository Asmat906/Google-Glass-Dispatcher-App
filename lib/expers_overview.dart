import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive/hive.dart';
import 'package:google_glass_dispatcher/database/db_address.dart';
import 'package:google_glass_dispatcher/database/db_experties.dart';
import 'package:google_glass_dispatcher/database/db_experts.dart';
import 'package:google_glass_dispatcher/new_order_form.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_glass_dispatcher/sideMenu/externaldb_model.dart';
class ExpertOverview extends StatefulWidget {
 final text;
  ExpertOverview({Key? key,  this.text}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _ExpertOverviewState();
  }
}

class _ExpertOverviewState extends State<ExpertOverview> {
  final _formKey = GlobalKey<FormState>();
  //ExpertOverview ?text;

  bool errorName = false;
  bool errorEmail = false;
  bool errorExpertId = false;
  bool errorLastName = false;
  var currentSelectedValue;
  bool ?mergingExpert;
   bool? indicatorMerge;
   bool? indicatorExport;
   bool? indicatorImport;

  

 
  List<String> _selectedItems = [];
  
 List allAddressesText=[];
 List allAddressesText1=[];

  
  final box = GetStorage();
  bool selection=false;
  bool mergechoose=false;
  String data='';
  void _showMultiSelect() async {
    List<ExpertiesDo> allAddresses = await ExpertiesDB.getAllExperties();
    List<String> cityNames = allAddresses.map((city) => city.name).toList();
    var responseText=cityNames.join(',');
    List<String> _items = responseText.split(',');
    

    final List<String>? results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiSelect(items: _items);
        
      },
    );

    // Update UI
    if (results != null) {
      setState(() {
        newPhone = results;
      });
    }
  }
  var c;var d;var qfff;bool? select;
  @override
  initState() {
    select=false;
    super.initState();
    getAllAddressesWithSetState();
    WidgetsFlutterBinding.ensureInitialized();
    c=box.read("key");
    d=box.read("ExpertStorage");
  }
  bool isSelected = false;
  List<ExpertDo> selectedExperts=[];
  List<DataRow> generateListDataRowsFromListAddressDO(List<ExpertDo> listAddress) {
    return 
    listAddress.map<DataRow>((e) {
      return DataRow(cells: <DataCell>[
        DataCell(
          Row(
            children: [
              InkWell(
                onTap: () {
                  createOrEditNewAddress(address: e);
                },
                child: Image.asset(
                  "assets/images/pen.png",
                  width: 20,
                ),
              ),
              SizedBox(
                width: 10,
              ),
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
        DataCell(createTextPopupMenu(e.name, e)),
        DataCell(createTextPopupMenu(e.lastName, e)),
        DataCell(createTextPopupMenu(e.email, e)),
        DataCell(createTextPopupMenu(e.expertId.toString(),e)),
      ]);
    }).toList();
  }
  List<DataRow> generateListDataRowsFromListAddressDOExp(List<ExpertDo> experts) => experts
      .map((ExpertDo expert) => DataRow(
            selected: selectedExperts.contains(expert),
            onSelectChanged: (isSelected) => setState(() {
              var isAdding = isSelected != null && isSelected;

              isAdding
                  ? selectedExperts.add(expert)
                  : selectedExperts.remove(expert);
            }),
            
            
            cells: [
              DataCell(Container(
                width: 100,
                child: Text(""),
              )),DataCell(Container(
                width: 100,
                child: Text(expert.name.toString()),
              )), DataCell(Container(
                width: 100,
                child: Text(expert.lastName.toString()),
              )),DataCell(Container(
                width: 100,
                child: Text(expert.email.toString()),
              )),DataCell(Container(
                width: 100,
                child: Text(expert.expertId.toString()),
              )),
              
            ],
          ))
      .toList();
  
  
  Offset _positionPopupMenu = Offset(0, 0);

  Widget createTextPopupMenu(String text, ExpertDo address) {
    return GestureDetector(
      onSecondaryTapDown: (details) {
        _positionPopupMenu = details.globalPosition;
      },
      onSecondaryTap: () {
        showMenu(
          useRootNavigator: true,
          color: Colors.blue,
          position: RelativeRect.fromLTRB(
            _positionPopupMenu.dx,
            _positionPopupMenu.dy,
            _positionPopupMenu.dx,
            _positionPopupMenu.dy,
          ),
          items: [
            PopupMenuItem(
              value: address,
              child: Row(
                children:  [
                  Icon(Icons.add_circle_outline),
                  SizedBox(width: 10),
                  Text("new_expert".tr),
                ],
              ),
            ),
            PopupMenuItem(
              child: Row(
                children: [
                  Image.asset(
                    "assets/images/pen.png",
                    width: 20,
                  ),
                  const SizedBox(width: 10),
                   Text("to_edit".tr),
                ],
              ),
            ),
            PopupMenuItem(
              child: Row(
                children:  [
                  Icon(Icons.delete_forever_sharp, color: Colors.red),
                  SizedBox(width: 10),
                  Text("Extinguish".tr),
                ],
              ),
            ),
          ],
          context: context,
        ).then((value) {
          Future.delayed(Duration(milliseconds: 100), () {
            createNewOrder(value);
          });
        });
      },
      child: Text(text),
    );
  }

  createNewOrder(value) {
    if (value != null) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
      Navigator.of(context).pushNamed('/newOrder', arguments: value);
    }
  }

  delete(ExpertDo address) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(
            "permanent_del",
            textAlign: TextAlign.center,
          ),
          titlePadding: EdgeInsets.all(20),
          children: [
            Center(
              child: Text(address.name + "\n" + address.lastName + "\n" + address.expertId.toString() + "\n" + address.email),
            ),
            
            SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    ExpertDB.delete(address);
                    getAllAddressesWithSetState();
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
  }bool ?click;
 List<ExpertDo> allAddresses=[];
  getAllAddressesWithSetState() async {
     allAddresses = await ExpertDB.getAllAddresses(); 
   widget.text!="true"? setState(() { 
     generateListDataRowsFromListAddressDO(allAddresses);
      
    }):selection==true?setState(() {
      allAddressesText1.clear();
      generateListDataRowsFromListAddressDOTextf (allAddressesText1);
    
    }):setState(() {
      generateListDataRowsFromListAddressDOExp(allAddresses);
    });
  }

  List<DataRow> myDataRows = [];
  List myDataRows2 = [];

  @override
  bool ?popup;
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: 
          GestureDetector(
            onTap: Get.back,
            child: Icon(Icons.arrow_back)),
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
                        exportExperts();
                        indicatorExport=true;
                        indicatorImport=false;
                        indicatorMerge=false; 
                      showDialog(
                          context: context,
                          builder: (context) => showMessage(),
                         );
                         
                         
                      }else if(value == 1){
                         importExperts();
                         indicatorExport=false;
                        indicatorImport=true;
                        indicatorMerge=false;
                      showDialog(
                          context: context,
                          builder: (context) => showMessage(),
                         );
                        
                        allAddressesText1.clear();
                        myDataRows2= box.read("itemCategoryModel");
                      }else if(value == 2){
                       
                       indicatorExport=false;
                        indicatorImport=false;
                        indicatorMerge=true;
                      showDialog(
                          context: context,
                          builder: (context) => showMessage(),
                         );

                         popup=true;
                        
                         
                        setState(() {
                          allAddressesText.clear(); print("<><><><><><><>ffffffff>,,,$allAddressesText");
                          mergingExpert==true? mergeExperts():null;
                        });
                      }
                   }
                  ),

                   
            ],
        
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
           selection==false? Text("Experten".tr):Text("Experts_List".tr),
          ],
        ),
      ),
      floatingActionButton:widget.text=="true"? 
      ElevatedButton(
        onPressed: () {
          
           
              final fruitMap = selectedExperts.asMap();
           
             box.write("SelectedExpertManual", fruitMap);
             box.write("SelectedExpertManualList", selectedExperts);
             dynamic pop= box.read("listlist");
             dynamic man= box.read("SelectedExpertManualList");
 
             man.addAll(pop);
             var y = man.toSet();
              man = y.toList();
         final collection=man.asMap();
        selectedExperts!=null? box.write("collection", collection):null;
        selectedExperts!=null? Navigator.pop(context):null;
         box.write("true", "True");
        },
        child: Text("Submit".tr),
      ):
      ElevatedButton(
        onPressed: () {
          createOrEditNewAddress();
          
        },
        child: Icon(Icons.add),
      )
      ,
      body: Column(
        children: [
           selection==true? localAndExternalDb():selection==false&&mergechoose==false?localDb():cont(),
           Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            ],
          )
        ],
      ),
     );
  }
  bool choosing=false;

   Widget localDb(){
    return  Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: const [
                  SizedBox(
                    height: 30,
                  )
                ],
              ),
            ],
          ),
          DataTable(
            //showCheckboxColumn: false,
            dividerThickness: 2,
            showBottomBorder: true,
            columns:  <DataColumn>[
              DataColumn(
                label: Text(
                  '',
                ),
              ),
              DataColumn(
                label: Text(
                  'Name'.tr,
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              DataColumn(
                label: Text(
                  'LastName'.tr,
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              DataColumn(
                label: Text(
                  'Email'.tr,
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              DataColumn(
                label: Text(
                  'Expertfield'.tr,
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ],
            rows:widget.text!='true'?generateListDataRowsFromListAddressDO(allAddresses):selection==true? generateListDataRowsFromListAddressDOTextf (allAddressesText):   generateListDataRowsFromListAddressDOExp(allAddresses),
          
          ),
        ],
      );
    
  }
  Widget cont(){
    return Container(child: Center(child: Text("",style: TextStyle(fontSize: 39),),),);
  }
  Widget mergDb(){
    return  Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: const [
                  SizedBox(
                    height: 30,
                  )
                ]
                
              ),
              Center(child: Text("Merged",style: TextStyle(fontSize: 50),)),
            ],
          ),
          DataTable(
            //showCheckboxColumn: false,
            dividerThickness: 2,
            showBottomBorder: true,
            columns:  <DataColumn>[
              DataColumn(
                label: Text(
                  '',
                ),
              ),
              DataColumn(
                label: Text(
                  'Name'.tr,
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              DataColumn(
                label: Text(
                  'LastName'.tr,
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              DataColumn(
                label: Text(
                  'Email'.tr,
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              DataColumn(
                label: Text(
                  'ExpertId'.tr,
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ],
            rows:generateListDataRowsFromListAddressDOTextfmerged(uniqueStrings),
          ),
          indicatorMerge==true?showMessage():cont(),
         
        ],
      );
    
  }
  
bool ?merging;
  Widget localAndExternalDb(){
    return  Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: const [
                  SizedBox(
                    height: 30,
                  )
                ],
              ),
            ],
          ),
          DataTable(
            //showCheckboxColumn: false,
            dividerThickness: 2,
            showBottomBorder: true,
            columns:  <DataColumn>[
              DataColumn(
                label: Text(
                  '',
                ),
              ),
              DataColumn(
                label: Text(
                  'Name'.tr,
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              DataColumn(
                label: Text(
                  'LastName'.tr,
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              DataColumn(
                label: Text(
                  'Email'.tr,
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              DataColumn(
                label: Text(
                  'ExpertId'.tr,
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ],
            rows:widget.text!='true'?generateListDataRowsFromListAddressDO(allAddresses):generateListDataRowsFromListAddressDOExp(allAddresses),
          ),
          SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(child: allAddressesText!=null?Text("External DB Experts Imported",style: TextStyle(fontSize: 20),):Text("External DB Experts Not Imported Yet",style: TextStyle(fontSize: 20,color: Colors.red)),)
            ],
          ),
           allAddressesText1!=null&&selection==true?
           DataTable(
            //showCheckboxColumn: false,
            dividerThickness: 2,
            showBottomBorder: true,
            columns: <DataColumn>[
              DataColumn(
                label: Text(
                  '',
                ),
              ),
              DataColumn(
                label: Text(
                  'Name'.tr,
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              DataColumn(
                label: Text(
                  'LastName'.tr,
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              DataColumn(
                label: Text(
                  'Email'.tr,
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              DataColumn(
                label: Text(
                  'ExpertId'.tr,
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ],
            rows:generateListDataRowsFromListAddressDOTextf(allAddressesText1),):Container(),
          
        ],
      );
    
  }
  
  Future<String> _getPathToDownload() async {
  return ExtStorage.getExternalStoragePublicDirectory(
      ExtStorage.DIRECTORY_DOWNLOADS);
}
bool? indicator;
Future exportExperts() async {
  List<ExpertDo> allAddresses = await ExpertDB.getAllAddresses();
  setState(() {
    select=true;
    selection=false;
    mergechoose=false;
    indicator=true;
    showMessage();
  });
  var Grooup2=[];
  String ?jsonUser;
  for (int i=0;i<allAddresses.length;i++){
    Experts user=Experts(allAddresses[i].name.toString(), allAddresses[i].lastName.toString(), allAddresses[i].email.toString(),allAddresses[i].expertId.toList(),allAddresses[i].id.toString());
   jsonUser = jsonEncode(user);
   Grooup2.add(jsonUser);
  }
   final String path = await _getPathToDownload();
   File file2 = File("$path/experts.txt");
   await file2.writeAsString(Grooup2.toString());
}
List uniqueStrings=[];// = myStrings.toSet().toList();
List jsonResult1=[];
bool ?pop;
 
Future mergeExperts() async { 
  final String path = await _getPathToDownload();
      File file3 = File("$path/experts.txt");
      
       var c=await file3.readAsString(); 
       List jsonResult = jsonDecode( c);
       jsonResult1=jsonResult;
       Experts ?itemCategoryModel;
       for (var value in  jsonResult) {
      itemCategoryModel = Experts.fromJson(value); 
         
         var name1=[];
        var lastName1=[];
        var email1=[];
        var expertId1=[];
        List<ExpertDo> jtechDBCount = await ExpertDB.getAllAddresses(); 
       uniqueStrings.add(itemCategoryModel);
       for(int i=0;i<jtechDBCount.length;i++){

          name1.add(jtechDBCount[i].name);
          lastName1.add(jtechDBCount[i].lastName);
          email1.add(jtechDBCount[i].email);
          expertId1.add(jtechDBCount[i].expertId);
          
        }
        if(name1.contains(itemCategoryModel.name)&&lastName1.contains(itemCategoryModel.lastName)&&email1.contains(itemCategoryModel.email)){
          print("not added");
        }
        else{ 
          saveAddressToDB(itemCategoryModel.name, itemCategoryModel.lastName, itemCategoryModel.email, itemCategoryModel.expertId, );
        
        }
      
    }
    uniqueStrings.join('');
    setState(() {
      //allAddresses.clear();
      allAddressesText=uniqueStrings;
      select=false;
      selection=false;
      pop=true;
      mergingExpert=false;
      box.write("import", selection);
    });
    allAddressesText=uniqueStrings;
}
List merge=[];
List uniqueStrings1=[];
List jsonResult2=[];
bool? imported;
Future importExperts() async { 
  final String path = await _getPathToDownload();
      File file3 = File("$path/experts.txt");
      
       var c=await file3.readAsString(); 
       List jsonResult = jsonDecode( c);
       jsonResult2=jsonResult;
       Experts ?itemCategoryModel;
       for (var value in  jsonResult) {
      itemCategoryModel = Experts.fromJson(value);
      
      var c=itemCategoryModel.email;
       uniqueStrings1.remove(itemCategoryModel);
       uniqueStrings1.add(itemCategoryModel);
    }
    uniqueStrings1.join('');
    setState(() {
      allAddressesText1=uniqueStrings1;
      mergingExpert=true;
      selection=true;
      imported=true;
      box.write("import", selection);
      });

       allAddressesText1=uniqueStrings1;
     
}


 
  
  List<DataRow> generateListDataRowsFromListAddressDOTextf(List listAddress) {
    return 
   listAddress.map<DataRow>((e) {
      return DataRow(cells: <DataCell>[
        DataCell(
          Row(
            children: [
              InkWell(
                onTap: () {
                  createOrEditNewAddress(address: e);
                },
                child: Image.asset(
                  "assets/images/pen.png",
                  width: 20,
                ),
              ),
              SizedBox(
                width: 10,
              ),
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
        DataCell(Text(e.name.toString())),
        DataCell(Text(e.lastName.toString())),
        DataCell(Text(e.email.toString())),
        DataCell(Text(e.expertId.toString())),
      ]);
    }).toList();
  }
   List<DataRow> generateListDataRowsFromListAddressDOTextfmerged(List listAddress) {
    return 
   listAddress.map<DataRow>((e) {
      return DataRow(cells: <DataCell>[
        DataCell(
          Row(
            children: [
              InkWell(
                onTap: () {
                  createOrEditNewAddress(address: e);
                },
                child: Image.asset(
                  "assets/images/pen.png",
                  width: 20,
                ),
              ),
              SizedBox(
                width: 10,
              ),
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
        DataCell(Text(e.name.toString())),
        DataCell(Text(e.lastName.toString())),
        DataCell(Text(e.email.toString())),
        DataCell(Text(e.expertId.toString())),
      ]);
    }).toList();
  }
  

  resetErrors() {
    errorExpertId = false;
    errorName = false;
    errorEmail = false;
    errorLastName = false;
  }
  List ?newPhone;
  createOrEditNewAddress({ExpertDo? address}) {
    String newName = "";
    String newEmail = "";
    newPhone ;
    String newAddress = "";

    resetErrors();

    if (address != null) {
      newName = address.name;
      newEmail = address.email;
      newPhone = address.expertId;
      newAddress = address.lastName;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:  [Text("new_expert".tr)],
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
                                icon: const Icon(Icons.person_rounded),
                              ),
                              onSaved: (String? value) {
                                newName = value ?? "";
                              },
                            ),
                          ),
                            Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              initialValue: newAddress,
                              minLines: 2,
                              maxLines: 2,
                              decoration: InputDecoration(
                                labelText: "LastName".tr,
                                errorText: errorLastName ? "LastName_warning".tr : null,
                                icon: Icon(Icons.location_on),
                              ),
                              onSaved: (String? value) {
                                newAddress = value ?? "";
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              initialValue: newEmail,
                              decoration: InputDecoration(
                                labelText: "Email".tr,
                                errorText: errorEmail ? "email_warning".tr : null,
                                icon: const Icon(Icons.email_rounded),
                              ),
                              onSaved: (String? value) {
                                newEmail = value ?? "";
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                               // use this button to open the multi-select dialog
                                ElevatedButton(
                                  child: Text('Select_your_Experties'.tr),
                                  onPressed: _showMultiSelect,
                                  
                                ),
                                const Divider(
                                  height: 30,
                                ),
                              //  display selected items
                                Wrap(
                                  children: _selectedItems
                                      .map((e) => Chip(
                                            label: Text(e),
                                          ))
                                      .toList(),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
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
                                    _formKey.currentState!.save();
                                    print("||||||||||||||||||||||<<<<<<<<$_formKey");
                                    if (hasFormErrors(newName, newAddress, newEmail, newPhone!)) {
                                      setState(() {});
                                    } else {
                                      saveAddressToDB(newName, newAddress, newEmail, newPhone!, editAddress: address);
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
  }Experts ?address;
  saveAddressToDB(String newName, String newAddress, String newEmail, List newPhone,
      {ExpertDo? editAddress = null}) {
    if (editAddress == null) {
      ExpertDo address = ExpertDo.newAddressEntry(newName, newAddress, newEmail, newPhone);
      ExpertDB.saveToBox(address);
    }
    else if(address != null){
      address!.name=newName;
      address!.lastName=newAddress;
      address!.email=newEmail;
      address!.expertId=newPhone;


    }
     else {
      editAddress.name = newName;
      editAddress.lastName = newAddress;
      editAddress.expertId = newPhone;
      editAddress.email = newEmail;
      ExpertDB.replace(editAddress);
    }
    getAllAddressesWithSetState();
   popup==true?null:
    Navigator.pop(context);
  }

  bool hasFormErrors(String name, String lastname, String email, List expertId) {
    errorName = name.isEmpty;
    errorEmail = email.isEmpty;
    errorExpertId = expertId.isEmpty;
    errorLastName = lastname.isEmpty;

    return errorName || errorName || errorExpertId || errorLastName;
  }
  Widget showMessage(){
    return Dialog(
      shape: RoundedRectangleBorder(
        //borderRadius: BorderRadius.circular(Constants.padding),
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
              Text("Experten".tr,style: TextStyle(fontSize: 22,fontWeight: FontWeight.w600),),
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
                    child: Text("Ok",style: TextStyle(fontSize: 18),)),
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

class MultiSelect extends StatefulWidget {
  final List<String> items;
  const MultiSelect({Key? key, required this.items}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MultiSelectState();
}

class _MultiSelectState extends State<MultiSelect> {
  // this variable holds the selected items
  final List<String> _selectedItems = [];

// This function is triggered when a checkbox is checked or unchecked
  void _itemChange(String itemValue, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedItems.add(itemValue);
      } else {
        _selectedItems.remove(itemValue);
      }
    });
  }

  // this function is called when the Cancel button is pressed
  void _cancel() {
    Navigator.pop(context);
  }

// this function is called when the Submit button is tapped
  void _submit() {
    Navigator.pop(context, _selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select_your_Experties'.tr),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.items
              .map((item) => CheckboxListTile(
                    value: _selectedItems.contains(item),
                    title: Text(item),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (isChecked) => _itemChange(item, isChecked!),
                  ))
              .toList(),
        ),
      ),
      actions: [
        TextButton(
          child: Text('Cancel'.tr),
          onPressed: _cancel,
        ),
        ElevatedButton(
          child: Text('Submit'.tr),
          onPressed: _submit,
        ),
      ],
    );
  }
}
class User {
  String name;
  String lastName;
  String email;
  String expertId;

  User(this.name, this.lastName,this.email,this.expertId);

  factory User.fromJson(dynamic json) {
    return User(
     json['name'] as String,
     json['lastNmae'] as String,
     json['email'] as String,
     json['expertId'] as String);
  }

  @override
  String toString() {
    return ' ${this.name}, ${this.lastName} ,${this.email},${this.expertId}';
  }
}

class Constants{
  Constants._();
  static const double padding =20;
  static const double avatarRadius =45;
}

 
