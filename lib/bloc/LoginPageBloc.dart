// ignore_for_file: file_names

import 'package:bloc/bloc.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:revision_app/helpers/SharedPrefKeys.dart';
import 'package:revision_app/models/tbl_dk_user.dart';
import 'package:revision_app/services/dbService.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class LoginPageEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class UserLogInEvent extends LoginPageEvent {
  final String username;
  final String password;

  UserLogInEvent({required this.username, required this.password});

  @override
  List<Object> get props => [username, password];

  @override
  String toString() => "UserLoginEvent { username: $username, password:$password}";
}

class UserLogOutEvent extends LoginPageEvent {}
// endregionEvents

//region States
class LoginPageState extends Equatable{
  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginPageState {}

class LoginSuccess extends LoginPageState {
  final TblDkUser user;

  LoginSuccess(this.user);

  TblDkUser get getUser => user;

  @override
  List<Object> get props => [user];
}

class LoginFailure extends LoginPageState {
  final String errorStatus;

  LoginFailure(this.errorStatus);

  String get getErrorStatus => errorStatus;


  @override
  List<Object> get props => [errorStatus];

  @override
  String toString() => "LoginFailureState { errorStatus: $errorStatus }";

}

class LoginProgress extends LoginPageState {}

//endregion States

class LoginPageBloc extends Bloc<LoginPageEvent, LoginPageState> {
  DbService? _srv;
  String host = '';
  int port = 1433;
  String dbName = '';
  String dbUName = '';
  String dbUPass = '';
  LoginPageBloc():super(LoginInitial()){
    on<UserLogInEvent>(onUserLogin);
    on<UserLogOutEvent>((event, emit) => emit(LoginInitial()));
  }

  @override
  void onTransition(Transition<LoginPageEvent, LoginPageState> transition){
    super.onTransition(transition);
    debugPrint(transition.toString());
}

void onUserLogin(UserLogInEvent event, Emitter<LoginPageState> emit) async {
    emit(LoginProgress());
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      String deviceName = '${androidInfo.brand} ${androidInfo.device}';
      host = prefs.getString(SharedPrefKeys.serverAddress) ?? "";
      port = prefs.getInt(SharedPrefKeys.serverPort) ?? 1433;
      dbName = prefs.getString(SharedPrefKeys.dbName) ?? "";
      dbUName = prefs.getString(SharedPrefKeys.dbUName) ?? "";
      dbUPass = prefs.getString(SharedPrefKeys.dbUPass) ?? "";
      _srv = DbService(host, port, dbName, dbUName, dbUPass);
      TblDkUser? user = await _srv?.getUserData(event.username, event.password);
      if (user != null) {
        prefs.setInt(SharedPrefKeys.salesmanId, user.EmpId);
        prefs.setInt(SharedPrefKeys.teacherId, user.UId);
        prefs.setInt(SharedPrefKeys.userTypeId, user.UTypeId);
        prefs.setString(SharedPrefKeys.deviceName, deviceName);
        prefs.setString(SharedPrefKeys.userName, user.UName);
        prefs.remove(SharedPrefKeys.countedInvHeadsStartDate);
        prefs.remove(SharedPrefKeys.countedInvHeadsEndDate);
        prefs.remove(SharedPrefKeys.countedInvHeadsSearchText);
        emit(LoginSuccess(user));
        debugPrint("Logged in user: ${user.UName}");
      } else {
        emit(LoginFailure('User is empty'));
      }
    } catch (e) {
        emit(LoginFailure(e.toString()));
  }
}
}

