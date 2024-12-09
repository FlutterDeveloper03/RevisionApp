// ignore_for_file: non_constant_identifier_names

import 'package:revision_app/models/model.dart';

class TblDkWarehouse extends Model{
  final int WhId;
  final String WhGuid;
  final int CId;
  final int DeptId;
  final int DivId;
  final String WhName;
  final int WhIndex;
  final int UsageStatusId;

  TblDkWarehouse({
    required this.WhId,
    required this.WhGuid,
    required this.CId,
    required this.DeptId,
    required this.DivId,
    required this.WhName,
    required this.WhIndex,
    required this.UsageStatusId
});

@override
  Map<String,dynamic> toMap()=>{
  "WhId":WhId,
  "WhGuid":WhGuid,
  "CId":CId,
  "DeptId":DeptId,
  "DivId":DivId,
  "WhName": WhName,
  "WhIndex":WhIndex,
  "UsageStatusId":UsageStatusId
};

static TblDkWarehouse fromMap(Map<String,dynamic> map)=>
     TblDkWarehouse(
       WhId:map["WhId"] ?? 0,
       WhGuid:map["WhGuid"] ?? "",
       CId:map["CId"] ?? 0,
       DeptId: map["DeptId"] ?? 0,
       DivId:map["DivId"] ?? 0,
       WhName:map["WhName"]?.toString() ?? "",
       WhIndex: map["WhIndex"] ?? 0,
       UsageStatusId: map["UsageStatusId"] ?? 0
     );
}
