import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'db_address.g.dart';

final String BOX_NAME = "address";

@HiveType(typeId: 3)
class AddressDO {
  @HiveField(0)
  String name;

  @HiveField(1)
  String email;

  @HiveField(2)
  String address;

  @HiveField(3)
  String phone;

  @HiveField(4)
  String id;

  AddressDO(this.name, this.address, this.email, this.phone, this.id);

  String toJson() {
    String json = '{\n';
    json += '"name": "$name",\n';
    json += '"email": "$email",\n';
    json += '"address": "${address.replaceAll("\n", ",")}",\n';
    json += '"phone": "$phone"\n';
    json += '}\n';
    return json;
  }

  static AddressDO newAddressEntry(String name, String address, String email, String phone) {
    return AddressDO(name, address, email, phone, const Uuid().v4());
  }
}

class AddressDB {
  static Box myBox = Hive.box("");
  static bool initialized = false;

  static initBox() async {
    if (!initialized) {
      myBox = await Hive.openBox(BOX_NAME);
      initialized = true;
    }
  }

  static Future<List<AddressDO>> getAllAddresses() async {
    await initBox();
    List<AddressDO> ll = myBox.values.map<AddressDO>((e) => e).toList();
    return ll;
  }

  static saveToBox(AddressDO address) async {
    await initBox();
    myBox.add(address);
    print("><><><><><<><>expert  database?.,,.,<>..$myBox");
  }

  static List<AddressDO> getMatchingAddressesByName(String searchText) {
    if (searchText.length > 0) {
      initBox();
      if (myBox != null) {
        return myBox.values
            .map<AddressDO>((e) => e)
            .where((element) => element.name.toLowerCase().contains(searchText.toLowerCase()))
            .toList();
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

  static List<AddressDO> getMatchingAddressesByAnything(String searchText) {
    if (searchText.length > 0) {
      initBox();
      return myBox.values
          .map<AddressDO>((e) => e)
          .where((element) =>
              element.name.toLowerCase().contains(searchText.toLowerCase()) ||
              element.address.toLowerCase().contains(searchText.toLowerCase()) ||
              element.email.toLowerCase().contains(searchText.toLowerCase()) ||
              element.phone.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    } else {
      return [];
    }
  }

  static AddressDO? getMatchingAddressByID(String id) {
    initBox();
    List<AddressDO> hits = myBox.values.map<AddressDO>((e) => e).where((element) => element.id == id).toList();
    if (hits.isNotEmpty) {
      print("><><><<> not empty in customer><>><...$hits");
      return hits.first;
    } else {
      return null;
    }
  }

  static delete(AddressDO tech) {
    myBox.toMap().forEach((key, value) async {
      value as AddressDO;
      if (value.id == tech.id) {
        await myBox.delete(key);
      }
    });
  }

  static replace(AddressDO address) async {
    Iterable keys = myBox.keys;

    for (dynamic key in keys) {
      AddressDO currentAddress = myBox.get(key);
      if (currentAddress.id == address.id) {
        await myBox.put(key, address);
        return;
      }
    }
  }
}
