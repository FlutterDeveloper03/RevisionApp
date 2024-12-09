import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:revision_app/helpers/SharedPrefKeys.dart';
import 'package:revision_app/models/tbl_dk_warehouse.dart';
import 'package:revision_app/models/v_dk_mat_count_params.dart';
import 'package:revision_app/services/dbService.dart';
import 'package:shared_preferences/shared_preferences.dart';

// region Events
class ListDataPageEvent extends Equatable{
  @override
  List<Object> get props => [];
}

class LoadListDataEvent extends ListDataPageEvent{}
class SaveListDataEvent extends ListDataPageEvent{
  final TblDkWarehouse warehouse;
  final String warehouseCondition;
  final DateTime countDate;
  final String countingType;
  final String note1;
  final String note2;
  final String countPass;

  SaveListDataEvent(this.warehouseCondition, this.countDate, this.countingType, this.note1, this.note2, this.warehouse, this.countPass);

  @override
  List<Object> get props => [warehouseCondition, countDate, countingType, note1, note2,warehouse, countPass];
}
// endRegion Event

// region States
class ListDataPageState extends Equatable{
  @override
  List<Object> get props => [];
}

class InitialListDataState extends ListDataPageState{}
class LoadingListDataState extends ListDataPageState{}
class ListDataPageLoadedState extends ListDataPageState{
  final List<TblDkWarehouse> warehouses;

  ListDataPageLoadedState(this.warehouses);

  @override
  List<Object> get props => [warehouses];
}
class SavingListDataState extends ListDataPageState{}
class ListDataPageSavedState extends ListDataPageState{
  final VDkMatCountParams params;

  ListDataPageSavedState(this.params);

  @override
  List<Object> get props => [params];
}
class LoadErrorListDataState extends ListDataPageState{
  final String errorText;

  LoadErrorListDataState(this.errorText);

  String get getErrorText=>errorText;

  @override
  List<Object> get props => [errorText];
}

class ErrorSaveListDataState extends ListDataPageState{
  final String errorText;

  ErrorSaveListDataState(this.errorText);

  String get getErrorText=>errorText;

  @override
  List<Object> get props => [errorText];
}
// endRegion States

class ListDataPageBloc extends Bloc<ListDataPageEvent, ListDataPageState>{
  DbService? _srv;
  String host = '';
  int port = 1433;
  String dbName = '';
  String dbUName = '';
  String dbUPass = '';
  ListDataPageBloc():super(InitialListDataState()){
    on<LoadListDataEvent>(loadData);
    on<SaveListDataEvent>(saveData);
  }

  @override
  void onTransition(Transition<ListDataPageEvent, ListDataPageState> transition){
    super.onTransition(transition);
    debugPrint(transition.toString());
  }

  void loadData(LoadListDataEvent event, Emitter<ListDataPageState> emit) async {
    emit(LoadingListDataState());
    try{
      final prefs = await SharedPreferences.getInstance();
      host = prefs.getString(SharedPrefKeys.serverAddress) ?? "";
      port = prefs.getInt(SharedPrefKeys.serverPort) ?? 1433;
      dbName = prefs.getString(SharedPrefKeys.dbName) ?? "";
      dbUName = prefs.getString(SharedPrefKeys.dbUName) ?? "";
      dbUPass = prefs.getString(SharedPrefKeys.dbUPass) ?? "";
      _srv = DbService(host, port, dbName, dbUName, dbUPass);
      List<TblDkWarehouse>? warehouses = await _srv?.getWarehouses();
      if(warehouses != null) {
        emit(ListDataPageLoadedState(warehouses));
      }else{
        emit(LoadErrorListDataState("Warehouses list is empty"));
      }
    } catch (ex){
      emit(LoadErrorListDataState(ex.toString()));
    }
  }


  void saveData(SaveListDataEvent event, Emitter<ListDataPageState> emit) async {
    emit(SavingListDataState());
    try{
      final sharedPref = await SharedPreferences.getInstance();
      // TblDkWarehouse warehouse = event.warehouse;
      // DateTime countDate = event.countDate;
      // String warehouseCondition = event.warehouseCondition;
      // String countingType = event.countingType;
      // _note1 = event.note1;
      // _note2 = event.note2;
      // sharedPref.setString(SharedPrefKeys.note1, _note1);
      // sharedPref.setString(SharedPrefKeys.note2, _note2);
      // sharedPref.setString(SharedPrefKeys.countingType, countingType);
      // sharedPref.setString(SharedPrefKeys.warehouseCondition, warehouseCondition);
      // sharedPref.setString(SharedPrefKeys.warehouse, warehouse.WhName);
      sharedPref.setInt(SharedPrefKeys.warehouseId, event.warehouse.WhId);
      // sharedPref.setString(SharedPrefKeys.countedDate, DateFormat('yyyy-MM-dd HH:mm:ss').format(event.countDate));
      // sharedPref.setString(SharedPrefKeys.countPass, event.countPass);
      sharedPref.setBool(SharedPrefKeys.newCount, true);
      String userName = sharedPref.getString(SharedPrefKeys.userName) ?? '';
      String deviceName = sharedPref.getString(SharedPrefKeys.deviceName) ?? '';
      VDkMatCountParams params = VDkMatCountParams(
          WhType: event.warehouseCondition, CountDate: event.countDate, CountType: event.countingType, Note1: event.note1,
          Note2: event.note2, WhId: event.warehouse.WhId, CountPass: event.countPass, WhName: event.warehouse.WhName,
          UserName: userName, DeviceName: deviceName);
      emit(ListDataPageSavedState(params));
    } on Exception catch (e) {
      emit(ErrorSaveListDataState(e.toString()));
    }
  }
}