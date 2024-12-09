// ignore_for_file: file_names

import 'package:android_id/android_id.dart';
import 'package:bloc/bloc.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:revision_app/helpers/SharedPrefKeys.dart';
import 'package:revision_app/models/v_dk_mat_count_params.dart';
import 'package:revision_app/models/v_dk_material_count.dart';
import 'package:revision_app/models/v_dk_materials.dart';
import 'package:revision_app/services/dbService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UncountedProductsEvent extends Equatable{
  @override
  List<Object> get props => [];
}

class LoadUncountedProdsEvent extends UncountedProductsEvent{
  final List<VDkMaterialCount> matCounts;
  final int whId;
  LoadUncountedProdsEvent(this.matCounts, this.whId);

  @override
  List<Object> get props => [matCounts, whId];
}
class SetUncountedProdsToZeroEvent extends UncountedProductsEvent{
  final List<VDkMaterials> materials;
  final VDkMatCountParams params;

  SetUncountedProdsToZeroEvent(this.materials, this.params);
  @override
  List<Object> get props => [materials, params];
}
class SearchUncountedProdsEvent extends UncountedProductsEvent {
  final List<VDkMaterials> materials;
  final String searchText;

  SearchUncountedProdsEvent(this.materials, this.searchText);

  @override
  List<Object> get props => [materials, searchText];
}
// endRegion Events

class UncountedProductsState extends Equatable{
  @override
  List<Object> get props => [];
}
class InitialUncountedProdsState extends UncountedProductsState{}
class LoadingUncountedProdsState extends UncountedProductsState{}
class UncountedProdsLoadedState extends UncountedProductsState{
  final List<VDkMaterials> materials;

  UncountedProdsLoadedState(this.materials);

  @override
  List<Object> get props => [materials];
}
class UncountedProdsLoadErrorState extends UncountedProductsState{
  final String errorText;

  UncountedProdsLoadErrorState(this.errorText);

  @override
  List<Object> get props => [errorText];
}

class SettingUncountedProdsToZeroState extends UncountedProductsState{}
class UncountedProdsSetToZeroState extends UncountedProductsState{
  final List<VDkMaterials> addedMats;

  UncountedProdsSetToZeroState(this.addedMats);

  @override
  List<Object> get props => [addedMats];
}
class SetUncountedToZeroErrorState extends UncountedProductsState{
  final String errorText;

  SetUncountedToZeroErrorState(this.errorText);

  @override
  List<Object> get props => [errorText];
}

class SearchingUncountedProdsState extends UncountedProductsState {}
class SearchUncountedProdsEmptyState extends UncountedProductsState {
  final String barcode;

  SearchUncountedProdsEmptyState(this.barcode);

  @override
  List<Object> get props => [barcode];
}
class SearchingUncountedProdsCompletedState extends UncountedProductsState {
  final List<VDkMaterials> materials;
  final String searchText;

  SearchingUncountedProdsCompletedState(this.materials, this.searchText);

  @override
  List<Object> get props => [materials, searchText];
}
// endRegion States

class UncountedProductsBloc extends Bloc<UncountedProductsEvent, UncountedProductsState> {
  DbService? _srv;
  String host = '';
  int port = 1433;
  String dbName = '';
  String dbUName = '';
  String dbUPass = '';
  UncountedProductsBloc() : super(InitialUncountedProdsState()){
    on<LoadUncountedProdsEvent>(_loadUncountedProds);
    on<SetUncountedProdsToZeroEvent>(_setUncountedProdsToZero);
    on<SearchUncountedProdsEvent>(searchUncountedProds);
  }

  @override
  void onTransition(Transition<UncountedProductsEvent, UncountedProductsState> transition){
    super.onTransition(transition);
    debugPrint(transition.toString());
  }

  void _loadUncountedProds(LoadUncountedProdsEvent event, Emitter<UncountedProductsState> emit) async{
    emit(LoadingUncountedProdsState());
    List<VDkMaterials>? materials = [];
    List<VDkMaterials>? materials2 = [];
    try{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      host = prefs.getString(SharedPrefKeys.serverAddress) ?? "";
      port = prefs.getInt(SharedPrefKeys.serverPort) ?? 1433;
      dbName = prefs.getString(SharedPrefKeys.dbName) ?? "";
      dbUName = prefs.getString(SharedPrefKeys.dbUName) ?? "";
      dbUPass = prefs.getString(SharedPrefKeys.dbUPass) ?? "";
      _srv = DbService(host, port, dbName, dbUName, dbUPass);
      materials = await _srv?.getMaterials(event.whId);
      if(materials != null){
        for(var mat in materials){
          if(event.matCounts.where((element) => element.MatId==mat.MatId).isEmpty){
            materials2.add(mat);
          }
        }
        emit(UncountedProdsLoadedState(materials2));
      }
      else{
        emit(UncountedProdsLoadErrorState("Error while getting materials from tbl_mg_materials"));
      }
    }catch(e) {
      emit(UncountedProdsLoadErrorState(e.toString()));
    }
  }

  void _setUncountedProdsToZero(SetUncountedProdsToZeroEvent event, Emitter<UncountedProductsState> emit) async{
    emit(SettingUncountedProdsToZeroState());
    List<VDkMaterials> addedMats = [];
    bool allLinesSaved = true;
    try{
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      String deviceName = '${androidInfo.brand} ${androidInfo.device}';
      String deviceId = await const AndroidId().getId() ?? '';
      final prefs = await SharedPreferences.getInstance();
      int uId = prefs.getInt(SharedPrefKeys.teacherId) ?? 0;
      bool newCount = prefs.getBool(SharedPrefKeys.newCount) ?? false;
      host = prefs.getString(SharedPrefKeys.serverAddress) ?? "";
      port = prefs.getInt(SharedPrefKeys.serverPort) ?? 1433;
      dbName = prefs.getString(SharedPrefKeys.dbName) ?? "";
      dbUName = prefs.getString(SharedPrefKeys.dbUName) ?? "";
      dbUPass = prefs.getString(SharedPrefKeys.dbUPass) ?? "";
      _srv = DbService(host, port, dbName, dbUName, dbUPass);
      if(event.materials.isNotEmpty){
        for(var mat in event.materials){
          if(mat.MatWhTotalAmount != 0){
            double countDiff = 0 - mat.MatWhTotalAmount;
            bool? result = await _srv?.addMaterialForZero(mat, '$deviceId $deviceName', '', countDiff, 0, mat.UnitDetId, uId, event.params, newCount);
            if(result == null || !result){
              allLinesSaved = false;
            }
            else{
              addedMats.add(mat);
            }
          }
        }
      }
      if(allLinesSaved) {
        emit(UncountedProdsSetToZeroState(addedMats));
      }
      else{
        emit(SetUncountedToZeroErrorState("There is some problem with saving uncounted product to tbl_mg_material_count"));
      }
    }
        catch(e){
          emit(SetUncountedToZeroErrorState(e.toString()));
        }
  }

  void searchUncountedProds(SearchUncountedProdsEvent event, Emitter<UncountedProductsState> emit) async{
    emit(SearchingUncountedProdsState());
    try {
      List<String> searchTexts = event.searchText.split(" ");
      List<VDkMaterials> searchResultList = [];
      searchResultList = event.materials
          .where((element) =>
      ((element.Barcode.isNotEmpty) ? searchTexts.every((element2) => element.Barcode.toLowerCase().contains(element2.toLowerCase())) : false) ||
          ((element.MatName.isNotEmpty) ? searchTexts.every((element2) => element.MatName.toLowerCase().contains(element2.toLowerCase())) : false))
          .toList();
      if(searchResultList.isNotEmpty){
        debugPrint("Search list length: ${searchResultList.length}");
        emit(SearchingUncountedProdsCompletedState(searchResultList, event.searchText));
      }
      else{
        emit(SearchUncountedProdsEmptyState(event.searchText));
      }
    }
    catch(e){
      emit(SearchUncountedProdsEmptyState((e.toString())));
    }
  }
}