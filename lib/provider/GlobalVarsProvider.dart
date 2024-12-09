// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:revision_app/models/tbl_dk_inv_head.dart';
import 'package:revision_app/models/tbl_dk_material.dart';
import 'package:revision_app/models/tbl_dk_user.dart';
import 'package:revision_app/models/v_dk_inv_line.dart';
import 'package:revision_app/models/v_dk_mat_count_params.dart';
import 'package:revision_app/models/v_dk_material_count.dart';
import 'package:revision_app/models/v_dk_materials.dart';

class GlobalVarsProvider with ChangeNotifier{
  TblDkUser? _user;
  TblDkUser? get getUser=>_user;
  set setUser(TblDkUser user){
    _user = user;
    notifyListeners();
  }

  List<VDkMaterialCount> _counts=[];
  List<VDkMaterialCount> get getCounts=>_counts;
  set setCounts(List<VDkMaterialCount> counts){
    _counts = counts;
    notifyListeners();
  }

  List<TblDkMaterial> _materials=[];
  List<TblDkMaterial> get getMaterials=>_materials;
  set setMaterials(List<TblDkMaterial> materials){
    _materials = materials;
    notifyListeners();
  }

  List<TblDkInvHead> _invHeads=[];
  List<TblDkInvHead> get getInvHeads=>_invHeads;
  set setInvHeads(List<TblDkInvHead> invHeads){
    _invHeads = invHeads;
    notifyListeners();
  }

  List<VDkInvLine> _invLines=[];
  List<VDkInvLine> get getInvLines=>_invLines;
  set setInvLines(List<VDkInvLine> invLines){
    _invLines = invLines;
    notifyListeners();
  }

  List<VDkMaterials> _uncountedMats=[];
  List<VDkMaterials> get getUncountedMats=>_uncountedMats;
  set setUncountedMats(List<VDkMaterials> uncountedMats){
    _uncountedMats = uncountedMats;
    notifyListeners();
  }

  List<VDkMatCountParams> _matCountParams=[];
  List<VDkMatCountParams> get getMatCountParams=>_matCountParams;
  set setMatCountParams(List<VDkMatCountParams> matCountParams){
    _matCountParams = matCountParams;
    notifyListeners();
  }

  double _totalCount = 0;
  double get getTotalCount=>_totalCount;
  set setTotalCount(double totalCount){
    _totalCount = totalCount;
    notifyListeners();
  }

  int _count = 0;
  int get getCount=>_count;
  set setCount(int count){
    _count = count;
    notifyListeners();
  }

  double _totalDiff = 0;
  double get getTotalDiff=>_totalDiff;
  set setTotalDiff(double totalDiff){
    _totalDiff = totalDiff;
    notifyListeners();
  }
}