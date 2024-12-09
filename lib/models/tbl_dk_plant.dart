// ignore_for_file: non_constant_identifier_names

import 'package:revision_app/models/model.dart';

class TblDkPlant extends Model{
  final int PlantId;
  final String PlantName;
  final int CId;
  final String PlantIdGuid;

  TblDkPlant({
    required this.PlantId,
    required this.PlantName,
    required this.CId,
    required this.PlantIdGuid
  });

  @override
  Map<String, dynamic> toMap() =>
      {
        'PlantId': PlantId,
        'PlantName': PlantName,
        'CId': CId,
        'PlantIdGuid': PlantIdGuid
      };

  static TblDkPlant fromMap(Map<String, dynamic> map) =>
      TblDkPlant(
          PlantId: map['PlantId'] ?? 0,
          PlantName: map['PlantName'] ?? "",
          CId: map['CId'] ?? 0,
          PlantIdGuid: map['PlantIdGuid'] ?? ""
      );

  Map<String, dynamic> toJson() =>
      {
        'PlantId': PlantId,
        'PlantName': PlantName,
        'CId': CId,
        'PlantIdGuid': PlantIdGuid
      };

  TblDkPlant.fromJson(Map<String, dynamic> json)
      : PlantId = json ['PlantId'] ?? 0,
        PlantName = json ['PlantName'] ?? "",
        CId = json ['CId'] ?? 0,
        PlantIdGuid = json ['PlantIdGuid'] ?? "";
}