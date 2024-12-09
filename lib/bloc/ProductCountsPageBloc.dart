// ignore_for_file: file_names

import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:revision_app/helpers/SharedPrefKeys.dart';
import 'package:revision_app/models/v_dk_mat_count_params.dart';
import 'package:revision_app/models/v_dk_material_count.dart';
import 'package:revision_app/services/dbService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductCountsPageEvent extends Equatable{

  @override
  List<Object> get props => [];
}

class LoadProductCountsEvent extends ProductCountsPageEvent{
  final VDkMatCountParams params;
  final int materialId;
  final int userId;

  LoadProductCountsEvent(this.params, this.materialId, this.userId);

  @override
  List<Object> get props => [params, materialId, userId];
}
class DeleteProductCountEvent extends ProductCountsPageEvent{
  final VDkMaterialCount matCount;

  DeleteProductCountEvent(this.matCount);

  @override
  List<Object> get props => [matCount];
}

class UpdateMatCountEvent extends ProductCountsPageEvent{
  final List<VDkMaterialCount> matCounts;
  final Map<int, double> countTotals;

  UpdateMatCountEvent(this.matCounts, this.countTotals);

  @override
  List<Object> get props => [matCounts, countTotals];
}
// endRegion Events

// region States
class ProductCountsPageState extends Equatable{

  @override
  List<Object> get props => [];
}
class InitialProductCountsPageState extends ProductCountsPageState{}
class LoadingProductCountsState extends ProductCountsPageState{}
class ProductCountsLoadedState extends ProductCountsPageState{
  final List<VDkMaterialCount> materialCounts;
  final double totalCount;
  final double totalDiff;

  ProductCountsLoadedState(this.materialCounts, this.totalCount, this.totalDiff);

  @override
  List<Object> get props => [materialCounts, totalCount, totalDiff];
}
class ProductCountsLoadErrorState extends ProductCountsPageState{
  final String errorText;

  ProductCountsLoadErrorState(this.errorText);

  @override
  List<Object> get props => [errorText];
}
class DeletingProductCountState extends ProductCountsPageState{}
class ProductCountDeletedState extends ProductCountsPageState{
  final VDkMaterialCount matCount;

  ProductCountDeletedState(this.matCount);

  @override
  List<Object> get props => [matCount];
}
class ProductCountDeleteErrorState extends ProductCountsPageState{
  final String errorText;

  ProductCountDeleteErrorState(this.errorText);

  @override
  List<Object> get props => [errorText];
}
class UpdatingMatCountState extends ProductCountsPageState{}
class UpdatedMatCountState extends ProductCountsPageState{}
class UpdateErrorMatCountState extends ProductCountsPageState{
  final String errorText;

  UpdateErrorMatCountState(this.errorText);

  @override
  List<Object> get props => [errorText];
}
// endRegion States

class ProductCountsPageBloc extends Bloc<ProductCountsPageEvent, ProductCountsPageState> {
  DbService? _srv;
  String host = '';
  int port = 1433;
  String dbName = '';
  String dbUName = '';
  String dbUPass = '';
  String deviceId = "";
  String deviceName = '';
  bool newCount = false;
  ProductCountsPageBloc() : super(InitialProductCountsPageState()) {
    on<LoadProductCountsEvent>(_loadProductCounts);
    on<DeleteProductCountEvent>(_deleteProductCount);
    on<UpdateMatCountEvent>(_updateMatCount);
  }

  void _loadProductCounts(LoadProductCountsEvent event, Emitter<ProductCountsPageState> emit) async {
    emit(LoadingProductCountsState());
    List<VDkMaterialCount>? matCounts = [];
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceId = await const AndroidId().getId() ?? '';
      deviceName = '${androidInfo.brand} ${androidInfo.device}';
      final prefs = await SharedPreferences.getInstance();
       host = prefs.getString(SharedPrefKeys.serverAddress) ?? "";
       port = prefs.getInt(SharedPrefKeys.serverPort) ?? 1433;
       dbName = prefs.getString(SharedPrefKeys.dbName) ?? "";
       dbUName = prefs.getString(SharedPrefKeys.dbUName) ?? "";
       dbUPass = prefs.getString(SharedPrefKeys.dbUPass) ?? "";
       newCount = prefs.getBool(SharedPrefKeys.newCount) ?? false;
       double totalCount = 0;
       double totalDiff = 0;
       _srv = DbService(host, port, dbName, dbUName, dbUPass);
       if(event.params.CountType=='opened'){
           matCounts = await _srv?.getProductCountsForOpened(event.params, event.materialId);
         }
       else {
           matCounts = await _srv?.getMaterialCounts(event.params, event.materialId);
       }
       if(matCounts != null ) {
         matCounts.sort((a,b) => b.MatCountDate!.compareTo(a.MatCountDate!));
         for (var item in matCounts){
           totalCount += item.MatCountTotal;
         }
         totalDiff = (totalCount-matCounts[0].MatWhTotalAmount);
         if(newCount){
           prefs.setBool(SharedPrefKeys.newCount, false);
         }
         emit (ProductCountsLoadedState(matCounts, totalCount, totalDiff));
       } else {
         emit(ProductCountsLoadErrorState("There is some problem in getting material counts!"));
       }
    } catch (e) {
      emit(ProductCountsLoadErrorState(e.toString()));
    }
  }

  void _deleteProductCount(DeleteProductCountEvent event, Emitter<ProductCountsPageState> emit) async{
    emit(DeletingProductCountState());
    try{
      final prefs = await SharedPreferences.getInstance();
       host = prefs.getString(SharedPrefKeys.serverAddress) ?? "";
       port = prefs.getInt(SharedPrefKeys.serverPort) ?? 1433;
       dbName = prefs.getString(SharedPrefKeys.dbName) ?? "";
       dbUName = prefs.getString(SharedPrefKeys.dbUName) ?? "";
       dbUPass = prefs.getString(SharedPrefKeys.dbUPass) ?? "";
      _srv = DbService(host, port, dbName, dbUName, dbUPass);
      bool? result = await _srv?.deleteSingleProductCount(event.matCount);
      bool? result2 = await _srv?.deleteSingleProductStockCount(event.matCount);
      if(result != null && result && result2!=null && result2) {
        emit (ProductCountDeletedState(event.matCount));
      }
      else {
        emit(ProductCountDeleteErrorState('Error in deleting product count!'));
      }
    } catch (e) {
      emit(ProductCountDeleteErrorState(e.toString()));
    }
  }

  void _updateMatCount(UpdateMatCountEvent event, Emitter<ProductCountsPageState> emit) async{
    bool allCountsSaved = false;
    emit(UpdatingMatCountState());
    try {
      final prefs = await SharedPreferences.getInstance();
      host = prefs.getString(SharedPrefKeys.serverAddress) ?? "";
      port = prefs.getInt(SharedPrefKeys.serverPort) ?? 1433;
      dbName = prefs.getString(SharedPrefKeys.dbName) ?? "";
      dbUName = prefs.getString(SharedPrefKeys.dbUName) ?? "";
      dbUPass = prefs.getString(SharedPrefKeys.dbUPass) ?? "";
      _srv = DbService(host, port, dbName, dbUName, dbUPass);
      if(event.countTotals.isNotEmpty) {
        for (var count in event.countTotals.keys) {
          if (event.matCounts
              .where((element) =>
          element.CountId == count &&
              element.MatCountTotal != event.countTotals[count]!)
              .isNotEmpty) {
            if (event.countTotals[count] == 0) {
              bool? result = await _srv?.deleteSingleProductCount(event.matCounts.firstWhere((element) => element.CountId == count));
              bool? result2 = await _srv?.deleteSingleProductStockCount(event.matCounts.firstWhere((element) => element.CountId == count));
              if (result != null && result && result2 != null && result2) {
                allCountsSaved = true;
              }
              else {
                allCountsSaved = false;
              }
            }
            else {
              bool? result = await _srv?.updateMaterialCount(
                  event.matCounts.firstWhere((element) =>
                  element.CountId ==
                      count), event.countTotals[count]!);
              bool? result2 = await _srv?.updateStockCount(
                  event.matCounts.firstWhere((element) =>
                  element.CountId ==
                      count), event.countTotals[count]!);
              if (result != null && result && result2 != null && result2) {
                allCountsSaved = true;
              }
              else {
                allCountsSaved = false;
              }
            }
          }
          else{
            allCountsSaved = true;
          }
        }
      }
      else{
        allCountsSaved = true;
      }
      if(allCountsSaved==true){
        emit(UpdatedMatCountState());
      }
      else{
        emit(UpdateErrorMatCountState("Failed updating material count"));
      }
    }
    catch(e){
      emit(UpdateErrorMatCountState(e.toString()));
    }
  }
}