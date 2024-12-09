// ignore_for_file: constant_identifier_names, file_names

class SharedPrefKeys {
  SharedPrefKeys._();
  static const String languageCode = 'languageCode';
  static const String serverAddress= 'ServerAddress';
  static const String serverPort= 'ServerPort';
  static const String dbName = 'DbName';
  static const String dbUName = 'DbUName';
  static const String dbUPass = 'DbUPass';
  static const String appLanguage = 'AppLanguage';
  static const String resPriceGroupId = 'ResPriceGroupId';
  static const String resourcesGridType = 'ResourcesGridType';
  static const String gridCrossAxisCnt = 'GridCrossAxisCnt';
  static const String salesman = 'salesman';
  static const String defaultUrl = '192.168.1.200:1433';
  static const String defaultServerPort = '1433';
  static const String defaultDbUName = 'sa';
  static const String defaultDbName = 'akhasap_db';
  static const String socketAddress='socketAddress';
  static const String apiPrefix = 'ApiPrefix';
  static const String lastActivationCheckedDate = 'LastActivatedDate';
  static const String lastActivationCheckedOfflineDate = 'LastActivationOfflineCheckedDate';
  static const String theme = 'theme';
  static const int activationCheckPeriodDays = 30;
  static const String initialPage= 'InitialPage';
  static const String tableId= 'tableId';
  static const String tableName= 'tableName';
  static const String posType= 'PosType'; //1=market, 2=Resto
  static const String dbConnectionMode= 'DbConnectionMode'; //1=online, 2=offline
  static const String imgTimeout= 'ImageTimeout'; //1=online, 2=offline
  static const String DefaultPrintConMode = 'DefaultPrinterConnectionMode'; //1=Bluetooth, 2=IpAddress
  static const String LastConnectedBluetoothDevice = 'LastConnectedBluetoothDevice'; //json
  static const String PrinterModel = 'PrinterModel'; //json
  static const String PrintCount = 'PrintCount';
  static const String warehouseCondition = 'warehouseCondition';
  static const String countingType = 'countingType';
  static const String note1 = 'note1';
  static const String note2 = 'note2';
  static const String countingData = "countingData";
  static const String warehouse = "warehouse";
  static const String warehouseId = "warehouseId";
  static const String salesmanId = "salesmanId";
  static const String teacherId = "teacherId";
  static const String countedDate = "countedDate";
  static const String userTypeId = "userTypeId";
  static const String userName = "userName";
  static const String scrollPosition = "scrollPosition";
  static const String countPass = "countPass";
  static const String newCount = "newCount";
  static const String deviceName = "deviceName";
  static const String settingsPassword = "settingsPassword";
  static const String settingsPassConfirmation = 'settingsPassConfirmation';
  static const String countedInvHeadsStartDate = 'currentCountStartDate';
  static const String countedInvHeadsEndDate = 'currentCountEndDate';
  static const String countedInvHeadsSearchText = 'countedInvHeadsSearchText';
  static const String Company = 'Company';
  static const String RespDeviceAct = 'RespDeviceAct';
}
