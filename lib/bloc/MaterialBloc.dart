// ignore_for_file: file_names

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:revision_app/helpers/IsolateHelper.dart';
import 'package:revision_app/models/tbl_dk_material.dart';
import 'package:revision_app/models/tbl_dk_unit.dart';
import 'package:revision_app/models/v_dk_mat_count_params.dart';
import 'package:revision_app/provider/GlobalVarsProvider.dart';

// region Events
abstract class MaterialBlocEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadMaterialEvent extends MaterialBlocEvent {
  final int whId;
  final String barcode;
  LoadMaterialEvent(this.whId, this.barcode);

  @override
  List<Object> get props => [whId,barcode];
}

class SaveMaterialEvent extends MaterialBlocEvent {
  final TblDkMaterial material;
  final String description;
  final double countTotal;
  final int unitDetId;
  final VDkMatCountParams params;

  SaveMaterialEvent(this.description, this.material, this.countTotal, this.unitDetId, this.params);

  @override
  List<Object> get props => [description,material,countTotal,unitDetId,params];
}
// endregion Events

// region States
class MaterialBlocState extends Equatable{

  @override
  List<Object> get props => [];
}

class MaterialLoadedState extends MaterialBlocState{
  final TblDkMaterial material;
  final List<TblDkUnit> units;
  MaterialLoadedState(this.material, this.units);

  @override
  List<Object> get props => [material, units];
}
class SavedMaterialState extends MaterialBlocState{
  final TblDkMaterial material;

  SavedMaterialState(this.material);

  @override
  List<Object> get props => [material];
}
class InitialMaterialState extends MaterialBlocState{}
class LoadingMaterialState extends MaterialBlocState{}
class SavingMaterialCountState extends MaterialBlocState{}
class LoadErrorMaterialState extends MaterialBlocState{
  final String errorText;

  LoadErrorMaterialState(this.errorText);

  String get getErrorText=>errorText;

  @override
  List<Object> get props => [errorText];
}
class SaveErrorMaterialCountState extends MaterialBlocState{
  final String errorText;

  SaveErrorMaterialCountState(this.errorText);

  String get getErrorText=>errorText;

  @override
  List<Object> get props => [errorText];
}

// endregion States

class MaterialBloc extends Bloc <MaterialBlocEvent, MaterialBlocState> {
  String host = '';
  int port = 1433;
  String dbName = '';
  String dbUName = '';
  String dbUPass = '';
  String deviceId="";
  int whId = 0;
  String version="";
  String deviceName="";
  final GlobalVarsProvider globalProvider;
  final IsolateHelper isolateHelper;
  MaterialBloc(this.globalProvider) : isolateHelper = IsolateHelper(), super(InitialMaterialState()) {
    on<LoadMaterialEvent>(loadMaterial);
    on<SaveMaterialEvent>(saveMaterialCount);
  }

  void loadMaterial(LoadMaterialEvent event, Emitter<MaterialBlocState> emit) async {
    emit(LoadingMaterialState());
    try {
      final result = await isolateHelper.loadMaterial({'whId': event.whId, 'barcode': event.barcode});
      TblDkMaterial? material = result['material'];
      List<TblDkUnit>? units = result['units'];

      if (material != null && units != null) {
        debugPrint("Loaded material name: ${material.MatName}");
        debugPrint("Loaded unit: ${units[0].UnitDetCode}");
        emit(MaterialLoadedState(material, units));
      } else {
        emit(LoadErrorMaterialState("There is no product with ${event.barcode} barcode value"));
      }
    } catch (e) {
      emit(LoadErrorMaterialState("There is no product with ${event.barcode} barcode value"));
    }
  }

  void saveMaterialCount(SaveMaterialEvent event, Emitter<MaterialBlocState> emit) async {
    emit(SavingMaterialCountState());
    try {
      if(event.countTotal < 1){
        emit(SaveErrorMaterialCountState(
            "The given number is incorrect!"));
      }
      else {
        final result = await isolateHelper.saveMaterialCount({
          'countTotal': event.countTotal,
          'material': event.material,
          'description': event.description,
          'unitDetId': event.unitDetId,
          'params': event.params
        });

        final bool? isSuccess = result['result'];

        if (isSuccess != null && isSuccess) {
          emit(SavedMaterialState(event.material));
        } else {
          emit(SaveErrorMaterialCountState(
              "Error on saving material to database!"));
        }
      }
    } catch (e) {
      emit(SaveErrorMaterialCountState(e.toString()));
    }
  }
}


//------------------With IsolateHelper--------------------------------


  // void loadMaterial(LoadMaterialEvent event, Emitter<MaterialBlocState> emit) async{
  //   List<TblDkUnit>? units = [];
  //   emit(LoadingMaterialState());
  //   try{
  //     final prefs = await SharedPreferences.getInstance();
  //     host = prefs.getString(SharedPrefKeys.serverAddress) ?? "";
  //     port = prefs.getInt(SharedPrefKeys.serverPort) ?? 1433;
  //     dbName = prefs.getString(SharedPrefKeys.dbName) ?? "";
  //     dbUName = prefs.getString(SharedPrefKeys.dbUName) ?? "";
  //     dbUPass = prefs.getString(SharedPrefKeys.dbUPass) ?? "";
  //     _srv = DbService(host, port, dbName, dbUName, dbUPass);
  //     TblDkMaterial? material = await _srv?.getMaterial(event.whId, event.barcode);
  //     if(material != null) {
  //       units = await _srv?.getUnits(material.UnitId);
  //       if(units != null) {
  //         emit(MaterialLoadedState(material,units));
  //       }
  //     }
  //     else{
  //       emit(LoadErrorMaterialState("There is no product with ${event.barcode} barcode value"));
  //     }
  //   }
  //   catch(e){
  //     emit(LoadErrorMaterialState("There is no product with ${event.barcode} barcode value"));
  //   }
  // }
  // void saveMaterialCount(SaveMaterialEvent event, Emitter<MaterialBlocState> emit) async{
  //   emit(SavingMaterialCountState());
  //   try{
  //     DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  //     AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  //     deviceId = await const AndroidId().getId() ?? '';
  //     final info = await PackageInfo.fromPlatform();
  //     version = info.version;
  //     deviceName = '${androidInfo.brand} ${androidInfo.device}';
  //     final prefs = await SharedPreferences.getInstance();
  //     host = prefs.getString(SharedPrefKeys.serverAddress) ?? "";
  //     port = prefs.getInt(SharedPrefKeys.serverPort) ?? 1433;
  //     dbName = prefs.getString(SharedPrefKeys.dbName) ?? "";
  //     dbUName = prefs.getString(SharedPrefKeys.dbUName) ?? "";
  //     dbUPass = prefs.getString(SharedPrefKeys.dbUPass) ?? "";
  //     whId = prefs.getInt(SharedPrefKeys.warehouseId) ?? 0;
  //     _srv = DbService(host, port, dbName, dbUName, dbUPass);
  //     double countDiff = event.countTotal - event.material.WhTotalAmount;
  //     bool? result = await _srv?.addMaterial(event.material, '$deviceId $deviceName', event.description, countDiff, event.countTotal, event.unitDetId);
  //     if(result != null && result){
  //       List<VDkMaterialCount>? matCounts = await _srv?.getMaterialCounts('$deviceId $deviceName', whId);
  //       if(matCounts != null){
  //         matCounts.sort((a, b) => b.MatCountDate!.compareTo(a.MatCountDate!));
  //         globalProvider.setCounts = matCounts;
  //         emit(SavedMaterialState());
  //       }
  //     }
  //     else{
  //       emit(SaveErrorMaterialCountState("Error on saving material to database!"));
  //     }
  //   }
  //   catch(e){
  //     emit(SaveErrorMaterialCountState(e.toString()));
  //   }
  // }


  //------------------With Isolate--------------------------------
  // void loadMaterial(LoadMaterialEvent event, Emitter<MaterialBlocState> emit) async {
  //   emit(LoadingMaterialState());
  //   final receivePort = ReceivePort();
  //   try {
  //     await Isolate.spawn(loadMaterialEntryPoint, receivePort.sendPort);
  //     final sendPort = await receivePort.first as SendPort;
  //
  //     final responsePort = ReceivePort();
  //     sendPort.send([{'whId': event.whId, 'barcode': event.barcode}, responsePort.sendPort]);
  //
  //     final result = await responsePort.first as Map<String, dynamic>;
  //     final material = result['material'];
  //     final units = result['units'];
  //
  //     if (material != null && units != null) {
  //       emit(MaterialLoadedState(material, units));
  //     } else {
  //       emit(LoadErrorMaterialState("There is no product with ${event.barcode} barcode value"));
  //     }
  //   } catch (e) {
  //     emit(LoadErrorMaterialState("There is no product with ${event.barcode} barcode value"));
  //   } finally {
  //     receivePort.close();
  //   }
  // }
  //
  // void saveMaterialCount(SaveMaterialEvent event, Emitter<MaterialBlocState> emit) async {
  //   emit(SavingMaterialCountState());
  //   final receivePort = ReceivePort();
  //
  //   try {
  //     await Isolate.spawn(saveMaterialCountEntryPoint, receivePort.sendPort);
  //     final sendPort = await receivePort.first as SendPort;
  //
  //     final responsePort = ReceivePort();
  //     sendPort.send([{
  //       'countTotal': event.countTotal,
  //       'material': event.material,
  //       'description': event.description,
  //       'unitDetId': event.unitDetId,
  //     }, responsePort.sendPort]);
  //
  //     final result = await responsePort.first as Map<String, dynamic>;
  //     final bool? isSuccess = result['result'];
  //     final List<VDkMaterialCount>? matCounts = result['matCounts'];
  //
  //     if (isSuccess != null && isSuccess && matCounts != null) {
  //       globalProvider.setCounts = matCounts;
  //       emit(SavedMaterialState());
  //     } else {
  //       emit(SaveErrorMaterialCountState("Error on saving material to database!"));
  //     }
  //   } catch (e) {
  //     emit(SaveErrorMaterialCountState(e.toString()));
  //   } finally {
  //     receivePort.close();
  //   }
  // }
  //
  // void loadMaterialEntryPoint(SendPort sendPort) async {
  //   final receivePort = ReceivePort();
  //   sendPort.send(receivePort.sendPort);
  //
  //   await for (var msg in receivePort) {
  //     final data = msg[0];
  //     final responsePort = msg[1];
  //
  //     final prefs = await SharedPreferences.getInstance();
  //     String host = prefs.getString(SharedPrefKeys.serverAddress) ?? "";
  //     int port = prefs.getInt(SharedPrefKeys.serverPort) ?? 1433;
  //     String dbName = prefs.getString(SharedPrefKeys.dbName) ?? "";
  //     String dbUName = prefs.getString(SharedPrefKeys.dbUName) ?? "";
  //     String dbUPass = prefs.getString(SharedPrefKeys.dbUPass) ?? "";
  //     final DbService _srv = DbService(host, port, dbName, dbUName, dbUPass);
  //
  //     TblDkMaterial? material = await _srv.getMaterial(data['whId'], data['barcode']);
  //     List<TblDkUnit>? units = [];
  //     if (material != null) {
  //       units = await _srv.getUnits(material.UnitId);
  //     }
  //     responsePort.send({
  //       'material': material,
  //       'units': units,
  //     });
  //   }
  // }
  // void saveMaterialCountEntryPoint(SendPort sendPort) async {
  //   final receivePort = ReceivePort();
  //   sendPort.send(receivePort.sendPort);
  //
  //   await for (var msg in receivePort) {
  //     final data = msg[0];
  //     final responsePort = msg[1];
  //
  //     DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  //     AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  //     String deviceId = await const AndroidId().getId() ?? '';
  //     final info = await PackageInfo.fromPlatform();
  //     String version = info.version;
  //     String deviceName = '${androidInfo.brand} ${androidInfo.device}';
  //
  //     final prefs = await SharedPreferences.getInstance();
  //     String host = prefs.getString(SharedPrefKeys.serverAddress) ?? "";
  //     int port = prefs.getInt(SharedPrefKeys.serverPort) ?? 1433;
  //     String dbName = prefs.getString(SharedPrefKeys.dbName) ?? "";
  //     String dbUName = prefs.getString(SharedPrefKeys.dbUName) ?? "";
  //     String dbUPass = prefs.getString(SharedPrefKeys.dbUPass) ?? "";
  //     int whId = prefs.getInt(SharedPrefKeys.warehouseId) ?? 0;
  //
  //     final DbService _srv = DbService(host, port, dbName, dbUName, dbUPass);
  //     double countDiff = data['countTotal'] - data['material'].WhTotalAmount;
  //     bool? result = await _srv.addMaterial(
  //         data['material'], '$deviceId $deviceName', data['description'],
  //         countDiff, data['countTotal'], data['unitDetId']);
  //
  //     List<VDkMaterialCount>? matCounts = [];
  //     if (result) {
  //       matCounts = await _srv.getMaterialCounts('$deviceId $deviceName', whId);
  //       matCounts.sort((a, b) => b.MatCountDate!.compareTo(a.MatCountDate!));
  //           }
  //
  //     responsePort.send({
  //       'result': result,
  //       'matCounts': matCounts,
  //     });
  //   }
  // }
// }