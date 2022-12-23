import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:hive/hive.dart';
import 'package:google_glass_dispatcher/database/db_experts.dart';
import 'package:google_glass_dispatcher/search/hit.dart';
final box = GetStorage();
typedef finalCallback = void Function(bool error);

class FreeTextResponse {
  int pageSize = 100;
  int page = 1;
  int hitCount = 0;
  String searchText = "";

  FreeTextResponse(this.page, this.pageSize, this.hitCount, this.searchText);
}

class RequestSearchFreeText {
  static int PAGE_SIZE = 100;

  static Future<List<Hit>> getResultList(
    String searchWords,
    int page, {
    int retries = 0,
  }) async {
    String responseString ="";
    if(searchWords.toUpperCase() == "TOTO") {
      responseString =
      "{\"pageSize\":100,\"page\":1,\"hitCount\":2,\"header\":{\"headerColumn\":[{\"columnName\":\"bild\",\"columnDescr\":\"Bild\",\"columnType\":\"MimeLink\",\"sortable\":0},{\"columnName\":\"herstellerName\",\"columnDescr\":\"Hersteller\",\"columnType\":\"Text\",\"sortable\":0},{\"columnName\":\"artikelbeschreibung\",\"columnDescr\":\"Artikelbeschreibung\",\"columnType\":\"Text\",\"sortable\":0},{\"columnName\":\"artikelnummer\",\"columnDescr\":\"Werksartikelnummer\",\"columnType\":\"Text\",\"sortable\":1},{\"columnName\":\"gtin\",\"columnDescr\":\"GTIN\",\"columnType\":\"Text\",\"sortable\":0}]},\"hits\":[{\"hitRows\":[{\"columnName\":\"PRODUCTINSTANCE_ID\",\"columnValue\":\"toto§|§TCF894CG§|§1629381268081\"},{\"columnName\":\"PRODUCT_ID\",\"columnValue\":\"toto§|§TCF894CG\"},{\"columnName\":\"SUPPLIER_ID\",\"columnValue\":\"toto\"},{\"columnName\":\"bild\",\"columnValue\":\"none\",\"columnValue2\":\"none\"},{\"columnName\":\"herstellerName\",\"columnValue\":\"TOTO Europe\"},{\"columnName\":\"artikelbeschreibung\",\"columnValue\":\"WASHLET RX EWATER+ Dusch-WC, mit Fernbedienung, EWATER+\"},{\"columnName\":\"artikelnummer\",\"columnValue\":\"TCF894CG\"},{\"columnName\":\"gtin\",\"columnValue\":\"4050663095444\"}]},{\"hitRows\":[{\"columnName\":\"PRODUCTINSTANCE_ID\",\"columnValue\":\"toto§|§TCF803CG§|§1629381268081\"},{\"columnName\":\"PRODUCT_ID\",\"columnValue\":\"toto§|§TCF803CG\"},{\"columnName\":\"SUPPLIER_ID\",\"columnValue\":\"toto\"},{\"columnName\":\"bild\",\"columnValue\":\"none\",\"columnValue2\":\"none\"},{\"columnName\":\"herstellerName\",\"columnValue\":\"TOTO Europe\"},{\"columnName\":\"artikelbeschreibung\",\"columnValue\":\"WASHLET SW Dusch-WC, mit Fernbedienung, EWATER+ und Entkalkungsfunktion\"},{\"columnName\":\"artikelnummer\",\"columnValue\":\"TCF803CG\"},{\"columnName\":\"gtin\",\"columnValue\":\"4050663095703\"}]}]}";
    }
    else if(searchWords.toUpperCase() == "KERMI") {
      responseString =
      "{\"pageSize\":100,\"page\":1,\"hitCount\":1,\"header\":{\"headerColumn\":[{\"columnName\":\"bild\",\"columnDescr\":\"Bild\",\"columnType\":\"MimeLink\",\"sortable\":0},{\"columnName\":\"herstellerName\",\"columnDescr\":\"Hersteller\",\"columnType\":\"Text\",\"sortable\":0},{\"columnName\":\"artikelbeschreibung\",\"columnDescr\":\"Artikelbeschreibung\",\"columnType\":\"Text\",\"sortable\":0},{\"columnName\":\"artikelnummer\",\"columnDescr\":\"Werksartikelnummer\",\"columnType\":\"Text\",\"sortable\":1},{\"columnName\":\"gtin\",\"columnDescr\":\"GTIN\",\"columnType\":\"Text\",\"sortable\":0}]},\"hits\":[{\"hitRows\":[{\"columnName\":\"PRODUCTINSTANCE_ID\",\"columnValue\":\"kermi_duschdesign§|§NIC2L08018VAK§|§1626276227831\"},{\"columnName\":\"PRODUCT_ID\",\"columnValue\":\"kermi_duschdesign§|§NIC2L08018VAK\"},{\"columnName\":\"SUPPLIER_ID\",\"columnValue\":\"kermi_duschdesign\"},{\"columnName\":\"bild\",\"columnValue\":\"none\",\"columnValue2\":\"none\"},{\"columnName\":\"herstellerName\",\"columnValue\":\"Kermi Duschdesign\"},{\"columnName\":\"artikelbeschreibung\",\"columnValue\":\"Kermi NICA NIC2L Eckeinstieg 2-teilig (Gleittueren bodenfrei) - Halbteil links, Hoehe 1850 mm, Wanneneinbaumaß 785-810 mm, Breitenverstellmaß 775-800 mm, Glasaußenkante 770-795 mm, Farbe Silber Hochglanz, Glas ESG Klar\"},{\"columnName\":\"artikelnummer\",\"columnValue\":\"NIC2L08018VAK\"},{\"columnName\":\"gtin\",\"columnValue\":\"4051484478669\"}]}]}";
    }
  dynamic jsonDecoded = json.decode(responseString);

    List<Hit> hits = [];

    List hitRows = jsonDecoded['hits'] as List;
    box.write('wholeResponse', hitRows);
    if(hitRows.length>0){
    hitRows.forEach((m) {
      m as Map<String, dynamic>;
      List<dynamic> l = m['hitRows'] as List<dynamic>;
      box.write('wholeResponse', l);
      print("<><><><><>><<>lllll.....$l");
       for(int i=0;i<l.length;i++){
          if(l[i]['columnName']=='herstellerName'){
           print("><<><><><><>herstellerName,,,,,,,${l[i]['columnValue']}");
           box.write('expert', '${l[i]['columnValue']}');
           print("><<><><>alllliiiiiiiiiiiiiiiii<<><>,,${box.read('expert')}");
         }
      }
      hits.add(Hit.parseFromJson(l));
    });}
    return hits;
  }
// typedef finalCallback = void Function(bool error);

// class FreeTextResponse {
//   int pageSize = 100;
//   int page = 1;
//   int hitCount = 0;
//   String searchText = "";

//   FreeTextResponse(this.page, this.pageSize, this.hitCount, this.searchText);
// }

// class RequestSearchFreeText {
//   static int PAGE_SIZE = 100;

//   static Future<List<Hit>> getResultList(
//     String searchWords,
//     int page, {
//     int retries = 0,
//   }) async {
//     String responseString = "{\"pageSize\":100,\"page\":1,\"hitCount\":1,\"header\":{\"headerColumn\":[{\"columnName\":\"bild\",\"columnDescr\":\"Bild\",\"columnType\":\"MimeLink\",\"sortable\":0},{\"columnName\":\"herstellerName\",\"columnDescr\":\"Hersteller\",\"columnType\":\"Text\",\"sortable\":0},{\"columnName\":\"artikelbeschreibung\",\"columnDescr\":\"Artikelbeschreibung\",\"columnType\":\"Text\",\"sortable\":0},{\"columnName\":\"artikelnummer\",\"columnDescr\":\"Werksartikelnummer\",\"columnType\":\"Text\",\"sortable\":1},{\"columnName\":\"gtin\",\"columnDescr\":\"GTIN\",\"columnType\":\"Text\",\"sortable\":0}]},\"hits\":[{\"hitRows\":[{\"columnName\":\"PRODUCTINSTANCE_ID\",\"columnValue\":\"toto§|§TCF894CG§|§1629381268081\"},{\"columnName\":\"PRODUCT_ID\",\"columnValue\":\"toto§|§TCF894CG\"},{\"columnName\":\"SUPPLIER_ID\",\"columnValue\":\"toto\"},{\"columnName\":\"bild\",\"columnValue\":\"none\",\"columnValue2\":\"none\"},{\"columnName\":\"herstellerName\",\"columnValue\":\"TOTO Europe\"},{\"columnName\":\"artikelbeschreibung\",\"columnValue\":\"WASHLET RX EWATER+ Dusch-WC, mit Fernbedienung, EWATER+\"},{\"columnName\":\"artikelnummer\",\"columnValue\":\"TCF894CG\"},{\"columnName\":\"gtin\",\"columnValue\":\"4050663095444\"}]}],\"filterOption\":[{\"columnName\":\"EF024845\",\"columnDescr\":\"Wassertemperatur\",\"filterType\":\"Regler\",\"sliderValues\":{\"minValue\":\"30.00\",\"maxValue\":\"40.00\"}}]}";
//     dynamic jsonDecoded = json.decode(responseString);

//     List<Hit> hits = [];

//     List hitRows = jsonDecoded['hits'] as List;
//     if(hitRows.length>0){
//     hitRows.forEach((m) {
//       m as Map<String, dynamic>;
//       List<dynamic> l = m['hitRows'] as List<dynamic>;
//        for(int i=0;i<l.length;i++){
//           if(l[i]['columnName']=='herstellerName'){
//            print("><<><><><><>trueee,,,,,,,${l[i]['columnValue']}");
//            box.write('expert', '${l[i]['columnValue']}');
//          }
//       }
//       hits.add(Hit.parseFromJson(l));
//     });}
//     return hits;
//   }
   
}
