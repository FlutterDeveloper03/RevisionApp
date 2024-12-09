// ignore_for_file: non_constant_identifier_names


import 'package:revision_app/models/model.dart';

class TblDkUser extends Model {
  //region Properties
  final int UId;
  final String UGuid;
  final int CId;
  final int DivId;
  final int RpAccId;
  final int ResPriceGroupId;
  final String URegNo;
  final String UFullName;
  final String UName;
  final String UEmail;
  final String UPass;
  final String UShortName;
  final int EmpId;
  final int UTypeId;
  final String AddInf1;
  final String AddInf2;
  final String AddInf3;
  final String AddInf4;
  final String AddInf5;
  final String AddInf6;
  final String AddInf7;
  final String AddInf8;
  final String AddInf9;
  final String AddInf10;
  final DateTime? ULastActivityDate;
  final String ULastActivityDevice;
  final DateTime? CreatedDate;
  final DateTime? ModifiedDate;
  final int CreatedUId;
  final int ModifiedUId;
  final DateTime? SyncDateTime;
  //endregion Properties

  //region Constructor
  TblDkUser({
    required this.UId,
    required this.UGuid,
    required this.CId,
    required this.DivId,
    required this.RpAccId,
    required this.ResPriceGroupId,
    required this.URegNo,
    required this.UFullName,
    required this.UName,
    required this.UEmail,
    required this.UPass,
    required this.UShortName,
    required this.EmpId,
    required this.UTypeId,
    required this.AddInf1,
    required this.AddInf2,
    required this.AddInf3,
    required this.AddInf4,
    required this.AddInf5,
    required this.AddInf6,
    required this.AddInf7,
    required this.AddInf8,
    required this.AddInf9,
    required this.AddInf10,
    required this.ULastActivityDate,
    required this.ULastActivityDevice,
    required this.CreatedDate,
    required this.ModifiedDate,
    required this.CreatedUId,
    required this.ModifiedUId,
    required this.SyncDateTime,
  });

//endregion Constructor

//region Functions
  @override
  Map<String, dynamic> toMap() => {
    "UId": UId,
    "UGuid": UGuid,
    "CId": CId,
    "DivId": DivId,
    "RpAccId": RpAccId,
    "ResPriceGroupId": ResPriceGroupId,
    "URegNo": URegNo,
    "UFullName": UFullName,
    "UName": UName,
    "UEmail": UEmail,
    "UPass": UPass,
    "UShortName": UShortName,
    "EmpId": EmpId,
    "UTypeId": UTypeId,
    "AddInf1": AddInf1,
    "AddInf2": AddInf2,
    "AddInf3": AddInf3,
    "AddInf4": AddInf4,
    "AddInf5": AddInf5,
    "AddInf6": AddInf6,
    "AddInf7": AddInf7,
    "AddInf8": AddInf8,
    "AddInf9": AddInf9,
    "AddInf10": AddInf10,
    "ULastActivityDate": ULastActivityDate?.millisecondsSinceEpoch,
    "ULastActivityDevice": ULastActivityDevice,
    "CreatedDate": CreatedDate?.millisecondsSinceEpoch,
    "ModifiedDate": ModifiedDate?.millisecondsSinceEpoch,
    "CreatedUId": CreatedUId,
    "ModifiedUId": ModifiedUId,
    "SyncDateTime": SyncDateTime?.millisecondsSinceEpoch,
  };

  static TblDkUser fromMap(Map<String, dynamic> map) => TblDkUser(
    UId: map['UId'] ?? 0,
    UGuid: map['UGuid'] ?? '',
    CId: map['CId'] ?? 0,
    DivId: map['DivId'] ?? 0,
    RpAccId: map['RpAccId'] ?? 0,
    ResPriceGroupId: map['ResPriceGroupId'] ?? 0,
    URegNo: map['URegNo'] ?? '',
    UFullName: map['UFullName'] ?? '',
    UName: map['UName'] ?? '',
    UEmail: map['UEmail'] ?? '',
    UPass: map['UPass'] ?? '',
    UShortName: map['UShortName'] ?? '',
    EmpId: map['EmpId'] ?? '',
    UTypeId: map['UTypeId'] ?? '',
    AddInf1: map['AddInf1'] ?? '',
    AddInf2: map['AddInf2'] ?? '',
    AddInf3: map['AddInf3'] ?? '',
    AddInf4: map['AddInf4'] ?? '',
    AddInf5: map['AddInf5'] ?? '',
    AddInf6: map['AddInf6'] ?? '',
    AddInf7: map['AddInf7'] ?? '',
    AddInf8: map['AddInf8'] ?? '',
    AddInf9: map['AddInf9'] ?? '',
    AddInf10: map['AddInf10'] ?? '',
    ULastActivityDate: DateTime.parse(map['ULastActivityDate'] ?? '1900-01-01'),
    ULastActivityDevice: map['ULastActivityDevice'] ?? '',
    CreatedDate: DateTime.parse(map['CreatedDate'] ?? '1900-01-01'),
    ModifiedDate: DateTime.parse(map['ModifiedDate'] ?? '1900-01-01'),
    CreatedUId: map['CreatedUId'] ?? 0,
    ModifiedUId: map['ModifiedUId'] ?? 0,
    SyncDateTime: DateTime.parse(map['SyncDateTime'] ?? '1900-01-01'),
  );

  TblDkUser.fromJson(Map<String, dynamic> json)
      : UId = json['UId'] ?? 0,
        UGuid = json['UGuid'] ?? '',
        CId = json['CId'] ?? 0,
        DivId = json['DivId'] ?? 0,
        RpAccId = json['RpAccId'] ?? 0,
        ResPriceGroupId = json['ResPriceGroupId'] ?? 0,
        URegNo = json['URegNo'] ?? '',
        UFullName = json['UFullName'] ?? '',
        UName = json['UName'] ?? '',
        UEmail = json['UEmail'] ?? '',
        UPass = json['UPass'] ?? '',
        UShortName = json['UShortName'] ?? '',
        EmpId = json['EmpId'] ?? 0,
        UTypeId = json['UTypeId'] ?? 0,
        AddInf1 = json['AddInf1'] ?? '',
        AddInf2 = json['AddInf2'] ?? '',
        AddInf3 = json['AddInf3'] ?? '',
        AddInf4 = json['AddInf4'] ?? '',
        AddInf5 = json['AddInf5'] ?? '',
        AddInf6 = json['AddInf6'] ?? '',
        AddInf7 = json['AddInf7'] ?? '',
        AddInf8 = json['AddInf8'] ?? '',
        AddInf9 = json['AddInf9'] ?? '',
        AddInf10 = json['AddInf10'] ?? '',
        ULastActivityDate = (json['ULastActivityDate'] != null) ? DateTime.parse(json['ULastActivityDate']) : null,
        ULastActivityDevice = json['ULastActivityDevice'] ?? '',
        CreatedDate = (json['CreatedDate'] != null) ? DateTime.parse(json['CreatedDate']) : null,
        ModifiedDate = (json['ModifiedDate'] != null) ? DateTime.parse(json['ModifiedDate']) : null,
        CreatedUId = json['CreatedUId'] ?? 0,
        ModifiedUId = json['ModifiedUId'] ?? 0,
        SyncDateTime = (json['SyncDateTime'] != null) ? DateTime.parse(json['SyncDateTime']) : null;

  Map<String, dynamic> toJson() => {
    'UId': UId,
    'UGuid': UGuid,
    'CId': CId,
    'DivId': DivId,
    'RpAccId': RpAccId,
    'ResPriceGroupId': ResPriceGroupId,
    'URegNo': URegNo,
    'UFullName': UFullName,
    'UName': UName,
    'UEmail': UEmail,
    'UPass': UPass,
    'UShortName': UShortName,
    'EmpId': EmpId,
    'UTypeId': UTypeId,
    'AddInf1': AddInf1,
    'AddInf2': AddInf2,
    'AddInf3': AddInf3,
    'AddInf4': AddInf4,
    'AddInf5': AddInf5,
    'AddInf6': AddInf6,
    'AddInf7': AddInf7,
    'AddInf8': AddInf8,
    'AddInf9': AddInf9,
    'AddInf10': AddInf10,
    'ULastActivityDate': ULastActivityDate?.toIso8601String(),
    'ULastActivityDevice': ULastActivityDevice,
    'CreatedDate': CreatedDate?.toIso8601String(),
    'ModifiedDate': ModifiedDate?.toIso8601String(),
    'CreatedUId': CreatedUId,
    'ModifiedUId': ModifiedUId,
    'SyncDateTime': SyncDateTime?.toIso8601String(),
  };

  TblDkUser copyWith({
    int? UId,
    String? UGuid,
    int? CId,
    int? DivId,
    int? RpAccId,
    int? ResPriceGroupId,
    String? URegNo,
    String? UFullName,
    String? UName,
    String? UEmail,
    String? UPass,
    String? UShortName,
    int? EmpId,
    int? UTypeId,
    String? AddInf1,
    String? AddInf2,
    String? AddInf3,
    String? AddInf4,
    String? AddInf5,
    String? AddInf6,
    String? AddInf7,
    String? AddInf8,
    String? AddInf9,
    String? AddInf10,
    DateTime? ULastActivityDate,
    String? ULastActivityDevice,
    DateTime? CreatedDate,
    DateTime? ModifiedDate,
    int? CreatedUId,
    int? ModifiedUId,
    DateTime? SyncDateTime,
  }) {
    return TblDkUser(
      UId: UId ?? this.UId,
      UGuid: UGuid ?? this.UGuid,
      CId: CId ?? this.CId,
      DivId: DivId ?? this.DivId,
      RpAccId: RpAccId ?? this.RpAccId,
      ResPriceGroupId: ResPriceGroupId ?? this.ResPriceGroupId,
      URegNo: URegNo ?? this.URegNo,
      UFullName: UFullName ?? this.UFullName,
      UName: UName ?? this.UName,
      UEmail: UEmail ?? this.UEmail,
      UPass: UPass ?? this.UPass,
      UShortName: UShortName ?? this.UShortName,
      EmpId: EmpId ?? this.EmpId,
      UTypeId: UTypeId ?? this.UTypeId,
      AddInf1: AddInf1 ?? this.AddInf1,
      AddInf2: AddInf2 ?? this.AddInf2,
      AddInf3: AddInf3 ?? this.AddInf3,
      AddInf4: AddInf4 ?? this.AddInf4,
      AddInf5: AddInf5 ?? this.AddInf5,
      AddInf6: AddInf6 ?? this.AddInf6,
      AddInf7: AddInf7 ?? this.AddInf7,
      AddInf8: AddInf8 ?? this.AddInf8,
      AddInf9: AddInf9 ?? this.AddInf9,
      AddInf10: AddInf10 ?? this.AddInf10,
      ULastActivityDate: ULastActivityDate ?? this.ULastActivityDate,
      ULastActivityDevice: ULastActivityDevice ?? this.ULastActivityDevice,
      CreatedDate: CreatedDate ?? this.CreatedDate,
      ModifiedDate: ModifiedDate ?? this.ModifiedDate,
      CreatedUId: CreatedUId ?? this.CreatedUId,
      ModifiedUId: ModifiedUId ?? this.ModifiedUId,
      SyncDateTime: SyncDateTime ?? this.SyncDateTime,
    );
  }

//endregion Functions
}
