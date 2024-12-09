// ignore_for_file: non_constant_identifier_names

import 'model.dart';

class VDkMatCountParams extends Model {
  final String WhType;
  final DateTime? CountDate;
  final String CountType;
  final String Note1;
  final String Note2;
  final int WhId;
  final String CountPass;
  final String WhName;
  final String UserName;
  final String DeviceName;

  VDkMatCountParams({
    required this.WhType,
    required this.CountDate,
    required this.CountType,
    required this.Note1,
    required this.Note2,
    required this.WhId,
    required this.CountPass,
    required this.WhName,
    required this.UserName,
    required this.DeviceName
  });

  @override
  Map<String, dynamic> toMap() =>
      {
        'WhType': WhType,
        'CountDate': CountDate?.millisecondsSinceEpoch,
        'CountType': CountType,
        'Note1': Note1,
        'Note2': Note2,
        'WhId': WhId,
        'CountPass': CountPass,
        'WhName': WhName,
        'UserName': UserName,
        'DeviceName': DeviceName
      };

  static VDkMatCountParams fromMap(Map<String, dynamic> map) =>
      VDkMatCountParams(
          WhType: map['WhType'] ?? "",
          CountDate: DateTime.parse(map['CountDate'] ?? ''),
          CountType: map['CountType'] ?? "",
          Note1: map['Note1'] ?? "",
          Note2: map['Note2'] ?? "",
          WhId: map['WhId'] ?? 0,
          CountPass: map['CountPass'] ?? "",
          WhName: map['WhName'] ?? "",
          UserName: map['UserName'] ?? "",
          DeviceName: map['DeviceName'] ?? "",
      );


  Map<String, dynamic> toJson() =>
      {
        'WhType': WhType,
        'CountDate': CountDate?.toString(),
        'CountType': CountType,
        'Note1': Note1,
        'Note2': Note2,
        'WhId': WhId,
        'CountPass': CountPass,
        'WhName': WhName,
        'UserName': UserName,
        'DeviceName': DeviceName
      };

  VDkMatCountParams.fromJson(Map<String, dynamic> json)
      : WhType = json['WhType'] ?? "",
        CountDate = (json['CountDate'] != null) ? DateTime.parse(json['CountDate']) : null,
        CountType = json['CountType'] ?? "",
        Note1 = json['Note1'] ?? "",
        Note2 = json['Note2'] ?? "",
        WhId = json['WhId'] ?? 0,
        CountPass = json['CountPass'] ?? "",
        WhName = json['WhName'] ?? "",
        UserName = json['UserName'] ?? "",
        DeviceName = json['DeviceName'] ?? "";

  VDkMatCountParams copyWith({
    String? WhType,
    DateTime? CountDate,
    String? CountType,
    String? Note1,
    String? Note2,
    int? WhId,
    String? CountPass,
    String? WhName,
    String? UserName,
    String? DeviceName
  }) {
    return VDkMatCountParams(
        WhType: WhType ?? this.WhType,
        CountDate: CountDate ?? this.CountDate,
        CountType: CountType ?? this.CountType,
        Note1: Note1 ?? this.Note1,
        Note2: Note2 ?? this.Note2,
        WhId: WhId ?? this.WhId,
        CountPass: CountPass ?? this.CountPass,
        WhName: WhName ?? this.WhName,
        UserName: UserName ?? this.UserName,
        DeviceName: DeviceName ?? this.DeviceName
    );
  }
}