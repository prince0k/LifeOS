// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detailed_smoking_log_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DetailedSmokingLogModelAdapter
    extends TypeAdapter<DetailedSmokingLogModel> {
  @override
  final int typeId = 5;

  @override
  DetailedSmokingLogModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DetailedSmokingLogModel(
      timestamp: fields[0] as String,
      trigger: fields[1] as String,
      mood: fields[2] as String,
      notes: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DetailedSmokingLogModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.timestamp)
      ..writeByte(1)
      ..write(obj.trigger)
      ..writeByte(2)
      ..write(obj.mood)
      ..writeByte(3)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DetailedSmokingLogModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
