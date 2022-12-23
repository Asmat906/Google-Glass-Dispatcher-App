import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:google_glass_dispatcher/database/db_address.dart';
import 'package:google_glass_dispatcher/sideMenu/externaldb_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ext_storage/ext_storage.dart';

class AddressOverview extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AddressOverviewState();
  }
}

class _AddressOverviewState extends State<AddressOverview> {
  final _formKey = GlobalKey<FormState>();

  bool errorName = false;
  bool errorEmail = false;
  bool errorPhone = false;
  bool errorAddress = false;

  bool? select;
  bool selection=false;
  bool mergechoose=false;
  bool ?mergingExpert;
  bool ?popup;

   bool? indicatorMerge;
   bool? indicatorExport;
   bool? indicatorImport;

  List allAddressesText=[];
 List allAddressesText1=[];

  @override
  initState() {
    super.initState();
    getAllAddressesWithSetState();
  }

  List<DataRow> generateListDataRowsFromListAddressDO(List<AddressDO> listAddress) {
    return listAddress.map<DataRow>((e) {
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
        DataCell(createTextPopupMenu(e.address, e)),
        DataCell(createTextPopupMenu(e.email, e)),
        DataCell(createTextPopupMenu(e.phone, e)),
      ]);
    }).toList();
  }
  List<DataRow> generateListDataRowsFromListExpertiesDOTf(List listAddress1) {
    return listAddress1.map<DataRow>((e) {
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
        DataCell(Text(e.address.toString())),
        DataCell(Text(e.email.toString())),
        DataCell(Text(e.phone.toString())),
      ]);
    }).toList();
  }

  Offset _positionPopupMenu = Offset(0, 0);

  Widget createTextPopupMenu(String text, AddressDO address) {
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
                children: [
                  Icon(Icons.add_circle_outline),
                  SizedBox(width: 10),
                  Text("NewOrder".tr),
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
                  SizedBox(width: 10),
                  Text("to_edit".tr),
                ],
              ),
            ),
            PopupMenuItem(
              child: Row(
                children: [
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

  delete(AddressDO address) {
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
              child: Text(address.name + "\n" + address.address + "\n" + address.phone + "\n" + address.email),
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    AddressDB.delete(address);
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
  }



  getAllAddressesWithSetState() async {
    List<AddressDO> allAddresses = await AddressDB.getAllAddresses();
    
    setState(() {
      myDataRows = generateListDataRowsFromListAddressDO(allAddresses);
      myDataRows1 = generateListDataRowsFromListExpertiesDOTf(allAddressesText1);
    });
  }

  List<DataRow> myDataRows = [];
  List<DataRow> myDataRows1 = [];

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
                        exportKunden();
                        indicatorExport=true;
                        indicatorImport=false;
                        indicatorMerge=false;
                        showDialog(
                          context: context,
                          builder: (context) => showMessage(),
                         );
                         
                      }else if(value == 1){
                         importKunden();
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
                          allAddressesText.clear();
                          mergingExpert==true? mergeKunden():null;
                        });
                      }
                   }
                  ),

                   
            ],
        
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("customer_addresses".tr),
          ],
        ),
     
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () {
          createOrEditNewAddress();
        },
        child: Icon(Icons.add),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  SizedBox(
                    width: 200,
                    child: TextField(
                      onChanged: (String searchText) {
                        if (searchText.isNotEmpty) {
                          setState(() {
                            myDataRows = generateListDataRowsFromListAddressDO(
                                AddressDB.getMatchingAddressesByAnything(searchText));
                          });
                        } else {
                          getAllAddressesWithSetState();
                        }
                      },
                      decoration: InputDecoration(
                        icon: Icon(Icons.search),
                        fillColor: Colors.grey,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  selection==true? localAndExternalDb():selection==false&&mergechoose==false?localDb():cont(),
                ],
              ),
            ],
          ),
         
        ],
      ),
    );
  }
  Widget cont(){
    return Container(child: Center(child: Text(" ",style: TextStyle(fontSize: 39),),),);
  }
  Widget localDb(){
    return  DataTable(
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
                  'Address'.tr,
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
              ),
            ],
            rows: selection==true? generateListDataRowsFromListExpertiesDOTf (allAddressesText):myDataRows,
          );
       
  }
  Widget localAndExternalDb(){
    return Column(
      children: [
         DataTable(
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
                  'Address'.tr,
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
              ),
            ],
            rows: myDataRows,
          ),
          SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(child: allAddressesText!=null?Text("External DB Kunden Imported",style: TextStyle(fontSize: 20),):Text("External DB Experts Not Imported Yet",style: TextStyle(fontSize: 20,color: Colors.red)),)
            ],
          ),
         
         DataTable(
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
                  'Address'.tr,
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
              ),
            ],
            rows:generateListDataRowsFromListExpertiesDOTf(allAddressesText1),
          )
       
      ],
    );
  }

  resetErrors() {
    errorPhone = false;
    errorName = false;
    errorEmail = false;
    errorAddress = false;
  }

  createOrEditNewAddress({AddressDO? address}) {
    String newName = "";
    String newEmail = "";
    String newPhone = "";
    String newAddress = "";

    resetErrors();

    if (address != null) {
      newName = address.name;
      newEmail = address.email;
      newPhone = address.phone;
      newAddress = address.address;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text("New_address".tr)],
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
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              initialValue: newAddress,
                              minLines: 2,
                              maxLines: 2,
                              decoration: InputDecoration(
                                labelText: "Address".tr,
                                errorText: errorAddress ? "address_warning".tr : null,
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
                                    _formKey.currentState!.save();
                                    if (hasFormErrors(newName, newAddress, newEmail, newPhone)) {
                                      setState(() {});
                                    } else {
                                      saveAddressToDB(newName, newAddress, newEmail, newPhone, editAddress: address);
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
AddressDO? address;
  saveAddressToDB(String newName, String newAddress, String newEmail, String newPhone,
      {AddressDO? editAddress = null}) {
    if (editAddress == null) {
       address = AddressDO.newAddressEntry(newName, newAddress, newEmail, newPhone);
      AddressDB.saveToBox(address!);
      print("><><><><><><><><>cccccccccc<<>>< customer\<><><>..$address");
    } else {
      editAddress.name = newName;
      editAddress.address = newAddress;
      editAddress.phone = newPhone;
      editAddress.email = newEmail;
      AddressDB.replace(editAddress);
    }
    getAllAddressesWithSetState();
    popup==true?null:
    Navigator.pop(context);
  }

  bool hasFormErrors(String name, String address, String email, String phone) {
    errorName = name.isEmpty;
    errorEmail = email.isEmpty;
    errorPhone = phone.isEmpty;
    errorAddress = address.isEmpty;

    return errorName || errorName || errorPhone || errorAddress;
  }
   Future<String> _getPathToDownload() async {
  return ExtStorage.getExternalStoragePublicDirectory(
      ExtStorage.DIRECTORY_DOWNLOADS);
}

  Future exportKunden() async {
  List<AddressDO> allAddresses = await AddressDB.getAllAddresses();
  setState(() {
     select=true;
     selection=false;
     mergechoose=false;
  });var Grooup2=[];
  String ?jsonUser;
  for (int i=0;i<allAddresses.length;i++){
    Customer user=Customer(allAddresses[i].name.toString(), allAddresses[i].address.toString(), allAddresses[i].email.toString(),allAddresses[i].phone.toString(),allAddresses[i].id.toString(),);
   jsonUser = jsonEncode(user);
   Grooup2.add(jsonUser);
  }
  print("><<><><><><>export><<>>$Grooup2");
   final String path = await _getPathToDownload();
   File file2 = File("$path/customer.txt");
   await file2.writeAsString(Grooup2.toString());
}
List uniqueStrings=[];
List jsonResult1=[];
bool ?pop;
Future mergeKunden() async { 
  final String path = await _getPathToDownload();
      File file3 = File("$path/customer.txt");
      
       var c=await file3.readAsString(); 
       List jsonResult = jsonDecode( c);
       jsonResult1=jsonResult;
       Customer ?itemCategoryModel;
       for (var value in  jsonResult) {
      itemCategoryModel = Customer.fromJson(value);  
        var name1=[];
        var address1=[];
        var email1=[];
        var phone1=[];
        List<AddressDO> jtechDBCount = await AddressDB.getAllAddresses();
  
        print("><><<>><<>><VVV<>VVVVVV><<><>$jtechDBCount");
        
        
       uniqueStrings.add(itemCategoryModel);
       for(int i=0;i<jtechDBCount.length;i++){

          name1.add(jtechDBCount[i].name);
          address1.add(jtechDBCount[i].address);
          email1.add(jtechDBCount[i].email);
          phone1.add(jtechDBCount[i].phone);
         print('<><>><><name1<>><><name1><><><>$name1');
          
        }
        if(name1.contains(itemCategoryModel.name)&&address1.contains(itemCategoryModel.address)&&email1.contains(itemCategoryModel.email)){
          print("not added");
          //saveAddressToDB(name1.toString(), lastName1.toString(), email1.toString(),expertId1, );
        }else{ 
          saveAddressToDB(itemCategoryModel.name, itemCategoryModel.address,itemCategoryModel.email,itemCategoryModel.phone );
        
         // saveAddressToDB(itemCategoryModel.name, itemCategoryModel.email, itemCategoryModel.phone,itemCategoryModel.techmail, itemCategoryModel.shortcut,);
       }
        
       uniqueStrings.add(itemCategoryModel);
      
    }
    uniqueStrings.join('');
    setState(() {
        //allAddresses.clear();
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
Future importKunden() async { 
  final String path = await _getPathToDownload();
      File file3 = File("$path/customer.txt");
      var c=await file3.readAsString(); 
      List jsonResult = jsonDecode( c);
      jsonResult2=jsonResult;
      Customer ?itemCategoryModel;
      for (var value in  jsonResult) {
        itemCategoryModel = Customer.fromJson(value);
      
        var c=itemCategoryModel.name;
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
              Text("customers".tr,style: TextStyle(fontSize: 22,fontWeight: FontWeight.w600),),
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
                  child: Image.asset("assets/images/address_book.png")
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