// ignore_for_file: unnecessary_string_interpolations

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_glass_dispatcher/database/db_address.dart';
import 'package:google_glass_dispatcher/database/db_experts.dart';
import 'package:google_glass_dispatcher/database/db_order.dart';
import 'package:google_glass_dispatcher/expers_overview.dart';
import 'package:google_glass_dispatcher/search/gtin_search.dart';
import 'package:google_glass_dispatcher/search/hit.dart';

class NewOrderForm extends StatefulWidget {
  final expertList;
  NewOrderForm({Key? key,  this.expertList}) : super(key: key);
  @override
  _NewOrderFormState createState() {
    return _NewOrderFormState();
  }
}

class _NewOrderFormState extends State<NewOrderForm> {
  List<AddressDO> addresses = [];
  List<ExpertDo> addressesExp= [];
  AddressDO? selectedAddress;
  ExpertDo? selectedExpAddress;
  String textEditingString = "";
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController mailController = TextEditingController();
  TextEditingController durationController = TextEditingController();
  TextEditingController todoController = TextEditingController();
  TextEditingController gtinController = TextEditingController();

  bool errorAddress = false,
      errorPhone = false,
      errorMail = false,
      errorTodo = false,
      errorSelectedAddress = false,
      errorDuration = false;
      var fruitMap;

  OrderDO? editOrder;

  bool fetchedDataFromRoute = false;
  var box=GetStorage();
  String textToSend = "true";

  List<int> selectTimeList = [];
  int selectedTimeDurationValue = 0;

  Map<String, Hit> selectedGtins = {};
  Map<dynamic, ExpertDo> selectedGtinsEx = {};
  Map<dynamic, ExpertDo> selectedGtinsExManual = {};
  Map<dynamic, ExpertDo> selectedGtinsExAuto = {};

  //if you are editing an old order keep the id
  String uid = "";

  _NewOrderFormState() : super() {
    for (int i = 0; i < 33; ++i) {
      this.selectTimeList.add(i * 15);
    }
    this.selectedTimeDurationValue = this.selectTimeList.first;
  }

    void refreshData() {
      refresh!=null? selectedGtinsEx.addAll(refresh):null;
          
    
    //id++;
  }
  dynamic refresh;
  FutureOr onGoBack(dynamic value) {
    refresh=box.read("collection", );
   refreshData();
    setState(() {});
  }
  @override
   void initState() {
    super.initState();
    refresh=box.read("collection", );
    
    
   
}

  void navigateSecondPage() {
    Route route = MaterialPageRoute(builder: (context) => ExpertOverview(text: textToSend,));
    Navigator.push(context, route).then(onGoBack);
  }

  @override
  Widget build(BuildContext context) {
    if (!fetchedDataFromRoute) {
      final passedArgument = ModalRoute.of(context)!.settings.arguments;

      if (passedArgument is AddressDO) {
        selectedAddress = passedArgument;
        textEditingString = passedArgument.name;
        addressController.text = passedArgument.address;
        phoneController.text = passedArgument.phone;
        mailController.text = passedArgument.email;
      } else {
        textEditingString = "";
        selectedAddress = null;
        addressController.text = "";
        phoneController.text = "";
        mailController.text = "";
      }
      if (passedArgument is OrderDO) {
        editOrder = passedArgument;
        todoController.text = editOrder!.todo;
        AddressDO? address = AddressDB.getMatchingAddressByID(editOrder!.addressId);
        textEditingString = address!.name;
        selectedAddress = address;
        addressController.text = address.address;
        phoneController.text = address.phone;
        mailController.text = address.email;
        
        selectedTimeDurationValue = editOrder!.duration;
        
        uid = passedArgument.id;
        if (editOrder!.addressIdExp.isNotEmpty) {
          
          dynamic Submitted=box.read("Submitted");
          Submitted as Map<dynamic,ExpertDo>;
          selectedGtinsEx.addAll(Submitted);//:selectedGtinsEx.addAll(refresh);
          // for (var elem in editOrder!.addressIdExp) {
          //   selectedGtinsEx[elem.id] = elem;
          // }
        }
        if (editOrder!.hits.isNotEmpty) {
          for (var elem in editOrder!.hits) {
            selectedGtins[elem.gtin] = elem;
          }
        }
      }
      fetchedDataFromRoute = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("New_Task".tr),
        centerTitle: true,
      ),
      body: Form(
        child: Center(
          child: SizedBox(
            width: 600,
            height: 800,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              scrollDirection: Axis.vertical,
              children: [
                //Name
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        margin: const EdgeInsets.only(right: 20),
                        child:  Text(
                          "Name".tr + ":",
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 8,
                      child: Container(
                        decoration: errorAddress
                            ? BoxDecoration(
                                border: Border.all(color: Colors.red, width: 2),
                                borderRadius: BorderRadius.circular(10))
                            : null,
                        child: Autocomplete<String>(
                          //initialValue: TextEditingValue(text: textEditingString),
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            addresses = AddressDB.getMatchingAddressesByName(textEditingValue.text);
                            textEditingString = textEditingValue.text;
                            if (textEditingValue.text.length > 0) {
                              //folgendes wird dann später nicht mehr benötigt da die Daten von der Datebnbank aus direkt kommen
                              return addresses.map((e) => e.name).where(
                                  (element) => element.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                            } else {
                              selectedAddress = null;
                              addressController.text = "";
                              phoneController.text = "";
                              mailController.text = "";
                              setState(() {});
                              return [];
                            }
                          },
                          onSelected: fillOutRestOfTheForm,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                

                //Address
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        margin: const EdgeInsets.only(right: 20),
                        child: Text(
                          "Address".tr + ":",
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 8,
                      child: TextField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          filled: true,
                          fillColor: Colors.black12,
                        ),
                        textInputAction: TextInputAction.newline,
                        keyboardType: TextInputType.multiline,
                        minLines: 5,
                        maxLines: 5,
                        controller: addressController,
                        readOnly: true,
                      ),
                    ),
                  ],
                ),
               const  SizedBox(height: 20),

                //Phone
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        margin: const EdgeInsets.only(right: 20),
                        child: Text(
                          "Telephone".tr + ":",
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 8,
                      child: TextField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          filled: true,
                          fillColor: Colors.black12,
                        ),
                        textInputAction: TextInputAction.newline,
                        keyboardType: TextInputType.multiline,
                        minLines: 1,
                        maxLines: 1,
                        controller: phoneController,
                        readOnly: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                //email
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        margin: const EdgeInsets.only(right: 20),
                        child: Text(
                          "Email".tr + ":",
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 8,
                      child: TextField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          filled: true,
                          fillColor: Colors.black12,
                        ),

                        textInputAction: TextInputAction.newline,
                        keyboardType: TextInputType.multiline,
                        // expands: true,
                        minLines: 1,
                        maxLines: 1,
                        controller: mailController,
                        readOnly: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                     Expanded(
                      flex: 2,
                      child: Container(
                        margin: const EdgeInsets.only(right: 20),
                        child: const Text(
                          "",
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Todo
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        margin: const EdgeInsets.only(right: 20),
                        child: Text(
                          "Task".tr +":",
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 8,
                      child: TextField(
                        controller: todoController,
                        textInputAction: TextInputAction.newline,
                        keyboardType: TextInputType.multiline,
                        // expands: true,
                        minLines: 5,
                        maxLines: 5,
                        decoration: InputDecoration(
                          errorText: errorTodo ? "fill_field" : null,
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Product
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Container(
                        margin: const EdgeInsets.only(right: 20),
                        child:  Text(
                          "Product_GTINS".tr +":",
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child:GestureDetector(
                        onTap: showGTINSearch,
                        child: Container(
                          child: const Icon(Icons.search,size: 40,),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                            boxShadow: const [
                              BoxShadow(color: Colors.green, spreadRadius: 3),
                            ],
                          ),
                          height: 50,
                        ),
                      ),
                  
                    ),
                    Expanded(
                      flex: 8,
                      child:getGtins(),
                  
                    ),
                    
                  
                  ],
                ),
                 const SizedBox(height: 20),
                // Product
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Container(
                        margin: const EdgeInsets.only(right: 20),
                        child: Text(
                          "Experten".tr + ":",
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child:GestureDetector(
                        onTap:selectedGtins.isNotEmpty?
                          navigateSecondPage:
                       null, 
                        child: Container(
                          child: const Icon(Icons.search,size: 40,),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                            boxShadow: const [
                              BoxShadow(color: Colors.green, spreadRadius: 3),
                            ],
                          ),
                          height: 50,
                        ),
                      ),
                  
                    ), 
                    Expanded(
                      flex: 8,
                     child: getGtinsExp(),
                  
                    ),
                   
                  
                  ],
                ),
                
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        margin: const EdgeInsets.only(right: 20),
                        child: Text(
                          "duration".tr,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: errorDuration
                            ? BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.red,
                                  width: 2,
                                ))
                            : null,
                        child: DropdownButton<int>(
                          value: this.selectedTimeDurationValue,
                          items: selectTimeList.map<DropdownMenuItem<int>>((int value) {
                            String text = "";
                            int minutes = value % 60;

                            if (value == 0) {
                              text = "--";
                            } else if (minutes == 0) {
                              text = "${value ~/ 60}h";
                            } else {
                              text = "${value ~/ 60}h ${minutes}m";
                            }
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text(text),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              this.selectedTimeDurationValue = value!;
                            });
                          },
                        ),
                      ),
                    ),
                    const Expanded(flex: 6, child: SizedBox(width: 100)),
                  ],
                ),

                const SizedBox(height: 50),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (doFormDataCheck()) {
                          OrderDO orderFromForm = OrderDO.newOrderEntry(

                            selectedAddress!.id,
                         this.selectedGtinsEx.values.toList(),
                            todoController.text,
                            this.selectedTimeDurationValue,
                            this.selectedGtins.values.toList(),
                            "-1",
                            DateTime.now(),
                            uid: uid,
                          );
                          OrderDB.delete(orderFromForm);
                         box.write("Submitted", selectedGtinsEx);
                          Navigator.pushNamed(context, "/technicianTime", arguments: orderFromForm);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Text(
                          "Assign_Technician".tr,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
   dynamic auto;
  void showGTINSearch() async {
    dynamic result = await showDialog(
      builder: (context) {
        
        return gtinSearch().getDialog();
      },
      context: context,
      barrierColor: Colors.blue,
      barrierDismissible: true,
    );
    
    if (result != null) {
      result as Map<String, Hit>;
      selectedGtins.addAll(result);
      dynamic q=box.read("list");
      
      q as Map<dynamic,ExpertDo>;

      selectedGtinsEx.addAll(q);
      var c =
      setState(() {});
    }
  }

  bool doFormDataCheck() {
    errorAddress = addressController.text.isEmpty;
    errorPhone = phoneController.text.isEmpty;
    errorMail = mailController.text.isEmpty;
    errorDuration = selectedTimeDurationValue == 0;
    errorTodo = todoController.text.isEmpty;
    errorSelectedAddress = selectedAddress == null;
    if (!(errorAddress || errorPhone || errorMail || errorTodo || errorSelectedAddress || errorDuration)) {
      setState(() {});
      return true;
    } else {
      setState(() {});
      return false;
    }
  }

  fillOutRestOfTheForm(String selectedElement) {
    List<AddressDO> match = addresses.where((element) => element.name == selectedElement).toList();
    if (match.length == 1) {
      selectedAddress = match.first;
      addressController.text = selectedAddress!.address;
      phoneController.text = selectedAddress!.phone;
      mailController.text = selectedAddress!.email;
    }
  }

  String formatStringLength(String text, int length) {
    if (text.length <= length) {
      return text;
    } else {
      return text.substring(0, length - 3) + "...";
    }
  }
  dynamic manual;
  
 
  Widget getGtins() {
    if (selectedGtins.isNotEmpty) {
      List<Widget> chipArr = [];
      for (var element in selectedGtins.values) {
        Chip c = Chip(
          label: Text(formatStringLength(element.description, 20)),
          deleteIcon: const Icon(Icons.close),
          deleteIconColor: Colors.black45,
          deleteButtonTooltipMessage: "delete?",
          useDeleteButtonTooltip: true,
          padding: const EdgeInsets.all(4),
          backgroundColor: Colors.green,
          onDeleted: () {
            setState(() {
              selectedGtins.remove(element.gtin);
              selectedGtinsEx.remove(element);
              selectedGtinsEx.removeWhere((key, value) => value==element);
            });
          },
          elevation: 3.0,
        );

        chipArr.add(Tooltip(
          message: element.description,
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.black12,
              )),
          textStyle: const TextStyle(fontSize: 20),
          child: c,
        ));
      }
      Row r = Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.only(right: 20),
              child: const Text(
                "",
                textAlign: TextAlign.right,
              ),
            ),
          ),
          Expanded(
            flex: 8,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: chipArr,
            ),
          ),
        ],
      );
      return r;
    } else {
      return Row();
    }
  }
   Widget getGtinsExp() {
     
    dynamic c=box.read("Selected");
    if (selectedGtinsEx.isNotEmpty&&selectedGtins.isNotEmpty) {
     List<Widget> chipArr = [];
      for (var element in selectedGtinsEx.values) {
        Chip c = Chip(
          label: Text(formatStringLength("${element.name}" +" "+"${element.lastName}", 20)),
          deleteIcon: const Icon(Icons.close),
          deleteIconColor: Colors.black45,
          deleteButtonTooltipMessage: "delete?",
          useDeleteButtonTooltip: true,
          padding: const EdgeInsets.all(4),
          backgroundColor: Colors.green,
          onDeleted: () {
            
            setState(() {
              selectedGtinsEx.removeWhere((key, value) => value==element);
            });
          },
          elevation: 3.0,
        );

        chipArr.add(Tooltip(
          message: element.name,
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.black12,
              )),
          textStyle: const TextStyle(fontSize: 20),
          child: c,
        ));
      }
      Row r = Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.only(right: 20),
              child: const Text(
                "",
                textAlign: TextAlign.right,
              ),
            ),
          ),
          Expanded(
            flex: 8,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: chipArr,
            ),
          ),
        ],
      );
      return r;
    } else {
      return Row();
    }
  }
 
}
