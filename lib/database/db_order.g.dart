// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_order.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OrderDOAdapter extends TypeAdapter<OrderDO> {
  @override
  final int typeId = 2;

  @override
  OrderDO read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrderDO(
      fields[0] as String,
      (fields[1] as List).cast<ExpertDo>(),
      fields[2] as String,
      fields[4] as int,
      (fields[3] as List).cast<Hit>(),
      fields[5] as String,
      fields[6] as DateTime,
      fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, OrderDO obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.addressId)
      ..writeByte(1)
      ..write(obj.addressIdExp)
      ..writeByte(2)
      ..write(obj.todo)
      ..writeByte(3)
      ..write(obj.hits)
      ..writeByte(4)
      ..write(obj.duration)
      ..writeByte(5)
      ..write(obj.technicianId)
      ..writeByte(6)
      ..write(obj.startTime)
      ..writeByte(7)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderDOAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
