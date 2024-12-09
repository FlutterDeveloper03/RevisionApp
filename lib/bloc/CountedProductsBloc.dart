// ignore_for_file: file_names

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:revision_app/helpers/IsolateHelper.dart';
import 'package:revision_app/models/tbl_dk_inv_head.dart';
import 'package:revision_app/models/v_dk_inv_line.dart';

class CountedProductsEvent extends Equatable{

  @override
  List<Object> get props => [];
}
class LoadProductsEvent extends CountedProductsEvent{
  final TblDkInvHead matInvHead;

  LoadProductsEvent(this.matInvHead);

  @override
  List<Object> get props => [matInvHead];
}
class SearchProductsEvent extends CountedProductsEvent {
  final List<VDkInvLine> invLines;
  final String searchText;

  SearchProductsEvent(this.invLines, this.searchText);

  @override
  List<Object> get props => [invLines, searchText];
}
//endRegion Events

// region States
class CountedProductsState extends Equatable{

  @override
  List<Object> get props => [];
}
class InitialProductsState extends CountedProductsState{}
class LoadedProductsState extends CountedProductsState{
  final List<VDkInvLine> invLines;

  LoadedProductsState(this.invLines);

  @override
  List<Object> get props => [invLines];
}
class LoadingProductsState extends CountedProductsState{}
class LoadErrorProductsState extends CountedProductsState{
  final String errorText;

  LoadErrorProductsState(this.errorText);

  @override
  List<Object> get props => [errorText];
}
class SearchingProductsState extends CountedProductsState {

  @override
  List<Object> get props => [];
}
class SearchResultEmptyState extends CountedProductsState {
  final String barcode;

  SearchResultEmptyState(this.barcode);

  @override
  List<Object> get props => [barcode];
}
class SearchingCompletedState extends CountedProductsState {
  final List<VDkInvLine> invLineProducts;
  final String barcode;

  SearchingCompletedState(this.invLineProducts, this.barcode);

  @override
  List<Object> get props => [invLineProducts, barcode];
}

// endRegion States
class CountedProductsBloc extends Bloc<CountedProductsEvent, CountedProductsState>{
  String host = '';
  int port = 1433;
  String dbName = '';
  String dbUName = '';
  String dbUPass = '';
  String deviceId = "";
  String deviceName = '';
  final IsolateHelper isolateHelper;
  CountedProductsBloc() : isolateHelper = IsolateHelper(),super(InitialProductsState()){
    on<LoadProductsEvent>(loadProducts);
    on<SearchProductsEvent>(searchProducts);
  }

  void loadProducts(LoadProductsEvent event, Emitter<CountedProductsState> emit) async {
    int whId = 0;
    emit(LoadingProductsState());
    try {
      if(event.matInvHead.MatInvTypeId==13){
        whId = event.matInvHead.InWhId;
      }
      else if(event.matInvHead.MatInvTypeId==14){
        whId = event.matInvHead.OutWhId;
      }
      final result = await isolateHelper.loadProducts({
        'matInvHeadId': event.matInvHead.MatInvHeadId,
        'whId': whId
      });
      if (result['status'] == 'success') {
        emit(LoadedProductsState(result['invLines']));
      } else {
        emit(LoadErrorProductsState(result['message']));
      }
    } catch (e) {
      emit(LoadErrorProductsState(e.toString()));
    }
  }

  // void loadProducts(LoadProductsEvent event, Emitter<CountedProductsState> emit) async{
  //   List<VDkInvLine>? invLines = [];
  //   emit(LoadingProductsState());
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
  //     int whId = prefs.getInt(SharedPrefKeys.warehouseId) ?? 0;
  //     _srv = DbService(host, port, dbName, dbUName, dbUPass);
  //     invLines = await _srv?.getInvLines('$deviceId $deviceName',whId, event.matInvHeadId);
  //     if(invLines!=null && invLines.isNotEmpty){
  //       emit(LoadedProductsState(invLines));
  //     }
  //     else{
  //       emit(LoadErrorProductsState("There is no products with invHeadId ${event.matInvHeadId}"));
  //     }
  //   }
  //   catch(e){
  //     emit(LoadErrorProductsState(e.toString()));
  //   }
  // }

 void searchProducts(SearchProductsEvent event, Emitter<CountedProductsState> emit) {
   List<VDkInvLine> searchResultList = [];
    emit(SearchingProductsState());
    try{
      List<String> searchTexts = event.searchText.split(" ");
      searchResultList = event.invLines
          .where((element) =>
      ((element.Barcode.isNotEmpty) ? searchTexts.every((element2) => element.Barcode.toLowerCase().contains(element2.toLowerCase())) : false) ||
          ((element.MatName.isNotEmpty) ? searchTexts.every((element2) => element.MatName.toLowerCase().contains(element2.toLowerCase())) : false))
          .toList();
      if(searchResultList.isNotEmpty){
        emit(SearchingCompletedState(searchResultList, event.searchText));
      }
      else{
        emit(SearchResultEmptyState(event.searchText));
      }
    }
    catch(e){
      emit(SearchResultEmptyState((e.toString())));
    }
    }
  

}

