// ignore_for_file: non_constant_identifier_names

import 'package:revision_app/models/model.dart';

class TblDkInvHead extends Model{
  final int MatInvHeadId;
  final String MatInvCode;
  final DateTime? MatInvDate;
  final double MatInvTotal;
  final int MatInvTypeId;
  final String MatInvDesc;
  final int TId;
  final int SalesmanId;
  final String GroupCode;
  final int OutWhId;
  final int InWhId;
  TblDkInvHead({
    required this.MatInvHeadId,
    required this.MatInvCode,
    required this.MatInvDate,
    required this.MatInvTotal,
    required this.MatInvTypeId,
    required this.MatInvDesc,
    required this.TId,
    required this.SalesmanId,
    required this.GroupCode,
    required this.OutWhId,
    required this.InWhId
  });

  @override
  Map<String, dynamic> toMap() =>
      {
        'MatInvHeadId': MatInvHeadId,
        'MatInvCode': MatInvCode,
        'MatInvDate': MatInvDate?.millisecondsSinceEpoch,
        'MatInvTotal': MatInvTotal,
        'MatInvTypeId': MatInvTypeId,
        'MatInvDesc': MatInvDesc,
        'TId': TId,
        'SalesmanId': SalesmanId,
        'GroupCode': GroupCode,
        'OutWhId': OutWhId,
        'InWhId': InWhId
      };

  static TblDkInvHead fromMap(Map<String, dynamic> map) =>
      TblDkInvHead(
          MatInvHeadId: map['mat_inv_head_id'] ?? 0,
          MatInvCode: map['mat_inv_code'] ?? "",
          MatInvDate: DateTime.parse(map['mat_inv_date'] ?? ''),
          MatInvTotal: map['mat_inv_total'] ?? 0,
          MatInvTypeId: map['mat_inv_type_id'] ?? 0,
          MatInvDesc: map['mat_inv_desc'] ?? "",
          TId: map['T_ID'] ?? 0,
          SalesmanId: map['salesman_id'] ?? 0,
          GroupCode: map['group_code'] ?? "",
          OutWhId: map['out_wh_id'] ?? 0,
          InWhId: map['in_wh_id'] ?? 0
      );

  Map<String, dynamic> toJson() =>
      {
        'MatInvHeadId': MatInvHeadId,
        'MatInvCode': MatInvCode,
        'MatInvDate': MatInvDate?.toString(),
        'MatInvTotal': MatInvTotal,
        'MatInvTypeId': MatInvTypeId,
        'MatInvDesc': MatInvDesc,
        'TId': TId,
        'SalesmanId': SalesmanId,
        'GroupCode': GroupCode,
        'OutWhId': OutWhId,
        'InWhId': InWhId
      };

  TblDkInvHead.fromJson(Map<String, dynamic> json)
      : MatInvHeadId = json ['MatInvHeadId'] ?? 0,
        MatInvCode = json ['MatInvCode'] ?? "",
        MatInvDate = (json['MatInvDate'] != null) ? DateTime.parse(json['MatInvDate']) : null,
        MatInvTotal = json ['MatInvTotal'] ?? 0,
        MatInvTypeId = json ['MatInvTypeId'] ?? 0,
        MatInvDesc = json ['MatInvDesc'] ?? "",
        TId = json ['TId'] ?? 0,
        SalesmanId = json ['SalesmanId'] ?? 0,
        GroupCode = json['group_code'] ?? "",
        OutWhId = json['out_wh_id'] ?? 0,
        InWhId = json['in_wh_id'] ?? 0;
}