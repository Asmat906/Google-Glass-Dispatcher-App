import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'db_experties.g.dart';

final String BOX_NAME = "experties";

@HiveType(typeId: 6)
class ExpertiesDo {
  @HiveField(0)
  String name;

  // @HiveField(1)
  // String id;

  ExpertiesDo(this.name,  );

  String toJson() {
    String json = '{\n';
    json += '"name": "$name",\n';
    
    json += '}\n';
    return json;
  }

  static ExpertiesDo newExpertiesEntry(String name, ) {
    return ExpertiesDo(name, );
  }
}

class ExpertiesDB {
  static Box myBox = Hive.box("");
  static bool initialized = false;

  static initBox() async {
    if (!initialized) {
      myBox = await Hive.openBox(BOX_NAME);
      initialized = true;
    }
  }

  static Future<List<ExpertiesDo>> getAllExperties() async {
    await initBox();
    List<ExpertiesDo> ll = myBox.values.map<ExpertiesDo>((e) => e).toList();
    return ll;
  }

  static saveToBox(ExpertiesDo address) async {
    await initBox();
    myBox.add(address);
    print("><><><><><<><>expert  database?.,,.,<>..$myBox");
  }

  static List<ExpertiesDo> getMatchingExpertiesByName(String searchText) {
    if (searchText.length > 0) {
      initBox();
      if (myBox != null) {
        return myBox.values
            .map<ExpertiesDo>((e) => e)
            .where((element) => element.name.toLowerCase().contains(searchText.toLowerCase()))
            .toList();
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

  static List<ExpertiesDo> getMatchingExpertiesByAnything(String searchText) {
    if (searchText.length > 0) {
      initBox();
      return myBox.values
          .map<ExpertiesDo>((e) => e)
          .where((element) =>
              element.name.toLowerCase().contains(searchText.toLowerCase()) )
          .toList();
    } else {
      return [];
    }
  }

  static ExpertiesDo? getMatchingExpertiessByID(String name) {
    initBox();
    List<ExpertiesDo> hits = myBox.values.map<ExpertiesDo>((e) => e).where((element) => element.name == name).toList();
    if (hits.isNotEmpty) {
      print("><><><<> not empty in customer><>><...$hits");
      return hits.first;
    } else {
      return null;
    }
  }

  static delete(ExpertiesDo tech) {
    myBox.toMap().forEach((key, value) async {
      value as ExpertiesDo;
      if (value.name == tech.name) {
        await myBox.delete(key);
      }
    });
  }

  static replace(ExpertiesDo address) async {
    Iterable keys = myBox.keys;

    for (dynamic key in keys) {
      ExpertiesDo currentAddress = myBox.get(key);
      if (currentAddress.name == address.name) {
        await myBox.put(key, address);
        return;
      }
    }
  }
}
