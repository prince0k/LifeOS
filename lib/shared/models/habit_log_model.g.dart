// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_log_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitLogModelAdapter extends TypeAdapter<HabitLogModel> {
  @override
  final int typeId = 4;

  @override
  HabitLogModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HabitLogModel(
      date: fields[0] as String,
      smokingCount: fields[1] as int,
      detailedSmokingLogs: (fields[2] as List).cast<DetailedSmokingLogModel>(),
      totalScreenTimeMinutes: fields[3] as int,
      appScreenTimes: (fields[4] as Map).cast<String, int>(),
    );
  }

  @override
  void write(BinaryWriter writer, HabitLogModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.smokingCount)
      ..writeByte(2)
      ..write(obj.detailedSmokingLogs)
      ..writeByte(3)
      ..write(obj.totalScreenTimeMinutes)
      ..writeByte(4)
      ..write(obj.appScreenTimes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitLogModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
