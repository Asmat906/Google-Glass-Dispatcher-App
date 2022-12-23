// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hit.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HitAdapter extends TypeAdapter<Hit> {
  @override
  final int typeId = 4;

  @override
  Hit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Hit(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
      fields[3] as String,
      fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Hit obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.imageUrl)
      ..writeByte(1)
      ..write(obj.imageUrl2)
      ..writeByte(2)
      ..write(obj.manufacturer)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.gtin);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
