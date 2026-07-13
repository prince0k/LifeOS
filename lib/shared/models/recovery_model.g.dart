// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recovery_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecoveryModelAdapter extends TypeAdapter<RecoveryModel> {
  @override
  final int typeId = 2;

  @override
  RecoveryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecoveryModel(
      date: fields[0] as String,
      sleepStartTime: fields[1] as String,
      sleepEndTime: fields[2] as String,
      nightWakeUps: fields[3] as int,
      sleepQuality: fields[4] as int,
      energyRating: fields[5] as int,
      stressRating: fields[6] as int,
      mood: fields[7] as String,
      checkedPhysicalActivities: (fields[8] as List).cast<String>(),
      checkedMentalActivities: (fields[9] as List).cast<String>(),
      computedRecoveryScore: fields[10] as double,
      computedState: fields[11] as String,
    );
  }

  @override
  void write(BinaryWriter writer, RecoveryModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.sleepStartTime)
      ..writeByte(2)
      ..write(obj.sleepEndTime)
      ..writeByte(3)
      ..write(obj.nightWakeUps)
      ..writeByte(4)
      ..write(obj.sleepQuality)
      ..writeByte(5)
      ..write(obj.energyRating)
      ..writeByte(6)
      ..write(obj.stressRating)
      ..writeByte(7)
      ..write(obj.mood)
      ..writeByte(8)
      ..write(obj.checkedPhysicalActivities)
      ..writeByte(9)
      ..write(obj.checkedMentalActivities)
      ..writeByte(10)
      ..write(obj.computedRecoveryScore)
      ..writeByte(11)
      ..write(obj.computedState);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecoveryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
