// ignore_for_file: non_constant_identifier_names

import 'package:revision_app/models/model.dart';

class TblDkDivision extends Model{
  final int DivId;
  final String DivName;
  final int CId;
  final String DivIdGuid;

  TblDkDivision({
    required this.DivId,
    required this.DivName,
    required this.CId,
    required this.DivIdGuid
  });

  @override
  Map<String, dynamic> toMap() =>
      {
        'DivId': DivId,
        'DivName': DivName,
        'CId': CId,
        'DivIdGuid': DivIdGuid
      };

  static TblDkDivision fromMap(Map<String, dynamic> map) =>
      TblDkDivision(
          DivId: map['DivId'] ?? 0,
          DivName: map['DivName'] ?? "",
          CId: map['CId'] ?? 0,
          DivIdGuid: map['DivIdGuid'] ?? ""
      );

  Map<String, dynamic> toJson() =>
      {
        'DivId': DivId,
        'DivName': DivName,
        'CId': CId,
        'DivIdGuid': DivIdGuid
      };

  TblDkDivision.fromJson(Map<String, dynamic> json)
      : DivId = json ['DivId'] ?? 0,
        DivName = json ['DivName'] ?? "",
        CId = json ['CId'] ?? 0,
        DivIdGuid = json ['DivIdGuid'] ?? "";
}