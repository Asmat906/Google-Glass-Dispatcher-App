// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_address.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AddressDOAdapter extends TypeAdapter<AddressDO> {
  @override
  final int typeId = 3;

  @override
  AddressDO read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AddressDO(
      fields[0] as String,
      fields[2] as String,
      fields[1] as String,
      fields[3] as String,
      fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AddressDO obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.address)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddressDOAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
