// ignore_for_file: non_constant_identifier_names

import 'package:revision_app/models/model.dart';

class VDkInvLine extends Model{
  final int MatInvHeadId;
  final int MatId;
  final int MatInvLineId;
  final String MatName;
  final String Barcode;
  final double MatWhTotalAmount;
  final double MatCountDiff;
  final String SpeCode;
  final String SecurityCode;

  VDkInvLine({
    required this.MatInvHeadId,
    required this.MatId,
    required this.MatInvLineId,
    required this.MatName,
    required this.Barcode,
    required this.MatWhTotalAmount,
    required this.MatCountDiff,
    required this.SpeCode,
    required this.SecurityCode
  });

  @override
  Map<String, dynamic> toMap() =>
      {
        'MatInvHeadId': MatInvHeadId,
        'MatId': MatId,
        'MatInvLineId': MatInvLineId,
        'MatName': MatName,
        'Barcode': Barcode,
        'MatWhTotalAmount': MatWhTotalAmount,
        'MatCountDiff': MatCountDiff,
        'SpeCode': SpeCode,
        'SecurityCode': SecurityCode
      };

  static VDkInvLine fromMap(Map<String, dynamic> map) =>
      VDkInvLine(
        MatInvHeadId: map['MatInvHeadId'] ?? 0,
        MatId: map['MatId'] ?? 0,
        MatInvLineId: map['MatInvLineId'] ?? 0,
        MatName: map['MatName'] ?? "",
        Barcode: map['Barcode'] ?? "",
        MatWhTotalAmount: map['MatWhTotalAmount'] ?? 0,
        MatCountDiff: map['MatCountDiff'] ?? 0,
        SpeCode: map['SpeCode'] ?? "",
        SecurityCode: map['SecurityCode'] ?? ""
      );

  Map<String, dynamic> toJson() =>
      {
        'MatInvHeadId': MatInvHeadId,
        'MatId': MatId,
        'MatInvLineId': MatInvLineId,
        'MatName': MatName,
        'Barcode': Barcode,
        'MatWhTotalAmount': MatWhTotalAmount,
        'MatCountDiff': MatCountDiff,
        'SpeCode': SpeCode,
        'SecurityCode': SecurityCode
      };

  VDkInvLine.fromJson(Map<String, dynamic> json)
      :
        MatInvHeadId = json ['MatInvHeadId'] ?? 0,
        MatId = json ['MatId'] ?? 0,
        MatInvLineId = json ['MatInvLineId'] ?? 0,
        MatName = json ['MatName'] ?? "",
        Barcode = json ['Barcode'] ?? "",
        MatWhTotalAmount = json ['MatWhTotalAmount'] ?? 0,
        MatCountDiff = json ['MatCountDiff'] ?? 0,
        SpeCode = json ['SpeCode'] ?? "",
        SecurityCode = json ['SecurityCode'] ?? "";
}