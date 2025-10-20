// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settlement_payment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettlementPaymentAdapter extends TypeAdapter<SettlementPayment> {
  @override
  final int typeId = 4;

  @override
  SettlementPayment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SettlementPayment(
      id: fields[0] as String,
      fromMemberId: fields[1] as String,
      toMemberId: fields[2] as String,
      amount: fields[3] as double,
      paidAt: fields[4] as DateTime,
      note: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SettlementPayment obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fromMemberId)
      ..writeByte(2)
      ..write(obj.toMemberId)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.paidAt)
      ..writeByte(5)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettlementPaymentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
