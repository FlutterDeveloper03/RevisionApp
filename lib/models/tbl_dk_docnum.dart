// ignore_for_file: non_constant_identifier_names

import 'package:revision_app/models/model.dart';

class TblDkDocNum extends Model{
  final int DocId;
  final int DocLastNum;
  final String DocFormat;
  final String DocNum;

  TblDkDocNum({
    required this.DocId,
    required this.DocLastNum,
    required this.DocFormat,
    required this.DocNum
  });

  @override
  Map<String, dynamic> toMap() =>
      {
        'DocId': DocId,
        'DocLastNum': DocLastNum,
        'DocFormat': DocFormat,
        'DocNum': DocNum
      };

  static TblDkDocNum fromMap(Map<String, dynamic> map) =>
      TblDkDocNum(
          DocId: map['DocId'] ?? 0,
          DocLastNum: map['DocLastNum'] ?? 0,
          DocFormat: map['DocFormat'] ?? "",
          DocNum: map['DocNum'] ?? ""
      );

  Map<String, dynamic> toJson() =>
      {
        'DocId': DocId,
        'DocLastNum': DocLastNum,
        'DocFormat': DocFormat,
        'DocNum': DocNum
      };

  TblDkDocNum.fromJson(Map<String, dynamic> json)
      : DocId = json ['doc_id'] ?? 0,
        DocLastNum = json ['doc_lastnum'] ?? 0,
        DocFormat = json ['doc_format'] ?? "",
        DocNum = json ['docnum'] ?? "";
}