// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShiftTemplateModelAdapter extends TypeAdapter<ShiftTemplateModel> {
  @override
  final int typeId = 7;

  @override
  ShiftTemplateModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShiftTemplateModel(
      name: fields[0] as String,
      workStart: fields[1] as String,
      workEnd: fields[2] as String,
      targetSleep: fields[3] as String,
      deepWorkTargetMinutes: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ShiftTemplateModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.workStart)
      ..writeByte(2)
      ..write(obj.workEnd)
      ..writeByte(3)
      ..write(obj.targetSleep)
      ..writeByte(4)
      ..write(obj.deepWorkTargetMinutes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShiftTemplateModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SettingsModelAdapter extends TypeAdapter<SettingsModel> {
  @override
  final int typeId = 1;

  @override
  SettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SettingsModel(
      shiftTemplates: (fields[0] as Map).cast<String, ShiftTemplateModel>(),
      recoveryWeights: (fields[1] as Map).cast<String, double>(),
      selectedAppPackages: (fields[2] as List).cast<String>(),
      unhealthyHabitCeiling: fields[3] as int,
      schemaVersion: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SettingsModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.shiftTemplates)
      ..writeByte(1)
      ..write(obj.recoveryWeights)
      ..writeByte(2)
      ..write(obj.selectedAppPackages)
      ..writeByte(3)
      ..write(obj.unhealthyHabitCeiling)
      ..writeByte(4)
      ..write(obj.schemaVersion);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
