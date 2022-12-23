// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_experts.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExpertDoAdapter extends TypeAdapter<ExpertDo> {
  @override
  final int typeId = 5;

  @override
  ExpertDo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExpertDo(
      fields[0] as String,
      fields[2] as String,
      fields[1] as String,
      (fields[3] as List).cast<dynamic>(),
      fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ExpertDo obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.lastName)
      ..writeByte(3)
      ..write(obj.expertId)
      ..writeByte(4)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpertDoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
