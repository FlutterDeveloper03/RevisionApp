// ignore_for_file: non_constant_identifier_names

import 'package:revision_app/models/model.dart';
import 'package:revision_app/models/v_dk_material_count.dart';

class VDkInvoice extends Model{
  final double MatInvTotal;
  final double MatDiff;
  final VDkMaterialCount MatCount;

  VDkInvoice({
    required this.MatInvTotal,
    required this.MatDiff,
    required this.MatCount
  });

  @override
  Map<String, dynamic> toMap() =>
      {
        'MatInvTotal': MatInvTotal,
        'MatDiff': MatDiff,
        'MatCount': MatCount
      };

  static VDkInvoice fromMap(Map<String, dynamic> map) =>
      VDkInvoice(
          MatInvTotal: map['MatInvTotal'] ?? 0,
          MatDiff: map['MatDiff'] ?? 0,
          MatCount: map['MatCount']
      );
}