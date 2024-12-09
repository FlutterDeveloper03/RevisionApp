// ignore_for_file: non_constant_identifier_names

import 'package:revision_app/models/model.dart';

class TblDkUnit extends Model{
  final int UnitDetId;
  final String UnitDetCode;
  final int UnitId;
  final String UnitDetIdGuid;
  final String UnitIdGuid;

  TblDkUnit({
    required this.UnitDetId,
    required this.UnitDetCode,
    required this.UnitId,
    required this.UnitDetIdGuid,
    required this.UnitIdGuid,
});

  @override
  Map<String, dynamic> toMap() =>
      {
        'UnitDetId': UnitDetId,
        'UnitDetCode': UnitDetCode,
        'UnitId': UnitId,
        'UnitDetIdGuid': UnitDetIdGuid,
        'UnitIdGuid': UnitIdGuid
      };

  static TblDkUnit fromMap(Map<String, dynamic> map) =>
      TblDkUnit(
          UnitDetId: map['UnitDetId'] ?? 0,
          UnitDetCode: map['UnitDetCode'] ?? "",
          UnitId: map['UnitId'] ?? 0,
          UnitDetIdGuid: map['UnitDetIdGuid'] ?? "",
          UnitIdGuid: map['UnitIdGuid'] ?? ""
      );

  Map<String, dynamic> toJson() =>
      {
        'UnitDetId': UnitDetId,
        'UnitDetCode': UnitDetCode,
        'UnitId': UnitId,
        'UnitDetIdGuid': UnitDetIdGuid,
        'UnitIdGuid': UnitIdGuid
      };

  TblDkUnit.fromJson(Map<String, dynamic> json)
  : UnitDetId = json ['UnitDetId'] ?? 0,
  UnitDetCode = json ['UnitDetCode'] ?? "",
  UnitId = json ['UnitId'] ?? 0,
  UnitDetIdGuid = json ['UnitDetIdGuid'] ?? "",
  UnitIdGuid = json ['UnitIdGuid'] ?? "";
}