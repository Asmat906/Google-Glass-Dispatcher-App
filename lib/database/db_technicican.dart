import 'package:collection/collection.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'db_technicican.g.dart';

final String BOX_NAME = "technician";

@HiveType(typeId: 1)
class TechnicianDO {
  @HiveField(0)
  String name;

  @HiveField(1)
  String phone;

  @HiveField(2)
  String email;

  @HiveField(3)
  String id;

  @HiveField(4)
  String techEmail;

  @HiveField(5)
  String shortcut;

  TechnicianDO(this.name, this.email, this.phone, this.id, this.techEmail, this.shortcut);
  String toJson() {
    String json = '{\n';
    json += '"name": "$name",\n';
    json += '"email": "$email",\n';
    json += '"phone": "$phone",\n';
    
    json += '}\n';
    return json;
  }
  static TechnicianDO newTechnicianEntry(
      String name, String phone, String email, String techemail, String shortcut) {
    return TechnicianDO(name, phone, email, Uuid().v4(), techemail, shortcut);
  }
}

class TechnicianDB {
  static Box myBox = Hive.box("");
  static bool initialized = false;

  static initBox() async {
    if (!initialized) {
      myBox = await Hive.openBox(BOX_NAME);
      initialized = true;
    }
  }

  static List<TechnicianDO> getAllTechnician({bool sorted = false}) {
    if (sorted) {
      List<TechnicianDO> allTechies =
          myBox.values.map<TechnicianDO>((e) => e).toList();
      allTechies.sort((a, b) => compareAsciiUpperCase(a.shortcut, b.shortcut));
      return allTechies;
    } else {
      return myBox.values.map<TechnicianDO>((e) => e).toList();
    }
  }

  static TechnicianDO getTechnicianById(String id) {
    return myBox.values
        .map<TechnicianDO>((e) => e)
        .where((element) => element.id == id)
        .first;
  }

  static Future<int> getLengthOfBox() async {
    return myBox.length;
  }

  static saveToBox(TechnicianDO tech) {
    myBox.add(tech);
  }

  static delete(TechnicianDO tech) {
    myBox.toMap().forEach((key, value) async {
      value as TechnicianDO;
      if (value.id == tech.id) {
        await myBox.delete(key);
      }
    });
  }

  static replace(TechnicianDO tech) async{
    Iterable keys = myBox.keys;

    for (dynamic key in keys) {
      TechnicianDO currentTech = myBox.get(key);
      if (currentTech.id == tech.id) {
        await myBox.put(key, tech);
        return;
      }
    }
  }

  static bool getIsTechnicianStandard (TechnicianDO tech)
  {
    if(tech.shortcut!="none")
      return false;
    else
      return true;
  }

}
