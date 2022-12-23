// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_technicican.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TechnicianDOAdapter extends TypeAdapter<TechnicianDO> {
  @override
  final int typeId = 1;

  @override
  TechnicianDO read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TechnicianDO(
      fields[0] as String,
      fields[2] as String,
      fields[1] as String,
      fields[3] as String,
      fields[4] as String,
      fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TechnicianDO obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.phone)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.id)
      ..writeByte(4)
      ..write(obj.techEmail)
      ..writeByte(5)
      ..write(obj.shortcut);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TechnicianDOAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
