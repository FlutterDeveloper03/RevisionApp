// ignore_for_file: non_constant_identifier_names

import 'model.dart';

class VDkMaterials extends Model {
  final int MatId;
  final String MatName;
  final int UnitDetId;
  final int UnitId;
  final String MatCode;
  final String SpeCode;
  final String GroupCode;
  final String? SecurityCode;
  final String UnitDetCode;
  final String Barcode;
  final int WhId;
  final double MatWhTotalAmount;
  final double SalePrice;
  final double PurchasePrice;

  VDkMaterials({
    required this.MatId,
    required this.MatName,
    required this.UnitDetId,
    required this.UnitId,
    required this.MatCode,
    required this.SpeCode,
    required this.GroupCode,
    required this.SecurityCode,
    required this.UnitDetCode,
    required this.Barcode,
    required this.WhId,
    required this.MatWhTotalAmount,
    required this.SalePrice,
    required this.PurchasePrice
  });

  @override
  Map<String, dynamic> toMap() =>
      {
        'MatId': MatId,
        'MatName': MatName,
        'UnitDetId': UnitDetId,
        'UnitId': UnitId,
        'MatCode': MatCode,
        'SpeCode': SpeCode,
        'GroupCode': GroupCode,
        'SecurityCode': SecurityCode,
        'UnitDetCode': UnitDetCode,
        'Barcode': Barcode,
        'WhId': WhId,
        'MatWhTotalAmount': MatWhTotalAmount,
        'SalePrice': SalePrice,
        'PurchasePrice': PurchasePrice
      };

  static VDkMaterials fromMap(Map<String, dynamic> map) =>
      VDkMaterials(
          MatId: map['MatId'] ?? 0,
          MatName: map['MatName'] ?? "",
          UnitDetId: map['UnitDetId'] ?? 0,
          UnitId: map['UnitId'] ?? 0,
          MatCode: map['MatCode'] ?? "",
          SpeCode: map['SpeCode'] ?? "",
          GroupCode: map['GroupCode'] ?? "",
          SecurityCode: map['SecurityCode'] ?? "",
          UnitDetCode: map['UnitDetCode'] ?? "",
          Barcode: map['Barcode'] ?? "",
          WhId: map['WhId'] ?? 0,
          MatWhTotalAmount: map['MatWhTotalAmount'] ?? 0,
          SalePrice: map['SalePrice'] ?? 0,
          PurchasePrice: map['PurchasePrice'] ?? 0
      );


  Map<String, dynamic> toJson() =>
      {
        'MatId': MatId,
        'MatName': MatName,
        'UnitDetId': UnitDetId,
        'UnitId': UnitId,
        'MatCode': MatCode,
        'SpeCode': SpeCode,
        'GroupCode': GroupCode,
        'SecurityCode': SecurityCode,
        'UnitDetCode': UnitDetCode,
        'Barcode': Barcode,
        'WhId': WhId,
        'MatWhTotalAmount': MatWhTotalAmount,
        'SalePrice': SalePrice,
        'PurchasePrice': PurchasePrice,
      };

  VDkMaterials.fromJson(Map<String, dynamic> json)
      : MatId = json['MatId'] ?? 0,
        MatName = json['MatName'] ?? "",
        UnitDetId = json['UnitDetId'] ?? 0,
        UnitId = json['UnitId'] ?? 0,
        MatCode = json['MatCode'] ?? "",
        SpeCode = json['SpeCode'] ?? "",
        GroupCode = json['GroupCode'] ?? "",
        SecurityCode = json['SecurityCode'] ?? "",
        UnitDetCode = json['UnitDetCode'] ?? "",
        Barcode = json['Barcode'] ?? "",
        WhId = json['WhId'] ?? 0,
        MatWhTotalAmount = json['MatWhTotalAmount'] ?? 0,
        SalePrice = json['SalePrice'] ?? 0,
        PurchasePrice = json['PurchasePrice'] ?? 0;
}