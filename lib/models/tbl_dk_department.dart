// ignore_for_file: non_constant_identifier_names

import 'package:revision_app/models/model.dart';

class TblDkDepartment extends Model{
  final int DeptId;
  final String DeptName;
  final int CId;
  final String DeptIdGuid;

  TblDkDepartment({
    required this.DeptId,
    required this.DeptName,
    required this.CId,
    required this.DeptIdGuid
  });

  @override
  Map<String, dynamic> toMap() =>
      {
        'DeptId': DeptId,
        'DeptName': DeptName,
        'CId': CId,
        'DeptIdGuid': DeptIdGuid
      };

  static TblDkDepartment fromMap(Map<String, dynamic> map) =>
      TblDkDepartment(
          DeptId: map['DeptId'] ?? 0,
          DeptName: map['DeptName'] ?? "",
          CId: map['CId'] ?? 0,
          DeptIdGuid: map['DeptIdGuid'] ?? ""
      );

  Map<String, dynamic> toJson() =>
      {
        'DeptId': DeptId,
        'DeptName': DeptName,
        'CId': CId,
        'DeptIdGuid': DeptIdGuid
      };

  TblDkDepartment.fromJson(Map<String, dynamic> json)
      : DeptId = json ['DeptId'] ?? 0,
        DeptName = json ['DeptName'] ?? "",
        CId = json ['CId'] ?? 0,
        DeptIdGuid = json ['DeptIdGuid'] ?? "";
}