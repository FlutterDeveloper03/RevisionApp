import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:revision_app/models/tbl_dk_inv_head.dart';
import 'package:revision_app/models/tbl_dk_department.dart';
import 'package:revision_app/models/tbl_dk_division.dart';
import 'package:revision_app/models/tbl_dk_docnum.dart';
import 'package:revision_app/models/tbl_dk_inv_line.dart';
import 'package:revision_app/models/tbl_dk_material.dart';
import 'package:revision_app/models/tbl_dk_material_count.dart';
import 'package:revision_app/models/tbl_dk_period.dart';
import 'package:revision_app/models/tbl_dk_plant.dart';
import 'package:revision_app/models/tbl_dk_unit.dart';
import 'package:revision_app/models/tbl_dk_user.dart';
import 'package:revision_app/models/tbl_dk_warehouse.dart';
import 'package:revision_app/models/v_dk_inv_line.dart';
import 'package:revision_app/models/v_dk_mat_count_params.dart';
import 'package:revision_app/models/v_dk_material_count.dart';
import 'package:revision_app/models/v_dk_materials.dart';
import 'package:sql_conn/sql_conn.dart';

class DbService {
  final String host;
  final int port;
  final String dbUName;
  final String dbUPass;
  final String dbName;

  DbService(this.host, this.port, this.dbName, this.dbUName, this.dbUPass);

  Future<int> connect() async {
    try {
      if (host.isNotEmpty && port > 0 && dbUName.isNotEmpty &&
          dbUPass.isNotEmpty && dbName.isNotEmpty) {
        await SqlConn.connect(ip: host,
            port: port.toString(),
            databaseName: dbName,
            username: dbUName,
            password: dbUPass);
        if (SqlConn.isConnected) {
          debugPrint("Connected!");
          return 1;
        } else {
          debugPrint("Print: Can't connect to db.");
          return 0;
        }
      } else {
        debugPrint(
            "Print: Can't connect to db. Some required fields are empty");
        return 0;
      }
    } catch (e) {
      debugPrint("PrintError on QueryFromDb.connect: $e");
      return 0;
    }
  }

  Future<TblDkUser?> getUserData(String uName, String uPass) async {
    String query =
    '''select Top(1) T_ID as UId, T_ID_guid as UGuid, s.firm_id as CId, s.div_id as DivId, t.arap_id as RpAccId, 1 as ResPriceGroupId, '' as URegNo,t.TName as UFullName, t.T_User_Name as UName,
		    '' as UEmail, T_User_Pass as UPass,'' as UShortName, t.salesman_id as EmpId, User_Type_ID as UTypeId
        from tbl_mg_salesman s
        left outer join Teachers t on t.salesman_id=s.salesman_id
        where user_pass_hash = HASHBYTES('SHA2_512', '$uPass'+CAST(T_ID_guid AS NVARCHAR(40)))  and (isnull(user_disabled,0)<>1) and t.T_User_Name like '${uName
        .replaceAll("'", '')}'
        FOR JSON PATH
    ''';
    if (host.isNotEmpty && port > 0 && dbUName.isNotEmpty &&
        dbUPass.isNotEmpty && dbName.isNotEmpty) {
      try {
        int connectionStatus = 1;
        if (!SqlConn.isConnected) {
          connectionStatus = await connect();
        }
        if (connectionStatus == 1) {
          var result = await SqlConn.readData(query);
          if (result != null) {
            List decoded = jsonDecode(result);
            return decoded
                .map((e) => TblDkUser.fromJson(e))
                .first;
          }
        }
      } on PlatformException catch (e) {
        debugPrint("PrintError from getUserData(): ${e.toString()}");
      } catch (e) {
        debugPrint("PrintError from getUserData(): ${e.toString()}");
        rethrow;
      }
    }
    return null;
  }

  Future<List<TblDkWarehouse>> getWarehouses() async {
    String query = '''
    select
    firm_id CId,
    div_id DivId,
    dept_id DeptId,
    isenabled UsageStatusId,
    wh_id_guid WhGuid,
    wh_id WhId,
    wh_index WhIndex,
    wh_name WhName
    from tbl_mg_whouse
    for json path
    ''';
    if (host.isNotEmpty && port > 0 && dbUName.isNotEmpty &&
        dbUPass.isNotEmpty && dbName.isNotEmpty) {
      try {
        int connectionStatus = 1;
        if (!SqlConn.isConnected) {
          connectionStatus = await connect();
        }
        if (connectionStatus == 1) {
          int connectionStatus = 1;
          if (!SqlConn.isConnected) {
            connectionStatus = await connect();
          }
          if (connectionStatus == 1) {
            var result = await SqlConn.readData(query);
            if (result != null) {
              List decoded = jsonDecode(result);
              return decoded.map((e) => TblDkWarehouse.fromMap(e)).toList();
            }
          }
        }
      } catch (e) {
        debugPrint("PrintError from getWarehouses(): ${e.toString()}");
      }
    }
    return [];
  }

  Future<TblDkMaterial?> getMaterial(int whId, String barcode) async {
    String query =
    '''select 
        material_id MatId,
        material_code MatCode,
        material_name MatName,
        unit_id UnitId,
        mat_whouseTotal_amount WhTotalAmount,
        sale_price SalePrice,
        mat_purch_price PurchasePrice,
        wh_id WhId,
        unit_det_id UnitDetId,
        bar_barcode BarcodeValue,
        unit_det_code UnitDetCode,
        spe_code SpeCode,
        group_code GroupCode,
        security_code SecurityCode
        from v_mg_materials_bar_all 
        where wh_id= $whId and bar_barcode like '$barcode'
        for json path
    ''';

    if (host.isNotEmpty && port > 0 && dbUName.isNotEmpty &&
        dbUPass.isNotEmpty && dbName.isNotEmpty) {
      try {
        int connectionStatus = 1;
        if (!SqlConn.isConnected) {
          connectionStatus = await connect();
        }
        if (connectionStatus == 1) {
          var result = await SqlConn.readData(query);
          if (result != null) {
            List decoded = jsonDecode(result);
            return decoded
                .map((e) => TblDkMaterial.fromJson(e))
                .first;
          }
        }
      } on PlatformException catch (e) {
        debugPrint("PrintError from getMaterial(): ${e.toString()}");
      } catch (e) {
        debugPrint("PrintError from getMaterial(): ${e.toString()}");
      }
    }
    return null;
  }

  Future<bool> getMatCount() async{
    String query =
    '''SELECT TOP 1 T_ID, mat_count_params 
       FROM tbl_mg_material_count
       for json path
    ''';

    if (host.isNotEmpty && port > 0 && dbUName.isNotEmpty &&
        dbUPass.isNotEmpty && dbName.isNotEmpty) {
      try {
        int connectionStatus = 1;
        if (!SqlConn.isConnected) {
          connectionStatus = await connect();
        }
        if (connectionStatus == 1) {
          var result = await SqlConn.readData(query);
          if (result != null) {
            return true;
          }
        }
      } on PlatformException catch (e) {
        if(e.message=="Invalid column name 'T_ID'." || e.message=="Invalid column name 'mat_count_params'."){
          bool added = await alterCountTable();
          if(added==true){
            return true;
          }
          else{
            debugPrint("PrintError on alterCountTable: ${e.toString()}");
            return false;
          }
        }
        debugPrint("PrintError from getMatCount(): ${e.toString()}");
      } catch (e) {
        debugPrint("PrintError from getMatCount(): ${e.toString()}");
      }
    }
    return false;
  }

  Future<bool> getStockCount() async{
    String query =
    '''SELECT TOP 1 T_ID, mat_count_params 
       FROM tbl_mg_stock_count
       for json path
    ''';

    if (host.isNotEmpty && port > 0 && dbUName.isNotEmpty &&
        dbUPass.isNotEmpty && dbName.isNotEmpty) {
      try {
        int connectionStatus = 1;
        if (!SqlConn.isConnected) {
          connectionStatus = await connect();
        }
        if (connectionStatus == 1) {
          var result = await SqlConn.readData(query);
          if (result != null) {
            return true;
          }
        }
      } on PlatformException catch (e) {
        if(e.message=="Invalid column name 'T_ID'." || e.message=="Invalid column name 'mat_count_params'."){
          bool added = await alterStockCountTable();
          bool triggerAltered = await alterStockCountTrigger();
          if(added==true && triggerAltered==true){
            return true;
          }
          else{
            debugPrint("PrintError on alterStockCountTable or alterStockTrigger: ${e.toString()}");
            return false;
          }
        }
        debugPrint("PrintError from getStockCount(): ${e.toString()}");
      } catch (e) {
        debugPrint("PrintError from getStockCount(): ${e.toString()}");
      }
    }
    return false;
  }

  Future<bool> alterCountTable() async{
    if (host.isNotEmpty && port > 0 && dbUName.isNotEmpty &&
        dbUPass.isNotEmpty && dbName.isNotEmpty) {
      try {
        int connectionStatus = 1;
        if (!SqlConn.isConnected) {
          connectionStatus = await connect();
        }
        if (connectionStatus == 1) {
          var result = await SqlConn.writeData("""
        ALTER TABLE tbl_mg_material_count
        ADD T_ID INT, mat_count_params NVARCHAR(MAX);
        """);
          if (result != null) {
            return true;
          }
        }
      }on PlatformException catch (e) {
        if(e.message=="Column names in each table must be unique. Column name 'T_ID' in table 'tbl_mg_material_count' is specified more than once."){
          return true;
        }
        else if(e.message=="Column names in each table must be unique. Column name 'mat_count_params' in table 'tbl_mg_material_count' is specified more than once."){
          return true;
        }
        debugPrint("PrintError from alterCountTable(): ${e.toString()}");
      }catch(e){
        debugPrint("PrintError on alterCountTable: ${e.toString()}");
        rethrow;
      }
    }
    return false;
  }

  Future<bool> alterStockCountTable() async{
    if (host.isNotEmpty && port > 0 && dbUName.isNotEmpty &&
        dbUPass.isNotEmpty && dbName.isNotEmpty) {
      try {
        int connectionStatus = 1;
        if (!SqlConn.isConnected) {
          connectionStatus = await connect();
        }
        if (connectionStatus == 1) {
          var result = await SqlConn.writeData("""
        ALTER TABLE tbl_mg_stock_count
        ADD T_ID INT, mat_count_params NVARCHAR(MAX);
        """);
          if (result != null) {
            return true;
          }
        }
      }on PlatformException catch (e) {
        if(e.message=="Column names in each table must be unique. Column name 'T_ID' in table 'tbl_mg_stock_count' is specified more than once."){
          return true;
        }
        else if(e.message=="Column names in each table must be unique. Column name 'mat_count_params' in table 'tbl_mg_stock_count' is specified more than once."){
          return true;
        }
        debugPrint("PrintError from alterStockCountTable(): ${e.toString()}");
      }catch(e){
        debugPrint("PrintError on alterStockCountTable: ${e.toString()}");
        rethrow;
      }
    }
    return false;
  }

  Future<bool> alterStockCountTrigger() async{
    if (host.isNotEmpty && port > 0 && dbUName.isNotEmpty &&
        dbUPass.isNotEmpty && dbName.isNotEmpty) {
      try {
        int connectionStatus = 1;
        if (!SqlConn.isConnected) {
          connectionStatus = await connect();
        }
        if (connectionStatus == 1) {
          var result = await SqlConn.writeData("""
        ALTER TRIGGER [dbo].[trg_mat_count_insert] 
   ON  [dbo].[tbl_mg_material_count]
   AFTER insert
AS 
BEGIN

	SET NOCOUNT ON; 

	DECLARE @material_id INT 
	SELECT @material_id = i.material_id FROM Inserted i
    INSERT INTO dbo.tbl_mg_stock_count
    (
        material_id,
        bar_barcode,
        scan_date,
        scan_amount,
        scan_price,
        scan_fich,
        scan_machine,
        wh_id,
        mat_whousetotal_amount,
        scan_id_guid,
		mat_count_params,
		T_ID
    )
    select 
	i.material_id,'',
	i.material_count_date,
	i.material_count_total,
	0,
	'',
	i.device_id,
	1,
    i.wh_0,
	NEWID(),
	mat_count_params,
	T_ID
	FROM Inserted i

	UPDATE dbo.tbl_mg_materials
	SET spe_code15 = ''
	WHERE material_id = @material_id

END

        """);
          if (result != null) {
            return true;
          }
        }
      }on PlatformException catch (e) {
        if(e.message=="Column names in each table must be unique. Column name 'T_ID' in table 'tbl_mg_stock_count' is specified more than once."){
          return true;
        }
        else if(e.message=="Column names in each table must be unique. Column name 'mat_count_params' in table 'tbl_mg_stock_count' is specified more than once."){
          return true;
        }
        debugPrint("PrintError from alterStockCountTrigger(): ${e.toString()}");
      }catch(e){
        debugPrint("PrintError on alterStockCountTrigger(): ${e.toString()}");
        rethrow;
      }
    }
    return false;
  }

  Future<bool> addMaterial(TblDkMaterial material, String deviceId,String desc, double countDiff,double countTotal, int unitDetId, int uId, VDkMatCountParams params, bool newCount) async {
    String dateFormatter = DateFormat("yyyy-MM-dd HH:mm:ss").format(params.CountDate!);
    String query = '';
    if(newCount) {
      query = '''insert into tbl_mg_material_count
                          (material_id
                          ,material_count_total
                          ,material_count_date
                          ,material_count_diff
                          ,device_id
                          ,material_count_desc
                          ,wh_id
                          ,unit_det_id
                          ,mat_whousetotal_amount
                          ,count_id_guid
                          ,T_ID
                          ,mat_count_params
                          )
                         VALUES
                           ('${material.MatId}'
                           ,'$countTotal'
                           ,GETDATE()
                           ,'$countDiff'
                           ,'$deviceId'
                           ,'$desc'
                           ,'${material.WhId}'
                           ,'$unitDetId'
                           ,${material.WhTotalAmount}
                           ,NEWID()
                           ,'$uId'
                           ,'{ "WhType": "${params.WhType}", "CountDate": "$dateFormatter", "CountType": "${params.CountType}", "Note1": "${params.Note1}", "Note2": "${params.Note2}",  "WhId": ${params.WhId}, "WhName": "${params.WhName}", "UserName": "${params.UserName}", "DeviceName": "${params.DeviceName}", "CountPass": "' + CONVERT(varchar(128), HASHBYTES('SHA2_512', '${params.CountPass}'), 2) + '" }')
                    ''';
    }
    else{
      query = '''insert into tbl_mg_material_count
                          (material_id
                          ,material_count_total
                          ,material_count_date
                          ,material_count_diff
                          ,device_id
                          ,material_count_desc
                          ,wh_id
                          ,unit_det_id
                          ,mat_whousetotal_amount
                          ,count_id_guid
                          ,T_ID
                          ,mat_count_params
                          )
                         VALUES
                           ('${material.MatId}'
                           ,'$countTotal'
                           ,GETDATE()
                           ,'$countDiff'
                           ,'$deviceId'
                           ,'$desc'
                           ,'${material.WhId}'
                           ,'$unitDetId'
                           ,${material.WhTotalAmount}
                           ,NEWID()
                           ,'$uId'
                           ,'{ "WhType": "${params.WhType}", "CountDate": "$dateFormatter", "CountType": "${params.CountType}", "Note1": "${params.Note1}", "Note2": "${params.Note2}",  "WhId": ${params.WhId}, "WhName": "${params.WhName}", "UserName": "${params.UserName}", "DeviceName": "${params.DeviceName}", "CountPass": "${params.CountPass}" }')
                    ''';
    }

    if (host.isNotEmpty && port > 0 && dbUName.isNotEmpty && dbUPass.isNotEmpty && dbName.isNotEmpty) {
      debugPrint("Generated query in add material: $query");
      try {
        int connectionStatus = 1;
        if (!SqlConn.isConnected) {
          connectionStatus = await connect();
        }
        if (connectionStatus == 1) {
          var result = await SqlConn.writeData(query);
          return result;
        }
      } on PlatformException catch (e) {
        debugPrint("PrintError from addMaterial(): ${e.toString()}");
      } catch (e) {
        debugPrint("PrintError from addMaterial(): ${e.toString()}");
        rethrow;
      }
    }
    return false;
  }

  Future<bool> addMaterialForZero(VDkMaterials material, String deviceId,String desc, double countDiff,double countTotal, int unitDetId, int uId, VDkMatCountParams params, bool newCount) async {
    String dateFormatter = DateFormat("yyyy-MM-dd HH:mm:ss").format(params.CountDate!);
    String query = '';
    if(newCount){
      query = '''insert into tbl_mg_material_count
                          (material_id
                          ,material_count_total
                          ,material_count_date
                          ,material_count_diff
                          ,device_id
                          ,material_count_desc
                          ,wh_id
                          ,unit_det_id
                          ,mat_whousetotal_amount
                          ,count_id_guid
                          ,T_ID
                          ,mat_count_params
                          )
                         VALUES
                           ('${material.MatId}'
                           ,'$countTotal'
                           ,GETDATE()
                           ,'$countDiff'
                           ,'$deviceId'
                           ,'$desc'
                           ,'${material.WhId}'
                           ,'$unitDetId'
                           ,${material.MatWhTotalAmount}
                           ,NEWID()
                           ,'$uId'
                           ,'{ "WhType": "${params.WhType}", "CountDate": "$dateFormatter", "CountType": "${params.CountType}", "Note1": "${params.Note1}", "Note2": "${params.Note2}",  "WhId": ${params.WhId}, "WhName": "${params.WhName}", "UserName": "${params.UserName}",  "DeviceName": "${params.DeviceName}", "CountPass": "' + CONVERT(varchar(128), HASHBYTES('SHA2_512', '${params.CountPass}'), 2) + '" }')
                    ''';
    }
    else {
      query = '''insert into tbl_mg_material_count
                          (material_id
                          ,material_count_total
                          ,material_count_date
                          ,material_count_diff
                          ,device_id
                          ,material_count_desc
                          ,wh_id
                          ,unit_det_id
                          ,mat_whousetotal_amount
                          ,count_id_guid
                          ,T_ID
                          ,mat_count_params
                          )
                         VALUES
                           ('${material.MatId}'
                           ,'$countTotal'
                           ,GETDATE()
                           ,'$countDiff'
                           ,'$deviceId'
                           ,'$desc'
                           ,'${material.WhId}'
                           ,'$unitDetId'
                           ,${material.MatWhTotalAmount}
                           ,NEWID()
                           ,'$uId'
                           ,'{ "WhType": "${params.WhType}", "CountDate": "$dateFormatter", "CountType": "${params.CountType}", "Note1": "${params.Note1}", "Note2": "${params.Note2}",  "WhId": ${params.WhId}, "WhName": "${params.WhName}", "UserName": "${params.UserName}",  "DeviceName": "${params.DeviceName}", "CountPass": "${params.CountPass}" }')
                    ''';
    }

    if (host.isNotEmpty && port > 0 && dbUName.isNotEmpty && dbUPass.isNotEmpty && dbName.isNotEmpty) {
      debugPrint("Generated query in add material for zero: $query");
      try {
        int connectionStatus = 1;
        if (!SqlConn.isConnected) {
          connectionStatus = await connect();
        }
        if (connectionStatus == 1) {
          var result = await SqlConn.writeData(query);
          return result;
        }
      } on PlatformException catch (e) {
        debugPrint("PrintError from addMaterialForZero(): ${e.toString()}");
      } catch (e) {
        debugPrint("PrintError from addMaterialForZero(): ${e.toString()}");
        rethrow;
      }
    }
    return false;
  }

  Future<List<VDkMaterialCount>> getMaterialCountsForOpened(String? deviceId, VDkMatCountParams params, bool newCount) async{
    String dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss').format(params.CountDate!);
    String query = "";
    if(newCount) {
      query = '''
    SELECT
    mb.material_name AS MatName,
    mb.material_id AS MatId,
    mb.material_code AS MatCode,
    mb.unit_id AS UnitId,
    mb.sale_price AS SalePrice,
    mb.mat_purch_price AS PurchasePrice,
    mb.wh_id AS WhId,
    mb.unit_det_id AS UnitDetId,
    mb.bar_barcode AS BarcodeValue,
    mb.unit_det_code AS UnitDetCode,
    mb.spe_code AS SpeCode,
    mb.group_code AS GroupCode,
    mb.security_code AS SecurityCode,
    t.T_User_Name as UName,
    t.T_ID as UserId,
    latest.mc_mat_whousetotal_amount AS MatWhTotalAmount,
    SUM(mc.material_count_total) AS MatCountTotal,
    MAX(mc.material_count_date) AS MatCountDate,
    MAX(mc.material_count_diff) AS MatCountDiff,
    MAX(mc.material_count_desc) AS MatCountDescription,   
    MAX(mc.count_id_guid) AS CountIdGuid,
    MAX(mc.count_id) AS CountId,
    MAX(mc.device_id) AS DeviceId,
    mc.mat_count_params AS MatCountParams
FROM tbl_mg_material_count mc
LEFT OUTER JOIN v_mg_materials_bar_all mb ON mb.material_id = mc.material_id AND mb.wh_id = ${params.WhId}
LEFT OUTER JOIN dbo.Teachers t on t.T_ID = mc.T_ID
LEFT JOIN (
    SELECT
        material_id,
        MAX(material_count_date) AS latest_date,
        mat_whousetotal_amount AS mc_mat_whousetotal_amount
    FROM tbl_mg_material_count
    GROUP BY material_id, mat_whousetotal_amount
) latest ON mc.material_id = latest.material_id AND mc.material_count_date = latest.latest_date
WHERE JSON_VALUE(mc.mat_count_params, '\$.WhType') = '${params.WhType}'
    AND JSON_VALUE(mc.mat_count_params, '\$.CountDate') = '$dateFormatter'
    AND JSON_VALUE(mc.mat_count_params, '\$.CountType') = '${params.CountType}'
    AND JSON_VALUE(mc.mat_count_params, '\$.WhId') = ${params.WhId}
    AND JSON_VALUE(mc.mat_count_params, '\$.CountPass') = CONVERT(varchar(128), HASHBYTES('SHA2_512', '${params.CountPass}'), 2)
    AND JSON_VALUE(mc.mat_count_params, '\$.Note1') = '${params.Note1}'
    AND JSON_VALUE(mc.mat_count_params, '\$.Note2') = '${params.Note2}'
    AND JSON_VALUE(mc.mat_count_params, '\$.WhName') = '${params.WhName}'
GROUP BY
    mb.material_name,
    mb.material_id,
    mb.material_code,
    mb.unit_id,
    mb.sale_price,
    mb.mat_purch_price,
    mb.wh_id,
    mb.unit_det_id,
    mb.bar_barcode,
    mb.unit_det_code,
    mb.spe_code,
    mb.group_code,
    mb.security_code,
    latest.mc_mat_whousetotal_amount,
    t.T_User_Name,
    t.T_ID,
    mc.mat_count_params
    for json path;
    ''';
    }
    else{
      query = '''
    SELECT
    mb.material_name AS MatName,
    mb.material_id AS MatId,
    mb.material_code AS MatCode,
    mb.unit_id AS UnitId,
    mb.sale_price AS SalePrice,
    mb.mat_purch_price AS PurchasePrice,
    mb.wh_id AS WhId,
    mb.unit_det_id AS UnitDetId,
    mb.bar_barcode AS BarcodeValue,
    mb.unit_det_code AS UnitDetCode,
    mb.spe_code AS SpeCode,
    mb.group_code AS GroupCode,
    mb.security_code AS SecurityCode,
    t.T_User_Name as UName,
    t.T_ID as UserId,
    latest.mc_mat_whousetotal_amount AS MatWhTotalAmount,
    SUM(mc.material_count_total) AS MatCountTotal,
    MAX(mc.material_count_date) AS MatCountDate,
    MAX(mc.material_count_diff) AS MatCountDiff,
    MAX(mc.material_count_desc) AS MatCountDescription,   
    MAX(mc.count_id_guid) AS CountIdGuid,
    MAX(mc.count_id) AS CountId,
    MAX(mc.device_id) AS DeviceId,
    mc.mat_count_params AS MatCountParams
FROM tbl_mg_material_count mc
LEFT OUTER JOIN v_mg_materials_bar_all mb ON mb.material_id = mc.material_id AND mb.wh_id = ${params.WhId}
LEFT OUTER JOIN dbo.Teachers t on t.T_ID = mc.T_ID
LEFT JOIN (
    SELECT
        material_id,
        MAX(material_count_date) AS latest_date,
        mat_whousetotal_amount AS mc_mat_whousetotal_amount
    FROM tbl_mg_material_count
    GROUP BY material_id, mat_whousetotal_amount
) latest ON mc.material_id = latest.material_id AND mc.material_count_date = latest.latest_date
WHERE JSON_VALUE(mc.mat_count_params, '\$.WhType') = '${params.WhType}'
    AND JSON_VALUE(mc.mat_count_params, '\$.CountDate') = '$dateFormatter'
    AND JSON_VALUE(mc.mat_count_params, '\$.CountType') = '${params.CountType}'
    AND JSON_VALUE(mc.mat_count_params, '\$.WhId') = ${params.WhId}
    AND JSON_VALUE(mc.mat_count_params, '\$.CountPass') = '${params.CountPass}'
    AND JSON_VALUE(mc.mat_count_params, '\$.Note1') = '${params.Note1}'
    AND JSON_VALUE(mc.mat_count_params, '\$.Note2') = '${params.Note2}'
    AND JSON_VALUE(mc.mat_count_params, '\$.WhName') = '${params.WhName}'
GROUP BY
    mb.material_name,
    mb.material_id,
    mb.material_code,
    mb.unit_id,
    mb.sale_price,
    mb.mat_purch_price,
    mb.wh_id,
    mb.unit_det_id,
    mb.bar_barcode,
    mb.unit_det_code,
    mb.spe_code,
    mb.group_code,
    mb.security_code,
    latest.mc_mat_whousetotal_amount,
    t.T_User_Name,
    t.T_ID,
    mc.mat_count_params
    for json path;
    ''';
    }
    if (host.isNotEmpty && port > 0 && dbUName.isNotEmpty &&
        dbUPass.isNotEmpty && dbName.isNotEmpty) {
      try {
        int connectionStatus = 1;
        if (!SqlConn.isConnected) {
          connectionStatus = await connect();
        }
        if (connectionStatus == 1) {
          int connectionStatus = 1;
          if (!SqlConn.isConnected) {
            connectionStatus = await connect();
          }
          if (connectionStatus == 1) {
            var result = await SqlConn.readData(query);
            if (result != null) {
              List decoded = jsonDecode(result);
              return decoded.map((e) => VDkMaterialCount.fromMap(e)).toList();
            }
          }
        }
      } catch (e) {
        debugPrint("PrintError from getMaterialCountsForOpened(): ${e.toString()}");
      }
    }
    return [];
  }

  Future<List<TblDkUnit>> getUnits(int unitId) async{
    String query = '''
    select
     unit_det_id UnitDetId 
    ,unit_det_code UnitDetCode
    ,unit_id UnitId
    ,unit_det_id_guid UnitDetIdGuid
    ,unit_id_guid UnitIdGuid
    from tbl_mg_unit_det
    where unit_id= $unitId
    for json path
    ''';
    if (host.isNotEmpty && port > 0 && dbUName.isNotEmpty &&
        dbUPass.isNotEmpty && dbName.isNotEmpty) {
      try {
        int connectionStatus = 1;
        if (!SqlConn.isConnected) {
          connectionStatus = await connect();
        }
        if (connectionStatus == 1) {
          int connectionStatus = 1;
          if (!SqlConn.isConnected) {
            connectionStatus = await connect();
          }
          if (connectionStatus == 1) {
            var result = await SqlConn.readData(query);
            if (result != null) {
              List decoded = jsonDecode(result);
              return decoded.map((e) => TblDkUnit.fromMap(e)).toList();
            }
          }
        }
      } catch (e) {
        debugPrint("PrintError from getUnits(): ${e.toString()}");
      }
    }
    return [];
  }

  Future<bool> updateMaterialCount(VDkMaterialCount materialCount, double countTotal) async {
    debugPrint("Json of count in updateMaterialCount: ${materialCount.toJson()}");
    String query = '''
     UPDATE tbl_mg_material_count
              SET [material_count_total] = $countTotal
                           WHERE count_id=${materialCount.CountId} and count_id_guid = '${materialCount.CountIdGuid}'
                    ''';
    if (host.isNotEmpty && port > 0 && dbUName.isNotEmpty && dbUPass.isNotEmpty && dbName.isNotEmpty) {
      debugPrint("Generated query: $query");
      try {
        int connectionStatus = 1;
        if (!SqlConn.isConnected) {
          connectionStatus = await connect();
        }
        if (connectionStatus == 1) {
          var result = await SqlConn.writeData(query);
          return result;
        }
      }catch (e) {
        debugPrint("PrintError from updateMaterialCount(): ${e.toString()}");
        rethrow;
      }
    }
    return false;
  }

  Future<bool> updateStockCount(VDkMaterialCount materialCount, double countTotal) async {
    String query = '''
     UPDATE tbl_mg_stock_count
              SET [scan_amount] = $countTotal
                           WHERE scan_date = '${materialCount.MatCountDate}' 
                           AND scan_machine = '${materialCount.DeviceId}'
                           AND T_ID = '${materialCount.UserId}'
                    ''';
    if (host.isNotEmpty && port > 0 && dbUName.isNotEmpty && dbUPass.isNotEmpty && dbName.isNotEmpty) {
      try {
        int connectionStatus = 1;
        if (!SqlConn.isConnected) {
          connectionStatus = await connect();
        }
        if (connectionStatus == 1) {
          var result = await SqlConn.writeData(query);
          return result;
        }
      }catch (e) {
        debugPrint("PrintError from updateStockCount(): ${e.toString()}");
        rethrow;
      }
    }
    return false;
  }

  Future<List<VDkMaterialCount>> getGroupMaterialCounts(String? deviceId, VDkMatCountParams params, bool newCount) async{
    String dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss').format(params.CountDate!);
    debugPrint("Json of params: ${params.toJson()}");
    String query ="";
    if(newCount) {
      query = '''
    SELECT
    mb.material_name AS MatName,
    mb.material_id AS MatId,
    mb.material_code AS MatCode,
    mb.unit_id AS UnitId,
    mb.sale_price AS SalePrice,
    mb.mat_purch_price AS PurchasePrice,
    mb.wh_id AS WhId,
    mb.unit_det_id AS UnitDetId,
    mb.bar_barcode AS BarcodeValue,
    mb.unit_det_code AS UnitDetCode,
    mb.spe_code AS SpeCode,
    mb.group_code AS GroupCode,
    mb.security_code AS SecurityCode,
    mb.mat_whousetotal_amount AS MatWhTotalAmount,
    t.T_User_Name as UName,
    t.T_ID as UserId,
    SUM(mc.material_count_total) AS MatCountTotal,
    MAX(mc.material_count_date) AS MatCountDate,
    MAX(mc.material_count_diff) AS MatCountDiff,
    MAX(mc.material_count_desc) AS MatCountDescription,       
    MAX(mc.count_id_guid) AS CountIdGuid,
    MAX(mc.count_id) AS CountId,
    MAX(mc.device_id) AS DeviceId,
    mc.mat_count_params AS MatCountParams
FROM tbl_mg_material_count mc
LEFT OUTER JOIN v_mg_materials_bar_all mb ON mb.material_id = mc.material_id AND mb.wh_id = ${params.WhId}
LEFT OUTER JOIN dbo.Teachers t on t.T_ID = mc.T_ID
where JSON_VALUE(mc.mat_count_params, '\$.WhType') = '${params.WhType}'
    AND JSON_VALUE(mc.mat_count_params, '\$.CountDate') = '$dateFormatter'
    AND JSON_VALUE(mc.mat_count_params, '\$.CountType') = '${params.CountType}'
    AND JSON_VALUE(mc.mat_count_params, '\$.WhId') = ${params.WhId}
    AND JSON_VALUE(mc.mat_count_params, '\$.CountPass') = CONVERT(varchar(128), HASHBYTES('SHA2_512', '${params.CountPass}'), 2)
    AND JSON_VALUE(mc.mat_count_params, '\$.Note1') = '${params.Note1}'
    AND JSON_VALUE(mc.mat_count_params, '\$.Note2') = '${params.Note2}'
    AND JSON_VALUE(mc.mat_count_params, '\$.WhName') = '${params.WhName}' 
GROUP BY
    mb.material_name,
    mb.material_id,
    mb.material_code,
    mb.unit_id,
    mb.sale_price,
    mb.mat_purch_price,
    mb.wh_id,
    mb.unit_det_id,
    mb.bar_barcode,
    mb.unit_det_code,
    mb.spe_code,
    mb.group_code,
    mb.security_code,
    mb.mat_whousetotal_amount,
    t.T_User_Name,
    t.T_ID,
    mc.mat_count_params
    for json path;
    ''';
    }
    else{
      query = '''
    SELECT
    mb.material_name AS MatName,
    mb.material_id AS MatId,
    mb.material_code AS MatCode,
    mb.unit_id AS UnitId,
    mb.sale_price AS SalePrice,
    mb.mat_purch_price AS PurchasePrice,
    mb.wh_id AS WhId,
    mb.unit_det_id AS UnitDetId,
    mb.bar_barcode AS BarcodeValue,
    mb.unit_det_code AS UnitDetCode,
    mb.spe_code AS SpeCode,
    mb.group_code AS GroupCode,
    mb.security_code AS SecurityCode,
    mb.mat_whousetotal_amount AS MatWhTotalAmount,
    t.T_User_Name as UName,
    t.T_ID as UserId,
    SUM(mc.material_count_total) AS MatCountTotal,
    MAX(mc.material_count_date) AS MatCountDate,
    MAX(mc.material_count_diff) AS MatCountDiff,
    MAX(mc.material_count_desc) AS MatCountDescription,       
    MAX(mc.count_id_guid) AS CountIdGuid,
    MAX(mc.count_id) AS CountId,
    MAX(mc.device_id) AS DeviceId,
    mc.mat_count_params AS MatCountParams
FROM tbl_mg_material_count mc
LEFT OUTER JOIN v_mg_materials_bar_all mb 
    ON mb.material_id = mc.material_id 
    AND mb.wh_id = '${params.WhId}'
LEFT OUTER JOIN dbo.Teachers t 
    ON t.T_ID = mc.T_ID
WHERE JSON_VALUE(mc.mat_count_params, '\$.WhType') = '${params.WhType}'
    AND JSON_VALUE(mc.mat_count_params, '\$.CountDate') = '$dateFormatter'
    AND JSON_VALUE(mc.mat_count_params, '\$.CountType') = '${params.CountType}'
    AND JSON_VALUE(mc.mat_count_params, '\$.WhId') = ${params.WhId}
    AND JSON_VALUE(mc.mat_count_params, '\$.CountPass') = '${params.CountPass}'
    AND JSON_VALUE(mc.mat_count_params, '\$.Note1') = '${params.Note1}'
    AND JSON_VALUE(mc.mat_count_params, '\$.Note2') = '${params.Note2}'
    AND JSON_VALUE(mc.mat_count_params, '\$.WhName') = '${params.WhName}'    
GROUP BY
    mb.material_name,
    mb.material_id,
    mb.material_code,
    mb.unit_id,
    mb.sale_price,
    mb.mat_purch_price,
    mb.wh_id,
    mb.unit_det_id,
    mb.bar_barcode,
    mb.unit_det_code,
    mb.spe_code,
    mb.group_code,
    mb.security_code,
    mb.mat_whousetotal_amount,
    t.T_User_Name,
    t.T_ID,
    mc.mat_count_params
    for json path;
    ''';
    }
    if (host.isNotEmpty && port > 0 && dbUName.isNotEmpty &&
        dbUPass.isNotEmpty && dbName.isNotEmpty) {
      try {
        int connectionStatus = 1;
        if (!SqlConn.isConnected) {
          connectionStatus = await connect();
        }
        if (connectionStatus == 1) {
          int connectionStatus = 1;
          if (!SqlConn.isConnected) {
            connectionStatus = await connect();
          }
          if (connectionStatus == 1) {
            var result = await SqlConn.readData(query);
            if (result != null) {
              List decoded = jsonDecode(result);
              return decoded.map((e) => VDkMaterialCount.fromMap(e)).toList();
            }
          }
        }
      } catch (e) {
        debugPrint("PrintError from getGroupMaterialCounts(): ${e.toString()}");
      }
    }
    return [];
  }

  Future<TblDkDepartment?> getDepartment() async {
    String query =
    '''select 
        dept_id DeptId,
        dept_name DeptName,
        firm_id CId,
        dept_id_guid DeptIdGuid
        from tbl_mg_department 
        for json path
    ''';

    if (host.isNotEmpty && port > 0 && dbUName.isNotEmpty &&
        dbUPass.isNotEmpty && dbName.isNotEmpty) {
      try {
        int connectionStatus = 1;
        if (!SqlConn.isConnected) {
          connectionStatus = await connect();
        }
        if (connectionStatus == 1) {
          var result = await SqlConn.readData(query);
          if (result != null) {
            List decoded = jsonDecode(result);
            return decoded
                .map((e) => TblDkDepartment.fromJson(e))
                .first;
          }
        }
      } on PlatformException catch (e) {
        debugPrint("PrintError from getDepartment(): ${e.toString()}");
      } catch (e) {
        debugPrint("PrintError from getDepartment(): ${e.toString()}");
      }
    }
    return null;
  }

  Future<TblDkDivision?> getDivision() async {
    String query =
    '''select 
        div_id DivId,
        div_name DivName,
        firm_id CId,
        div_id_guid DivIdGuid
        from tbl_mg_division 
        for json path
    ''';

    if (host.isNotEmpty && port > 0 && dbUName.isNotEmpty &&
        dbUPass.isNotEmpty && dbName.isNotEmpty) {
      try {
        int connectionStatus = 1;
        if (!SqlConn.isConnected) {
          connectionStatus = await connect();
        }
        if (connectionStatus == 1) {
          var result = await SqlConn.readData(query);
          if (result != null) {
            List decoded = jsonDecode(result);
            return decoded
                .map((e) => TblDkDivision.fromJson(e))
                .first;
          }
        }
      } on PlatformException catch (e) {
        debugPrint("PrintError from getDivision(): ${e.toString()}");
      } catch (e) {
        debugPrint("PrintError from getDivision(): ${e.toString()}");
      }
    }
    return null;
  }

  Future<TblDkPlant?> getPlant() async {
    String query =
    '''select 
        plant_id PlantId,
        plant_name PlantName,
        firm_id CId,
        plant_id_guid PlantIdGuid
        from tbl_mg_plant 
        for json path
    ''';

    if (host.isNotEmpty && port > 0 && dbUName.isNotEmpty &&
        dbUPass.isNotEmpty && dbName.isNotEmpty) {
      try {
        int connectionStatus = 1;
        if (!SqlConn.isConnected) {
          connectionStatus = await connect();
        }
        if (connectionStatus == 1) {
          var result = await SqlConn.readData(query);
          if (result != null) {
            List decoded = jsonDecode(result);
            return decoded
                .map((e) => TblDkPlant.fromJson(e))
                .first;
          }
        }
      } on PlatformException catch (e) {
        debugPrint("PrintError from getPlant(): ${e.toString()}");
      } catch (e) {
        debugPrint("PrintError from getPlant(): ${e.toString()}");
      }
    }
    return null;
  }

  Future<TblDkPeriod?> getPeriod() async {
    String query =
    '''select 
        p_id PId,
        p_start_date PStartDate,
        p_end_date PEndDate,
        firm_id CId,
        p_id_guid PIdGuid
        from tbl_mg_period 
        for json path
    ''';

    if (host.isNotEmpty && port > 0 && dbUName.isNotEmpty &&
        dbUPass.isNotEmpty && dbName.isNotEmpty) {
      try {
        int connectionStatus = 1;
        if (!SqlConn.isConnected) {
          connectionStatus = await connect();
        }
        if (connectionStatus == 1) {
          var result = await SqlConn.readData(query);
          if (result != null) {
            List decoded = jsonDecode(result);
            return decoded
                .map((e) => TblDkPeriod.fromJson(e))
                .first;
          }
        }
      } on PlatformException catch (e) {
        debugPrint("PrintError from getPeriod(): ${e.toString()}");
      } catch (e) {
        debugPrint("PrintError from getPeriod(): ${e.toString()}");
      }
    }
    return null;
  }

  Future<TblDkDocNum?> getDocNum(int tId,int sectionId) async {
    String query =
    '''
    CREATE TABLE #TempResult (doc_id int, doc_lastnum int, doc_format NVARCHAR(25), docnum NVARCHAR(25));
    INSERT INTO #TempResult
    exec sp_mg_getdocnum @module_id=5,@section_id='$sectionId',@firm_id=1,@T_ID='$tId',@div_id=0,@plant_id=0,@wh_id=0 
    SELECT * FROM #TempResult
    FOR JSON PATH;
    DROP TABLE #TempResult;
     ''';

    if (host.isNotEmpty && port > 0 && dbUName.isNotEmpty &&
        dbUPass.isNotEmpty && dbName.isNotEmpty) {
      try {
        int connectionStatus = 1;
        if (!SqlConn.isConnected) {
          connectionStatus = await connect();
        }
        if (connectionStatus == 1) {
          var result = await SqlConn.readData(query);
          if (result != null) {
            List decoded = jsonDecode(result);
            return decoded
                .map((e) => TblDkDocNum.fromJson(e))
                .first;
          }
        }
      } on PlatformException catch (e) {
        debugPrint("PrintError from getDocNum(): ${e.toString()}");
      } catch (e) {
        debugPrint("PrintError from getDocNum(): ${e.toString()}");
      }
    }
    return null;
  }

  Future<bool> saveInvHead(String docNum, int divId, int deptId, int plantId, int whId, double matInvTotal, int pId, int teacherId, int salesmanId, String matInvDesc, String matInvDesc2, String deviceId, String countedDate) async {
    String query = '''insert into tbl_mg_mat_inv_head
                          (mat_inv_code
                          ,mat_inv_date
                          ,mat_inv_docno
                          ,out_div_id
                          ,out_dept_id
                          ,out_plant_id
                          ,out_wh_id
                          ,in_div_id
                          ,in_dept_id
                          ,in_plant_id
                          ,in_wh_id
                          ,mat_inv_total
                          ,p_id
                          ,mat_inv_type_id
                          ,mat_inv_desc
                          ,spe_code
                          ,group_code
                          ,security_code
                          ,inv_id_auto_gen
                          ,salesman_id
                          ,T_ID
                          ,project_id
                         )
                         VALUES
                           ('$docNum',
                            '$countedDate',
                           'revision_app kemlik',
                           '$divId', 
                           '$deptId',
                           '$plantId',  
                           '$whId',
                           '0', 
                           '0',
                           '0',  
                           '0',
                           '$matInvTotal',
                           '$pId',
                           '14', 
                           '$matInvDesc', 
                           '$deviceId',
                           '$matInvDesc2',
                           '',
                           '0',
                           '$salesmanId',
                           '$teacherId',
                           '0'       
                           )
                    ''';

    if (host.isNotEmpty && port > 0 && dbUName.isNotEmpty && dbUPass.isNotEmpty && dbName.isNotEmpty) {
      try {
        int connectionStatus = 1;
        if (!SqlConn.isConnected) {
          connectionStatus = await connect();
        }
        if (connectionStatus == 1) {
          var result = await SqlConn.writeData(query);
          return result;
        }
      } on PlatformException catch (e) {
        debugPrint("PrintError from saveInvHead(): ${e.toString()}");
      } catch (e) {
        debugPrint("PrintError from saveInvHead(): ${e.toString()}");
        rethrow;
      }
    }
    return false;
  }

  Future<TblDkInvHead?> getInvHead(String docNum) async {
    String query =
    '''select 
        mat_inv_head_id MatInvHeadId,
        mat_inv_code MatInvCode,
        mat_inv_date MatInvDate,
        mat_inv_total MatInvTotal,
        mat_inv_type_id MatInvTypeId,
        mat_inv_desc MatInvDesc,
        T_ID TId,
        salesman_id SalesmanId
        from tbl_mg_mat_inv_head 
        where mat_inv_code like '$docNum'
        for json path      
    ''';

    if (host.isNotEmpty && port > 0 && dbUName.isNotEmpty &&
        dbUPass.isNotEmpty && dbName.isNotEmpty) {
      try {
        int connectionStatus = 1;
        if (!SqlConn.isConnected) {
          connectionStatus = await connect();
        }
        if (connectionStatus == 1) {
          var result = await SqlConn.readData(query);
          if (result != null) {
            List decoded = jsonDecode(result);
            return decoded
                .map((e) => TblDkInvHead.fromJson(e))
                .last;
          }
        }
      } on PlatformException catch (e) {
        debugPrint("PrintError from getInvHead(): ${e.toString()}");
      } catch (e) {
        debugPrint("PrintError from getInvHead(): ${e.toString()}");
      }
    }
    return null;
  }

  Future<bool> saveDocNum(int docNum,int firmId, int tId, String docCode, int sectionId) async{
    String query = ''' 
        exec sp_mg_setdocnum @module_id=5,@section_id='$sectionId',@doc_lastnum='$docNum',@firm_id='1',@doc_lastassg=N'$docCode',@T_ID='$tId',@div_id='0',@plant_id='0',@wh_id='0'
    ''';
    if (host.isNotEmpty && port > 0 && dbUName.isNotEmpty && dbUPass.isNotEmpty && dbName.isNotEmpty) {
      try {
        int connectionStatus = 1;
        if (!SqlConn.isConnected) {
          connectionStatus = await connect();
        }
        if (connectionStatus == 1) {
          var result = await SqlConn.writeData(query);
          return result;
        }
      } on PlatformException catch (e) {
        debugPrint("PrintError from saveDocNum(): ${e.toString()}");
      } catch (e) {
        debugPrint("PrintError from saveDocNum(): ${e.toString()}");
        rethrow;
      }
    }
    return false;
  }

  Future<bool> saveInvLine(VDkMaterialCount materialCount, int matInvHeadId, double matInvLineNet, double matDiff, String deviceId, String userName) async {
    String query = '''BEGIN TRANSACTION  
                      insert into tbl_mg_mat_inv_line
                          (material_id
                          ,mat_inv_quantity
                          ,unit_det_id
                          ,mat_inv_unit_price
                          ,mat_inv_linenet
                          ,out_wh_id
                          ,in_wh_id
                          ,mat_inv_head_id
                          ,fich_line_serialno
                          ,spe_code
                          ,security_code
                          )
                         VALUES
                           ('${materialCount.MatId}',
                           '$matDiff',
                           '${materialCount.UnitDetId}',
                           '${materialCount.PurchasePrice}',
                           '$matInvLineNet', 
                           '${materialCount.WhId}',  
                           '0', 
                           '$matInvHeadId',
                           '',
                           '$deviceId'
                           ,'$userName'                              
                           )
                           IF(@@ERROR > 0)  
                             BEGIN  
                               ROLLBACK TRANSACTION  
                             END  
                           ELSE  
                             BEGIN  
                               COMMIT TRANSACTION  
                             END  
                    ''';

    if (host.isNotEmpty && port > 0 && dbUName.isNotEmpty && dbUPass.isNotEmpty && dbName.isNotEmpty) {
      try {
        int connectionStatus = 1;
        if (!SqlConn.isConnected) {
          connectionStatus = await connect();
        }
        if (connectionStatus == 1) {
          var result = await SqlConn.writeData(query);
          return result;
        }
      } on PlatformException catch (e) {
        debugPrint("PrintError from saveInvLine(): ${e.toString()}");
      } catch (e) {
        debugPrint("PrintError from saveInvLine(): ${e.toString()}");
        rethrow;
      }
    }
    return false;
  }

  Future<bool> saveInvLineMore(VDkMaterialCount materialCount, int matInvHeadId, double matInvLineNet, double matDiff, String deviceId, String userName) async {
    String query = '''BEGIN TRANSACTION  
                      insert into tbl_mg_mat_inv_line
                          (material_id
                          ,mat_inv_quantity
                          ,unit_det_id
                          ,mat_inv_unit_price
                          ,mat_inv_linenet
                          ,out_wh_id
                          ,in_wh_id
                          ,mat_inv_head_id
                          ,fich_line_serialno
                          ,spe_code
                          ,security_code
                          )
                         VALUES
                           ('${materialCount.MatId}',
                           '$matDiff',
                           '${materialCount.UnitDetId}',
                           '${materialCount.PurchasePrice}',
                           '$matInvLineNet', 
                           '0',
                           '${materialCount.WhId}',                              
                           '$matInvHeadId',
                           '',
                           '$deviceId'
                           ,'$userName'                              
                           )
                           IF(@@ERROR > 0)  
                             BEGIN  
                               ROLLBACK TRANSACTION  
                             END  
                           ELSE  
                             BEGIN  
                               COMMIT TRANSACTION  
                             END  
                    ''';

    if (host.isNotEmpty && port > 0 && dbUName.isNotEmpty && dbUPass.isNotEmpty && dbName.isNotEmpty) {
      try {
        int connectionStatus = 1;
        if (!SqlConn.isConnected) {
          connectionStatus = await connect();
        }
        if (connectionStatus == 1) {
          var result = await SqlConn.writeData(query);
          return result;
        }
      } on PlatformException catch (e) {
        debugPrint("PrintError from saveInvLineMore(): ${e.toString()}");
      } catch (e) {
        debugPrint("PrintError from saveInvLineMore(): ${e.toString()}");
        rethrow;
      }
    }
    return false;
  }

  Future<bool> saveTransLine(VDkMaterialCount matCount, int matInvLineId, double totalPrice, int plantId, double matDiff, int invTypeId) async{
    String query = ''' 
        BEGIN TRANSACTION
         insert into tbl_mg_mat_trans_line
                          (material_id
                          ,mat_trans_line_date
                          ,fich_line_id
                          ,mat_inv_line_id
                          ,arap_id
                          ,mat_trans_type_id
                          ,mat_trans_type_code
                          ,mat_trans_line_amount_out
                          ,mat_trans_line_price_out
                          ,mat_trans_line_totalprice
                          ,mat_trans_line_nettotal
                          ,mat_trans_line_amount_in
                          ,mat_trans_line_price_in
                          ,mat_trans_line_totalprice_in
                          ,mat_trans_line_nettotal_in
                          ,mat_trans_line_wh_id_out
                          ,mat_trans_line_wh_id_in
                          ,p_id
                          ,fich_type_id
                          ,unit_det_id
                          ,mat_trans_line_wh_amount
                          ,mat_inv_type_id
                          )
                         VALUES
                           ('${matCount.MatId}',
                            GETDATE(),
                           '0',
                           '$matInvLineId', 
                           '0',
                           '1',
                           N'revision_app Yetmezlik Fakturasy',
                           '$matDiff',
                           '${matCount.PurchasePrice}',
                           '$totalPrice',
                           '$totalPrice', 
                           '0',
                           '0',
                           '0',
                           '0', 
                           '${matCount.WhId}',
                           '0',
                           '$plantId',
                           '0',
                           '${matCount.UnitDetId}',
                           '${matCount.MatWhTotalAmount}',
                           '$invTypeId'
                           )
                           IF(@@ERROR > 0)  
           BEGIN  
              ROLLBACK TRANSACTION  
           END  
        ELSE  
           BEGIN  
             COMMIT TRANSACTION  
           END  
                           ''';
    if (host.isNotEmpty && port > 0 && dbUName.isNotEmpty && dbUPass.isNotEmpty && dbName.isNotEmpty) {
      try {
        int connectionStatus = 1;
        if (!SqlConn.isConnected) {
          connectionStatus = await connect();
        }
        if (connectionStatus == 1) {
          var result = await SqlConn.writeData(query);
          return result;
        }
      } on PlatformException catch (e) {
        debugPrint("PrintError from saveTransLiine(): ${e.toString()}");
      } catch (e) {
        debugPrint("PrintError from saveTransLine(): ${e.toString()}");
        rethrow;
      }
    }
    return false;
  }

  Future<TblDkInvLine?> getInvLine(int matId, int matInvHeadId) async {
    String query =
    '''select 
        mat_inv_line_id MatInvLineId,
        material_id MatId,
        mat_inv_quantity MatInvQuantity,
        unit_det_id UnitDetId,
        mat_inv_unit_price MatInvUnitPrice,
        mat_inv_linenet MatInvLineNet,
        mat_inv_line_date MatInvLineDate,
        mat_inv_head_id MatInvHeadId
        from tbl_mg_mat_inv_line 
        where material_id = '$matId' and mat_inv_head_id = '$matInvHeadId'
        for json path
    ''';

    if (host.isNotEmpty && port > 0 && dbUName.isNotEmpty &&
        dbUPass.isNotEmpty && dbName.isNotEmpty) {
      try {
        int connectionStatus = 1;
        if (!SqlConn.isConnected) {
          connectionStatus = await connect();
        }
        if (connectionStatus == 1) {
          var result = await SqlConn.readData(query);
          if (result != null) {
            List decoded = jsonDecode(result);
            return decoded
                .map((e) => TblDkInvLine.fromJson(e))
                .first;
          }
        }
      } on PlatformException catch (e) {
        debugPrint("PrintError from getInvLine(): ${e.toString()}");
      } catch (e) {
        debugPrint("PrintError from getInvLine(): ${e.toString()}");
      }
    }
    return null;
  }

  Future<bool> deleteMaterialCount(String? deviceId, VDkMatCountParams params, bool newCount, int? userId) async{
    String dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss').format(params.CountDate!);
    debugPrint("Params in delete material count: ${params.toJson()}");
    String query = "";
    if(newCount) {
      if (userId != null) {
        query = ''' 
        delete from tbl_mg_material_count
        where T_ID like $userId
    AND JSON_VALUE(mat_count_params, '\$.WhType') = '${params.WhType}'
    AND JSON_VALUE(mat_count_params, '\$.CountDate') = '$dateFormatter'
    AND JSON_VALUE(mat_count_params, '\$.CountType') = '${params.CountType}'
    AND JSON_VALUE(mat_count_params, '\$.WhId') = ${params.WhId}
    AND JSON_VALUE(mat_count_params, '\$.CountPass') = CONVERT(varchar(128), HASHBYTES('SHA2_512', '${params
            .CountPass}'), 2)
    AND JSON_VALUE(mat_count_params, '\$.Note1') = '${params.Note1}'
    AND JSON_VALUE(mat_count_params, '\$.Note2') = '${params.Note2}'
    AND JSON_VALUE(mat_count_params, '\$.WhName') = '${params.WhName}'        
    ''';
      }
      else {
        query = ''' 
        delete from tbl_mg_material_count
        where JSON_VALUE(mat_count_params, '\$.WhType') = '${params.WhType}'
    AND JSON_VALUE(mat_count_params, '\$.CountDate') = '$dateFormatter'
    AND JSON_VALUE(mat_count_params, '\$.CountType') = '${params.CountType}'
    AND JSON_VALUE(mat_count_params, '\$.WhId') = ${params.WhId}
    AND JSON_VALUE(mat_count_params, '\$.CountPass') = CONVERT(varchar(128), HASHBYTES('SHA2_512', '${params
            .CountPass}'), 2)
    AND JSON_VALUE(mat_count_params, '\$.Note1') = '${params.Note1}'
    AND JSON_VALUE(mat_count_params, '\$.Note2') = '${params.Note2}'
    AND JSON_VALUE(mat_count_params, '\$.WhName') = '${params.WhName}'        
    ''';
      }
    }
    else {
      if (userId != null) {
        query = ''' 
        delete from tbl_mg_material_count
        where T_ID like $userId
    AND JSON_VALUE(mat_count_params, '\$.WhType') = '${params.WhType}'
    AND JSON_VALUE(mat_count_params, '\$.CountDate') = '$dateFormatter'
    AND JSON_VALUE(mat_count_params, '\$.CountType') = '${params.CountType}'
    AND JSON_VALUE(mat_count_params, '\$.WhId') = ${params.WhId}
    AND JSON_VALUE(mat_count_params, '\$.CountPass') = '${params.CountPass}'
    AND JSON_VALUE(mat_count_params, '\$.Note1') = '${params.Note1}'
    AND JSON_VALUE(mat_count_params, '\$.Note2') = '${params.Note2}'
    AND JSON_VALUE(mat_count_params, '\$.WhName') = '${params.WhName}'
    ''';
      }
      else {
        query = ''' 
        delete from tbl_mg_material_count
        where JSON_VALUE(mat_count_params, '\$.WhType') = '${params.WhType}'
    AND JSON_VALUE(mat_count_params, '\$.CountDate') = '$dateFormatter'
    AND JSON_VALUE(mat_count_params, '\$.CountType') = '${params.CountType}'
    AND JSON_VALUE(mat_count_params, '\$.WhId') = ${params.WhId}
    AND JSON_VALUE(mat_count_params, '\$.CountPass') = '${params.CountPass}'
    AND JSON_VALUE(mat_count_params, '\$.Note1') = '${params.Note1}'
    AND JSON_VALUE(mat_count_params, '\$.Note2') = '${params.Note2}'
    AND JSON_VALUE(mat_count_params, '\$.WhName') = '${params.WhName}'
    ''';
      }
    }
    if (host.isNotEmpty && port > 0 && dbUName.isNotEmpty && dbUPass.isNotEmpty && dbName.isNotEmpty) {
      try {
        int connectionStatus = 1;
        if (!SqlConn.isConnected) {
          connectionStatus = await connect();
        }
        if (connectionStatus == 1) {
          var result = await SqlConn.writeData(query);
          return result;
        }
      } on PlatformException catch (e) {
        debugPrint("PrintError from deleteMaterialCount(): ${e.toString()}");
      } catch (e) {
        debugPrint("PrintError from deleteMaterialCount(): ${e.toString()}");
        rethrow;
      }
    }
    return false;
  }

  Future<bool> deleteStockCount(String? deviceId, VDkMatCountParams params, bool newCount, int? userId) async{
    String dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss').format(params.CountDate!);
    String query = "";
    if(newCount) {
      if (userId != null) {
        query = ''' 
        delete from tbl_mg_stock_count
        where T_ID like $userId
    AND JSON_VALUE(mat_count_params, '\$.WhType') = '${params.WhType}'
    AND JSON_VALUE(mat_count_params, '\$.CountDate') = '$dateFormatter'
    AND JSON_VALUE(mat_count_params, '\$.CountType') = '${params.CountType}'
    AND JSON_VALUE(mat_count_params, '\$.WhId') = ${params.WhId}
    AND JSON_VALUE(mat_count_params, '\$.CountPass') = CONVERT(varchar(128), HASHBYTES('SHA2_512', '${params
            .CountPass}'), 2)
    AND JSON_VALUE(mat_count_params, '\$.Note1') = '${params.Note1}'
    AND JSON_VALUE(mat_count_params, '\$.Note2') = '${params.Note2}'
    AND JSON_VALUE(mat_count_params, '\$.WhName') = '${params.WhName}'        
    ''';
      }
      else {
        query = ''' 
        delete from tbl_mg_stock_count
        where JSON_VALUE(mat_count_params, '\$.WhType') = '${params.WhType}'
    AND JSON_VALUE(mat_count_params, '\$.CountDate') = '$dateFormatter'
    AND JSON_VALUE(mat_count_params, '\$.CountType') = '${params.CountType}'
    AND JSON_VALUE(mat_count_params, '\$.WhId') = ${params.WhId}
    AND JSON_VALUE(mat_count_params, '\$.CountPass') = CONVERT(varchar(128), HASHBYTES('SHA2_512', '${params
            .CountPass}'), 2)
    AND JSON_VALUE(mat_count_params, '\$.Note1') = '${params.Note1}'
    AND JSON_VALUE(mat_count_params, '\$.Note2') = '${params.Note2}'
    AND JSON_VALUE(mat_count_params, '\$.WhName') = '${params.WhName}'        
    ''';
      }
    }
    else {
      if (userId != null) {
        query = ''' 
        delete from tbl_mg_stock_count
        where T_ID like $userId
    AND JSON_VALUE(mat_count_params, '\$.WhType') = '${params.WhType}'
    AND JSON_VALUE(mat_count_params, '\$.CountDate') = '$dateFormatter'
    AND JSON_VALUE(mat_count_params, '\$.CountType') = '${params.CountType}'
    AND JSON_VALUE(mat_count_params, '\$.WhId') = ${params.WhId}
    AND JSON_VALUE(mat_count_params, '\$.CountPass') = '${params.CountPass}'
    AND JSON_VALUE(mat_count_params, '\$.Note1') = '${params.Note1}'
    AND JSON_VALUE(mat_count_params, '\$.Note2') = '${params.Note2}'
    AND JSON_VALUE(mat_count_params, '\$.WhName') = '${params.WhName}'
    ''';
      }
      else {
        query = ''' 
        delete from tbl_mg_stock_count
        where JSON_VALUE(mat_count_params, '\$.WhType') = '${params.WhType}'
    AND JSON_VALUE(mat_count_params, '\$.CountDate') = '$dateFormatter'
    AND JSON_VALUE(mat_count_params, '\$.CountType') = '${params.CountType}'
    AND JSON_VALUE(mat_count_params, '\$.WhId') = ${params.WhId}
    AND JSON_VALUE(mat_count_params, '\$.CountPass') = '${params.CountPass}'
    AND JSON_VALUE(mat_count_params, '\$.Note1') = '${params.Note1}'
    AND JSON_VALUE(mat_count_params, '\$.Note2') = '${params.Note2}'
    AND JSON_VALUE(mat_count_params, '\$.WhName') = '${params.WhName}'
    ''';
      }
    }
    if (host.isNotEmpty && port > 0 && dbUName.isNotEmpty && dbUPass.isNotEmpty && dbName.isNotEmpty) {
      try {
        int connectionStatus = 1;
        if (!SqlConn.isConnected) {
          connectionStatus = await connect();
        }
        if (connectionStatus == 1) {
          var result = await SqlConn.writeData(query);
          return result;
        }
      } on PlatformException catch (e) {
        debugPrint("PrintError from deleteStockCount(): ${e.toString()}");
      } catch (e) {
        debugPrint("PrintError from deleteStockCount(): ${e.toString()}");
        rethrow;
      }
    }
    return false;
  }

  Future<bool> deleteSingleMatCount(int userId, int matId, VDkMatCountParams params, bool newCount) async{
    String dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss').format(params.CountDate!);
    String query = '';
    if(newCount){
      query = ''' 
        delete from tbl_mg_material_count
        where T_ID like '$userId' and material_id = '$matId'
    AND JSON_VALUE(mat_count_params, '\$.WhType') = '${params.WhType}'
    AND JSON_VALUE(mat_count_params, '\$.CountDate') = '$dateFormatter'
    AND JSON_VALUE(mat_count_params, '\$.CountType') = '${params.CountType}'
    AND JSON_VALUE(mat_count_params, '\$.WhId') = ${params.WhId}
    AND JSON_VALUE(mat_count_params, '\$.CountPass') = CONVERT(varchar(128), HASHBYTES('SHA2_512', '${params.CountPass}'), 2)
    AND JSON_VALUE(mat_count_params, '\$.Note1') = '${params.Note1}'
    AND JSON_VALUE(mat_count_params, '\$.Note2') = '${params.Note2}'
    AND JSON_VALUE(mat_count_params, '\$.WhName') = '${params.WhName}'
    ''';
    }
    else{
      query = ''' 
        delete from tbl_mg_material_count
        where T_ID like '$userId' and material_id = '$matId'
    AND JSON_VALUE(mat_count_params, '\$.WhType') = '${params.WhType}'
    AND JSON_VALUE(mat_count_params, '\$.CountDate') = '$dateFormatter'
    AND JSON_VALUE(mat_count_params, '\$.CountType') = '${params.CountType}'
    AND JSON_VALUE(mat_count_params, '\$.WhId') = ${params.WhId}
    AND JSON_VALUE(mat_count_params, '\$.CountPass') = '${params.CountPass}'
    AND JSON_VALUE(mat_count_params, '\$.Note1') = '${params.Note1}'
    AND JSON_VALUE(mat_count_params, '\$.Note2') = '${params.Note2}'
    AND JSON_VALUE(mat_count_params, '\$.WhName') = '${params.WhName}'
    ''';
    }
    if (host.isNotEmpty && port > 0 && dbUName.isNotEmpty && dbUPass.isNotEmpty && dbName.isNotEmpty) {
      try {
        int connectionStatus = 1;
        if (!SqlConn.isConnected) {
          connectionStatus = await connect();
        }
        if (connectionStatus == 1) {
          var result = await SqlConn.writeData(query);
          return result;
        }
      } on PlatformException catch (e) {
        debugPrint("PrintError from deleteSingleMatCount(): ${e.toString()}");
      } catch (e) {
        debugPrint("PrintError from deleteSingleMatCount(): ${e.toString()}");
        rethrow;
      }
    }
    return false;
  }

  Future<bool> deleteSingleStockCount(int userId, int matId, VDkMatCountParams params, bool newCount) async{
    String dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss').format(params.CountDate!);
    String query = '';
    if(newCount){
      query = ''' 
        delete from tbl_mg_stock_count
        where T_ID like '$userId' and material_id = '$matId'
    AND JSON_VALUE(mat_count_params, '\$.WhType') = '${params.WhType}'
    AND JSON_VALUE(mat_count_params, '\$.CountDate') = '$dateFormatter'
    AND JSON_VALUE(mat_count_params, '\$.CountType') = '${params.CountType}'
    AND JSON_VALUE(mat_count_params, '\$.WhId') = ${params.WhId}
    AND JSON_VALUE(mat_count_params, '\$.CountPass') = CONVERT(varchar(128), HASHBYTES('SHA2_512', '${params.CountPass}'), 2)
    AND JSON_VALUE(mat_count_params, '\$.Note1') = '${params.Note1}'
    AND JSON_VALUE(mat_count_params, '\$.Note2') = '${params.Note2}'
    AND JSON_VALUE(mat_count_params, '\$.WhName') = '${params.WhName}'
    ''';
    }
    else{
      query = ''' 
        delete from tbl_mg_stock_count
        where T_ID like '$userId' and material_id = '$matId'
    AND JSON_VALUE(mat_count_params, '\$.WhType') = '${params.WhType}'
    AND JSON_VALUE(mat_count_params, '\$.CountDate') = '$dateFormatter'
    AND JSON_VALUE(mat_count_params, '\$.CountType') = '${params.CountType}'
    AND JSON_VALUE(mat_count_params, '\$.WhId') = ${params.WhId}
    AND JSON_VALUE(mat_count_params, '\$.CountPass') = '${params.CountPass}'
    AND JSON_VALUE(mat_count_params, '\$.Note1') = '${params.Note1}'
    AND JSON_VALUE(mat_count_params, '\$.Note2') = '${params.Note2}'
    AND JSON_VALUE(mat_count_params, '\$.WhName') = '${params.WhName}'
    ''';
    }
    if (host.isNotEmpty && port > 0 && dbUName.isNotEmpty && dbUPass.isNotEmpty && dbName.isNotEmpty) {
      try {
        int connectionStatus = 1;
        if (!SqlConn.isConnected) {
          connectionStatus = await connect();
        }
        if (connectionStatus == 1) {
          var result = await SqlConn.writeData(query);
          return result;
        }
      } on PlatformException catch (e) {
        debugPrint("PrintError from deleteSingleStockCount(): ${e.toString()}");
      } catch (e) {
        debugPrint("PrintError from deleteSingleStockCount(): ${e.toString()}");
        rethrow;
      }
    }
    return false;
  }

  Future<bool> deleteSingleProductCount(VDkMaterialCount matCount) async{
    String query = ''' 
        delete from tbl_mg_material_count
        where count_id = '${matCount.CountId}' and material_count_date = '${matCount.MatCountDate}'   
    ''';

    if (host.isNotEmpty && port > 0 && dbUName.isNotEmpty && dbUPass.isNotEmpty && dbName.isNotEmpty) {
      try {
        int connectionStatus = 1;
        if (!SqlConn.isConnected) {
          connectionStatus = await connect();
        }
        if (connectionStatus == 1) {
          var result = await SqlConn.writeData(query);
          return result;
        }
      } on PlatformException catch (e) {
        debugPrint("PrintError from deleteSingleProductCount(): ${e.toString()}");
      } catch (e) {
        debugPrint("PrintError from deleteSingleProductCount(): ${e.toString()}");
        rethrow;
      }
    }
    return false;
  }

  Future<bool> deleteSingleProductStockCount(VDkMaterialCount matCount) async{
    String query = ''' 
        delete from tbl_mg_stock_count
        where scan_date = '${matCount.MatCountDate}'   
        AND scan_machine = '${matCount.DeviceId}'
        AND T_ID = '${matCount.UserId}'
    ''';

    if (host.isNotEmpty && port > 0 && dbUName.isNotEmpty && dbUPass.isNotEmpty && dbName.isNotEmpty) {
      try {
        int connectionStatus = 1;
        if (!SqlConn.isConnected) {
          connectionStatus = await connect();
        }
        if (connectionStatus == 1) {
          var result = await SqlConn.writeData(query);
          return result;
        }
      } on PlatformException catch (e) {
        debugPrint("PrintError from deleteSingleProductStockCount(): ${e.toString()}");
      } catch (e) {
        debugPrint("PrintError from deleteSingleProductStockCount(): ${e.toString()}");
        rethrow;
      }
    }
    return false;
  }

  // Future<bool> deleteSingleMatCountForAdmin(int matId, VDkMatCountParams params, bool newCount) async{
  //   String dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss').format(params.CountDate!);
  //   String query = '';
  //   if(newCount){
  //     query = '''
  //       delete from tbl_mg_material_count
  //       where material_id = '$matId'
  //   AND JSON_VALUE(mat_count_params, '\$.WhType') = '${params.WhType}'
  //   AND JSON_VALUE(mat_count_params, '\$.CountDate') = '$dateFormatter'
  //   AND JSON_VALUE(mat_count_params, '\$.CountType') = '${params.CountType}'
  //   AND JSON_VALUE(mat_count_params, '\$.WhId') = ${params.WhId}
  //   AND JSON_VALUE(mat_count_params, '\$.CountPass') = CONVERT(varchar(128), HASHBYTES('SHA2_512', '${params.CountPass}'), 2)
  //   AND JSON_VALUE(mat_count_params, '\$.Note1') = '${params.Note1}'
  //   AND JSON_VALUE(mat_count_params, '\$.Note2') = '${params.Note2}'
  //   AND JSON_VALUE(mat_count_params, '\$.WhName') = '${params.WhName}'
  //   ''';
  //   }
  //   else{
  //     query = '''
  //       delete from tbl_mg_material_count
  //       where material_id = '$matId'
  //   AND JSON_VALUE(mat_count_params, '\$.WhType') = '${params.WhType}'
  //   AND JSON_VALUE(mat_count_params, '\$.CountDate') = '$dateFormatter'
  //   AND JSON_VALUE(mat_count_params, '\$.CountType') = '${params.CountType}'
  //   AND JSON_VALUE(mat_count_params, '\$.WhId') = ${params.WhId}
  //   AND JSON_VALUE(mat_count_params, '\$.CountPass') = '${params.CountPass}'
  //   AND JSON_VALUE(mat_count_params, '\$.Note1') = '${params.Note1}'
  //   AND JSON_VALUE(mat_count_params, '\$.Note2') = '${params.Note2}'
  //   AND JSON_VALUE(mat_count_params, '\$.WhName') = '${params.WhName}'
  //   ''';
  //   }
  //   if (host.isNotEmpty && port > 0 && dbUName.isNotEmpty && dbUPass.isNotEmpty && dbName.isNotEmpty) {
  //     try {
  //       int connectionStatus = 1;
  //       if (!SqlConn.isConnected) {
  //         connectionStatus = await connect();
  //       }
  //       if (connectionStatus == 1) {
  //         var result = await SqlConn.writeData(query);
  //         return result;
  //       }
  //     } on PlatformException catch (e) {
  //       debugPrint("PrintError from deleteSingleMatCountForAdmin(): ${e.toString()}");
  //     } catch (e) {
  //       debugPrint("PrintError from deleteSingleMatCountForAdmin(): ${e.toString()}");
  //       rethrow;
  //     }
  //   }
  //   return false;
  // }

  Future<bool> saveInvHeadMore(String docNum, int divId, int deptId, int plantId, int whId, double matInvTotal, int pId, int teacherId, int salesmanId, String matInvDesc, String matInvDesc2, String deviceId, String countedDate) async {
    String query = '''insert into tbl_mg_mat_inv_head
                          (mat_inv_code
                          ,mat_inv_date
                          ,mat_inv_docno
                          ,out_div_id
                          ,out_dept_id
                          ,out_plant_id
                          ,out_wh_id
                          ,in_div_id
                          ,in_dept_id
                          ,in_plant_id
                          ,in_wh_id
                          ,mat_inv_total
                          ,p_id
                          ,mat_inv_type_id
                          ,mat_inv_desc
                          ,spe_code
                          ,group_code
                          ,security_code
                          ,inv_id_auto_gen
                          ,salesman_id
                          ,T_ID
                          ,project_id
                         )
                         VALUES
                           ('$docNum',
                           '$countedDate',
                           'revision_app artyklyk',
                           '0', 
                           '0',
                           '0',  
                           '0',
                           '$divId', 
                           '$deptId',
                           '$plantId',  
                           '$whId',
                           '$matInvTotal',
                           '$pId',
                           '13', 
                           '$matInvDesc', 
                           '$deviceId',
                           '$matInvDesc2',
                           '',
                           '0',
                           '$salesmanId',
                           '$teacherId',
                           '0'       
                           )
                    ''';

    if (host.isNotEmpty && port > 0 && dbUName.isNotEmpty && dbUPass.isNotEmpty && dbName.isNotEmpty) {
      try {
        int connectionStatus = 1;
        if (!SqlConn.isConnected) {
          connectionStatus = await connect();
        }
        if (connectionStatus == 1) {
          var result = await SqlConn.writeData(query);
          return result;
        }
      } on PlatformException catch (e) {
        debugPrint("PrintError from saveInvHeadMore(): ${e.toString()}");
      } catch (e) {
        debugPrint("PrintError from saveInvHeadMore(): ${e.toString()}");
        rethrow;
      }
    }
    return false;
  }

  Future<bool> saveTransLineMore(VDkMaterialCount matCount, int matInvLineId, double totalPrice, int plantId, double matDiff, int invTypeId) async{
    String query = ''' 
        BEGIN TRANSACTION
         insert into tbl_mg_mat_trans_line
                          (material_id
                          ,mat_trans_line_date
                          ,fich_line_id
                          ,mat_inv_line_id
                          ,arap_id
                          ,mat_trans_type_id
                          ,mat_trans_type_code
                          ,mat_trans_line_amount_out
                          ,mat_trans_line_price_out
                          ,mat_trans_line_totalprice
                          ,mat_trans_line_nettotal
                          ,mat_trans_line_amount_in
                          ,mat_trans_line_price_in
                          ,mat_trans_line_totalprice_in
                          ,mat_trans_line_nettotal_in
                          ,mat_trans_line_wh_id_out
                          ,mat_trans_line_wh_id_in
                          ,p_id
                          ,fich_type_id
                          ,unit_det_id
                          ,mat_trans_line_wh_amount
                          ,mat_inv_type_id
                          )
                         VALUES
                           ('${matCount.MatId}',
                            GETDATE(),
                           '0',
                           '$matInvLineId', 
                           '0',
                           '2',
                           N'revision_app Artyklyk Fakturasy',                           
                           '0',
                           '0',
                           '0',
                           '0', 
                           '$matDiff',
                           '${matCount.PurchasePrice}',
                           '$totalPrice',
                           '$totalPrice', 
                           '0',
                           '${matCount.WhId}',
                           '$plantId',
                           '0',
                           '${matCount.UnitDetId}',
                           '${matCount.MatWhTotalAmount}',
                           '$invTypeId'
                           )
                           IF(@@ERROR > 0)  
           BEGIN  
              ROLLBACK TRANSACTION  
           END  
        ELSE  
           BEGIN  
             COMMIT TRANSACTION  
           END  
                           ''';
    if (host.isNotEmpty && port > 0 && dbUName.isNotEmpty && dbUPass.isNotEmpty && dbName.isNotEmpty) {
      try {
        int connectionStatus = 1;
        if (!SqlConn.isConnected) {
          connectionStatus = await connect();
        }
        if (connectionStatus == 1) {
          var result = await SqlConn.writeData(query);
          return result;
        }
      } on PlatformException catch (e) {
        debugPrint("PrintError from saveTransLineMore(): ${e.toString()}");
      } catch (e) {
        debugPrint("PrintError from saveTransLineMore(): ${e.toString()}");
        rethrow;
      }
    }
    return false;
  }

  Future<List<TblDkInvHead>> getInvHeads(String deviceId) async{
    String query = '''
    select * from tbl_mg_mat_inv_head
    where spe_code like '$deviceId'
    for json path
    ''';
    if (host.isNotEmpty && port > 0 && dbUName.isNotEmpty &&
        dbUPass.isNotEmpty && dbName.isNotEmpty) {
      try {
        int connectionStatus = 1;
        if (!SqlConn.isConnected) {
          connectionStatus = await connect();
        }
        if (connectionStatus == 1) {
          int connectionStatus = 1;
          if (!SqlConn.isConnected) {
            connectionStatus = await connect();
          }
          if (connectionStatus == 1) {
            var result = await SqlConn.readData(query);
            if (result != null) {
              List decoded = jsonDecode(result);
              return decoded.map((e) => TblDkInvHead.fromMap(e)).toList();
            }
          }
        }
      } catch (e) {
        debugPrint("PrintError from getInvHeads(): ${e.toString()}");
      }
    }
    return [];
  }

  Future<List<TblDkInvHead>> getInvHeadsForAdmin() async{
    String query = '''
    select * from tbl_mg_mat_inv_head
    for json path
    ''';
    if (host.isNotEmpty && port > 0 && dbUName.isNotEmpty &&
        dbUPass.isNotEmpty && dbName.isNotEmpty) {
      try {
        int connectionStatus = 1;
        if (!SqlConn.isConnected) {
          connectionStatus = await connect();
        }
        if (connectionStatus == 1) {
          int connectionStatus = 1;
          if (!SqlConn.isConnected) {
            connectionStatus = await connect();
          }
          if (connectionStatus == 1) {
            var result = await SqlConn.readData(query);
            if (result != null) {
              List decoded = jsonDecode(result);
              return decoded.map((e) => TblDkInvHead.fromMap(e)).toList();
            }
          }
        }
      } catch (e) {
        debugPrint("PrintError from getInvHeadsForAdmin(): ${e.toString()}");
      }
    }
    return [];
  }

  Future<List<TblDkInvHead>> getInvHeadsWithDate(String? deviceId, DateTime startDate, DateTime endDate) async{
    String query ="";
    if(deviceId == null){
      query = '''
    select * from tbl_mg_mat_inv_head
    where mat_inv_date between '$startDate' and '$endDate'
    for json path
    ''';
    }
    else {
    query = '''
    select * from tbl_mg_mat_inv_head
    where spe_code like '$deviceId' and mat_inv_date between '$startDate' and '$endDate'
    for json path
    ''';
    }
    if (host.isNotEmpty && port > 0 && dbUName.isNotEmpty &&
        dbUPass.isNotEmpty && dbName.isNotEmpty) {
      try {
        int connectionStatus = 1;
        if (!SqlConn.isConnected) {
          connectionStatus = await connect();
        }
        if (connectionStatus == 1) {
          int connectionStatus = 1;
          if (!SqlConn.isConnected) {
            connectionStatus = await connect();
          }
          if (connectionStatus == 1) {
            var result = await SqlConn.readData(query);
            if (result != null) {
              List decoded = jsonDecode(result);
              return decoded.map((e) => TblDkInvHead.fromMap(e)).toList();
            }
          }
        }
      } catch (e) {
        debugPrint("PrintError from getInvHeadsWithDate(): ${e.toString()}");
      }
    }
    return [];
  }

  Future<List<VDkInvLine>> getInvLines(String deviceId, int whId, int matInvHeadId) async{
    String query = '''
   select mb.material_name as MatName, mb.material_id as MatId, mb.bar_barcode as Barcode, 
	mi.mat_inv_line_id as MatInvLineId, mi.mat_inv_head_id as MatInvHeadId,
    mi.mat_inv_quantity as MatCountDiff, mi.spe_code as SpeCode, mi.security_code as SecurityCode,
	mt.mat_trans_line_wh_amount as MatWhTotalAmount
    from tbl_mg_mat_inv_line mi
left outer join v_mg_materials_bar_all mb on mb.material_id=mi.material_id and mb.wh_id='$whId'
left outer join tbl_mg_mat_trans_line mt on mt.mat_inv_line_id=mi.mat_inv_line_id 
where mi.spe_code like '$deviceId' and mi.mat_inv_head_id='$matInvHeadId'
for json path
    ''';
    if (host.isNotEmpty && port > 0 && dbUName.isNotEmpty &&
        dbUPass.isNotEmpty && dbName.isNotEmpty) {
      try {
        int connectionStatus = 1;
        if (!SqlConn.isConnected) {
          connectionStatus = await connect();
        }
        if (connectionStatus == 1) {
          int connectionStatus = 1;
          if (!SqlConn.isConnected) {
            connectionStatus = await connect();
          }
          if (connectionStatus == 1) {
            var result = await SqlConn.readData(query);
            if (result != null) {
              List decoded = jsonDecode(result);
              return decoded.map((e) => VDkInvLine.fromMap(e)).toList();
            }
          }
        }
      } catch (e) {
        debugPrint("PrintError from getInvLines(): ${e.toString()}");
      }
    }
    return [];
  }

  Future<List<VDkInvLine>> getInvLinesForAdmin(int whId, int matInvHeadId) async{
    String query = '''
   select mb.material_name as MatName, mb.material_id as MatId, mb.bar_barcode as Barcode, 
	mi.mat_inv_line_id as MatInvLineId, mi.mat_inv_head_id as MatInvHeadId,
    mi.mat_inv_quantity as MatCountDiff, mi.spe_code as SpeCode, mi.security_code as SecurityCode,
	mt.mat_trans_line_wh_amount as MatWhTotalAmount
    from tbl_mg_mat_inv_line mi
left outer join v_mg_materials_bar_all mb on mb.material_id=mi.material_id and mb.wh_id='$whId'
left outer join tbl_mg_mat_trans_line mt on mt.mat_inv_line_id=mi.mat_inv_line_id 
where mi.mat_inv_head_id='$matInvHeadId'
for json path
    ''';
    if (host.isNotEmpty && port > 0 && dbUName.isNotEmpty &&
        dbUPass.isNotEmpty && dbName.isNotEmpty) {
      try {
        int connectionStatus = 1;
        if (!SqlConn.isConnected) {
          connectionStatus = await connect();
        }
        if (connectionStatus == 1) {
          int connectionStatus = 1;
          if (!SqlConn.isConnected) {
            connectionStatus = await connect();
          }
          if (connectionStatus == 1) {
            var result = await SqlConn.readData(query);
            if (result != null) {
              List decoded = jsonDecode(result);
              return decoded.map((e) => VDkInvLine.fromJson(e)).toList();
            }
          }
        }
      } catch (e) {
        debugPrint("PrintError from getInvLinesForAdmin(): ${e.toString()}");
      }
    }
    return [];
  }

  Future<bool> deleteTransLine(int invLineId) async{
    debugPrint('MatInvLineId in delete: $invLineId');
    String query = ''' 
        delete from tbl_mg_mat_trans_line
        where mat_inv_line_id = '$invLineId'
    ''';
    if (host.isNotEmpty && port > 0 && dbUName.isNotEmpty && dbUPass.isNotEmpty && dbName.isNotEmpty) {
      try {
        int connectionStatus = 1;
        if (!SqlConn.isConnected) {
          connectionStatus = await connect();
        }
        if (connectionStatus == 1) {
          var result = await SqlConn.writeData(query);
          return result;
        }
      } on PlatformException catch (e) {
        debugPrint("PrintError from deleteTransLine(): ${e.toString()}");
      } catch (e) {
        debugPrint("PrintError from deleteTransLine(): ${e.toString()}");
        rethrow;
      }
    }
    return false;
  }

  Future<bool> deleteInvHead(String? deviceId, int invHeadId) async{
    String query="";
    if(deviceId==null){
      query = ''' 
        delete from tbl_mg_mat_inv_head
        where mat_inv_head_id = '$invHeadId'
    ''';
    }
    else {
      query = ''' 
        delete from tbl_mg_mat_inv_head
        where spe_code like '$deviceId' and mat_inv_head_id = '$invHeadId'
    ''';
    }
    if (host.isNotEmpty && port > 0 && dbUName.isNotEmpty && dbUPass.isNotEmpty && dbName.isNotEmpty) {
      try {
        int connectionStatus = 1;
        if (!SqlConn.isConnected) {
          connectionStatus = await connect();
        }
        if (connectionStatus == 1) {
          var result = await SqlConn.writeData(query);
          return result;
        }
      } on PlatformException catch (e) {
        debugPrint("PrintError from deleteInvHead(): ${e.toString()}");
      } catch (e) {
        debugPrint("PrintError from deleteInvHead(): ${e.toString()}");
        rethrow;
      }
    }
    return false;
  }

  Future<bool> deleteInvHeadProducts(String? deviceId, int invHeadId) async{
    String query="";
    if(deviceId==null){
      query = ''' 
        delete from tbl_mg_mat_inv_line
        where mat_inv_head_id = '$invHeadId'
    ''';
    }
    else {
      query = ''' 
        delete from tbl_mg_mat_inv_line
        where spe_code like '$deviceId' and mat_inv_head_id = '$invHeadId'
    ''';
    }
    if (host.isNotEmpty && port > 0 && dbUName.isNotEmpty && dbUPass.isNotEmpty && dbName.isNotEmpty) {
      try {
        int connectionStatus = 1;
        if (!SqlConn.isConnected) {
          connectionStatus = await connect();
        }
        if (connectionStatus == 1) {
          var result = await SqlConn.writeData(query);
          return result;
        }
      } on PlatformException catch (e) {
        debugPrint("PrintError from deleteInvHeadProducts(): ${e.toString()}");
      } catch (e) {
        debugPrint("PrintError from deleteInvHeadProducts(): ${e.toString()}");
        rethrow;
      }
    }
    return false;
  }

  Future<List<VDkMaterials>> getMaterials(int whId) async{
    String query = '''
    select mt.material_id as MatId, mt.material_name as MatName, mt.unit_det_id as UnitDetId, mt.unit_id as UnitId, mt.material_code as MatCode,
mt.spe_code as SpeCode, mt.group_code as GroupCode, mt.security_code as SecurityCode,
mb.unit_det_code as UnitDetCode, mb.bar_barcode as Barcode, mb.wh_id as WhId, mb.mat_whousetotal_amount as MatWhTotalAmount, 
mb.sale_price as SalePrice, mb.mat_purch_price as PurchasePrice from tbl_mg_materials mt
left outer join v_mg_materials_bar_all mb on mb.material_id = mt.material_id where mb.wh_id='$whId'
for json path
    ''';
    if (host.isNotEmpty && port > 0 && dbUName.isNotEmpty &&
        dbUPass.isNotEmpty && dbName.isNotEmpty) {
      try {
        int connectionStatus = 1;
        if (!SqlConn.isConnected) {
          connectionStatus = await connect();
        }
        if (connectionStatus == 1) {
          int connectionStatus = 1;
          if (!SqlConn.isConnected) {
            connectionStatus = await connect();
          }
          if (connectionStatus == 1) {
            var result = await SqlConn.readData(query);
            if (result != null) {
              List decoded = jsonDecode(result);
              return decoded.map((e) => VDkMaterials.fromMap(e)).toList();
            }
          }
        }
      } catch (e) {
        debugPrint("PrintError from getMaterials(): ${e.toString()}");
      }
    }
    return [];
  }

  Future<List<TblDkMaterialCount>> getCurrentCounts() async{
    String query = '''
   WITH GroupedData AS (
    SELECT 
        MAX(count_id) AS CountId,
        MAX(material_id) AS MatId,
        SUM(material_count_total) AS MatCountTotal,
        MIN(material_count_date) AS MatCountDate,
        AVG(material_count_diff) AS MatCountDiff,
        MAX(material_count_desc) AS MatCountDescription,
        MAX(wh_id) AS WhId,
        MAX(unit_det_id) AS UnitDetId,
        MAX(mat_whousetotal_amount) AS MatWhTotalAmount,
        MAX(count_id_guid) AS CountIdGuid,
        MAX(CAST(mat_count_params AS NVARCHAR(4000))) AS MatCountParams, 
        JSON_VALUE(MAX(CAST(mat_count_params AS NVARCHAR(4000))), '\$.CountDate') AS GroupingKey
    FROM tbl_mg_material_count
    GROUP BY 
        JSON_VALUE(CAST(mat_count_params AS NVARCHAR(4000)), '\$.CountDate')
),
RankedData AS (
    SELECT 
        CAST(mat_count_params AS NVARCHAR(4000)) AS MatCountParams,
        T_ID AS UserId,
        device_id AS DeviceId,
        JSON_VALUE(CAST(mat_count_params AS NVARCHAR(4000)), '\$.CountDate') AS GroupingKey,
        ROW_NUMBER() OVER (PARTITION BY JSON_VALUE(CAST(mat_count_params AS NVARCHAR(4000)), '\$.CountDate') ORDER BY material_count_date) AS rn
    FROM tbl_mg_material_count
)
SELECT 
    g.CountId,
    g.MatId,
    g.MatCountTotal,
    g.MatCountDate,
    g.MatCountDiff,
    r.DeviceId,
    g.MatCountDescription,
    g.WhId,
    g.UnitDetId,
    g.MatWhTotalAmount,
    g.CountIdGuid,
    r.UserId,
    g.MatCountParams
FROM GroupedData g
JOIN RankedData r
    ON g.GroupingKey = r.GroupingKey
    AND r.rn = 1
    for json path;
    ''';
    if (host.isNotEmpty && port > 0 && dbUName.isNotEmpty &&
        dbUPass.isNotEmpty && dbName.isNotEmpty) {
      debugPrint("Generated query in currentCounts: $query");
      try {
        int connectionStatus = 1;
        if (!SqlConn.isConnected) {
          connectionStatus = await connect();
        }
        if (connectionStatus == 1) {
          int connectionStatus = 1;
          if (!SqlConn.isConnected) {
            connectionStatus = await connect();
          }
          if (connectionStatus == 1) {
            var result = await SqlConn.readData(query);
            if (result != null) {
              List decoded = jsonDecode(result);
              return decoded.map((e) => TblDkMaterialCount.fromJson(e)).toList();
            }
          }
        }
      } catch (e) {
        debugPrint("PrintError from getCurrentCounts(): ${e.toString()}");
      }
    }
    return [];
  }

  Future<bool> checkCountPassword(String countPassword, VDkMatCountParams params) async{
    String dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss').format(params.CountDate!);
    if (host.isNotEmpty && port > 0 && dbUName.isNotEmpty &&
        dbUPass.isNotEmpty && dbName.isNotEmpty) {
      try {
        int connectionStatus = 1;
        if (!SqlConn.isConnected) {
          connectionStatus = await connect();
        }
        if (connectionStatus == 1) {
          var result = await SqlConn.readData("""
          select Top(1) * from tbl_mg_material_count
        where 
        JSON_VALUE(mat_count_params, '\$.CountPass') = CONVERT(varchar(128), HASHBYTES('SHA2_512', '$countPassword'), 2)
        AND JSON_VALUE(mat_count_params, '\$.CountDate') = '$dateFormatter'
        AND JSON_VALUE(mat_count_params, '\$.CountType') = '${params.CountType}'
        AND JSON_VALUE(mat_count_params, '\$.WhId') = ${params.WhId}
        AND JSON_VALUE(mat_count_params, '\$.CountPass') = '${params.CountPass}'
        AND JSON_VALUE(mat_count_params, '\$.Note1') = '${params.Note1}'
        AND JSON_VALUE(mat_count_params, '\$.Note2') = '${params.Note2}'
        AND JSON_VALUE(mat_count_params, '\$.WhName') = '${params.WhName}'
        for json path          
        """);
          if (result != null) {
            List decoded = jsonDecode(result);
            if (decoded.isNotEmpty){
              return true;
            }
            else {
              return false;
            }
          }
        }
      }on PlatformException catch (e) {
        debugPrint("PrintError from checkCountPassword(): ${e.toString()}");
      }catch(e){
        debugPrint("PrintError on checkCountPassword: ${e.toString()}");
        rethrow;
      }
    }
    return false;
  }

  Future<List<VDkMaterialCount>> getMaterialCounts(VDkMatCountParams params, int materialId) async{
    String countDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(params.CountDate!);
    String query = ''' 
    select mb.material_name AS MatName,mb.material_code AS MatCode,mb.unit_id AS UnitId,mb.sale_price AS SalePrice,
    mb.mat_purch_price AS PurchasePrice,mb.bar_barcode AS BarcodeValue,mb.unit_det_code AS UnitDetCode,
    mb.spe_code AS SpeCode,mb.group_code AS GroupCode,mb.security_code AS SecurityCode,mb.mat_whousetotal_amount AS MatWhTotalAmount,
    t.T_User_Name as UName,t.T_ID as UserId,mc.count_id as CountId,mc.material_id as MatId,mc.material_count_total as MatCountTotal,
    mc.material_count_date as MatCountDate,mc.material_count_diff as MatCountDiff,mc.device_id as DeviceId,mc.material_count_desc as MatCountDescription,
    mc.wh_id as WhId,mc.unit_det_id as UnitDetId,mc.count_id_guid as CountIdGuid,mc.mat_count_params as MatCountParams  
	  FROM tbl_mg_material_count mc
    LEFT OUTER JOIN v_mg_materials_bar_all mb ON mb.material_id = mc.material_id AND mb.wh_id = mc.wh_id
    LEFT OUTER JOIN dbo.Teachers t on t.T_ID = mc.T_ID
    where mc.material_id= $materialId 
      AND JSON_VALUE(mc.mat_count_params, '\$.CountPass') = '${params.CountPass}'
      AND JSON_VALUE(mc.mat_count_params, '\$.CountDate') = '$countDate'
      AND JSON_VALUE(mc.mat_count_params, '\$.CountType') = '${params.CountType}'
      AND JSON_VALUE(mc.mat_count_params, '\$.WhId') = ${params.WhId}
      AND JSON_VALUE(mc.mat_count_params, '\$.Note1') = '${params.Note1}'
      AND JSON_VALUE(mc.mat_count_params, '\$.Note2') = '${params.Note2}'
      AND JSON_VALUE(mc.mat_count_params, '\$.WhName') = '${params.WhName}'
      AND JSON_VALUE(mc.mat_count_params, '\$.UserName') = '${params.UserName}' 
      AND JSON_VALUE(mc.mat_count_params, '\$.DeviceName') = '${params.DeviceName}'  
      for json path  
        ''';
    if (host.isNotEmpty && port > 0 && dbUName.isNotEmpty &&
        dbUPass.isNotEmpty && dbName.isNotEmpty) {
      try {
        int connectionStatus = 1;
        if (!SqlConn.isConnected) {
          connectionStatus = await connect();
        }
        if (connectionStatus == 1) {
          int connectionStatus = 1;
          if (!SqlConn.isConnected) {
            connectionStatus = await connect();
          }
          if (connectionStatus == 1) {
            var result = await SqlConn.readData(query);
            if (result != null) {
              List decoded = jsonDecode(result);
              return decoded.map((e) => VDkMaterialCount.fromMap(e)).toList();
            }
          }
        }
      } catch (e) {
        debugPrint("PrintError from getMaterialCounts(): ${e.toString()}");
      }
    }
    return [];
  }

  Future<List<VDkMaterialCount>> getProductCountsForOpened(VDkMatCountParams params, int materialId) async{
    String countDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(params.CountDate!);
    String query = ''' 
        select mb.material_name AS MatName,
    mb.material_id AS MatId,
    mb.material_code AS MatCode,
    mb.unit_id AS UnitId,
    mb.sale_price AS SalePrice,
    mb.mat_purch_price AS PurchasePrice,
    mb.wh_id AS WhId,
    mb.unit_det_id AS UnitDetId,
    mb.bar_barcode AS BarcodeValue,
    mb.unit_det_code AS UnitDetCode,
    mb.spe_code AS SpeCode,
    mb.group_code AS GroupCode,
    mb.security_code AS SecurityCode,
    t.T_User_Name as UName,
    t.T_ID as UserId,
  	mc.count_id as CountId,
    mc.material_id as MatId,
    mc.material_count_total as MatCountTotal,
    mc.material_count_date as MatCountDate,
    mc.material_count_diff as MatCountDiff,
    mc.device_id as DeviceId,
    mc.material_count_desc as MatCountDescription,
    mc.wh_id as WhId,
    mc.unit_det_id as UnitDetId,
    mc.count_id_guid as CountIdGuid,
    mc.mat_whousetotal_amount AS MatWhTotalAmount,
    mc.mat_count_params as MatCountParams  
	FROM tbl_mg_material_count mc
LEFT OUTER JOIN v_mg_materials_bar_all mb ON mb.material_id = mc.material_id AND mb.wh_id = mc.wh_id
LEFT OUTER JOIN dbo.Teachers t on t.T_ID = mc.T_ID
        where mc.material_id= $materialId 
        and JSON_VALUE(mc.mat_count_params, '\$.CountPass') = '${params
            .CountPass}'
        AND JSON_VALUE(mc.mat_count_params, '\$.CountDate') = '$countDate'
        AND JSON_VALUE(mc.mat_count_params, '\$.CountType') = '${params
            .CountType}'
        AND JSON_VALUE(mc.mat_count_params, '\$.WhId') = ${params.WhId}
        AND JSON_VALUE(mc.mat_count_params, '\$.Note1') = '${params.Note1}'
        AND JSON_VALUE(mc.mat_count_params, '\$.Note2') = '${params.Note2}'
        AND JSON_VALUE(mc.mat_count_params, '\$.WhName') = '${params.WhName}'
        AND JSON_VALUE(mc.mat_count_params, '\$.UserName') = '${params.UserName}' 
        AND JSON_VALUE(mc.mat_count_params, '\$.DeviceName') = '${params
            .DeviceName}'    
            for json path
        ''';
    if (host.isNotEmpty && port > 0 && dbUName.isNotEmpty &&
        dbUPass.isNotEmpty && dbName.isNotEmpty) {
      try {
        int connectionStatus = 1;
        if (!SqlConn.isConnected) {
          connectionStatus = await connect();
        }
        if (connectionStatus == 1) {
          int connectionStatus = 1;
          if (!SqlConn.isConnected) {
            connectionStatus = await connect();
          }
          if (connectionStatus == 1) {
            var result = await SqlConn.readData(query);
            if (result != null) {
              List decoded = jsonDecode(result);
              return decoded.map((e) => VDkMaterialCount.fromMap(e)).toList();
            }
          }
        }
      } catch (e) {
        debugPrint("PrintError from getMaterialCounts(): ${e.toString()}");
      }
    }
    return [];
  }

}




