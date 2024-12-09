// ignore_for_file: file_names

import 'package:device_info_plus/device_info_plus.dart';
import 'package:android_id/android_id.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:revision_app/helpers/SharedPrefKeys.dart';
import 'package:revision_app/helpers/appLanguage.dart';
import 'package:shared_preferences/shared_preferences.dart';

//region Events

class SettingsPageEvent extends Equatable{
  @override
  List<Object> get props => [];
}

class LoadSettingsPageEvent extends SettingsPageEvent{}

class SaveServerSettingsEvent extends SettingsPageEvent{
  final String serverName;
  final int serverPort;
  final String serverUName;
  final String serverUPass;
  final String dbName;

  SaveServerSettingsEvent(this.serverName,this.serverPort, this.serverUName, this.serverUPass,this.dbName);

  @override
  List<Object> get props => [serverName,serverPort, serverUName,serverUPass,dbName];

}

// endregionEvents

//region States
class SettingsPageState extends Equatable{
  @override
  List<Object> get props => [];
}

class LoadingSettingPageState extends SettingsPageState{}
class InitialSettingPageState extends SettingsPageState{}
class ServerSettingsSavedState extends SettingsPageState{
  final String serverName;
  final int serverPort;
  final String serverUName;
  final String serverUPass;
  final String dbName;

  ServerSettingsSavedState(this.serverName,this.serverPort, this.serverUName, this.serverUPass,this.dbName);

  @override
  List<Object> get props => [serverName,serverPort, serverUName,serverUPass,dbName];
}

class SettingsPageLoadedState extends SettingsPageState{
  final List<AppLanguage> _languages;
  final String serverName;
  final int serverPort;
  final String serverUName;
  final String serverUPass;
  final String dbName;
  final String deviceId;
  final String deviceName;
  final String version;
  SettingsPageLoadedState(this._languages, this.serverName, this.serverPort, this.serverUName, this.serverUPass, this.dbName, this.deviceId, this.deviceName, this.version,);

  List<AppLanguage> get getAppLanguages=>_languages;

  @override
  List<Object> get props => [_languages,serverName,serverPort, serverUName,serverUPass,dbName, deviceId, deviceName, version];
}

class LoadErrorSettingsState extends SettingsPageState{
  final String errorText;

  LoadErrorSettingsState(this.errorText);


  String get getErrorText=>errorText;

  @override
  List<Object> get props => [errorText];
}

class SavingServerSettingsState extends SettingsPageState{}

class ErrorSaveServerSettingsState extends SettingsPageState{
  final String errorText;

  ErrorSaveServerSettingsState(this.errorText);

  String get getErrorText=>errorText;

  @override
  List<Object> get props => [errorText];
}

//endregion States

class SettingsPageBloc extends Bloc<SettingsPageEvent,SettingsPageState>{
  String _serverName="";
  int _serverPort=1433;
  String _serverUName="";
  String _serverUPass="";
  String _dbName="";
  String deviceId="";
  String deviceName="";
  String version="";
  SettingsPageBloc():super(InitialSettingPageState()){
    on<LoadSettingsPageEvent>(loadSettings);
    on<SaveServerSettingsEvent>(saveServerSettings);
  }

  @override
  void onTransition(Transition<SettingsPageEvent, SettingsPageState> transition){
    super.onTransition(transition);
    debugPrint(transition.toString());
  }

  void loadSettings(LoadSettingsPageEvent event, Emitter<SettingsPageState> emit) async{
    List<AppLanguage> appLanguages=[];
    emit(LoadingSettingPageState());
    try{
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceId = await const AndroidId().getId() ?? '';
      final info = await PackageInfo.fromPlatform();
      version = info.version;
      deviceName = '${androidInfo.brand} ${androidInfo.device}';
      final sharedPref = await SharedPreferences.getInstance();
      _serverName = sharedPref.getString(SharedPrefKeys.serverAddress) ?? "";
      _serverPort = sharedPref.getInt(SharedPrefKeys.serverPort) ?? 1433;
      _serverUName = sharedPref.getString(SharedPrefKeys.dbUName) ?? "";
      _serverUPass = sharedPref.getString(SharedPrefKeys.dbUPass) ?? "";
      _dbName = sharedPref.getString(SharedPrefKeys.dbName) ?? "";

      //region Languages
      appLanguages.add(AppLanguage('Türkmen', 'tk', 'TM')
      );
      appLanguages.add(AppLanguage('Русский', 'ru', 'RU')
      );
      appLanguages.add(AppLanguage('English', 'en', 'US')
      );
      //endRegion Languages

      emit(SettingsPageLoadedState(appLanguages,_serverName,_serverPort,_serverUName,_serverUPass,_dbName,deviceId,deviceName, version));
    } catch (ex){
      emit(LoadErrorSettingsState(ex.toString()));
    }


  }

  void saveServerSettings(SaveServerSettingsEvent event, Emitter<SettingsPageState> emit) async {
    emit(SavingServerSettingsState());
    try {
      final sharedPref = await SharedPreferences.getInstance();
      _serverName = event.serverName;
      _serverPort = event.serverPort;
      _serverUName = event.serverUName;
      _serverUPass = event.serverUPass;
      _dbName = event.dbName;
      sharedPref.setString(SharedPrefKeys.serverAddress, _serverName);
      sharedPref.setInt(SharedPrefKeys.serverPort, _serverPort);
      sharedPref.setString(SharedPrefKeys.dbUName, _serverUName);
      sharedPref.setString(SharedPrefKeys.dbUPass, _serverUPass);
      sharedPref.setString(SharedPrefKeys.dbName, _dbName);
      emit(ServerSettingsSavedState(_serverName,_serverPort,_serverUName,_serverUPass,_dbName));
    } on Exception catch (e) {
      emit(ErrorSaveServerSettingsState(e.toString()));
    }
  }
}