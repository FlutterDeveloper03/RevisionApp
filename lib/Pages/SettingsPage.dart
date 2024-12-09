// ignore_for_file: file_names, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:revision_app/Pages/LoginPage.dart';
import 'package:revision_app/bloc/LanguageBloc.dart';
import 'package:revision_app/bloc/LoginPageBloc.dart';
import 'package:revision_app/bloc/SettingsPageBloc.dart';
import 'package:revision_app/helpers/SharedPrefKeys.dart';
import 'package:revision_app/helpers/appLanguage.dart';
import 'package:revision_app/helpers/localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController servNameContrl;
  late TextEditingController serverUNameContrl;
  late TextEditingController serverUPassContrl;
  late TextEditingController dbNameContrl;
  bool unlock = false;
  Icon lockIcon = const Icon(Icons.lock_outline_sharp);
  bool _isPasswordVisible = false;
  @override
  void initState() {
    super.initState();
    servNameContrl = TextEditingController();
    dbNameContrl = TextEditingController();
    serverUNameContrl = TextEditingController();
    serverUPassContrl = TextEditingController();
    getServerData();
  }

  @override
  void dispose() {
    servNameContrl.dispose();
    dbNameContrl.dispose();
    serverUNameContrl.dispose();
    serverUPassContrl.dispose();
    super.dispose();
  }

  Future<void> getServerData() async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    servNameContrl.text = sharedPref.getString(SharedPrefKeys.serverAddress) ?? "";
    serverUNameContrl.text = sharedPref.getString(SharedPrefKeys.dbUName) ?? "";
    serverUPassContrl.text = sharedPref.getString(SharedPrefKeys.dbUPass) ?? "";
    dbNameContrl.text = sharedPref.getString(SharedPrefKeys.dbName) ?? "";
  }

  Future<void> changeIcon() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(SharedPrefKeys.settingsPassword) && prefs.containsKey(SharedPrefKeys.settingsPassConfirmation)) {
      lockIcon = const Icon(Icons.lock_outline_sharp);
      setState(() {});
    } else {
      lockIcon = const Icon(Icons.lock_open_outlined);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final trs = AppLocalizations.of(context);
    Size size = MediaQuery.of(context).size;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).canvasColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: Text(trs.translate("settings") ?? "Settings"),
          titleTextStyle: TextStyle(
            color: Theme.of(context).cardColor,
            fontSize: 20
          ),
          leading: IconButton(
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).cardColor),
          ),
          actions: [
            IconButton(
                color: Theme.of(context).cardColor,
                onPressed: () async{
                  final prefs = await SharedPreferences.getInstance();
                  if (prefs.containsKey(SharedPrefKeys.settingsPassword) && prefs.containsKey(SharedPrefKeys.settingsPassConfirmation)) {
                    _unlockDialog(context);
                  } else {
                    bool result = await _passwordCreateDialog(context);
                    if(!result) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(backgroundColor: Colors.deepOrangeAccent,duration: const Duration(milliseconds: 800),
                              content: Text(trs.translate("snack_password") ?? "Your fields are empty or the given password is incorrect!"))
                      );
                    }
                  }
                },
                icon: lockIcon
            )
          ],
        ),
        body: BlocConsumer<SettingsPageBloc,SettingsPageState>(
          listener: (BuildContext context, SettingsPageState state) {
            if(state is InitialSettingPageState){
              BlocProvider.of<SettingsPageBloc>(context).add(LoadSettingsPageEvent());
            }
            else if(state is ErrorSaveServerSettingsState){
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(backgroundColor: Colors.deepOrangeAccent,
                      content: Text(trs.translate("error_text") ?? "Error")));
            }
            else if(state is LoadErrorSettingsState){
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(backgroundColor: Colors.deepOrangeAccent,
                      content: Text(trs.translate("error_text") ?? "Error"))
              );
              BlocProvider.of<SettingsPageBloc>(context).add(LoadSettingsPageEvent());
            }
            else if(state is ServerSettingsSavedState){
              BlocProvider.of<LoginPageBloc>(context).add(UserLogOutEvent());
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (
                      context) => const LoginPage()));
            }
          },
              builder: (context,state) {
                if (state is SettingsPageLoadedState) {
                  AppLanguage language =
                  state.getAppLanguages.firstWhere((element) =>
                  element.langCode == (BlocProvider
                      .of<LanguageBloc>(context)
                      .state).locale.languageCode);
                  return Padding
                    (
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 20),
                          child: Container(
                            height: size.height / 3.8,
                            decoration: BoxDecoration(
                                color: Theme
                                    .of(context)
                                    .cardColor,
                                borderRadius: BorderRadius.circular(5),
                                boxShadow: [
                                  BoxShadow(
                                      color: Theme
                                          .of(context)
                                          .dividerColor,
                                      blurRadius: 2,
                                      offset: const Offset(1, 1)
                                  )
                                ]
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 7.0, right: 4),
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: Icon(
                                        Icons.phone_iphone_rounded, color: Theme
                                        .of(context)
                                        .primaryColor),
                                    title: Text(trs.translate("deviceName") ??
                                        "Device name",
                                      style: const TextStyle(fontSize: 16),),
                                    horizontalTitleGap: 9,
                                    trailing: FittedBox(
                                      fit: BoxFit.fitWidth,
                                      child: Text(state.deviceName,
                                          style: const TextStyle(fontSize: 13)
                                      ),
                                    ),
                                  ),
                                  Divider(color: Theme
                                      .of(context)
                                      .dividerColor),
                                  ListTile(
                                    leading: Icon(
                                        Icons.phone_iphone_rounded, color: Theme
                                        .of(context)
                                        .primaryColor),
                                    title: Text(
                                      trs.translate("device_id") ?? "Device ID",
                                      style: const TextStyle(fontSize: 16),),
                                    horizontalTitleGap: 9,
                                    trailing: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(state.deviceId,
                                          style: const TextStyle(fontSize: 13)
                                      ),
                                    ),
                                  ),
                                  Divider(color: Theme
                                      .of(context)
                                      .dividerColor),
                                  ListTile(
                                    leading: Icon(
                                        Icons.phone_iphone_rounded, color: Theme
                                        .of(context)
                                        .primaryColor),
                                    title: Text(
                                      trs.translate("version") ?? "Version",
                                      style: const TextStyle(fontSize: 16),),
                                    horizontalTitleGap: 9,
                                    trailing: Text(state.version,
                                        style: const TextStyle(fontSize: 13)
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 3),
                          child: Container(
                            height: size.height / 4.3,
                            decoration: BoxDecoration(
                                color: Theme
                                    .of(context)
                                    .cardColor,
                                borderRadius: BorderRadius.circular(5),
                                boxShadow: [
                                  BoxShadow(
                                      color: Theme
                                          .of(context)
                                          .dividerColor,
                                      blurRadius: 2,
                                      offset: const Offset(1, 1)
                                  )
                                ]
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 7, horizontal: 8),
                              child: SingleChildScrollView(
                                child: Column(
                                    children: state.getAppLanguages.map((e) {
                                      return Padding(
                                        padding: e.langCode == 'ru'
                                            ? const EdgeInsets.symmetric(
                                            vertical: 7.0)
                                            : EdgeInsets.zero,
                                        child: Container(
                                          decoration: BoxDecoration(
                                              border: Border(
                                                  bottom: e.langCode == 'en'
                                                      ? const BorderSide(
                                                      color: Colors.transparent)
                                                      : BorderSide(color: Theme
                                                      .of(context)
                                                      .dividerColor)
                                              )
                                          ),
                                          child: RadioListTile<AppLanguage>(
                                            value: e,
                                            groupValue: language,
                                            onChanged: (value) {
                                              BlocProvider.of<LanguageBloc>(
                                                  context).add(
                                                  LanguageSelected(
                                                      value?.langCode ?? "tk"));
                                            },
                                            title: Row(
                                              children: [
                                                Image.asset("assets/images/${e
                                                    .langCode}.png"),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .only(left: 15),
                                                  child: Text(trs.translate(
                                                      e.langCode.toString()) ??
                                                      e.langName.toString(),
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.black),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            controlAffinity: ListTileControlAffinity
                                                .trailing,
                                            tileColor: Theme
                                                .of(context)
                                                .cardColor,
                                            fillColor: MaterialStateProperty
                                                .resolveWith((states) {
                                              if (states.contains(
                                                  MaterialState.selected)) {
                                                return Theme
                                                    .of(context)
                                                    .primaryColor;
                                              } else {
                                                return Theme
                                                    .of(context)
                                                    .dividerColor;
                                              }
                                            }),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius
                                                  .circular(5),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList()
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 20),
                          child: Container(
                            width: size.width,
                            decoration: BoxDecoration(
                                color: Theme
                                    .of(context)
                                    .cardColor,
                                borderRadius: BorderRadius.circular(5),
                                boxShadow: [BoxShadow(
                                    color: Theme
                                        .of(context)
                                        .dividerColor,
                                    blurRadius: 2,
                                    offset: const Offset(1, 1)
                                )
                                ]
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        10, 25, 10, 0),
                                    child: TextField(
                                      controller: servNameContrl,
                                      onSubmitted: (value) {
                                        servNameContrl.text = value;
                                      },
                                      decoration: InputDecoration(
                                        label: Text(
                                            trs.translate("server_name") ??
                                                "Server name"),
                                        floatingLabelStyle: const TextStyle(
                                            color: Color(0xff0398A2)),
                                        alignLabelWithHint: true,
                                        enabledBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xffCDCDCD)),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5.0)
                                          ),
                                        ),
                                        focusedBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Color(0xff0398A2)),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5.0))
                                        ),
                                        border: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Color(0xffCDCDCD)),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5.0))
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0, vertical: 15),
                                    child: TextField(
                                      controller: serverUNameContrl,
                                      onTap: () {},
                                      decoration: InputDecoration(
                                        label: Text(
                                            trs.translate("server_user") ??
                                                "Server user"),
                                        floatingLabelStyle: const TextStyle(
                                            color: Color(0xff0398A2)),
                                        alignLabelWithHint: true,
                                        enabledBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xffCDCDCD)),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5.0)
                                          ),
                                        ),
                                        focusedBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Color(0xff0398A2)),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5.0))
                                        ),
                                        border: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Color(0xffCDCDCD)),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5.0))
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child: TextField(
                                      controller: serverUPassContrl,
                                      obscureText: !_isPasswordVisible,
                                      obscuringCharacter: "*",
                                      onTap: () {},
                                      decoration: InputDecoration(
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _isPasswordVisible = !_isPasswordVisible;
                                            });
                                          },
                                        ),
                                        label: Text(
                                            trs.translate("server_password") ??
                                                "Server password"),
                                        floatingLabelStyle: const TextStyle(
                                            color: Color(0xff0398A2)),
                                        alignLabelWithHint: true,
                                        enabledBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xffCDCDCD)),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5.0)
                                          ),
                                        ),
                                        focusedBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Color(0xff0398A2)),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5.0))
                                        ),
                                        border: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Color(0xffCDCDCD)),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5.0))
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0, vertical: 20),
                                    child: TextField(
                                      controller: dbNameContrl,
                                      onTap: () {},
                                      decoration: InputDecoration(
                                        label: Text(
                                            trs.translate("dataBaseName") ??
                                                "Database name"),
                                        floatingLabelStyle: const TextStyle(
                                            color: Color(0xff0398A2)),
                                        alignLabelWithHint: true,
                                        enabledBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xffCDCDCD)),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5.0)
                                          ),
                                        ),
                                        focusedBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Color(0xff0398A2)),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5.0))
                                        ),
                                        border: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Color(0xffCDCDCD)),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5.0))
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0, vertical: 20),
                                    child: TextButton(
                                      onPressed: () {
                                        BlocProvider.of<SettingsPageBloc>(
                                            context).add(
                                            SaveServerSettingsEvent(
                                                servNameContrl.text, 1433,
                                                serverUNameContrl.text,
                                                serverUPassContrl.text,
                                                dbNameContrl.text));
                                      },
                                      style: TextButton.styleFrom(
                                        backgroundColor: Theme
                                            .of(context)
                                            .primaryColor,
                                        fixedSize: Size(
                                            size.width, size.height / 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              5),
                                        ),
                                      ),
                                      child: Text(
                                        trs.translate("save") ?? "Save",
                                        style: TextStyle(
                                          color: Theme
                                              .of(context)
                                              .cardColor,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              }
        ),
      ),
    );
  }
  Future<bool> _passwordCreateDialog(BuildContext context) async {
    final trs = AppLocalizations.of(context);
    Size size = MediaQuery.of(context).size;
    TextEditingController passwordCtrl = TextEditingController();
    TextEditingController confirmCtrl = TextEditingController();
    bool isPasswordVisible = false;
    bool isPasswordVisible2 = false;
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          surfaceTintColor: Colors.transparent,
          backgroundColor: Theme.of(context).cardColor,
          titlePadding: const EdgeInsets.only(bottom: 20),
          titleTextStyle: TextStyle(fontSize: 22, color: Theme.of(context).cardColor),
          title: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(30),
                topLeft: Radius.circular(30),
              ),
            ),
            width: size.width,
            height: size.height / 11,
            alignment: Alignment.center,
            child: Text(trs.translate("create_password") ?? "Create the password"),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter set) {
            return SizedBox(
              height: size.height / 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      controller: passwordCtrl,
                      obscureText: !isPasswordVisible,
                      obscuringCharacter: "*",
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            set(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                        ),
                        isDense: true,
                        label: Text(trs.translate("password") ?? "Password"),
                        floatingLabelStyle: const TextStyle(color: Color(0xff0398A2)),
                        alignLabelWithHint: true,
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xffCDCDCD)),
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff0398A2)),
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        ),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xffCDCDCD)),
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      controller: confirmCtrl,
                      obscureText: !isPasswordVisible2,
                      obscuringCharacter: "*",
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordVisible2 ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            set(() {
                              isPasswordVisible2 = !isPasswordVisible2;
                            });
                          },
                        ),
                        isDense: true,
                        label: Text(trs.translate("confirm_password") ?? "Confirm the password"),
                        floatingLabelStyle: const TextStyle(color: Color(0xff0398A2)),
                        alignLabelWithHint: true,
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xffCDCDCD)),
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff0398A2)),
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        ),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xffCDCDCD)),
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          passwordCtrl.clear();
                          Navigator.pop(context);
                        },
                        child: Text(
                          trs.translate("cancel") ?? "Cancel",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async{
                          if(passwordCtrl.text.isNotEmpty && confirmCtrl.text.isNotEmpty && passwordCtrl.text==confirmCtrl.text){
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            prefs.setString(SharedPrefKeys.settingsPassword, passwordCtrl.text);
                            prefs.setString(SharedPrefKeys.settingsPassConfirmation, confirmCtrl.text);
                            changeIcon();
                            Navigator.pop(context, true);
                          }
                          else{
                            Navigator.pop(context, false);
                          }
                        },
                        child: Text(
                          trs.translate("confirm") ?? "Confirm",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
      }
          ),
        );
      },
    );
  }

  Future<void> _unlockDialog(BuildContext context) async {
    final trs = AppLocalizations.of(context);
    Size size = MediaQuery.of(context).size;
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, set) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30)
            ),
            surfaceTintColor: Colors.transparent,
            backgroundColor: Theme
                .of(context)
                .cardColor,
            titlePadding: const EdgeInsets.only(bottom: 20),
            titleTextStyle: TextStyle(
                fontSize: 22, color: Theme
                .of(context)
                .cardColor
            ),
            title: Container(
                decoration: BoxDecoration(
                    color: Theme
                        .of(context)
                        .primaryColor,
                    borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(30),
                        topLeft: Radius.circular(30)
                    )
                ),
                width: size.width,
                height: size.height / 11,
                alignment: Alignment.center,
                child: Text(trs.translate("confirmation") ?? "Confirmation")
            ),
            content: Text(trs.translate("unlock") ?? "Do you really want to unlock?",
              style: const TextStyle(fontSize: 16,),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(trs.translate("cancel") ?? "Cancel",
                  style: TextStyle(fontSize: 15, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.remove(SharedPrefKeys.settingsPassword);
                  prefs.remove(SharedPrefKeys.settingsPassConfirmation);
                  changeIcon();
                  Navigator.pop(context, true);
                },
                child: Text(trs.translate("confirm") ?? "Confirm",
                  style: TextStyle(fontSize: 15, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        });
      },
    );
  }
}
