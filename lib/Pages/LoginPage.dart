// ignore_for_file: file_names, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:revision_app/Pages/HomePage.dart';
import 'package:revision_app/Pages/SettingsPage.dart';
import 'package:revision_app/bloc/LoginPageBloc.dart';
import 'package:revision_app/bloc/SettingsPageBloc.dart';
import 'package:revision_app/helpers/SharedPrefKeys.dart';
import 'package:revision_app/helpers/localization.dart';
import 'package:revision_app/provider/GlobalVarsProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController userController;
  late TextEditingController passController;
  bool counting = false;
  int whId = 0;
  bool _isPasswordVisible = false;
  @override
  void initState() {
    userController = TextEditingController();
    passController = TextEditingController();
    super.initState();
  }

  Future<void> getPrefs() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    counting = prefs.getBool(SharedPrefKeys.countingData) ?? false;
    whId = prefs.getInt(SharedPrefKeys.warehouseId) ?? 0;
  }

  @override
  void dispose() {
    userController.dispose();
    passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trs = AppLocalizations.of(context);
    Size size = MediaQuery.of(context).size;
    GlobalVarsProvider globalVarsProvider = Provider.of<GlobalVarsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        automaticallyImplyLeading: false,
        title: const Text("revision_app"),
        titleTextStyle: TextStyle(color: Theme.of(context).cardColor, fontWeight: FontWeight.w600, fontSize: 20),
        actions: [
          IconButton(
          onPressed: () async{
            SharedPreferences sharedPref = await SharedPreferences.getInstance();
            String password = sharedPref.getString(SharedPrefKeys.settingsPassword) ?? '';
            String confirmation = sharedPref.getString(SharedPrefKeys.settingsPassConfirmation) ?? '';
            if(password.isNotEmpty && confirmation.isNotEmpty){
              bool result = await _passwordConfirmDialog(context);
              if(result){
                BlocProvider.of<SettingsPageBloc>(context).add(LoadSettingsPageEvent());
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
              }
              else{
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(backgroundColor: Colors.deepOrangeAccent,duration: const Duration(milliseconds: 800),
                        content: Text(trs.translate("snack_password") ?? "Your fields are empty or the given password is incorrect!"))
                );
              }
            }
            else{
              bool result = await _passwordCreateDialog(context);
              if(result){
                BlocProvider.of<SettingsPageBloc>(context).add(LoadSettingsPageEvent());
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
              }
              else{
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(backgroundColor: Colors.deepOrangeAccent,duration: const Duration(milliseconds: 800),
                        content: Text(trs.translate("snack_password") ?? "Your fields are empty or the given password is incorrect!"))
                );
              }
            }
          },
          icon: Icon(Icons.settings, color: Theme.of(context).cardColor)
        ),
]
      ),
      body: BlocConsumer<LoginPageBloc, LoginPageState>(
        listener: (context, state) async{
          if(state is LoginSuccess) {
            globalVarsProvider.setUser = state.user;
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const HomePage()));
          }
          else if (state is LoginFailure){
            debugPrint("${trs.translate("error_text") ?? "Error"}: ${state.errorStatus}");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(backgroundColor: Colors.deepOrangeAccent,duration: const Duration(milliseconds: 200),
                  content: Text(trs.translate("error_text") ?? "Error"))
            );
            BlocProvider.of<LoginPageBloc>(context).add(UserLogOutEvent());
          }
        },
        builder: (context, state){
          if(state is LoginProgress){
            return const Center(child: CircularProgressIndicator());
          }
          else if(state is LoginInitial){
    return SingleChildScrollView(
      child: Column(
        children: [
          Stack(
            children: [
              ClipPath(
                clipper: WaveClipper(),
                child: Container(
                  height: MediaQuery.sizeOf(context).height/3.4,
                  color: const Color(0xff0398A2),
                ),
              ),
              Positioned(
                left: 160,
                top: 100,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.center,
                  width: size.width/4,
                  height: size.height/7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Theme.of(context).dividerColor,
                        blurRadius: 5,
                      )
                    ],
                    color: Theme.of(context).cardColor,
                  ),
                  child: Transform.scale(
                    scale: 1.5,
                      child: Image.asset('assets/images/revision_app.png')
                  )
                ),
              ),
            ],
          ),
          const Text("revision_app",
            style: TextStyle(color: Color(0xff434343), fontSize: 32),
          ),
          const Divider(indent: 80, endIndent: 80, thickness: 2,),
          Text(trs.translate("revision_program") ?? "Revision program",
            style: const TextStyle(color: Color(0xff747474), fontSize: 16),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 50),
            child: Container(
              width: size.width,
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: const Color(0xff0398A2),
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0,3)
                    )
                  ]
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20),
                    child: TextField(
                      controller: userController,
                      onTap: (){},
                      decoration: InputDecoration(
                        label: Text(trs.translate('username') ?? "Username"),
                        floatingLabelStyle: const TextStyle(color: Color(0xff0398A2)),
                        alignLabelWithHint: true,
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xffCDCDCD)),
                          borderRadius: BorderRadius.all(
                              Radius.circular(5.0)
                          ),
                        ),
                        focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xffCDCDCD)),
                            borderRadius: BorderRadius.all(
                                Radius.circular(5.0))
                        ),
                        border: const OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xffCDCDCD)),
                            borderRadius: BorderRadius.all(
                                Radius.circular(5.0))
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: TextField(
                      controller: passController,
                      obscureText: !_isPasswordVisible,
                      obscuringCharacter: "*",
                      onTap: (){},
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
                        label: Text(trs.translate("password") ?? "Password"),
                        floatingLabelStyle: const TextStyle(color: Color(0xff0398A2)),
                        alignLabelWithHint: true,
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xffCDCDCD)),
                          borderRadius: BorderRadius.all(
                              Radius.circular(5.0)
                          ),
                        ),
                        focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff0398A2)),
                            borderRadius: BorderRadius.all(
                                Radius.circular(5.0))
                        ),
                        border: const OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xffCDCDCD)),
                            borderRadius: BorderRadius.all(
                                Radius.circular(5.0))
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 50),
                    child: TextButton(
                      onPressed: (){
                        BlocProvider.of<LoginPageBloc>(context).add(UserLogInEvent(username: userController.text, password: passController.text),
                        );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        fixedSize: Size(size.width, size.height/16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: Text(trs.translate("logIn") ?? "Log in",
                        style: TextStyle(
                          color: Theme.of(context).cardColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
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
    );
  }
}
Future<bool> _passwordConfirmDialog(BuildContext context) async {
  final trs = AppLocalizations.of(context);
  Size size = MediaQuery.of(context).size;
  TextEditingController confirmCtrl = TextEditingController();
  bool isPasswordVisible = false;
  return await showDialog(
    context: context,
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
          child: Text(trs.translate("confirm_password") ?? "Confirm the password"),
        ),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter set) {
          return SizedBox(
            height: size.height / 6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: confirmCtrl,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        confirmCtrl.clear();
                        Navigator.pop(context, false);
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
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        String password = prefs.getString(SharedPrefKeys.settingsPassword) ?? '';
                        if(password==confirmCtrl.text){
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
                      label: Text(trs.translate("confirm_password") ?? "Confirm Password"),
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

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, 230);
    path.quadraticBezierTo(size.width / 4, 150, size.width / 2, 155);
    path.quadraticBezierTo(4 / 5 * size.width, 150, size.width, 80);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
