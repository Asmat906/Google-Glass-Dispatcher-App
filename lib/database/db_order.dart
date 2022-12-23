import 'package:hive/hive.dart';
import 'package:google_glass_dispatcher/database/db_experts.dart';
import 'package:intl/intl.dart';
import 'package:google_glass_dispatcher/database/db_address.dart';
import 'package:google_glass_dispatcher/database/db_technicican.dart';
import 'package:google_glass_dispatcher/search/hit.dart';
import 'package:uuid/uuid.dart';

part 'db_order.g.dart';

final String BOX_NAME = "orders";

@HiveType(typeId: 2)
class OrderDO {
  @HiveField(0)
  String  addressId;

  @HiveField(1)
  
  List <ExpertDo> addressIdExp;

  @HiveField(2)
  String todo;

  @HiveField(3)
  List<Hit> hits;

  @HiveField(4)
  int duration;

  @HiveField(5)
  String technicianId;

  @HiveField(6)
  DateTime startTime;

  @HiveField(7)
  String id;

  bool isEmptyOrder = false;

  OrderDO(this.addressId,this.addressIdExp, this.todo, this.duration, this.hits, this.technicianId, this.startTime, this.id);

  static OrderDO newOrderEntry(
      String addressId,List<ExpertDo> addressIdExp, String todo, int duration, List<Hit> hitsList, String technicianId, DateTime startTime,
      {String uid = ""}) {
    return OrderDO(addressId,addressIdExp, todo, duration, hitsList, technicianId, startTime, uid.isEmpty ? Uuid().v4() : uid);
  }

  static OrderDO getEmptyOrder(int duration, DateTime startTime, TechnicianDO technician) {
    OrderDO emptyOrder = OrderDO("", [],"", duration, [], technician.id, startTime, "");
    emptyOrder.isEmptyOrder = true;
    return emptyOrder;
  }

  String toJson() {
    String json = "{";

    json += '"id": "${id}",\n';
    json += '"todo": "${todo.replaceAll('\"', '\\"')}",\n';
    json += '"duration": "${duration}",\n';
    json += '"startTime": "${startTime.toIso8601String()}",\n';

    json += '"client": ' + AddressDB.getMatchingAddressByID(addressId)!.toJson() + ",\n";
    // json += '"hellllllllll": "${duration}",\n';
    if (hits.isNotEmpty) {
     // json += '\n"experts": [\n';
    //json +=  ExpertDB.getMatchingAddressByID(addressIdExp)!.toJson() + "\n";
    if (addressIdExp.isNotEmpty) {
      json += '\n"Expert": [\n';
      for (int i = 0; i < addressIdExp.length; i++) {
        json += addressIdExp[i].toJson();
        print("><><<><>><><></\/\/\/\/\/\/\/><><><><<>//\\\,.,.,${addressIdExp[i]}");
        if (i + 1 < addressIdExp.length) {
          json += ',';
        }
      }
      json += ']\n';
    }
    // json += ']\n';
      
    }
    else{
      json += ',\n"No Expert": [\n';
    }
    
    if (hits.isNotEmpty) {
      json += ',\n"hits": [\n';
      for (int i = 0; i < hits.length; i++) {
        json += hits[i].toJson();
        print("><><<><>><><></\/\/\/\/\/\/\/><><><><<>//\\\,.,.,${hits[i]}");
        if (i + 1 < hits.length) {
          json += ',';
        }
      }
      json += ']\n';
    }
    
      
    json += '}\n';

    return json;
  }


  String toHtmlExtern(String receiverMail) {
    AddressDO? clientAdress =AddressDB.getMatchingAddressByID(addressId);
    ExpertDo? clientAdressExp =ExpertDB.getMatchingAddressByID(addressIdExp);
    String  html= '<head><meta charset="utf-8"><title>Auftrag</title></head><body><p align="center" style="Font-Size:16px">Forschungsprojekt<br>Handwerksgeselle 4.0</p><h2>AUFTRAG</h2>======================================================<br><br>';
    html += '<table><tr><td>Von: </td><td> HWG-Dispatcher</td></tr><tr><td>An: </td><td>$receiverMail</td></tr></table>';
    html += '======================================================<br><br>';
    html +='<table><tr><td>Kunde:</td><td>${clientAdress?.name}</td></tr><tr><td>Adresse:</td><td>${clientAdress?.address.replaceAll("\n", ", ")}</td></tr><tr><td>Telefon:</td><td>${clientAdress?.phone}</td></tr></table><br><table>';

   
    if (hits.isNotEmpty) {
      html += '<tr><td>Objekt/ GTIN: </td><td></td></tr>';
      for (int i = 0; i < hits.length; i++) {
        html += '<tr><td></td><td>${hits[i].manufacturer} - ${hits[i].gtin}</td></tr>';
        html += '<tr><td></td><td>${hits[i].description}</td></tr>';
        html += '<tr><td></td><td></td></tr>';
      }
    }
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd.MM.yyyy – kk:mm').format(now);

    html += '</table><br>';
    html += '<table><tr><td>Aufgabe: </td><td>${todo.replaceAll('\"', '\\"')}</td></tr><tr><td>Dauer: </td><td>${duration} Minuten</td></tr></table><br>';
  // html +='<table><tr><td>Expert:</td><td>${clientAdressExp?.name}</td></tr><tr><td>ExpertLastName:</td><td>${clientAdressExp?.lastName.replaceAll("\n", ", ")}</td></tr><tr><td>Email:</td><td>${clientAdressExp?.email}</td></tr><tr><td>ExpertId:</td><td>${clientAdressExp?.expertId}</td></tr></table><br><table>';
    
    //<!DOCTYPE html>
    //html +='<style> table, th, td {border:1px solid black;}</style><body><h2>A basic HTML table</h2><table style="width:100%"><tr><th>Company</th><th>Contact</th><th>Country</th></tr><tr><td>Alfreds Futterkiste</td><td>Maria Anders</td><td>Germany</td></tr><tr><td>Centro comercial Moctezuma</td><td>Francisco Chang</td><td>Mexico</td></tr></table><p>To undestand the example better, we have added borders to the table.</p></body>';
    if (hits.isNotEmpty && addressIdExp.isNotEmpty) {
      html += '<tr><td><h2> Experten</h2> </td><td></td></tr>';
      //html +='<body><table border="1" style="border-top:none;border-bottom:none;border-left:none; border-right:none; border-collapse:collapse;" width="500px"><tr> <th>Name</th><th>SurName</th><th>Email</th><th>ExpertId</th></tr>';
      
      html +='<body><table border="1" style="border-top:none;border-bottom:none;border-left:none; border-right:none;" width="500px"><tr> <th>Name</th><th>SurName</th><th>Email</th><th>ExpertId</th></tr>';
      //</table></body>';
     // html +='<tr><th>ExpertName</th><th>LastName</th><th>Email</th>&nbsp;&nbsp;&nbsp;<th>ExpertId</th></tr>';
      for (int i = 0; i < addressIdExp.length; i++) {
        // html += '<tr><td></td><td>${hits[i].manufacturer} - ${hits[i].gtin}</td></tr>';
        //html+='<body><h2>Experten</h2><table style="width:100%"><tr><th>ExpertName</th>&nbsp;&nbsp;&nbsp;<th>LastName</th><th>Email</th>&nbsp;&nbsp;&nbsp;<th>ExpertId</th></tr><tr><td>${clientAdressExp?.name}</td>&nbsp;&nbsp;&nbsp;<td>${clientAdressExp?.lastName}</td><td>${clientAdressExp?.email}</td>&nbsp;&nbsp;&nbsp;<td>${clientAdressExp?.expertId}</td></tr></table></body>';
        
        html+='<tr><td class="headcol">${addressIdExp[i].name}</td><td class="long">${addressIdExp[i].lastName}</td><td class="long">${addressIdExp[i].email}</td><td class="long">${addressIdExp[i].expertId}</td></tr> ';
   
        // html += '<tr><td></td><td>${hits[i].description}</td></tr>';
        // html += '<tr><td></td><td></td></tr>';
      }
      html+='</table></div>';
    }
     html += '=====================================================';
    html += '<br>';
    html += 'Handwerkergeselle 4.0 | c/o Tillerstack GmbH | ' + formattedDate;
    html += '</body>';
    return html;
  }
}

class OrderDB {
  static Box myBox = Hive.box("");
  static bool initialized = false;

  static initBox() async {
    if (!initialized) {
      myBox = await Hive.openBox(BOX_NAME);
      initialized = true;
    }
  }

  static saveToBox(OrderDO order) {
    myBox.add(order);
  }

  static List<OrderDO> getAllOrdersForDay(DateTime dt) {
    return myBox.values.map<OrderDO>((e) => e).where((e) {
      return (e.startTime.day == dt.day && e.startTime.month == dt.month && e.startTime.year == dt.year);
    }).toList();
  }

  static List<OrderDO> filterOrdersByTechnician(List<OrderDO> orders, TechnicianDO technician) {
    List<OrderDO> returnOrders = orders.where((element) => element.technicianId == technician.id).toList();
    returnOrders.sort((a, b) => a.startTime.compareTo(b.startTime));
    return returnOrders;
  }

  static List<OrderDO> sortByTime(List<OrderDO> orders) {
    orders.sort((a, b) => a.startTime.millisecondsSinceEpoch.compareTo(b.startTime.millisecondsSinceEpoch));
    return orders;
  }

  static delete(OrderDO order) {
    myBox.toMap().forEach((key, value) async {
      value as OrderDO;
      if (value.id == order.id) {
        await myBox.delete(key);
      }
    });
  }
}
