import 'package:hive/hive.dart';

part 'hit.g.dart';

@HiveType(typeId: 4)
class Hit {
  @HiveField(0)
  String imageUrl = "";
  @HiveField(1)
  String imageUrl2 = "";
  @HiveField(2)
  String manufacturer = "";
  @HiveField(3)
  String description = "";
  @HiveField(4)
  String gtin = "";

  Hit(this.imageUrl, this.imageUrl2, this.manufacturer, this.description, this.gtin);

  static Hit parseFromJson(List<dynamic> hitAsList) {
    String gtin = "";
    String imageUrl = "";
    String imageUrl2 = "";
    String manufacturer = "";
    String description = "";
    hitAsList.forEach((mapEntry) {
      mapEntry as Map<String, dynamic>;
      for (var key in mapEntry.keys.where((element) => element == "columnName")) {
        String keyValue = (mapEntry[key]);
        String value = mapEntry["columnValue"].toString();
        switch (keyValue) {
          case "gtin":
            gtin = value;
            break;
          case "herstellerName":
            manufacturer = value;
            break;
          case "bild":
            if(value.isNotEmpty) {
              imageUrl = value;
            }
            //imageUrl = mapEntry["columnValue"] == null ? "" : mapEntry["columnValue"].toString();
            imageUrl2 = mapEntry["columnValue"] == null ? "" : mapEntry["columnValue"].toString();
            break;
          case "artikelbeschreibung":
            description = value;
        }
      }
    });
    return Hit(imageUrl, imageUrl2, manufacturer, description, gtin);
  }

  String toJson() {
    String json = '{\n';
    json += '"gtin": "$gtin",\n';
    json += '"imageUrl": "$imageUrl",\n';
    json += '"imageUrl2": "$imageUrl2",\n';
    json += '"manufacturer": "$manufacturer",\n';
    json += '"description": "${description.replaceAll('\"', '\\"')}"\n';
    // json += '"description": "$description"\n';
    json += '}';
    return json;
  }
}
