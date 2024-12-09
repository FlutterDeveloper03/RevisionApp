// ignore_for_file: non_constant_identifier_names

import 'package:revision_app/models/model.dart';

class TblDkInvLine extends Model{
  final int MatInvLineId;
  final int MatId;
  final double MatInvQuantity;
  final int UnitDetId;
  final double MatInvUnitPrice;
  final double MatInvLineNet;
  final DateTime? MatInvLineDate;
  final int MatInvHeadId;

  TblDkInvLine({
    required this.MatInvLineId,
    required this.MatId,
    required this.MatInvQuantity,
    required this.UnitDetId,
    required this.MatInvUnitPrice,
    required this.MatInvLineNet,
    required this.MatInvLineDate,
    required this.MatInvHeadId
  });

  @override
  Map<String, dynamic> toMap() =>
      {
        'MatInvLineId': MatInvLineId,
        'MatId': MatId,
        'MatInvQuantity': MatInvQuantity,
        'UnitDetId': UnitDetId,
        'MatInvUnitPrice': MatInvUnitPrice,
        'MatInvLineNet': MatInvLineNet,
        'MatInvLineDate': MatInvLineDate?.millisecondsSinceEpoch,
        'MatInvHeadId': MatInvHeadId
      };

  static TblDkInvLine fromMap(Map<String, dynamic> map) =>
      TblDkInvLine(
        MatInvLineId: map['MatInvLineId'] ?? 0,
        MatId: map['MatId'] ?? 0,
        MatInvQuantity: map['MatInvQuantity'] ?? 0,
        UnitDetId: map['UnitDetId'] ?? 0,
        MatInvUnitPrice: map['MatInvUnitPrice'] ?? 0,
        MatInvLineNet: map['MatInvLineNet'] ?? 0,
        MatInvLineDate: DateTime.parse(map['MatInvLineDate'] ?? ''),
        MatInvHeadId: map['MatInvHeadId'] ?? 0,
      );

  Map<String, dynamic> toJson() =>
      {
        'MatInvLineId': MatInvLineId,
        'MatId': MatId,
        'MatInvQuantity': MatInvQuantity,
        'UnitDetId': UnitDetId,
        'MatInvUnitPrice': MatInvUnitPrice,
        'MatInvLineNet': MatInvLineNet,
        'MatInvLineDate': MatInvLineDate?.toString(),
        'MatInvHeadId': MatInvHeadId,
      };

  TblDkInvLine.fromJson(Map<String, dynamic> json)
      :
        MatInvLineId = json ['MatInvLineId'] ?? 0,
        MatId = json ['MatId'] ?? 0,
        MatInvQuantity = json ['MatInvQuantity'] ?? 0,
        UnitDetId = json ['UnitDetId'] ?? "",
        MatInvUnitPrice = json ['MatInvUnitPrice'] ?? 0,
        MatInvLineNet = json ['MatInvLineNet'] ?? 0,
        MatInvLineDate = (json['MatInvLineDate'] != null) ? DateTime.parse(json['MatInvLineDate']) : null,
        MatInvHeadId = json ['MatInvHeadId'] ?? 0;
}