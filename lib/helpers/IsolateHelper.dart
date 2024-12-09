import 'dart:isolate';
import 'package:android_id/android_id.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:revision_app/helpers/SharedPrefKeys.dart';
import 'package:revision_app/models/tbl_dk_department.dart';
import 'package:revision_app/models/tbl_dk_division.dart';
import 'package:revision_app/models/tbl_dk_docnum.dart';
import 'package:revision_app/models/tbl_dk_inv_head.dart';
import 'package:revision_app/models/tbl_dk_inv_line.dart';
import 'package:revision_app/models/tbl_dk_material.dart';
import 'package:revision_app/models/tbl_dk_period.dart';
import 'package:revision_app/models/tbl_dk_plant.dart';
import 'package:revision_app/models/tbl_dk_unit.dart';
import 'package:revision_app/models/v_dk_inv_line.dart';
import 'package:revision_app/models/v_dk_invoice.dart';
import 'package:revision_app/models/v_dk_mat_count_params.dart';
import 'package:revision_app/models/v_dk_material_count.dart';
import 'package:revision_app/services/dbService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';

class IsolateHelper {
  Future<Map<String, dynamic>> loadMaterial(Map<String, dynamic> args) async {
    final token = RootIsolateToken.instance;
    return await _spawnIsolate(_loadMaterialEntryPoint, args, token);
  }

  Future<Map<String, dynamic>> saveMaterialCount(Map<String, dynamic> args) async {
    final token = RootIsolateToken.instance;
    return await _spawnIsolate(_saveMaterialCountEntryPoint, args, token);
  }

  Future<Map<String, dynamic>> loadList(Map<String, dynamic> args) async {
    final token = RootIsolateToken.instance;
    return await _spawnIsolate(_loadListEntryPoint, args, token);
  }

  Future<Map<String, dynamic>> saveInvoice(Map<String, dynamic> args) async {
    final token = RootIsolateToken.instance;
    return await _spawnIsolate(_saveInvoiceEntryPoint, args, token);
  }

  Future<Map<String, dynamic>> deleteInvHead(Map<String, dynamic> args) async {
    final token = RootIsolateToken.instance;
    return await _spawnIsolate(_deleteInvHeadEntryPoint, args, token);
  }

  Future<Map<String, dynamic>> loadProducts(Map<String, dynamic> args) async {
    final token = RootIsolateToken.instance;
    return await _spawnIsolate(_loadProductsEntryPoint, args, token);
  }

  Future<Map<String, dynamic>> deleteMaterial(Map<String, dynamic> args) async {
    final token = RootIsolateToken.instance;
    return await _spawnIsolate(_deleteMaterialEntryPoint, args, token);
  }

  Future<Map<String, dynamic>> loadInvHeads(Map<String, dynamic> args) async {
    final token = RootIsolateToken.instance;
    return await _spawnIsolate(_loadInvHeadsEntryPoint, args, token);
  }

  Future<Map<String, dynamic>> _spawnIsolate(Function(List<Object?>) entryPoint, Map<String, dynamic> args, RootIsolateToken? token) async {
    final receivePort = ReceivePort();
    await Isolate.spawn(entryPoint, [receivePort.sendPort, token]);
    final sendPort = await receivePort.first as SendPort;

    final responsePort = ReceivePort();
    sendPort.send([args, responsePort.sendPort]);

    final result = await responsePort.first as Map<String, dynamic>;
    receivePort.close();
    responsePort.close();

    return result;
  }

  static void _loadMaterialEntryPoint(List<dynamic> args) async {
    final receivePort = ReceivePort();
    final sendPort = args[0] as SendPort;
    final token = args[1] as RootIsolateToken?;
    sendPort.send(receivePort.sendPort);
    if (token != null) {
      BackgroundIsolateBinaryMessenger.ensureInitialized(token);
    }
    await for (var msg in receivePort) {
      final data = msg[0];
      final responsePort = msg[1];

      final prefs = await SharedPreferences.getInstance();
      String host = prefs.getString(SharedPrefKeys.serverAddress) ?? "";
      int port = prefs.getInt(SharedPrefKeys.serverPort) ?? 1433;
      String dbName = prefs.getString(SharedPrefKeys.dbName) ?? "";
      String dbUName = prefs.getString(SharedPrefKeys.dbUName) ?? "";
      String dbUPass = prefs.getString(SharedPrefKeys.dbUPass) ?? "";
      final DbService srv = DbService(host, port, dbName, dbUName, dbUPass);

      TblDkMaterial? material = await srv.getMaterial(
          data['whId'], data['barcode']);
      List<TblDkUnit>? units = [];
      if (material != null) {
        units = await srv.getUnits(material.UnitId);
      }
      responsePort.send({
        'material': material,
        'units': units,
      });
    }
  }

  static void _saveMaterialCountEntryPoint(List<dynamic> args) async {
    final receivePort = ReceivePort();
    final sendPort = args[0] as SendPort;
    final token = args[1] as RootIsolateToken?;
    sendPort.send(receivePort.sendPort);
    if (token != null) {
      BackgroundIsolateBinaryMessenger.ensureInitialized(token);
    }
    await for (var msg in receivePort) {
      final data = msg[0];
      final responsePort = msg[1];


      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      String deviceId = await const AndroidId().getId() ?? '';
      String deviceName = '${androidInfo.brand} ${androidInfo.device}';

      final prefs = await SharedPreferences.getInstance();
      String host = prefs.getString(SharedPrefKeys.serverAddress) ?? "";
      int port = prefs.getInt(SharedPrefKeys.serverPort) ?? 1433;
      String dbName = prefs.getString(SharedPrefKeys.dbName) ?? "";
      String dbUName = prefs.getString(SharedPrefKeys.dbUName) ?? "";
      String dbUPass = prefs.getString(SharedPrefKeys.dbUPass) ?? "";
      bool newCount = prefs.getBool(SharedPrefKeys.newCount) ?? false;
      int uId = prefs.getInt(SharedPrefKeys.teacherId) ?? 0;
      final DbService srv = DbService(host, port, dbName, dbUName, dbUPass);
      double countDiff = data['countTotal'] - data['material'].WhTotalAmount;
      bool? result = await srv.addMaterial(data['material'], '$deviceId $deviceName', data['description'], countDiff, data['countTotal'], data['unitDetId'], uId, data['params'], newCount);
      // bool? result = await _srv.addMaterial(
      //     data['material'], '$deviceId $deviceName', data['description'],
      //     countDiff, data['countTotal'], data['unitDetId'], uId,
      //     {"WhType": data['WhType'], "CountDate" : data['CountDate'], "CountType" : data['CountType'], "Note1" : data['Note1'], "Note2" : data['Note2'],
      //       "WhId" : data['WhId'], "CountPass" : countPass, "WhName": data['WhName'], "UserName": data['UserName'], "DeviceName": data['DeviceName']});
      responsePort.send({
        'result': result
      });
    }
  }

  static void _loadListEntryPoint(List<dynamic> args) async {
    final receivePort = ReceivePort();
    final sendPort = args[0] as SendPort;
    final token = args[1] as RootIsolateToken?;
    sendPort.send(receivePort.sendPort);
    if (token != null) {
      BackgroundIsolateBinaryMessenger.ensureInitialized(token);
    }
    await for (var msg in receivePort) {
      final data = msg[0];
      final responsePort = msg[1];
      List<VDkMaterialCount>? materialCounts = [];
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      String deviceName = '${androidInfo.brand} ${androidInfo.device}';
      final prefs = await SharedPreferences.getInstance();
      String host = prefs.getString(SharedPrefKeys.serverAddress) ?? "";
      int port = prefs.getInt(SharedPrefKeys.serverPort) ?? 1433;
      String dbName = prefs.getString(SharedPrefKeys.dbName) ?? "";
      String dbUName = prefs.getString(SharedPrefKeys.dbUName) ?? "";
      String dbUPass = prefs.getString(SharedPrefKeys.dbUPass) ?? "";
      int userTypeId = prefs.getInt(SharedPrefKeys.userTypeId) ?? 0;
      bool newCount = prefs.getBool(SharedPrefKeys.newCount) ?? false;
      VDkMatCountParams params= data['params'] as VDkMatCountParams;
      final DbService srv = DbService(host, port, dbName, dbUName, dbUPass);
        if (params.WhType == 'opened') {
            materialCounts = await srv.getMaterialCountsForOpened(null, params, newCount);
        }
        else {
            materialCounts = await srv.getGroupMaterialCounts(null, params, newCount);
        }
        materialCounts.sort((a, b) =>
            b.MatCountDate!.compareTo(a.MatCountDate!));
        responsePort.send({
          'materialCounts': materialCounts,
          'deviceName': deviceName,
          'userTypeId': userTypeId
        });
    }
  }

  static void _saveInvoiceEntryPoint(List<dynamic> args) async {
    final receivePort = ReceivePort();
    final sendPort = args[0] as SendPort;
    final token = args[1] as RootIsolateToken?;
    sendPort.send(receivePort.sendPort);
    if (token != null) {
      BackgroundIsolateBinaryMessenger.ensureInitialized(token);
    }
    await for (var msg in receivePort) {
      final data = msg[0];
      final responsePort = msg[1];

      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      String deviceId = await const AndroidId().getId() ?? '';
      String deviceName = '${androidInfo.brand} ${androidInfo.device}';
      bool? result = true;
      bool? result2 = true;
      VDkMatCountParams params = data['params'] as VDkMatCountParams;
      final prefs = await SharedPreferences.getInstance();
      String host = prefs.getString(SharedPrefKeys.serverAddress) ?? "";
      int port = prefs.getInt(SharedPrefKeys.serverPort) ?? 1433;
      String dbName = prefs.getString(SharedPrefKeys.dbName) ?? "";
      String dbUName = prefs.getString(SharedPrefKeys.dbUName) ?? "";
      String dbUPass = prefs.getString(SharedPrefKeys.dbUPass) ?? "";
      int salesmanId = prefs.getInt(SharedPrefKeys.salesmanId) ?? 0;
      int teacherId = prefs.getInt(SharedPrefKeys.teacherId) ?? 0;
      int userTypeId = prefs.getInt(SharedPrefKeys.userTypeId) ?? 0;
      int whId = params.WhId;
      String matInvDesc = params.Note1;
      String matInvDesc2 = params.Note2;
      String countedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(params.CountDate!);
      bool newCount = prefs.getBool(SharedPrefKeys.newCount) ?? false;
      final DbService srv = DbService(host, port, dbName, dbUName, dbUPass);

      TblDkDepartment? department = await srv.getDepartment();
      TblDkDivision? division = await srv.getDivision();
      TblDkPlant? plant = await srv.getPlant();
      TblDkPeriod? period = await srv.getPeriod();

      bool allLinesSaved = true;
      List<VDkMaterialCount> eventCounts = data['counts'];
      List<VDkInvoice> lessCounts = [];
      List<VDkInvoice> moreCounts = [];
      bool isOnlyAdminDevice = data['isOnlyAdminDevice'];
      if(userTypeId!=1 || isOnlyAdminDevice==true) {
        eventCounts =
            eventCounts.where((element) => element.UserId == teacherId).toList();
      }
      else{
        eventCounts = data['counts'];
      }
      if (department != null && division != null && plant != null && period != null && data['counts'].isNotEmpty) {
        if(eventCounts.isNotEmpty){
          Map<int, List<VDkMaterialCount>> groupedElements = {};
          for (var element in eventCounts) {
            if (!groupedElements.containsKey(element.MatId)) {
              groupedElements[element.MatId] = [];
            }
            groupedElements[element.MatId]!.add(element);
          }
          for (var entry in groupedElements.entries) {
            double matDiff = 0;
            double countTotal = 0;
            double matInvTotal = 0;
            for (var element in entry.value) {
              countTotal += element.MatCountTotal;
              matDiff = countTotal - element.MatWhTotalAmount;
              matInvTotal = element.PurchasePrice * matDiff.abs();
            }
            VDkMaterialCount firstElement = entry.value[0];
            if(matDiff<0){
              lessCounts.add(VDkInvoice(MatInvTotal: matInvTotal, MatDiff: matDiff, MatCount: firstElement));
            }
            else if(matDiff>0){
              moreCounts.add(VDkInvoice(MatInvTotal: matInvTotal, MatDiff: matDiff, MatCount: firstElement));
            }
          }
          if(lessCounts.isNotEmpty){
            double innerLessTotal = 0;
            TblDkDocNum? docNum = await srv.getDocNum(teacherId, 7);
            if (docNum != null) {
              for(var element in lessCounts){
                innerLessTotal += element.MatInvTotal;
              }
              bool? result = await srv.saveInvHead(docNum.DocNum, division.DivId, department.DeptId, plant.PlantId, whId, innerLessTotal, period.PId, teacherId, salesmanId, matInvDesc, matInvDesc2, '$deviceId $deviceName', countedDate);
              if (result) {
                TblDkInvHead? invHead = await srv.getInvHead(docNum.DocNum);
                bool? savedResult = await srv.saveDocNum(docNum.DocLastNum+1, division.CId, teacherId, docNum.DocNum, 7);
                if (savedResult && invHead != null) {
                  for(var invoice in lessCounts) {
                    bool? savedInv = await srv.saveInvLine(
                        invoice.MatCount, invHead.MatInvHeadId,
                        invoice.MatInvTotal, invoice.MatDiff.abs(),
                        invoice.MatCount.DeviceId, invoice.MatCount.UName);
                    TblDkInvLine? invLine = await srv.getInvLine(
                        invoice.MatCount.MatId, invHead.MatInvHeadId);

                    if (savedInv && invLine != null) {
                      bool? savedTrans = await srv.saveTransLine(
                          invoice.MatCount, invLine.MatInvLineId,
                          invoice.MatInvTotal, plant.PlantId, invoice.MatDiff.abs(),
                          invHead.MatInvTypeId);
                      if (!savedTrans) {
                        allLinesSaved = false;
                        break;
                      }
                    } else {
                      allLinesSaved = false;
                      break;
                    }
                  }
                } else {
                  allLinesSaved = false;
                }
              } else {
                allLinesSaved = false;
              }
            } else {
              allLinesSaved = false;
            }
          }
          if(moreCounts.isNotEmpty){
            double innerMoreTotal = 0;
            TblDkDocNum? docNum = await srv.getDocNum(teacherId, 6);
            if (docNum != null) {
              for(var element in moreCounts){
                innerMoreTotal += element.MatInvTotal;
              }
              bool? result = await srv.saveInvHeadMore(docNum.DocNum, division.DivId, department.DeptId, plant.PlantId, whId, innerMoreTotal, period.PId, teacherId, salesmanId, matInvDesc, matInvDesc2, '$deviceId $deviceName', countedDate);
              if (result) {
                TblDkInvHead? invHead = await srv.getInvHead(docNum.DocNum);
                bool? savedResult = await srv.saveDocNum(docNum.DocLastNum + 1, division.CId, teacherId, docNum.DocNum, 6);
                if (savedResult && invHead != null) {
                  for (var invoice in moreCounts) {
                    bool? savedInv = await srv.saveInvLineMore(
                        invoice.MatCount,
                        invHead.MatInvHeadId,
                        invoice.MatInvTotal,
                        invoice.MatDiff.abs(),
                        invoice.MatCount.DeviceId,
                        invoice.MatCount.UName
                    );
                    TblDkInvLine? invLine = await srv.getInvLine(
                        invoice.MatCount.MatId, invHead.MatInvHeadId);

                    if (savedInv && invLine != null) {
                      bool? savedTrans = await srv.saveTransLineMore(
                          invoice.MatCount,
                          invLine.MatInvLineId,
                          invoice.MatInvTotal,
                          plant.PlantId,
                          invoice.MatDiff.abs(),
                          invHead.MatInvTypeId
                      );
                      if (!savedTrans) {
                        allLinesSaved = false;
                        break;
                      }
                    } else {
                      allLinesSaved = false;
                      break;
                    }
                  }
                }
              } else {
                allLinesSaved = false;
              }
            }
            else {
              allLinesSaved = false;
            }
          }
        }
        }
      else {
        allLinesSaved = false;
      }

      if (allLinesSaved) {
        if(userTypeId == 1 && isOnlyAdminDevice==false){
          result = await srv.deleteMaterialCount(null, params, newCount, null);
        }
        else{
          result = await srv.deleteMaterialCount('$deviceId $deviceName', params, newCount, teacherId);
        }
        if (result) {
          if(userTypeId == 1 && isOnlyAdminDevice==false){
            result2 = await srv.deleteStockCount(null, params, newCount, null);
          }
          else{
            result2 = await srv.deleteStockCount('$deviceId $deviceName', params, newCount, teacherId);
          }

          if(result2) {
            responsePort.send({'status': 'success'});
          }
          else {
            responsePort.send({'status': 'error', 'message': 'Failed to delete stock count.'});
          }
        } else {
          responsePort.send({'status': 'error', 'message': 'Failed to delete material count.'});
        }
      } else {
        responsePort.send({'status': 'error', 'message': 'There is some problem with saving invoice line or transaction line!'});
      }
    }
  }

  static Future<void> _deleteInvHeadEntryPoint(List<dynamic> args) async {
    final receivePort = ReceivePort();
    final sendPort = args[0] as SendPort;
    final token = args[1] as RootIsolateToken?;
    sendPort.send(receivePort.sendPort);

    if (token != null) {
      BackgroundIsolateBinaryMessenger.ensureInitialized(token);
    }

    await for (var msg in receivePort) {
      final data = msg[0];
      final responsePort = msg[1];

      String deviceName = '';
      String deviceId = '';
      bool? result = true;
      bool? result2 = true;
      bool? result3 = true;
      List<bool> results = [];
      try {
        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceName = '${androidInfo.brand} ${androidInfo.device}';
        deviceId = await const AndroidId().getId() ?? '';

        final prefs = await SharedPreferences.getInstance();
        String host = prefs.getString(SharedPrefKeys.serverAddress) ?? "";
        int port = prefs.getInt(SharedPrefKeys.serverPort) ?? 1433;
        String dbName = prefs.getString(SharedPrefKeys.dbName) ?? "";
        String dbUName = prefs.getString(SharedPrefKeys.dbUName) ?? "";
        String dbUPass = prefs.getString(SharedPrefKeys.dbUPass) ?? "";
        int whId = prefs.getInt(SharedPrefKeys.warehouseId) ?? 0;
        int userTypeId = prefs.getInt(SharedPrefKeys.userTypeId) ?? 0;
        DbService srv = DbService(host, port, dbName, dbUName, dbUPass);
        TblDkInvHead invHead = data['invHead'] as TblDkInvHead;
        List<VDkInvLine> invLines = await srv.getInvLinesForAdmin(whId, invHead.MatInvHeadId);
        if(userTypeId==1){
          result = await srv.deleteInvHead(null, invHead.MatInvHeadId);
          result2 = await srv.deleteInvHeadProducts(null, invHead.MatInvHeadId);
        }
        else {
          result = await srv.deleteInvHead(
              '$deviceId $deviceName', invHead.MatInvHeadId);
          result2 = await srv.deleteInvHeadProducts(
              '$deviceId $deviceName', invHead.MatInvHeadId);
        }
        if (result && result2) {
          for (var item in invLines) {
            result3 = await srv.deleteTransLine(item.MatInvLineId);
            results.add(result3);
          }
          if(results.contains(false)) {
            responsePort.send({'status': 'error', 'message': 'Error deleting transLines'});
          }
          else{
            responsePort.send({'status': 'success', 'invHead': invHead});
          }
        } else {
          responsePort.send({'status': 'error', 'message': 'Error deleting inventory head or products'});
        }
      } catch (e) {
        responsePort.send({'status': 'error', 'message': e.toString()});
      }
    }
  }

  static Future<void> _loadProductsEntryPoint(List<dynamic> args) async {
    final receivePort = ReceivePort();
    final sendPort = args[0] as SendPort;
    final token = args[1] as RootIsolateToken?;
    sendPort.send(receivePort.sendPort);

    if (token != null) {
      BackgroundIsolateBinaryMessenger.ensureInitialized(token);
    }

    await for (var msg in receivePort) {
      final data = msg[0];
      final responsePort = msg[1];
      List<VDkInvLine>? invLines=[];
      try {
        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        String deviceName = '${androidInfo.brand} ${androidInfo.device}';
        String deviceId = await const AndroidId().getId() ?? '';

        final prefs = await SharedPreferences.getInstance();
        String host = prefs.getString(SharedPrefKeys.serverAddress) ?? "";
        int port = prefs.getInt(SharedPrefKeys.serverPort) ?? 1433;
        String dbName = prefs.getString(SharedPrefKeys.dbName) ?? "";
        String dbUName = prefs.getString(SharedPrefKeys.dbUName) ?? "";
        String dbUPass = prefs.getString(SharedPrefKeys.dbUPass) ?? "";
        int userTypeId = prefs.getInt(SharedPrefKeys.userTypeId) ?? 0;
        DbService srv = DbService(host, port, dbName, dbUName, dbUPass);
        if(userTypeId==1){
          invLines = await srv.getInvLinesForAdmin(data['whId'], data['matInvHeadId']);
        }
        else {
          invLines = await srv.getInvLines(
              '$deviceId $deviceName', data['whId'], data['matInvHeadId']);
        }
        if (invLines.isNotEmpty) {
          responsePort.send({'status': 'success', 'invLines': invLines});
        } else {
          responsePort.send({'status': 'error', 'message': 'There are no products with invHeadId ${data['matInvHeadId']}'});
        }
      } catch (e) {
        responsePort.send({'status': 'error', 'message': e.toString()});
      }
    }
  }

  static Future<void> _deleteMaterialEntryPoint(List<dynamic> args) async {
    final receivePort = ReceivePort();
    final sendPort = args[0] as SendPort;
    final token = args[1] as RootIsolateToken?;
    sendPort.send(receivePort.sendPort);

    if (token != null) {
      BackgroundIsolateBinaryMessenger.ensureInitialized(token);
    }

    await for (var msg in receivePort) {
      final data = msg[0];
      final responsePort = msg[1];

      try {
        bool? result = false;
        bool? result2 = false;
        final prefs = await SharedPreferences.getInstance();
        String host = prefs.getString(SharedPrefKeys.serverAddress) ?? "";
        int port = prefs.getInt(SharedPrefKeys.serverPort) ?? 1433;
        String dbName = prefs.getString(SharedPrefKeys.dbName) ?? "";
        String dbUName = prefs.getString(SharedPrefKeys.dbUName) ?? "";
        String dbUPass = prefs.getString(SharedPrefKeys.dbUPass) ?? "";
        int userTypeId = prefs.getInt(SharedPrefKeys.userTypeId) ?? 0;
        int userId = prefs.getInt(SharedPrefKeys.teacherId) ?? 0;
        bool newCount = prefs.getBool(SharedPrefKeys.newCount) ?? false;
        DbService srv = DbService(host, port, dbName, dbUName, dbUPass);
        if(userTypeId==1){
          result = await srv.deleteSingleMatCount(
              data['userId'], data['matId'], data['params'], newCount);
        }
        else if(data['userId'] == userId){
            result = await srv.deleteSingleMatCount(
                data['userId'], data['matId'], data['params'], newCount);
        }
        else{
          result = null;
        }
        if (result != null && result) {
          if (userTypeId == 1) {
            result2 = await srv.deleteSingleStockCount(
                data['userId'], data['matId'], data['params'], newCount);
          }
          else if (data['userId'] == userId) {
            result2 = await srv.deleteSingleStockCount(
                data['userId'], data['matId'], data['params'], newCount);
          }
          else {
            result2 = null;
          }
        }
        if(result2!= null && result2 && result!= null && result) {
          responsePort.send({'status': 'success'});
        } else {
          responsePort.send({'status': 'error', 'message': 'There is some error with deleting!'});
        }
      } catch (e) {
        responsePort.send({'status': 'error', 'message': e.toString()});
      }
    }
  }

  static Future<void> _loadInvHeadsEntryPoint(List<dynamic> args) async {
    final receivePort = ReceivePort();
    final sendPort = args[0] as SendPort;
    final token = args[1] as RootIsolateToken?;
    sendPort.send(receivePort.sendPort);

    if (token != null) {
      BackgroundIsolateBinaryMessenger.ensureInitialized(token);
    }

    await for (var msg in receivePort) {
      final responsePort = msg[1];

      try {
        List<TblDkInvHead>? invHeads = [];
        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        String deviceName = '${androidInfo.brand} ${androidInfo.device}';
        String deviceId = await const AndroidId().getId() ?? '';

        final prefs = await SharedPreferences.getInstance();
        String host = prefs.getString(SharedPrefKeys.serverAddress) ?? "";
        int port = prefs.getInt(SharedPrefKeys.serverPort) ?? 1433;
        String dbName = prefs.getString(SharedPrefKeys.dbName) ?? "";
        String dbUName = prefs.getString(SharedPrefKeys.dbUName) ?? "";
        String dbUPass = prefs.getString(SharedPrefKeys.dbUPass) ?? "";
        int userTypeId = prefs.getInt(SharedPrefKeys.userTypeId) ?? 0;
        DbService srv = DbService(host, port, dbName, dbUName, dbUPass);
        if(userTypeId==1){
          invHeads = await srv.getInvHeadsForAdmin();
        }
        else {
          invHeads = await srv.getInvHeads('$deviceId $deviceName');
        }
        if (invHeads.isNotEmpty) {
          invHeads.sort((a, b) => b.MatInvDate!.compareTo(a.MatInvDate!));
          responsePort.send({'status': 'success', 'invHeads': invHeads});
        } else {
          responsePort.send({'status': 'error', 'message': 'No inventory heads found.'});
        }
      } catch (e) {
        responsePort.send({'status': 'error', 'message': e.toString()});
      }
    }
  }
}