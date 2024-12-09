// ignore_for_file: non_constant_identifier_names
import 'model.dart';

class TblDkMaterial extends Model {
  final int MatId;
  final String MatCode;
  final String MatName;
  final int UnitId;
  final double WhTotalAmount;
  final double SalePrice;
  final double PurchasePrice;
  final int WhId;
  final int UnitDetId;
  final String BarcodeValue;
  final String UnitDetCode;
  final String? SpeCode;
  final String? GroupCode;
  final String? SecurityCode;

  TblDkMaterial({
    required this.MatId,
    required this.MatCode,
    required this.MatName,
    required this.UnitId,
    required this.WhTotalAmount,
    required this.SalePrice,
    required this.PurchasePrice,
    required this.WhId,
    required this.UnitDetId,
    required this.BarcodeValue,
    required this.UnitDetCode,
    required this.SpeCode,
    required this.GroupCode,
    required this.SecurityCode
  });

  @override
  Map<String, dynamic> toMap() =>
      {
        'MatId': MatId,
        'MatCode': MatCode,
        'MatName': MatName,
        'UnitId': UnitId,
        'WhTotalAmount': WhTotalAmount,
        'SalePrice': SalePrice,
        'PurchasePrice': PurchasePrice,
        'WhId': WhId,
        'UnitDetId': UnitDetId,
        'BarcodeValue': BarcodeValue,
        'UnitDetCode': UnitDetCode,
        'SpeCode': SpeCode,
        'GroupCode': GroupCode,
        'SecurityCode': SecurityCode
      };

  static TblDkMaterial fromMap(Map<String, dynamic> map) =>
      TblDkMaterial(
          MatId: map['MatId'] ?? 0,
          MatCode: map['MatCode'] ?? "",
          MatName: map['MatName'] ?? "",
          UnitId: map['UnitId'] ?? 0,
          WhTotalAmount: map['WhTotalAmount'] ?? 0,
          SalePrice: map['SalePrice'] ?? 0,
          PurchasePrice: map['PurchasePrice'] ?? 0,
          WhId: map['WhId'] ?? 0,
          UnitDetId: map['UnitDetId'] ?? 0,
          BarcodeValue: map['BarcodeValue'] ?? "",
          UnitDetCode: map['UnitDetCode'] ?? "",
          SpeCode: map['SpeCode'] ?? "",
          GroupCode: map['GroupCode'] ?? "",
          SecurityCode: map['SecurityCode'] ?? ""
      );


  Map<String, dynamic> toJson() =>
      {
        'MatId': MatId,
        'MatCode': MatCode,
        'MatName': MatName,
        'UnitId': UnitId,
        'WhTotalAmount': WhTotalAmount,
        'SalePrice': SalePrice,
        'PurchasePrice': PurchasePrice,
        'WhId': WhId,
        'UnitDetId': UnitDetId,
        'BarcodeValue': BarcodeValue,
        'UnitDetCode': UnitDetCode,
        'SpeCode': SpeCode,
        'GroupCode': GroupCode,
        'SecurityCode': SecurityCode
      };

  TblDkMaterial.fromJson(Map<String, dynamic> json)
      : MatId = json['MatId'] ?? 0,
        MatCode = json['MatCode'] ?? "",
        MatName = json['MatName'] ?? "",
        UnitId = json['UnitId'] ?? 0,
        WhTotalAmount = json['WhTotalAmount'] ?? 0,
        SalePrice = json['SalePrice'] ?? 0,
        PurchasePrice = json['PurchasePrice'] ?? 0,
        WhId = json['WhId'] ?? 0,
        UnitDetId = json['UnitDetId'] ?? 0,
        BarcodeValue = json['BarcodeValue'] ?? "",
        UnitDetCode = json['UnitDetCode'] ?? "",
        SpeCode = json['SpeCode'] ?? "",
        GroupCode = json['GroupCode'] ?? "",
        SecurityCode = json['SecurityCode'] ?? "";

}
