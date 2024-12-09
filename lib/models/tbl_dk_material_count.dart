// ignore_for_file: non_constant_identifier_names
import 'dart:convert';

import 'package:revision_app/models/v_dk_mat_count_params.dart';

import 'model.dart';

class TblDkMaterialCount extends Model {
  final int CountId;
  final int MatId;
  final double MatCountTotal;
  final DateTime? MatCountDate;
  final double MatCountDiff;
  final String DeviceId;
  final String MatCountDescription;
  final int WhId;
  final int UnitDetId;
  final double MatWhTotalAmount;
  final String CountIdGuid;
  final int UserId;
  final VDkMatCountParams MatCountParams;


  TblDkMaterialCount({
    required this.CountId,
    required this.MatId,
    required this.MatCountTotal,
    required this.MatCountDate,
    required this.MatCountDiff,
    required this.DeviceId,
    required this.MatCountDescription,
    required this.WhId,
    required this.UnitDetId,
    required this.MatWhTotalAmount,
    required this.CountIdGuid,
    required this.UserId,
    required this.MatCountParams
  });

  @override
  Map<String, dynamic> toMap() =>
      {
        'CountId':CountId,
        'MatId': MatId,
        'MatCountTotal': MatCountTotal,
        'MatCountDate': MatCountDate?.millisecondsSinceEpoch,
        'MatCountDiff': MatCountDiff,
        'DeviceId': DeviceId,
        'MatCountDescription': MatCountDescription,
        'WhId': WhId,
        'UnitDetId': UnitDetId,
        'MatWhTotalAmount': MatWhTotalAmount,
        'CountIdGuid': CountIdGuid,
        'UserId': UserId,
        'MatCountParams': MatCountParams.toMap()
      };

  static TblDkMaterialCount fromMap(Map<String, dynamic> map) =>
      TblDkMaterialCount(
        CountId: map['CountId'] ?? 0,
          MatId: map['MatId'] ?? 0,
          MatCountTotal: map['MatCountTotal'] ?? 0,
          MatCountDate: DateTime.parse(map['MatCountDate'] ?? ''),
          MatCountDiff: map['MatCountDiff'] ?? 0,
          DeviceId: map['DeviceId'] ?? 0,
          MatCountDescription: map['MatCountDescription'] ?? "",
          WhId: map['WhId'] ?? 0,
          UnitDetId: map['UnitDetId'] ?? 0,
          MatWhTotalAmount: map['MatWhTotalAmount'] ?? 0,
          CountIdGuid: map['CountIdGuid'] ?? "",
          UserId: map['UserId'] ?? 0,
          MatCountParams: VDkMatCountParams.fromMap(jsonDecode(map['MatCountParams'])),
      );


  Map<String, dynamic> toJson() =>
      {
        'CountId': CountId,
        'MatId': MatId,
        'MatCountTotal': MatCountTotal,
        'MatCountDate': MatCountDate?.toString(),
        'MatCountDiff': MatCountDiff,
        'DeviceId': DeviceId,
        'MatCountDescription': MatCountDescription,
        'WhId': WhId,
        'UnitDetId': UnitDetId,
        'MatWhTotalAmount': MatWhTotalAmount,
        'CountIdGuid': CountIdGuid,
        'UserId': UserId,
        'MatCountParams': MatCountParams.toJson()
      };

  TblDkMaterialCount.fromJson(Map<String, dynamic> json)
      : CountId = json['CountId'] ?? 0,
        MatId = json['MatId'] ?? 0,
        MatCountTotal = json['MatCountTotal'] ?? 0,
        MatCountDate = (json['MatCountDate'] != null) ? DateTime.parse(json['MatCountDate']) : null,
        MatCountDiff = json['MatCountDiff'] ?? 0,
        DeviceId = json ['DeviceId'] ?? 0,
        MatCountDescription = json ['MatCountDescription'] ?? "",
        WhId = json ['WhId'] ?? 0,
        UnitDetId = json ['UnitDetId'] ?? 0,
        MatWhTotalAmount = json['MatWhTotalAmount'] ?? 0,
        CountIdGuid = json ['CountIdGuid'] ?? "",
        UserId = json['UserId'] ?? 0,
        MatCountParams = VDkMatCountParams.fromJson(jsonDecode(json['MatCountParams']));
}
