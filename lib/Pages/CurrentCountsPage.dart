// ignore_for_file: file_names, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:revision_app/Pages/HomePage.dart';
import 'package:revision_app/Pages/ListDataPage.dart';
import 'package:revision_app/Pages/ListPage.dart';
import 'package:revision_app/bloc/CurrentCountsPageBloc.dart';
import 'package:revision_app/bloc/ListDataPageBloc.dart';
import 'package:revision_app/bloc/ListPageBLoc.dart';
import 'package:revision_app/helpers/SharedPrefKeys.dart';
import 'package:revision_app/helpers/localization.dart';
import 'package:revision_app/models/v_dk_mat_count_params.dart';
import 'package:revision_app/provider/GlobalVarsProvider.dart';

class CurrentCountsPage extends StatelessWidget {
  final CurrentCountsBloc currentCountsBloc;

  CurrentCountsPage({super.key}) : currentCountsBloc = CurrentCountsBloc();

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: currentCountsBloc,
      child: const CurrentCountsView(),
    );
  }
}

class CurrentCountsView extends StatefulWidget {
  const CurrentCountsView({super.key});

  @override
  State<CurrentCountsView> createState() => _CurrentCountsViewState();
}

class _CurrentCountsViewState extends State<CurrentCountsView> {
  bool hasText = false;
  TextEditingController searchContrl = TextEditingController();
  List<VDkMatCountParams> params = [];

  @override
  void initState() {
    searchContrl.addListener(() {
      setState(() {
        hasText = searchContrl.text.isNotEmpty;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    searchContrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trs = AppLocalizations.of(context);
    GlobalVarsProvider globalProvider =
    Provider.of<GlobalVarsProvider>(context);

    return PopScope(
      canPop: false,
        onPopInvoked: (didPop) {
          Navigator.push(context,MaterialPageRoute(builder: (context) => const HomePage()));
        },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        floatingActionButton: FloatingActionButton.extended(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () {
            BlocProvider.of<ListDataPageBloc>(context)
                .add(LoadListDataEvent());
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ListDataPage()));
          },
          label: Text(
            trs.translate("newCount") ?? "New count",
            style: TextStyle(color: Theme.of(context).cardColor, fontSize: 15),
          ),
        ),
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).cardColor),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()));
            },
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(trs.translate("current_counts") ?? "Current Counts"),
            ],
          ),
          titleTextStyle:
          TextStyle(color: Theme.of(context).cardColor, fontSize: 20),
        ),
        body: BlocConsumer<CurrentCountsBloc, CurrentCountsState>(
          listener: (BuildContext context, CurrentCountsState state) async {
            if (state is PasswordConfirmedState) {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString(SharedPrefKeys.countPass, state.countPass);
              prefs.setBool(SharedPrefKeys.newCount, false);
              BlocProvider.of<ListPageBloc>(context)
                  .add(LoadListEvent(state.params));
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ListPage(params: state.params, provider: globalProvider)),
              );
            } else if (state is CurrentCountsLoadedState) {
              globalProvider.setMatCountParams = state.params;
              params = state.params;
            } else if (state is ConfirmPasswordErrorState) {
              _passwordErrorDialog(context);
            }
          },
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () async {
                BlocProvider.of<CurrentCountsBloc>(context)
                    .add(LoadCurrentCountsEvent());
              },
              child: state is LoadingCurrentCountsState
                  ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ],
              )
                  : state is CurrentCountsLoadErrorState
                  ? Center(
                child: Column(
                  children: [
                    Text(
                        "${trs.translate("load_error") ?? "Loading error"}: ${state.errorText}"),
                    TextButton(
                        onPressed: () {
                          BlocProvider.of<CurrentCountsBloc>(context)
                              .add(LoadCurrentCountsEvent());
                        },
                        child: Text(
                          trs.translate("try_again") ?? "Try again",
                          style: TextStyle(
                              color: Theme.of(context).primaryColor),
                        ))
                  ],
                ),
              )
                  : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: globalProvider.getMatCountParams.length,
                itemBuilder: (context, index) {
                  return CurrentCountsItem(
                    matCountParam:
                    globalProvider.getMatCountParams[index],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Future<bool> _passwordErrorDialog(BuildContext context) async {
    final trs = AppLocalizations.of(context);
    Size size = MediaQuery.of(context).size;
    return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          surfaceTintColor: Colors.transparent,
          backgroundColor: Theme.of(context).cardColor,
          titlePadding: const EdgeInsets.only(bottom: 20),
          titleTextStyle:
          TextStyle(fontSize: 20, color: Theme.of(context).cardColor),
          title: Container(
              decoration: const BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30),
                      topLeft: Radius.circular(30))),
              width: size.width,
              height: size.height / 15,
              alignment: Alignment.center,
              child: Text(trs.translate("error_text") ?? "Error")),
          content: SizedBox(
            height: size.height / 6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  trs.translate("wrong_pass") ??
                      'The given password is incorrect!',
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red,
                    fixedSize: Size(size.width / 2, size.height / 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Text(
                    trs.translate("ok") ?? "Ok",
                    style: TextStyle(
                      color: Theme.of(context).cardColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CurrentCountsItem extends StatefulWidget {
  final VDkMatCountParams matCountParam;

  const CurrentCountsItem({super.key, required this.matCountParam});

  @override
  State<CurrentCountsItem> createState() => _CurrentCountsItemState();
}

class _CurrentCountsItemState extends State<CurrentCountsItem> {
  @override
  Widget build(BuildContext context) {
    final trs = AppLocalizations.of(context);
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10),
      child: InkWell(
        onTap: () {
          _passwordDialog(context,BlocProvider.of<CurrentCountsBloc>(context), widget.matCountParam);
        },
        child: Container(
          height: size.height / 3,
          decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                    color: Theme.of(context).dividerColor,
                    blurRadius: 2,
                    offset: const Offset(1, 1))
              ]),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${trs.translate("deviceName") ?? "Device name"}:",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Text(widget.matCountParam.DeviceName),
                    )
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${trs.translate("username") ?? "Username"}:",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Text(widget.matCountParam.UserName),
                    )
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${trs.translate("warehouseCondition") ?? "Warehouse condition"}:",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Text(
                          trs.translate(widget.matCountParam.WhType) ?? ""),
                    )
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${trs.translate("countDate") ?? "Date time"}:",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Text(DateFormat('dd-MM-yyyy HH:mm:ss').format(
                          widget.matCountParam.CountDate ?? DateTime.now())),
                    )
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${trs.translate("warehouse") ?? "Warehouse"}:",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Text(widget.matCountParam.WhName),
                    )
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${trs.translate("countType") ?? "Count type"}:",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Text(
                          trs.translate(widget.matCountParam.CountType) ?? ""),
                    )
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${trs.translate("note1") ?? "Note 1"}:",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Text(widget.matCountParam.Note1),
                    )
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${trs.translate("note2") ?? "Note 2"}:",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Text(widget.matCountParam.Note2),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _passwordDialog(BuildContext context, CurrentCountsBloc bloc, VDkMatCountParams params) async {
    final trs = AppLocalizations.of(context);
    Size size = MediaQuery.of(context).size;
    TextEditingController passwordCtrl = TextEditingController();
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
            child: Text(trs.translate("rev_password") ?? "Revision password"),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          passwordCtrl.clear();
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
                        onPressed: () {
                          bloc.add(ConfirmPasswordEvent(passwordCtrl.text, params));
                          Navigator.pop(context, true);
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

}
