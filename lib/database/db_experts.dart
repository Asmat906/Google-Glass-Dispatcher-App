import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
part 'db_experts.g.dart';

final String BOX_NAME = "expert";

@HiveType(typeId: 5)
class ExpertDo {
  @HiveField(0)
  String name;

  @HiveField(1)
  String email;

  @HiveField(2)
  String lastName;

  @HiveField(3)
  List expertId;

  @HiveField(4)
  String id;

  ExpertDo(this.name, this.lastName, this.email, this.expertId, this.id);
   String toJson() {
    String json = '{';
    json += '"name": "$name",\n';
    json += '"email": "$email",\n';
    json += '"lastName": "${lastName.replaceAll("\n", ",")}",\n';
    json += '"expertId": "$expertId",\n';
    json += '"id": "$id"\n';
    json += '}\n';
    return json;
  }

  static ExpertDo newAddressEntry(String name, String lastName, String email, List expertId,) {
    return ExpertDo(name, lastName, email, expertId, const Uuid().v4());
  }
}

class ExpertDB {
  static Box myBox = Hive.box("");
  static bool initialized = false;

  static initBox() async {
    if (!initialized) {
      myBox = await Hive.openBox(BOX_NAME);
      initialized = true;
    }
  }

  static Future<List<ExpertDo>> getAllAddresses() async {
    await initBox();
    List<ExpertDo> ll = myBox.values.map<ExpertDo>((e) => e).toList();
    return ll;
  }

  static saveToBox(ExpertDo address) async {
    await initBox();
    myBox.add(address);
    print("><><><><><<><>expert  database?.,,.,<>..$myBox");
  }

  static List<ExpertDo> getMatchingAddressesByName(String searchText) {
    if (searchText.length > 0) {
      initBox();
      if (myBox != null) {
        return myBox.values
            .map<ExpertDo>((e) => e)
            .where((element) => element.name.toLowerCase().contains(searchText.toLowerCase()))
            .toList();
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

  static List<ExpertDo> getMatchingAddressesByAnything(String searchText) {
    if (searchText.length > 0) {
      initBox();
      return myBox.values
          .map<ExpertDo>((e) => e)
          .where((element) =>
              element.name.toLowerCase().contains(searchText.toLowerCase()) ||
              element.lastName.toLowerCase().contains(searchText.toLowerCase()) ||
              element.email.toLowerCase().contains(searchText.toLowerCase()) //||
             // element.expertId.toLowerCase().contains(searchText.toLowerCase())
             )
          .toList();
    } else {
      return [];
    }
  }

  static ExpertDo? getMatchingAddressByID(List id) {
    initBox();
    List<ExpertDo> hits = myBox.values.map<ExpertDo>((e) => e).where((element) => element.id == id).toList();
    if (hits.isNotEmpty) {
      print("><><><<> not empty> in expert<>><...$hits");
      return hits.first;
    } else {
      return null;
    }
  }

  static delete(ExpertDo tech) {
    myBox.toMap().forEach((key, value) async {
      value as ExpertDo;
      if (value.id == tech.id) {
        await myBox.delete(key);
      }
    });
  }

  static replace(ExpertDo address) async {
    Iterable keys = myBox.keys;

    for (dynamic key in keys) {
      ExpertDo currentAddress = myBox.get(key);
      if (currentAddress.id == address.id) {
        await myBox.put(key, address);
        return;
      }
    }
  }
}