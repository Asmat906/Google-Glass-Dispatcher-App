import 'dart:convert';
import 'dart:io';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:google_glass_dispatcher/database/db_experts.dart';
import 'package:google_glass_dispatcher/database/db_technicican.dart';
import 'package:google_glass_dispatcher/consts/mail_settings.dart';
import 'package:google_glass_dispatcher/sideMenu/externaldb_model.dart';

class TechnicianOverview extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TechnicianOverviewState();
  }
}

class _TechnicianOverviewState extends State<TechnicianOverview> {
  final _formKey = GlobalKey<FormState>();

  bool errorName = false;
  bool errorEmail = false;
  bool errorPhone = false;
  List allAddressesText1=[];
  List allAddressesText=[];
  bool selection=false;
  bool ?mergingExpert;
  bool  ?select;
  bool mergechoose=false;

   bool? indicatorMerge;
   bool? indicatorExport;
   bool? indicatorImport;
   bool ?popup;

  @override
  initState() {
    super.initState();
    getAllTechnician();
  }

  resetErrors() {
    errorName = false;
    errorEmail = false;
    errorPhone = false;
  }

  getAllTechnician() {
    List<TechnicianDO> allTechies = TechnicianDB.getAllTechnician(sorted: true);
    myDataRows = allTechies.map<DataRow>((e) {
      return 
      DataRow(cells: <DataCell>[
        DataCell(
          Row(
            children: [
              InkWell(
                onTap: () {
                  createOrEditNewTechnician(technicianID: e.id);
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
        DataCell(Text(e.name)),
        DataCell(Text(e.email)),
        DataCell(Text(e.phone)),
      ]);
    }).toList();
    setState(() {});
  }
  List<DataRow> generateListDataRowsFromListAddressDOTextf(List listAddress) {
    return listAddress.map<DataRow>((e) {
      return DataRow(cells: <DataCell>[
        DataCell(
          Row(
            children: [
              InkWell(
                onTap: () {
                  createOrEditNewTechnician(technicianID: e.id);
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
        DataCell(Text(e.name)),
        DataCell(Text(e.email)),
        DataCell(Text(e.phone)),
      ]);
    }).toList();
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
                     List<TechnicianDO> allAddresses =  TechnicianDB.getAllTechnician() as List<TechnicianDO> ;

                      if(value == 0){
                         exportTechnicker();
                        indicatorExport=true;
                        indicatorImport=false;
                        indicatorMerge=false;
                      allAddresses.isNotEmpty?  showDialog(
                          context: context,
                          builder: (context) => showMessage(),
                         ):null;
                         
                      }else if(value == 1){
                        importTechnicker();
                         indicatorExport=false;
                        indicatorImport=true;
                        indicatorMerge=false;
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
                         setState(() {
                           mergeTechnicker();
                        });
                      }
                   }
                  ),

                   
            ],
        
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Techniker".tr),
          ],
        ),
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () {
          createOrEditNewTechnician();
        },
        child: Icon(Icons.add),
      ),
      body: Column(
        children: [
         selection==true? localAndExternalDb():selection==false&&mergechoose==false?localDb():cont(),
         ],
      ),
    );
  }
   Widget cont(){
    return Container(child: Center(child: Text("",style: TextStyle(fontSize: 39),),),);
  }
  Widget localDb(){
   return  Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SingleChildScrollView(
                child: DataTable(
                  sortColumnIndex: 1,
                  sortAscending: true,
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
                        'Email'.tr,
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Telephone'.tr,
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    )
                  ],
                  rows: selection==true? generateListDataRowsFromListAddressDOTextf (allAddressesText):myDataRows,
                ),
              ),
            ],
          );
        
  }
  Widget localAndExternalDb(){
   return  Column(
     children: [
       Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SingleChildScrollView(
                    child: DataTable(
                      sortColumnIndex: 1,
                      sortAscending: true,
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
                            'Email'.tr,
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Telephone'.tr,
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        )
                      ],
                      rows: myDataRows,
                    ),
                  ),
                ],
              ),
        SizedBox(height: 10,),
        allAddressesText1.isNotEmpty?  Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(child: allAddressesText1.isNotEmpty?Text("External DB Technician Imported",style: TextStyle(fontSize: 20),):Text("External DB Experts Not Imported Yet",style: TextStyle(fontSize: 20,color: Colors.red)),)
            ],
          ):Container(),
           
      allAddressesText1.isNotEmpty?  Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SingleChildScrollView(
                    child: DataTable(
                      sortColumnIndex: 1,
                      sortAscending: true,
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
                            'Email'.tr,
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Telephone'.tr,
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        )
                      ],
                      rows: generateListDataRowsFromListAddressDOTextf(allAddressesText1),
                    ),
                  ),
                ],
        ):Container()
              
     ],
   );
        
  }
  
  Future<String> _getPathToDownload() async {
  return ExtStorage.getExternalStoragePublicDirectory(
      ExtStorage.DIRECTORY_DOWNLOADS);
}

  Future exportTechnicker() async {
 
  List<TechnicianDO> allAddresses = await TechnicianDB.getAllTechnician();
  setState(() {
      select=true;
      selection=false;
      mergechoose=false;
  });
  var Grooup2=[];
  String ?jsonUser;
  for (int i=0;i<allAddresses.length;i++){
    Technician user=Technician(allAddresses[i].name.toString(), allAddresses[i].email.toString(), allAddresses[i].phone.toString(),allAddresses[i].techEmail.toString(),allAddresses[i].shortcut.toString());
   jsonUser = jsonEncode(user);
   Grooup2.add(jsonUser);
  }
   final String path = await _getPathToDownload();
   File file2 = File("$path/technician.txt");
   await file2.writeAsString(Grooup2.toString());
}
  List merge=[];
List uniqueStrings1=[];
List jsonResult2=[];
  Future importTechnicker() async { 
  final String path = await _getPathToDownload();
      File file3 = File("$path/technician.txt");
      
       var c=await file3.readAsString(); 
       List jsonResult = jsonDecode( c);
       jsonResult2=jsonResult;
       Technician ?itemCategoryModel;
       for (var value in  jsonResult) {
      itemCategoryModel = Technician.fromJson(value);
      
      var c=itemCategoryModel.email;
       uniqueStrings1.remove(itemCategoryModel);
       uniqueStrings1.add(itemCategoryModel);
    }
    uniqueStrings1.join('');
    setState(() {
      allAddressesText1=uniqueStrings1;
      mergingExpert=true;
      selection=true;
    });
    allAddressesText1=uniqueStrings1;
     
}
List uniqueStrings=[];
List jsonResult1=[];
bool ?pop;
Future mergeTechnicker() async { 
  final String path = await _getPathToDownload();
      File file3 = File("$path/technician.txt");
      
       var c=await file3.readAsString(); 
       List jsonResult = jsonDecode( c);
       jsonResult1=jsonResult;
       print("><><<>mmmmm><><><><>$jsonResult");
       Technician ?itemCategoryModel;
       for (var value in  jsonResult) {
      itemCategoryModel = Technician.fromJson(value); 
        var name1=[];
        var gmail1=[];
        var phone1=[];
        var jtechDBCount = TechnicianDB.getAllTechnician();
        for(int i=0;i<jtechDBCount.length;i++){
          name1.add(jtechDBCount[i].name);
          gmail1.add(jtechDBCount[i].email);
          phone1.add(jtechDBCount[i].phone); 
        }
        if(name1.contains(itemCategoryModel.name)&&gmail1.contains(itemCategoryModel.email)&&phone1.contains(itemCategoryModel.phone)){
          print("not added");
        }else{ saveAddressToDB(itemCategoryModel.name, itemCategoryModel.email, itemCategoryModel.phone,itemCategoryModel.techmail, itemCategoryModel.shortcut,);
       }
        
       
       uniqueStrings.isNotEmpty?uniqueStrings.remove(uniqueStrings):
       uniqueStrings.add(itemCategoryModel);
      
    }
    uniqueStrings.join(',');
    setState(() {
        //allAddresses.clear();
      select=false;
      selection=false;
      pop=true;
      mergingExpert=false;
    });
    allAddressesText = uniqueStrings.toSet().toList();
}

  createOrEditNewTechnician({String technicianID = ""}) {
    resetErrors();
    String newName = "";
    String newEmail = "";
    String newPhone = "";
    String newShortcut ="";
    String newTecEmail="";

    TechnicianDO? currentEditTechnician;

    if (technicianID.isNotEmpty) {
      currentEditTechnician = TechnicianDB.getTechnicianById(technicianID);
      newName = currentEditTechnician.name;
      newEmail = currentEditTechnician.email;
      newPhone = currentEditTechnician.phone;
      newShortcut = currentEditTechnician.shortcut;
      newTecEmail = currentEditTechnician.techEmail;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text(currentEditTechnician == null ? "new_technician".tr : "to_edit".tr)],
          ),
          children: [
            StatefulBuilder(
              builder: (context, setState) {
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
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              initialValue: newEmail,
                              decoration: InputDecoration(
                                labelText: "Email".tr,
                                errorText: errorEmail ? "email_warning".tr : null,
                                icon: Icon(Icons.email_rounded),
                              ),
                              onSaved: (String? value) {
                                newEmail = value ?? "";
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              initialValue: newPhone,
                              decoration: InputDecoration(
                                labelText: "Telephone".tr,
                                errorText: errorPhone ? "phone_warning".tr : null,
                                icon: Icon(Icons.phone),
                              ),
                              onSaved: (String? value) {
                                newPhone = value ?? "";
                              },
                            ),
                          ),
                          Visibility(child:
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              initialValue: newTecEmail,
                              decoration: InputDecoration(
                                labelText: "TecEmail".tr,
                                errorText: errorName ? "techmail_warning".tr : null,
                                icon: Icon(Icons.person_rounded),
                              ),
                              onSaved: (String? value) {
                                newTecEmail = value ?? "";
                              },
                            ),
                          ),visible: false),// set this false for hiding on dispatcher gui
                          Visibility(child:
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              initialValue: newShortcut,
                              decoration: InputDecoration(
                                labelText: "shortcut".tr,
                                errorText: errorName ? "abrevation_warning".tr : null,
                                icon: Icon(Icons.person_rounded),
                              ),
                              onSaved: (String? value) {
                                newShortcut = value ?? "";
                              },
                            ),
                          ),visible: false),
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
                                  child:  Padding(
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

                                    if (isErrorInInput(newName, newEmail, newPhone)) {
                                      setState(() {});
                                    } else {
                                     // saveTechnician(newName, newEmail, newPhone, currentEditTechnician, newTecEmail, newShortcut);
                                    saveAddressToDB(newName, newEmail, newPhone,  newTecEmail,newShortcut,currentEditTechnician );
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

  bool isErrorInInput(String name, String email, String phone) {
    errorName = name.isEmpty;
    errorEmail = email.isEmpty;
    errorPhone = phone.isEmpty;
    return errorName || errorName || errorPhone;
  }
  
  // saveTechnician(String name, String email, String phone, TechnicianDO? tech, String techemail, String shortcut) {
  // //saveTechnician(dynamic name, dynamic email, dynamic phone, dynamic tech, dynamic techemail, dynamic shortcut) {
    
  //   if (tech == null) {
  //     TechnicianDO newTech;
  //     int techDBCount = TechnicianDB.getAllTechnician().length;
  //       if(techDBCount == 0) {
  //         print("ifffffff");
  //         newTech = TechnicianDO.newTechnicianEntry(name, email, phone,MAIL_USERNAME, "HWK-1");
  //       }else if (techDBCount == 1) {
  //          print("ifffffff 11111");
  //         newTech = TechnicianDO.newTechnicianEntry(
  //             name, email, phone, MAIL_USERNAME, "HWK-2");
  //       }else if (techDBCount == 2) {
  //          print("ifffffff 22222");
  //         newTech = TechnicianDO.newTechnicianEntry(
  //             name, email, phone, MAIL_USERNAME, "HWK-3");
  //       }else
  //         {
  //            print("ifffffff  333333");
  //           newTech = TechnicianDO.newTechnicianEntry(
  //               name, email, phone, "none", "none");
  //         }

  //     TechnicianDB.saveToBox(newTech);
  //   } else {
  //      print("<>><<>>><ggggggg<>><>$tech");
  //      print("ifffffff   4444444");
  //     tech.name = name;
  //     tech.email = email;
  //     tech.phone = phone;
  //     tech.shortcut = shortcut;
  //     tech.techEmail = techemail;
  //     TechnicianDB.replace(tech);
  //   }
  //   getAllTechnician();
  //   Navigator.pop(context);
  // }
  TechnicianDO? address;
  saveAddressToDB(String name, String email, String phone, String techemail, String shortcut,
      [TechnicianDO? tech = null]) {
    if (tech == null) {
          TechnicianDO newTech;
      int techDBCount = TechnicianDB.getAllTechnician().length;
      var jtechDBCount = TechnicianDB.getAllTechnician();
        if(techDBCount == 0) {
          newTech = TechnicianDO.newTechnicianEntry(name, email, phone,MAIL_USERNAME, "HWK-1");
        }else if (techDBCount == 1) {
          newTech = TechnicianDO.newTechnicianEntry(
              name, email, phone, MAIL_USERNAME, "HWK-2");
        }else if (techDBCount == 2) {
          newTech = TechnicianDO.newTechnicianEntry(
              name, email, phone, MAIL_USERNAME, "HWK-3");
        }
          else
          {
            newTech = TechnicianDO.newTechnicianEntry(
                name, email, phone, "none", "none");
          }

      TechnicianDB.saveToBox(newTech);
    }
     else {
      tech.name = name;
      tech.email = email;
      tech.phone = phone;
      tech.shortcut = shortcut;
      tech.techEmail = techemail;
      TechnicianDB.replace(tech);
    }
    getAllTechnician();
    popup==true?null:
    Navigator.pop(context);
  }

  delete(TechnicianDO tech) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(
            "Wirklich permanent löschen",
            textAlign: TextAlign.center,
          ),
          titlePadding: EdgeInsets.all(20),
          children: [
            Center(
              child: Text(tech.name + "\n" + tech.email + "\n" + tech.phone),
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    TechnicianDB.delete(tech);
                    setState(() {
                      getAllTechnician();
                    });
                    Navigator.pop(context);
                  },
                  child: Text("Ja"),
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
                  child: Text("Nein"),
                ),
              ],
            ),
          ],
        );
      },
    );
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
              Text("quote".tr,style: TextStyle(fontSize: 22,fontWeight: FontWeight.w600),),
              SizedBox(height: 15,),
            indicatorMerge==true?  Text("Merged Successfully",style: TextStyle(fontSize: 14),textAlign: TextAlign.center,):indicatorExport==true?Text("Exported Successfully",style: TextStyle(fontSize: 14),textAlign: TextAlign.center,):indicatorImport==true?Text("Imported Successfully",style: TextStyle(fontSize: 14),textAlign: TextAlign.center,):Text(""),
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
class Constants{
  Constants._();
  static const double padding =20;
  static const double avatarRadius =45;
}
