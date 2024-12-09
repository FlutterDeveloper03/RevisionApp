// ignore_for_file: file_names

import 'package:android_id/android_id.dart';
import 'package:bloc/bloc.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:revision_app/helpers/IsolateHelper.dart';
import 'package:revision_app/helpers/SharedPrefKeys.dart';
import 'package:revision_app/models/tbl_dk_inv_head.dart';
import 'package:revision_app/services/dbService.dart';
import 'package:shared_preferences/shared_preferences.dart';

// region Events
class CountedPageBlocEvent extends Equatable{

  @override
  List<Object> get props => [];
}

class LoadInvHeadsEvent extends CountedPageBlocEvent{}

class LoadInvHeadsWithDateEvent extends CountedPageBlocEvent{

  final DateTime startDate;
  final DateTime endDate;

  LoadInvHeadsWithDateEvent(this.startDate, this.endDate);

  @override
  List<Object> get props => [startDate, endDate];
}
class DeleteProductsEvent extends CountedPageBlocEvent{
  final TblDkInvHead invHead;

  DeleteProductsEvent(this.invHead);
  @override
  List<Object> get props => [invHead];
}

class SearchInvHeadsEvent extends CountedPageBlocEvent {
  final List<TblDkInvHead> invHeads;
  final String searchText;

  SearchInvHeadsEvent(this.invHeads, this.searchText);

  @override
  List<Object> get props => [invHeads, searchText];
}
// endRegion Events

// region States
class CountedPageBlocState extends Equatable{

  @override
  List<Object> get props => [];
}
class InitialCountedPageState extends CountedPageBlocState{}
class LoadedInvHeadsState extends CountedPageBlocState{
  final List<TblDkInvHead> invHeads;

  LoadedInvHeadsState(this.invHeads);

  @override
  List<Object> get props => [invHeads];
}
class LoadingInvHeadsState extends CountedPageBlocState{}
class LoadErrorInvHeadsState extends CountedPageBlocState{
  final String errorText;

  LoadErrorInvHeadsState(this.errorText);

  @override
  List<Object> get props => [errorText];
}
class LoadedInvHeadsWithDateState extends CountedPageBlocState {
  final List<TblDkInvHead> invHeads;

  LoadedInvHeadsWithDateState(this.invHeads);

  @override
  List<Object> get props => [invHeads];
}
class LoadEmptyInvHeadsState extends CountedPageBlocState{}
  class ProductsDeletedState extends CountedPageBlocState{
  final TblDkInvHead invHead;

  ProductsDeletedState(this.invHead);

  @override
  List<Object> get props => [invHead];
  }
  class DeletingProductsState extends CountedPageBlocState{}
  class DeleteErrorState extends CountedPageBlocState{
  final String error;

  DeleteErrorState(this.error);

  @override
  List<Object> get props => [error];
  }

class SearchingInvHeadsState extends CountedPageBlocState {

  @override
  List<Object> get props => [];
}
class SearchInvHeadsResultEmptyState extends CountedPageBlocState {
  final String barcode;

  SearchInvHeadsResultEmptyState(this.barcode);

  @override
  List<Object> get props => [barcode];
}
class SearchingInvHeadsCompletedState extends CountedPageBlocState {
  final List<TblDkInvHead> invHeads;
  final String searchText;

  SearchingInvHeadsCompletedState(this.invHeads, this.searchText);

  @override
  List<Object> get props => [invHeads, searchText];
}
// endRegion States

class CountedPageBloc extends Bloc<CountedPageBlocEvent, CountedPageBlocState>{
  DbService? _srv;
  String host = '';
  int port = 1433;
  String dbName = '';
  String dbUName = '';
  String dbUPass = '';
  String deviceId = "";
  String deviceName = '';
  final IsolateHelper isolateHelper;
  CountedPageBloc() : isolateHelper = IsolateHelper(), super(InitialCountedPageState()){
    on<LoadInvHeadsEvent>(_loadInvHeads);
    on<LoadInvHeadsWithDateEvent>(_loadInvHeadsWithDate);
    on<DeleteProductsEvent>(deleteInvHead);
    on<SearchInvHeadsEvent>(searchInvHeads);
  }

  void _loadInvHeads(LoadInvHeadsEvent event, Emitter<CountedPageBlocState> emit) async {
    emit(LoadingInvHeadsState());
    try {
      final result = await isolateHelper.loadInvHeads({});
      if (result['status'] == 'success') {
        List<TblDkInvHead> invHeads = result['invHeads'] as List<TblDkInvHead>;
        emit(LoadedInvHeadsState(invHeads));
      } else {
        emit(LoadErrorInvHeadsState(result['message']));
      }
    } catch (e) {
      emit(LoadErrorInvHeadsState(e.toString()));
    }
  }

  // void _loadInvHeads(LoadInvHeadsEvent event, Emitter<CountedPageBlocState> emit) async{
  //   List<TblDkInvHead>? invHeads = [];
  //   emit(LoadingInvHeadsState());
  //   try{
  //     DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  //     AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  //     deviceName = '${androidInfo.brand} ${androidInfo.device}';
  //     deviceId = await const AndroidId().getId() ?? '';
  //     final prefs = await SharedPreferences.getInstance();
  //     host = prefs.getString(SharedPrefKeys.serverAddress) ?? "";
  //     port = prefs.getInt(SharedPrefKeys.serverPort) ?? 1433;
  //     dbName = prefs.getString(SharedPrefKeys.dbName) ?? "";
  //     dbUName = prefs.getString(SharedPrefKeys.dbUName) ?? "";
  //     dbUPass = prefs.getString(SharedPrefKeys.dbUPass) ?? "";
  //     _srv = DbService(host, port, dbName, dbUName, dbUPass);
  //     invHeads = await _srv?.getInvHeads('$deviceId $deviceName');
  //     if(invHeads!=null && invHeads.isNotEmpty){
  //       invHeads.sort((a, b) =>
  //           b.MatInvDate!.compareTo(a.MatInvDate!));
  //       emit(LoadedInvHeadsState(invHeads));
  //     }
  //   }
  //   catch(e){
  //     emit(LoadErrorInvHeadsState(e.toString()));
  //   }
  // }

  void _loadInvHeadsWithDate(LoadInvHeadsWithDateEvent event, Emitter<CountedPageBlocState> emit) async{
    List<TblDkInvHead>? invHeads = [];
    emit(LoadingInvHeadsState());
    try{
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceName = '${androidInfo.brand} ${androidInfo.device}';
      deviceId = await const AndroidId().getId() ?? '';
      final prefs = await SharedPreferences.getInstance();
      int userTypeId = prefs.getInt(SharedPrefKeys.userTypeId) ?? 0;
      host = prefs.getString(SharedPrefKeys.serverAddress) ?? "";
      port = prefs.getInt(SharedPrefKeys.serverPort) ?? 1433;
      dbName = prefs.getString(SharedPrefKeys.dbName) ?? "";
      dbUName = prefs.getString(SharedPrefKeys.dbUName) ?? "";
      dbUPass = prefs.getString(SharedPrefKeys.dbUPass) ?? "";
      _srv = DbService(host, port, dbName, dbUName, dbUPass);
      DateTime endDate = event.endDate.add(const Duration(hours: 23, minutes: 59, seconds: 59, milliseconds: 99));
      if(userTypeId==1){
        invHeads = await _srv?.getInvHeadsWithDate(
            null, event.startDate, endDate);
      }
      else {
        invHeads = await _srv?.getInvHeadsWithDate(
            '$deviceId $deviceName', event.startDate, endDate);
      }
      if(invHeads!=null && invHeads.isNotEmpty){
        invHeads.sort((a, b) =>
            b.MatInvDate!.compareTo(a.MatInvDate!));
        emit(LoadedInvHeadsWithDateState(invHeads));
      }
      else{
        emit(LoadEmptyInvHeadsState());
      }
    }
    catch(e){
      emit(LoadErrorInvHeadsState(e.toString()));
    }
  }

  void deleteInvHead(DeleteProductsEvent event, Emitter<CountedPageBlocState> emit) async {
    emit(DeletingProductsState());
    try {
      final result = await isolateHelper.deleteInvHead({'invHead': event.invHead});
      if (result['status'] == 'success') {
        emit(ProductsDeletedState(result['invHead']));
      } else {
        emit(DeleteErrorState(result['message']));
      }
    } catch (e) {
      emit(DeleteErrorState(e.toString()));
    }
  }

  void searchInvHeads(SearchInvHeadsEvent event, Emitter<CountedPageBlocState> emit) async{
    emit(SearchingInvHeadsState());
    try {
      List<String> searchTexts = event.searchText.split(" ");
      List<TblDkInvHead> searchResultList = [];
      searchResultList = event.invHeads
          .where((element) =>
      ((element.MatInvCode.isNotEmpty) ? searchTexts.every((element2) => element.MatInvCode.toLowerCase().contains(element2.toLowerCase())) : false) ||
          ((element.MatInvDesc.isNotEmpty) ? searchTexts.every((element2) => element.MatInvDesc.toLowerCase().contains(element2.toLowerCase())) : false)
          ||
          ((element.GroupCode.isNotEmpty) ? searchTexts.every((element2) => element.GroupCode.toLowerCase().contains(element2.toLowerCase())) : false))
          .toList();
      if(searchResultList.isNotEmpty){
        debugPrint("Search list length: ${searchResultList.length}");
        emit(SearchingInvHeadsCompletedState(searchResultList, event.searchText));
      }
      else{
        emit(SearchInvHeadsResultEmptyState(event.searchText));
      }
    }
    catch(e){
      emit(SearchInvHeadsResultEmptyState((e.toString())));
    }
  }

  // void deleteInvHead(DeleteProductsEvent event, Emitter<CountedPageBlocState> emit) async{
  //   emit(DeletingProductsState());
  //   try{
  //     DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  //     AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  //     deviceName = '${androidInfo.brand} ${androidInfo.device}';
  //     deviceId = await const AndroidId().getId() ?? '';
  //     final prefs = await SharedPreferences.getInstance();
  //     host = prefs.getString(SharedPrefKeys.serverAddress) ?? "";
  //     port = prefs.getInt(SharedPrefKeys.serverPort) ?? 1433;
  //     dbName = prefs.getString(SharedPrefKeys.dbName) ?? "";
  //     dbUName = prefs.getString(SharedPrefKeys.dbUName) ?? "";
  //     dbUPass = prefs.getString(SharedPrefKeys.dbUPass) ?? "";
  //     _srv = DbService(host, port, dbName, dbUName, dbUPass);
  //     bool? result = await _srv?.deleteInvHead('$deviceId $deviceName', event.invHead.MatInvHeadId);
  //     bool? result2 = await _srv?.deleteInvHeadProducts('$deviceId $deviceName', event.invHead.MatInvHeadId);
  //     if(result!=null && result && result2 !=null && result2){
  //       emit(ProductsDeletedState(event.invHead));
  //     }
  //   }
  //   catch(e){
  //     emit(LoadErrorInvHeadsState(e.toString()));
  //   }
  // }
}
