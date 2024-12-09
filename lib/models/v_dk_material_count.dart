// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:revision_app/models/model.dart';
import 'package:revision_app/models/v_dk_mat_count_params.dart';

class VDkMaterialCount extends Model{
  final String MatName;
  final int MatId;
  final String MatCode;
  final int UnitId;
  final double SalePrice;
  final double PurchasePrice;
  final int WhId;
  final int UnitDetId;
  final String BarcodeValue;
  final String UnitDetCode;
  final String SpeCode;
  final String GroupCode;
  final String SecurityCode;
  final double MatCountTotal;
  final DateTime? MatCountDate;
  final double MatCountDiff;
  final String MatCountDescription;
  final double MatWhTotalAmount;
  final String CountIdGuid;
  final int CountId;
  final String DeviceId;
  final String UName;
  final int UserId;
  final VDkMatCountParams? MatCountParams;

  VDkMaterialCount({
    required this.MatName,
    required this.MatId,
    required this.MatCode,
    required this.UnitId,
    required this.SalePrice,
    required this.PurchasePrice,
    required this.WhId,
    required this.UnitDetId,
    required this.BarcodeValue,
    required this.UnitDetCode,
    required this.SpeCode,
    required this.GroupCode,
    required this.SecurityCode,
    required this.MatCountTotal,
    required this.MatCountDate,
    required this.MatCountDiff,
    required this.MatCountDescription,
    required this.MatWhTotalAmount,
    required this.CountIdGuid,
    required this.CountId,
    required this.DeviceId,
    required this.UName,
    required this.UserId,
    required this.MatCountParams
  });

  @override
  Map<String, dynamic> toMap() =>
      {
        'MatName': MatName,
        'MatId': MatId,
        'MatCode': MatCode,
        'UnitId': UnitId,
        'SalePrice': SalePrice,
        'PurchasePrice': PurchasePrice,
        'WhId': WhId,
        'UnitDetId': UnitDetId,
        'BarcodeValue': BarcodeValue,
        'UnitDetCode': UnitDetCode,
        'SpeCode': SpeCode,
        'GroupCode': GroupCode,
        'SecurityCode': SecurityCode,
        'MatCountTotal': MatCountTotal,
        'MatCountDate': MatCountDate?.millisecondsSinceEpoch,
        'MatCountDiff': MatCountDiff,
        'MatCountDescription': MatCountDescription,
        'MatWhTotalAmount': MatWhTotalAmount,
        'CountIdGuid': CountIdGuid,
        'CountId': CountId,
        "DeviceId": DeviceId,
        "UName": UName,
        'UserId': UserId,
        'MatCountParams': MatCountParams?.toMap()
      };

  static VDkMaterialCount fromMap(Map<String, dynamic> map) =>
      VDkMaterialCount(
        MatName: map['MatName'] ?? "",
        MatId: map['MatId'] ?? 0,
        MatCode: map['MatCode'] ?? "",
        UnitId: map['UnitId'] ?? 0,
        SalePrice: map['SalePrice'] ?? 0,
        PurchasePrice: map['PurchasePrice'] ?? 0,
        WhId: map['WhId'] ?? 0,
        UnitDetId: map['UnitDetId'] ?? 0,
        BarcodeValue: map['BarcodeValue'] ?? "",
        UnitDetCode: map['UnitDetCode'] ?? "",
        SpeCode: map['SpeCode'] ?? "",
        GroupCode: map['GroupCode'] ?? "",
        SecurityCode: map['SecurityCode'] ?? "",
        MatCountTotal: map['MatCountTotal'] ?? 0,
        MatCountDate: DateTime.parse(map['MatCountDate'] ?? ''),
        MatCountDiff: map['MatCountDiff'] ?? 0,
        MatCountDescription: map['MatCountDescription'] ?? "",
        MatWhTotalAmount: map['MatWhTotalAmount'] ?? 0,
        CountIdGuid: map['CountIdGuid'] ?? "",
        CountId: map['CountId'] ?? 0,
        DeviceId: map['DeviceId'] ?? "",
        UName: map['UName'] ?? "",
        UserId: map['UserId'] ?? 0,
        MatCountParams: map['MatCountParams'] != null ? VDkMatCountParams.fromMap(jsonDecode(map['MatCountParams'])) : null,
      );


  Map<String, dynamic> toJson() =>
      {
        'MatName': MatName,
        'MatId': MatId,
        'MatCode': MatCode,
        'UnitId': UnitId,
        'SalePrice': SalePrice,
        'PurchasePrice': PurchasePrice,
        'WhId': WhId,
        'UnitDetId': UnitDetId,
        'BarcodeValue': BarcodeValue,
        'UnitDetCode': UnitDetCode,
        'SpeCode': SpeCode,
        'GroupCode': GroupCode,
        'SecurityCode': SecurityCode,
        'MatCountTotal': MatCountTotal,
        'MatCountDate': MatCountDate?.toString(),
        'MatCountDiff': MatCountDiff,
        'MatCountDescription': MatCountDescription,
        'MatWhTotalAmount': MatWhTotalAmount,
        'CountIdGuid': CountIdGuid,
        'CountId': CountId,
        'DeviceId': DeviceId,
        'UName': UName,
        'UserId': UserId,
        'MatCountParams': MatCountParams?.toJson()
      };

  VDkMaterialCount.fromJson(Map<String, dynamic> json)
      : MatName = json['MatName'] ?? "",
        MatId = json['MatId'] ?? 0,
        MatCode = json['MatCode'] ?? "",
        UnitId = json['UnitId'] ?? 0,
        SalePrice = json['SalePrice'] ?? 0,
        PurchasePrice = json['PurchasePrice'] ?? 0,
        WhId = json['WhId'] ?? 0,
        UnitDetId = json['UnitDetId'] ?? 0,
        BarcodeValue = json['BarcodeValue'] ?? "",
        UnitDetCode = json['UnitDetCode'] ?? "",
        SpeCode = json['SpeCode'] ?? "",
        GroupCode = json['GroupCode'] ?? "",
        SecurityCode = json['SecurityCode'] ?? "",
        MatCountTotal = json['MatCountTotal'] ?? 0,
        MatCountDate = (json['MatCountDate'] != null) ? DateTime.parse(json['MatCountDate']) : null,
        MatCountDiff = json['MatCountDiff'] ?? 0,
        MatCountDescription = json ['MatCountDescription'] ?? "",
        MatWhTotalAmount = json['MatWhTotalAmount'] ?? 0,
        CountIdGuid = json ['CountIdGuid'] ?? "",
        CountId = json['CountId'] ?? 0,
        DeviceId = json['DeviceId'] ?? "",
        UName = json['UName'] ?? "",
        UserId = json['UserId'] ?? 0,
        MatCountParams = json['MatCountParams'] != null ? VDkMatCountParams.fromJson(jsonDecode(json['MatCountParams'])) : null;

  VDkMaterialCount copyWith({
    String? MatName,
    int? MatId,
    String? MatCode,
    int? UnitId,
    double? SalePrice,
    double? PurchasePrice,
    int? WhId,
    int? UnitDetId,
    String? BarcodeValue,
    String? UnitDetCode,
    String? SpeCode,
    String? GroupCode,
    String? SecurityCode,
    double? MatCountTotal,
    DateTime? MatCountDate,
    double? MatCountDiff,
    String? MatCountDescription,
    double? MatWhTotalAmount,
    String? CountIdGuid,
    int? CountId,
    String? DeviceId,
    String? UName,
    int? UserId,
    VDkMatCountParams? MatCountParams
}) {
    return VDkMaterialCount(
      MatName: MatName ?? this.MatName,
      MatId: MatId ?? this.MatId,
      MatCode: MatCode ?? this.MatCode,
      UnitId: UnitId ?? this.UnitId,
      SalePrice: SalePrice ?? this.SalePrice,
      PurchasePrice: PurchasePrice ?? this.PurchasePrice,
      WhId: WhId ?? this.WhId,
      UnitDetId: UnitDetId ?? this.UnitDetId,
      BarcodeValue: BarcodeValue ?? this.BarcodeValue,
      UnitDetCode: UnitDetCode ?? this.UnitDetCode,
      SpeCode: SpeCode ?? this.SpeCode,
      GroupCode: GroupCode ?? this.GroupCode,
      SecurityCode: SecurityCode ?? this.SecurityCode,
      MatCountTotal: MatCountTotal ?? this.MatCountTotal,
      MatCountDate: MatCountDate ?? this.MatCountDate,
      MatCountDiff: MatCountDiff ?? this.MatCountDiff,
      MatCountDescription: MatCountDescription ?? this.MatCountDescription,
      MatWhTotalAmount: MatWhTotalAmount ?? this.MatWhTotalAmount,
      CountIdGuid: CountIdGuid ?? this.CountIdGuid,
      CountId: CountId ?? this.CountId,
      DeviceId: DeviceId ?? this.DeviceId,
      UName: UName ?? this.UName,
      UserId: UserId ?? this.UserId,
      MatCountParams: MatCountParams ?? this.MatCountParams
    );
  }
}