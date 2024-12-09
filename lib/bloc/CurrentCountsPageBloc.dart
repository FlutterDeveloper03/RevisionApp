// ignore_for_file: file_names

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:revision_app/helpers/SharedPrefKeys.dart';
import 'package:revision_app/models/tbl_dk_material_count.dart';
import 'package:revision_app/models/v_dk_mat_count_params.dart';
import 'package:revision_app/services/dbService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrentCountsEvent extends Equatable{
  @override
  List<Object> get props => [];
}
class LoadCurrentCountsEvent extends CurrentCountsEvent{}
class ConfirmPasswordEvent extends CurrentCountsEvent{
  final String countPassword;
  final VDkMatCountParams params;

  ConfirmPasswordEvent(this.countPassword, this.params);

  @override
  List<Object> get props => [countPassword, params];
}
// endRegion Events

class CurrentCountsState extends Equatable{
  @override
  List<Object> get props => [];
}
class InitialCurrentCountsState extends CurrentCountsState{}
class LoadingCurrentCountsState extends CurrentCountsState{}
class CurrentCountsLoadedState extends CurrentCountsState{
  final List<VDkMatCountParams> params;

  CurrentCountsLoadedState(this.params);

  @override
  List<Object> get props => [params];
}
class CurrentCountsLoadErrorState extends CurrentCountsState{
  final String errorText;

  CurrentCountsLoadErrorState(this.errorText);

  @override
  List<Object> get props => [errorText];
}
class ConfirmingPasswordState extends CurrentCountsState{}
class PasswordConfirmedState extends CurrentCountsState{
  final VDkMatCountParams params;
  final String countPass;

  PasswordConfirmedState(this.params, this.countPass);

  @override
  List<Object> get props => [params, countPass];
}
class ConfirmPasswordErrorState extends CurrentCountsState{
  final String errorText;

  ConfirmPasswordErrorState(this.errorText);

  @override
  List<Object> get props => [errorText];
}
// endRegion States

class CurrentCountsBloc extends Bloc<CurrentCountsEvent, CurrentCountsState>{
  DbService? _srv;
  String host = '';
  int port = 1433;
  String dbName = '';
  String dbUName = '';
  String dbUPass = '';
  String deviceId = "";
  String deviceName = '';
  CurrentCountsBloc() : super(InitialCurrentCountsState()){
    on<LoadCurrentCountsEvent>(_loadCurrentCounts);
    on<ConfirmPasswordEvent>(_confirmPassword);
  }

  void _loadCurrentCounts(LoadCurrentCountsEvent event, Emitter<CurrentCountsState> emit) async{
    emit(LoadingCurrentCountsState());
    try{
      List<TblDkMaterialCount>? materialCounts = [];
      List<VDkMatCountParams> params = [];
      final prefs = await SharedPreferences.getInstance();
      String host = prefs.getString(SharedPrefKeys.serverAddress) ?? "";
      int port = prefs.getInt(SharedPrefKeys.serverPort) ?? 1433;
      String dbName = prefs.getString(SharedPrefKeys.dbName) ?? "";
      String dbUName = prefs.getString(SharedPrefKeys.dbUName) ?? "";
      String dbUPass = prefs.getString(SharedPrefKeys.dbUPass) ?? "";
      _srv = DbService(host, port, dbName, dbUName, dbUPass);
      bool? firstResult = await _srv?.getMatCount();
      bool? secondResult = await _srv?.getStockCount();
      if (firstResult != null && firstResult && secondResult!=null && secondResult) {
         materialCounts = await _srv?.getCurrentCounts();
         if(materialCounts != null && materialCounts.isNotEmpty){
           for (var item in materialCounts){
             params.add(item.MatCountParams);
           }
         }
         emit(CurrentCountsLoadedState(params));
      }
      else{
        emit(CurrentCountsLoadErrorState("Error while getting mat_count_params column from tbl_mg_material_count or tbl_mg_stock_count"));
      }
    } catch (e) {
    emit(CurrentCountsLoadErrorState(e.toString()));
    }
  }

  void _confirmPassword(ConfirmPasswordEvent event, Emitter<CurrentCountsState> emit) async {
    emit(ConfirmingPasswordState());
    try {
      final prefs = await SharedPreferences.getInstance();
      String host = prefs.getString(SharedPrefKeys.serverAddress) ?? "";
      int port = prefs.getInt(SharedPrefKeys.serverPort) ?? 1433;
      String dbName = prefs.getString(SharedPrefKeys.dbName) ?? "";
      String dbUName = prefs.getString(SharedPrefKeys.dbUName) ?? "";
      String dbUPass = prefs.getString(SharedPrefKeys.dbUPass) ?? "";
       _srv = DbService(host, port, dbName, dbUName, dbUPass);
      bool? result = await _srv?.checkCountPassword(event.countPassword, event.params);
      if(result != null && result){
        prefs.setInt(SharedPrefKeys.warehouseId, event.params.WhId);
        emit(PasswordConfirmedState(event.params, event.countPassword));
      }
      else {
        emit(ConfirmPasswordErrorState("The given password is incorrect!"));
      }
    } catch (e) {
      emit(ConfirmPasswordErrorState(e.toString()));
    }
  }
}