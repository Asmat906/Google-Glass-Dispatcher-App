// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_experties.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExpertiesDoAdapter extends TypeAdapter<ExpertiesDo> {
  @override
  final int typeId = 6;

  @override
  ExpertiesDo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExpertiesDo(
      fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ExpertiesDo obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpertiesDoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
