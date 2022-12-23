import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_glass_dispatcher/database/db_experts.dart';
import 'package:google_glass_dispatcher/network/request_search_free_text.dart';
import 'package:google_glass_dispatcher/search/hit.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class gtinSearch {
  TextEditingController _searchController = TextEditingController();

  bool firstStart =true;
  Future<List<Hit>>? _hits = null;
  Future<List<ExpertDo>>? _hitsexp = null;
  bool startSearching = false;
  bool connecionError = false;
  Map<String, Hit> gtins = {};
  
  int itemsCount = 0;
  final box = GetStorage();
   List<DataRow> myDataRows = [];
   var expertValue;
   

  getAllAddressesWithSetState() async {
    List<ExpertDo> allAddresses = await ExpertDB.getAllAddresses();
   // List<ExpertDo> allAddresses = await ExpertDB.getAllAddresses();
   // setState(() {
    var expertValue=box.read('expert');
    print("><><><><><>TTTTTTTTTTTTTTTTT<>><><$expertValue");
    var whole= box.read('wholeResponse',);
     List<ExpertDo> match = allAddresses.where((element) => element.expertId.contains(expertValue)).toList();
      myDataRows = generateListDataRowsFromListAddressDO(match);
      print("<><>><><>><allAddresses<><><><><>allAddressesallAddresses<><><><.,.,.,.,.,$allAddresses>");
      print("<><>><><>><<><><><><>matchmatchmatchmatch<><><><.,.,.,.,.,$match>");
      print("<><>><><>><<><><><><>myDataRows<><><><.,.,.,.,.,$myDataRows>");
        var firstMap = {"1":"2"};
         var secondMap = {"2":"3"};

          var thirdMap = {};
          //asnathsdhhdwa

          thirdMap.addAll(firstMap);
          thirdMap.addAll(secondMap);

           print(thirdMap);
      
   // });
   final expertMap = match.asMap();
   box.write("list",expertMap );
   box.write("listlist",match );


  }
  
  var c;
   List<DataRow> generateListDataRowsFromListAddressDO(List<ExpertDo> listAddress) {
    return listAddress.map<DataRow>((e) {
      
     c =e.id;
     
      var g=box.write("idofexpert","c");
      return DataRow(cells: <DataCell>[
        
       
      
       DataCell(Text(e.name, )),
        DataCell(Text(e.lastName, )),
        DataCell(Text(e.email, )),
       DataCell(Text(e.expertId.toString(), )),
      ]);
    }).toList();
  }
  
  handleGtinClick(Hit hit) {
    if (gtins.containsKey(hit.gtin)) {
      removeGtin(hit.gtin);
    } else {
      addGtin(hit);
    }
  }

  addGtin(Hit hit) {
    gtins[hit.gtin] = hit;
  }
                           
  removeGtin(String gtin) {
    gtins.removeWhere((key, value) => key == gtin);
  }
  

  bool isSelected(String gtin) {
    if (gtin.length == 0) {
      return false;
    }
    return gtins.containsKey(gtin,);
  }

  SimpleDialog getDialog() {
    return SimpleDialog(
      title: Container(
        color: Colors.white,
        child: SizedBox(
          width: 700,
          child: Text(
            "GTIN_SEARCH".tr,
            textAlign: TextAlign.center,
          ),
        ),
      ),
      titleTextStyle: const TextStyle(
        fontSize: 30,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
      children: [
        StatefulBuilder(
          builder: (context, mySetState) {
            return Column(
              children: [
                Container(
                  padding: EdgeInsets.zero,
                  color: Colors.white,
                  child: SizedBox(
                    width: 460,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            autofocus: true,
                            onSubmitted: (value) {
                              mySetState(() {
                                _hits = handleSearchRequest();
                              });
                            },
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            mySetState(() {
                              _hits = handleSearchRequest();
                            });
                          },
                          child: Text("Search".tr),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 450,
                  width: 700,
                  child: FutureBuilder(
                    future: _hits,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) { 
                        List<Hit> hits = [];
                        hits = snapshot.data as List<Hit>;
                        startSearching = false;
                        return Column(children: [
                          returnSearchResultCount(hits.length),
                          Expanded(
                              child: ListView.separated(
                            scrollDirection: Axis.vertical,
                            itemCount: hits.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              Hit currentHit = hits.elementAt(index);
                              return InkWell(
                                borderRadius: BorderRadius.circular(10),
                                hoverColor: Colors.greenAccent,
                                onTap: () {
                                  handleGtinClick(currentHit);
                                  mySetState(() {
                                  // var expertValue=box.read('expert'); 
                                   getAllAddressesWithSetState();
                                  });
                                },
                                splashColor: Colors.red,
                                child: Container(
                                  color: gtins.containsKey(currentHit.gtin)
                                      ? Colors.blueAccent
                                      : Colors.transparent,
                                  child: Row(
                                    children: [
                                      Column(
                                        children: [
                                          FutureBuilder<Widget>(
                                            future:
                                                fetchImage(),
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData) {
                                                return snapshot.data as Widget;
                                              } else {
                                                return Icon(Icons.memory);
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SizedBox(
                                          height: 180,
                                          width: 400,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                currentHit.description,
                                                style:const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.start,
                                              ),
                                              Text(
                                                currentHit.manufacturer,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    SizedBox(height: 10),
                          ))
                        ]);
                      } else {
                        startSearching=false;
                        if (snapshot.hasData == false && connecionError == true){
                          return Text("no_connection", textAlign: TextAlign.center);
                        }
                        else if (firstStart==true) {
                          return  Text("Please_do_a_search".tr, textAlign: TextAlign.center);
                        }
                        else if(snapshot.hasData==false &&!startSearching) {
                          return  Text("no_hits_query".tr, textAlign: TextAlign.center);
                        }
                        else if (startSearching) {
                          connecionError = false;
                          return const LinearProgressIndicator();
                        } else{
                          return const Text("");
                        }
                      }
                    },
                  ),
                ),
                
                
                Column(
                  children: [
                    gtins.isNotEmpty? DataTable(
            dividerThickness: 2,
            showBottomBorder: true,
            columns: const <DataColumn>[
              
              DataColumn(
                label: Text(
                  ' ',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              DataColumn(
                label: Text(
                  ' ',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              DataColumn(
                label: Text(
                  ' ',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              DataColumn(
                label: Text(
                  ' ',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ],
            
            rows: myDataRows,
          ):Container(child: Text(""),),
        
                    SizedBox(
                      width: 700,
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("you_chosen".tr +" ${gtins.length}"+" items".tr),
                         const SizedBox(
                            width: 20,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              debugPrint("><><<><><><>?|?|?|?|?|?,,,,,,,${gtins.toString()}");
                              Navigator.pop(context, gtins);
                            },
                            child: const Text("OK"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        )
      ],
    );
  }

  Future<List<Hit>> handleSearchRequest() async {
    firstStart=false;
    _hits = null;
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.none) {
      connecionError = true;
    } else
      connecionError = false;

    startSearching = true;

    return RequestSearchFreeText.getResultList(
      _searchController.text,
      1,
    );
  }

  Future<Padding> fetchImage() async {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Image.asset("assets/images/logo.png",width:150,height: 200,),
    );
  }

  Widget returnSearchResultCount(int count) {
    if (count == 100) {
      return const SizedBox(
          height: 25,
          child:const  Text("mindestens 100 Treffer (Bitte weiter eingrenzen!)"));
    } else {
      return SizedBox(height: 25, child: Text("Treffer: $count"));
    }
  }

  Widget returnListTile(Hit currentHit, mySetState) {
    return ListTile(
      onTap: () {
        mySetState(() {
          if (isSelected(currentHit.gtin)) {
            removeGtin(currentHit.gtin);
          } else {
            addGtin(currentHit);
          }
        });
      },
      selected: isSelected(currentHit.gtin),
      selectedTileColor: Colors.blueAccent,
      contentPadding: const EdgeInsets.symmetric(vertical: 10),
      leading: FutureBuilder<Widget>(
        future: fetchImage(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return snapshot.data as Image;
          } else {
            return const Icon(Icons.memory);
          }
        },
      ),
      title: Text(
        currentHit.description,
        style:const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      subtitle: Text(
        currentHit.manufacturer,
        style: const TextStyle(color: Colors.black),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
    );
  }
}


