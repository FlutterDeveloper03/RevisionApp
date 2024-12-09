import 'package:android_id/android_id.dart';
import 'package:bloc/bloc.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:revision_app/helpers/IsolateHelper.dart';
import 'package:revision_app/helpers/SharedPrefKeys.dart';
import 'package:revision_app/models/v_dk_mat_count_params.dart';
import 'package:revision_app/models/v_dk_material_count.dart';
import 'package:revision_app/provider/GlobalVarsProvider.dart';
import 'package:revision_app/services/dbService.dart';
import 'package:shared_preferences/shared_preferences.dart';

// region Events
abstract class ListPageBlocEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadListEvent extends ListPageBlocEvent {
  final VDkMatCountParams params;

  LoadListEvent(this.params);

  @override
  List<Object> get props => [params];
}
class SearchCountsEvent extends ListPageBlocEvent {
  final List<VDkMaterialCount> counts;
  final String searchText;

  SearchCountsEvent(this.counts, this.searchText);

  @override
  List<Object> get props => [counts, searchText];
}
class SaveInvoiceEvent extends ListPageBlocEvent{
  final List<VDkMaterialCount> counts;
  final bool isOnlyAdminDevice;
  final VDkMatCountParams params;

  SaveInvoiceEvent(this.counts, this.isOnlyAdminDevice, this.params);


  @override
  List<Object> get props => [counts, isOnlyAdminDevice, params];
}
class DeleteMaterialEvent extends ListPageBlocEvent{
  final VDkMaterialCount matCount;
  final VDkMatCountParams params;
  final int userId;
  DeleteMaterialEvent(this.matCount, this.params, this.userId);

  @override
  List<Object> get props => [matCount, params, userId];
}
class DeleteCountsEvent extends ListPageBlocEvent{
  final VDkMatCountParams params;

  DeleteCountsEvent(this.params);

  @override
  List<Object> get props => [params];
}
class SetCountsToZeroEvent extends ListPageBlocEvent {
  final List<VDkMaterialCount> counts;
  final VDkMatCountParams params;

  SetCountsToZeroEvent(this.counts, this.params);

  @override
  List<Object> get props => [counts, params];
}
// endRegion Events


// region States
class ListPageBlocState extends Equatable {
  @override
  List<Object> get props => [];
}

class ListLoadedState extends ListPageBlocState {
  final List<VDkMaterialCount> materialCounts;
  final String deviceName;
  final int userTypeId;
  final VDkMatCountParams params;

  ListLoadedState(this.materialCounts, this.deviceName, this.userTypeId, this.params);

  @override
  List<Object> get props => [materialCounts, deviceName, userTypeId,params];
}
class InitialListState extends ListPageBlocState {}
class LoadingListState extends ListPageBlocState {}
class LoadErrorListState extends ListPageBlocState {
  final String errorText;

  LoadErrorListState(this.errorText);


  String get getErrorText=>errorText;

  @override
  List<Object> get props => [errorText];
}
class SearchingCountsState extends ListPageBlocState {}
class SearchResultEmptyState extends ListPageBlocState {
  final String barcode;

  SearchResultEmptyState(this.barcode);

  @override
  List<Object> get props => [barcode];
}
class SearchingCompletedState extends ListPageBlocState {
  final List<VDkMaterialCount> counts;
  final String barcode;

  SearchingCompletedState(this.counts, this.barcode);

  @override
  List<Object> get props => [counts, barcode];
}
class SavingInvoiceState extends ListPageBlocState{}
class SavedInvoiceState extends ListPageBlocState{}
class SaveErrorInvoiceState extends ListPageBlocState{
  final String errorText;

  SaveErrorInvoiceState(this.errorText);

  @override
  List<Object> get props => [errorText];
}
class MaterialDeletedState extends ListPageBlocState{
  final VDkMaterialCount materialCount;

  MaterialDeletedState(this.materialCount);

  @override
  List<Object> get props => [materialCount];
}
class DeletingMaterialState extends ListPageBlocState{}
class ErrorDeleteState extends ListPageBlocState{
  final String error;

  ErrorDeleteState(this.error);

  @override
  List<Object> get props => [error];
}
class DeletingCountsState extends ListPageBlocState{}
class CountsDeletedState extends ListPageBlocState{}
class CountsSetToZeroState extends ListPageBlocState{}
class SetCountsToZeroErrorState extends ListPageBlocState{
  final String errorText;

  SetCountsToZeroErrorState(this.errorText);

  @override
  List<Object> get props => [errorText];
}
class SettingCountsToZeroState extends ListPageBlocState{}
// endregion States

class ListPageBloc extends Bloc<ListPageBlocEvent, ListPageBlocState> {
  DbService? _srv;
  String host = '';
  int port = 1433;
  String dbName = '';
  String dbUName = '';
  String dbUPass = '';
  String deviceId = "";
  String deviceName = '';
  String countingType="";
  String warehouseCondition="";
  final GlobalVarsProvider globalProvider;
  final IsolateHelper isolateHelper;
  ListPageBloc(this.globalProvider) : isolateHelper = IsolateHelper(), super(InitialListState()) {
    on<LoadListEvent>(loadList);
    on<SearchCountsEvent>(searchCounts);
    on<SaveInvoiceEvent>(saveInvoice);
    on<DeleteMaterialEvent>(deleteMaterial);
    on<DeleteCountsEvent>(deleteCounts);
  }

  void loadList (LoadListEvent event, Emitter<ListPageBlocState> emit) async {
    emit(LoadingListState());
    try{
      final result = await isolateHelper.loadList({
        'params': event.params,
      });
      List<VDkMaterialCount>? materialCounts = result['materialCounts'];
      String deviceName = result['deviceName'];
      int userTypeId = result['userTypeId'];
      if(materialCounts != null) {
        emit(ListLoadedState(materialCounts, deviceName, userTypeId, event.params));
      }
      else {
        emit(LoadErrorListState('Error loading material counts'));
      }
    }
    catch(e){
      emit(LoadErrorListState(e.toString()));
    }
  }

  void searchCounts(SearchCountsEvent event, Emitter<ListPageBlocState> emit) async{
    emit(SearchingCountsState());
    try {
      List<String> searchTexts = event.searchText.split(" ");
      List<VDkMaterialCount> searchResultList = [];
      searchResultList = event.counts
          .where((element) =>
      ((element.BarcodeValue.isNotEmpty) ? searchTexts.every((element2) => element.BarcodeValue.toLowerCase().contains(element2.toLowerCase())) : false) ||
          ((element.MatName.isNotEmpty) ? searchTexts.every((element2) => element.MatName.toLowerCase().contains(element2.toLowerCase())) : false)
          || ((element.DeviceId.isNotEmpty) ? searchTexts.every((element2) => element.DeviceId.toLowerCase().contains(element2.toLowerCase())) : false)
        || ((element.UName.isNotEmpty) ? searchTexts.every((element2) => element.UName.toLowerCase().contains(element2.toLowerCase())) : false))
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

  void saveInvoice(SaveInvoiceEvent event, Emitter<ListPageBlocState> emit) async{
    emit(SavingInvoiceState());
      try {
        final result = await isolateHelper.saveInvoice({
          'counts': event.counts,
          'isOnlyAdminDevice': event.isOnlyAdminDevice,
          'params': event.params
        });
        final String? status = result['status'];
        final String? message = result['message'];

        if (status=='success') {
          emit(SavedInvoiceState());
        } else {
          emit(SaveErrorInvoiceState(message ?? ""));
        }
    }
    catch(e){
      emit(SaveErrorInvoiceState((e.toString())));
    }
  }

  // void saveInvoice(SaveInvoiceEvent event, Emitter<ListPageBlocState> emit) async{
  //   List<VDkMaterialCount> lessCounts = [];
  //   List<VDkMaterialCount> moreCounts = [];
  //   bool allLinesSaved = true;
  //   double matInvTotal = 0;
  //   double matInvTotal2 = 0;
  //   emit(SavingInvoiceState());
  //   try {
  //     DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  //     AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  //     deviceName = '${androidInfo.brand} ${androidInfo.device}';
  //     deviceId = await const AndroidId().getId() ?? '';
  //     final prefs = await SharedPreferences.getInstance();
  //     int whId = prefs.getInt(SharedPrefKeys.warehouseId) ?? 0;
  //     host = prefs.getString(SharedPrefKeys.serverAddress) ?? "";
  //     port = prefs.getInt(SharedPrefKeys.serverPort) ?? 1433;
  //     dbName = prefs.getString(SharedPrefKeys.dbName) ?? "";
  //     dbUName = prefs.getString(SharedPrefKeys.dbUName) ?? "";
  //     dbUPass = prefs.getString(SharedPrefKeys.dbUPass) ?? "";
  //     int salesmanId = prefs.getInt(SharedPrefKeys.salesmanId) ?? 0;
  //     int teacherId = prefs.getInt(SharedPrefKeys.teacherId) ?? 0;
  //     String matInvDesc = prefs.getString(SharedPrefKeys.note1) ?? "";
  //     String matInvDesc2 = prefs.getString(SharedPrefKeys.note2) ?? "";
  //     String countedDate = prefs.getString(SharedPrefKeys.countedDate) ?? "";
  //     _srv = DbService(host, port, dbName, dbUName, dbUPass);
  //     TblDkDepartment? department = await _srv?.getDepartment();
  //     TblDkDivision? division = await _srv?.getDivision();
  //     TblDkPlant? plant = await _srv?.getPlant();
  //     TblDkPeriod? period = await _srv?.getPeriod();
  //     if(department!=null && division!=null && plant!=null && period!=null && event.counts.isNotEmpty){
  //       lessCounts = event.counts.where((element) => (element.MatCountTotal-element.MatWhTotalAmount) < 0).toList();
  //       moreCounts = event.counts.where((element) => (element.MatCountTotal-element.MatWhTotalAmount) > 0).toList();
  //       if(lessCounts.isNotEmpty){
  //         TblDkDocNum? docNum = await _srv?.getDocNum(teacherId,7);
  //         if(docNum != null){
  //           lessCounts.forEach((element) {
  //             matInvTotal += element.PurchasePrice * (element.MatCountTotal-element.MatWhTotalAmount).abs();
  //           });
  //           bool? result = await _srv?.saveInvHead(docNum.DocNum, division.DivId, department.DeptId, plant.PlantId, whId, matInvTotal, period.PId, teacherId, salesmanId, matInvDesc, matInvDesc2,'$deviceId $deviceName', countedDate);
  //           if(result != null && result){
  //             TblDkInvHead? invHead = await _srv?.getInvHead(docNum.DocNum);
  //             bool? savedResult = await _srv?.saveDocNum(docNum.DocLastNum, division.CId, teacherId, docNum.DocNum, 7);
  //             if(savedResult != null && savedResult && invHead != null){
  //               for (var element in lessCounts) {
  //                 double matDiff = (element.MatCountTotal - element.MatWhTotalAmount).abs();
  //                 double matInvLineNet = element.PurchasePrice * matDiff;
  //                 bool? savedInv = await _srv?.saveInvLine(element, invHead.MatInvHeadId, matInvLineNet, matDiff, '$deviceId $deviceName');
  //                 TblDkInvLine? invLine = await _srv?.getInvLine(element.MatId, invHead.MatInvHeadId);
  //                 if (savedInv != null && savedInv && invLine != null) {
  //                   bool? savedTrans = await _srv?.saveTransLine(element, invLine.MatInvLineId, matInvLineNet, plant.PlantId, matDiff, invHead.MatInvTypeId);
  //                   if (savedTrans == null || !savedTrans) {
  //                     allLinesSaved = false;
  //                     break;
  //                   }
  //                 } else {
  //                   allLinesSaved = false;
  //                   break;
  //                 }
  //               }
  //             }
  //             else{
  //               allLinesSaved = false;
  //             }
  //           }
  //           else{
  //             allLinesSaved = false;
  //           }
  //         }
  //         else{
  //           allLinesSaved = false;
  //         }
  //       }
  //       if(moreCounts.isNotEmpty){
  //         TblDkDocNum? docNum = await _srv?.getDocNum(teacherId,6);
  //         if(docNum != null){
  //           moreCounts.forEach((element) {
  //             matInvTotal2 += element.PurchasePrice * (element.MatCountTotal-element.MatWhTotalAmount);
  //           });
  //           bool? result = await _srv?.saveInvHeadMore(docNum.DocNum, division.DivId, department.DeptId, plant.PlantId, whId, matInvTotal2, period.PId, teacherId, salesmanId, matInvDesc, matInvDesc2, '$deviceId $deviceName', countedDate);
  //           if(result != null && result){
  //             TblDkInvHead? invHead = await _srv?.getInvHead(docNum.DocNum);
  //             bool? savedResult = await _srv?.saveDocNum(docNum.DocLastNum, division.CId, teacherId, docNum.DocNum, 6);
  //             if(savedResult != null && savedResult && invHead != null){
  //               for (var element in moreCounts) {
  //                 double matDiff = element.MatCountTotal - element.MatWhTotalAmount;
  //                 double matInvLineNet = element.PurchasePrice * matDiff;
  //                 bool? savedInv = await _srv?.saveInvLine(element, invHead.MatInvHeadId, matInvLineNet, matDiff, '$deviceId $deviceName');
  //                 TblDkInvLine? invLine = await _srv?.getInvLine(element.MatId, invHead.MatInvHeadId);
  //                 if (savedInv != null && savedInv && invLine != null) {
  //                   bool? savedTrans = await _srv?.saveTransLineMore(element, invLine.MatInvLineId, matInvLineNet, plant.PlantId, matDiff, invHead.MatInvTypeId);
  //                   if (savedTrans == null || !savedTrans) {
  //                     allLinesSaved = false;
  //                     break;
  //                   }
  //                 } else {
  //                   allLinesSaved = false;
  //                   break;
  //                 }
  //               }
  //             }
  //             else{
  //               allLinesSaved = false;
  //             }
  //           }
  //           else{
  //             allLinesSaved = false;
  //           }
  //         }
  //       }
  //     }
  //     else {
  //       allLinesSaved = false;
  //     }
  //     if (allLinesSaved) {
  //       bool? result = await _srv?.deleteMaterialCount('$deviceId $deviceName');
  //       if(result!=null && result){
  //         emit(SavedInvoiceState());
  //       }
  //     } else {
  //       emit(SaveErrorInvoiceState("There is some problem with saving invoice line or transaction line!"));
  //     }
  //     }
  //       catch(e){
  //         emit(SaveErrorInvoiceState((e.toString())));
  //       }
  // }

  void deleteMaterial(DeleteMaterialEvent event, Emitter<ListPageBlocState> emit) async {
    emit(DeletingMaterialState());
    try {
      final result = await isolateHelper.deleteMaterial({
        'matId': event.matCount.MatId,
        'params': event.params,
        'userId': event.userId
      });
      if (result['status'] == 'success') {
        emit(MaterialDeletedState(event.matCount));
      } else {
        emit(ErrorDeleteState(result['message']));
      }
    } catch (e) {
      emit(ErrorDeleteState(e.toString()));
    }
  }


  // void deleteMaterial(DeleteMaterialEvent event, Emitter<ListPageBlocState> emit) async{
  //   emit(DeletingMaterialState());
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
  //     bool? result = await _srv?.deleteSingleMatCount('$deviceId $deviceName', event.matCount.MatId);
  //     if(result !=null && result){
  //       emit(MaterialDeletedState());
  //     } else{
  //       emit(ErrorDeleteState("There is some error with deleting!"));
  //     }
  //   } catch (e) {
  //     emit(ErrorDeleteState(e.toString()));
  //   }
  // }

  void deleteCounts(DeleteCountsEvent event, Emitter<ListPageBlocState> emit) async {
    emit(DeletingCountsState());
    bool? result = true;
    bool? result2 = true;
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceName = '${androidInfo.brand} ${androidInfo.device}';
      deviceId = await const AndroidId().getId() ?? '';
      final prefs = await SharedPreferences.getInstance();
      host = prefs.getString(SharedPrefKeys.serverAddress) ?? "";
      port = prefs.getInt(SharedPrefKeys.serverPort) ?? 1433;
      dbName = prefs.getString(SharedPrefKeys.dbName) ?? "";
      dbUName = prefs.getString(SharedPrefKeys.dbUName) ?? "";
      dbUPass = prefs.getString(SharedPrefKeys.dbUPass) ?? "";
      int userTypeId = prefs.getInt(SharedPrefKeys.userTypeId) ?? 0;
      bool newCount = prefs.getBool(SharedPrefKeys.newCount) ?? false;
      int teacherId = prefs.getInt(SharedPrefKeys.teacherId) ?? 0;
      _srv = DbService(host, port, dbName, dbUName, dbUPass);
      if(userTypeId == 1){
        result = await _srv?.deleteMaterialCount(null, event.params, newCount, null);
      }
      else{
        result = await _srv?.deleteMaterialCount('$deviceId $deviceName', event.params, newCount, teacherId);
      }
      if (result != null && result) {
        if(userTypeId == 1){
          result2 = await _srv?.deleteStockCount('$deviceId $deviceName', event.params, newCount, null);
        }
        else{
          result2 = await _srv?.deleteStockCount('$deviceId $deviceName', event.params, newCount, teacherId);
        }

        if(result2 != null && result2) {
          emit(CountsDeletedState());
        }
        else {
          emit(ErrorDeleteState('Error while deleting stock count'));
        }
      }
    } catch (e) {
      emit(ErrorDeleteState(e.toString()));
    }
  }
}