// ignore_for_file: non_constant_identifier_names

import 'package:revision_app/models/model.dart';

class TblDkPeriod extends Model{
  final int PId;
  final DateTime? PStartDate;
  final DateTime? PEndDate;
  final int CId;
  final String PIdGuid;

  TblDkPeriod({
    required this.PId,
    required this.PStartDate,
    required this.PEndDate,
    required this.CId,
    required this.PIdGuid
});

  @override
  Map<String, dynamic> toMap() =>
      {
        'PId': PId,
        'PStartDate': PStartDate?.millisecondsSinceEpoch,
        'PEndDate': PEndDate?.millisecondsSinceEpoch,
        'CId': CId,
        'PIdGuid': PIdGuid
      };

  static TblDkPeriod fromMap(Map<String, dynamic> map) =>
      TblDkPeriod(
          PId: map['PId'] ?? 0,
          PStartDate: DateTime.parse(map['PStartDate'] ?? ''),
          PEndDate: DateTime.parse(map['PEndDate'] ?? ''),
          CId: map['CId'] ?? 0,
          PIdGuid: map['PIdGuid'] ?? ""
      );

  Map<String, dynamic> toJson() =>
      {
        'PId': PId,
        'PStartDate': PStartDate?.toString(),
        'PEndDate': PEndDate?.toString(),
        'CId': CId,
        'PIdGuid': PIdGuid
      };

  TblDkPeriod.fromJson(Map<String, dynamic> json)
      : PId = json ['PId'] ?? 0,
        PStartDate = (json['PStartDate'] != null) ? DateTime.parse(json['PStartDate']) : null,
        PEndDate = (json['PEndDate'] != null) ? DateTime.parse(json['PEndDate']) : null,
        CId = json ['CId'] ?? 0,
        PIdGuid = json ['PIdGuid'] ?? "";
}