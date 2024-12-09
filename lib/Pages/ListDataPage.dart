// ignore_for_file: file_names

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:revision_app/Pages/HomePage.dart';
import 'package:revision_app/Pages/ListPage.dart';
import 'package:revision_app/bloc/ListDataPageBloc.dart';
import 'package:revision_app/bloc/ListPageBLoc.dart';
import 'package:revision_app/helpers/SharedPrefKeys.dart';
import 'package:revision_app/helpers/localization.dart';
import 'package:revision_app/models/tbl_dk_warehouse.dart';
import 'package:revision_app/provider/GlobalVarsProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';



class ListDataPage extends StatefulWidget {

  const ListDataPage({super.key});

  @override
  State<ListDataPage> createState() => _ListDataPageState();
}

List<String> storages = ['centralWarehouse','warehouse1','store'];

class _ListDataPageState extends State<ListDataPage> {
  TextEditingController firstNoteCtrl = TextEditingController();
  TextEditingController secondNoteCtrl = TextEditingController();
  TextEditingController passwordCtrl = TextEditingController();
  TblDkWarehouse? storage;
  String storageStyle='';
  String countStyle='';
  String savedStorage='';
  DateTime dateTime = DateTime.now();
  bool pageOpened = true;
  List<String> countStyles=[];
  List<String> storageStyles = ['closed','opened'];
  bool _isPasswordVisible = false;
  @override
  void initState() {
    super.initState();
    pageOpened = true;
    getNotes();
  }

  @override
  void dispose() {
    firstNoteCtrl.dispose();
    secondNoteCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  Future<SharedPreferences> getPrefs() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs;
  }

  Future<void> getNotes() async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    storageStyle = sharedPref.getString(SharedPrefKeys.warehouseCondition) ?? storageStyles[0];
    if(storageStyle==storageStyles[1]){
      countStyles = ['multiple_count'];
    }
    else{
      countStyles = ['multiple_count','single_count'];
    }
    countStyle = sharedPref.getString(SharedPrefKeys.countingType) ?? countStyles[0];
    savedStorage = sharedPref.getString(SharedPrefKeys.warehouse) ?? "";
  }

  @override
  Widget build(BuildContext context) {
    final trs = AppLocalizations.of(context);
    Size size = MediaQuery.of(context).size;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).primaryColor,
          title: Text(trs.translate("counting_information") ?? "Counting information"),
          titleTextStyle: TextStyle(color: Theme.of(context).cardColor, fontSize: 24),
        ),
        body: BlocListener<ListDataPageBloc,ListDataPageState>(
          listener: (BuildContext context, ListDataPageState state) {
            if(state is InitialListDataState){
              BlocProvider.of<ListDataPageBloc>(context).add(LoadListDataEvent());
            }
            else if(state is ErrorSaveListDataState){
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(backgroundColor: Colors.deepOrangeAccent,
                      content: Text(trs.translate("error_text") ?? "Error"))
              );
              BlocProvider.of<ListDataPageBloc>(context).add(LoadListDataEvent());
            }
            else if(state is LoadErrorListDataState){
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(backgroundColor: Colors.deepOrangeAccent,
                      content: Text(trs.translate("error_text") ?? "Error"))
              );
              BlocProvider.of<ListDataPageBloc>(context).add(LoadListDataEvent());
            }
            else if(state is ListDataPageSavedState){
              BlocProvider.of<ListPageBloc>(context).add(LoadListEvent(state.params));
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> ListPage(params: state.params, provider: Provider.of<GlobalVarsProvider>(context))), (route)=>false);
            }
          },
          child: Stack(
            children: [
              Container(
                height: size.height/2,
                color: Theme.of(context).primaryColor,
              ),
              BlocBuilder<ListDataPageBloc,ListDataPageState>(
                builder: (context,state){
                  if(state is ListDataPageLoadedState) {
                    if (pageOpened == true) {
                      if (state.warehouses
                          .where((element) =>
                      element.WhName == savedStorage)
                          .isNotEmpty) {
                        storage = state.warehouses
                            .where((element) =>
                        element.WhName == savedStorage)
                            .first;
                      }
                      else {
                        storage = state.warehouses[0];
                      }
                    }
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Container(
                          height: size.height / 1.4,
                          decoration: BoxDecoration(
                            color: Theme
                                .of(context)
                                .cardColor,
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: [ BoxShadow(
                                color: Theme
                                    .of(context)
                                    .dividerColor,
                                blurRadius: 2,
                                spreadRadius: 2,
                                offset: const Offset(3, 3)
                            )
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0),
                            child:  SingleChildScrollView(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: ListTile(
                                      onTap: () {
                                        showMenu(
                                            context: context,
                                            initialValue: storageStyle,
                                            items: storageStyles.map((
                                                value) =>
                                                PopupMenuItem<String>(
                                                  value: value,
                                                  child: Theme(
                                                    data: Theme.of(
                                                        context)
                                                        .copyWith(
                                                      highlightColor: const Color(
                                                          0xffC5FCFF),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment
                                                          .spaceBetween,
                                                      children: [
                                                        Text(trs
                                                            .translate(
                                                            value) ??
                                                            value),
                                                        storageStyle ==
                                                            value
                                                            ? const Icon(
                                                          Icons.check,
                                                          color: Color(
                                                              0xff003C40),
                                                          size: 20,)
                                                            : const SizedBox
                                                            .shrink()
                                                      ],
                                                    ),
                                                  ),
                                                )).toList(),
                                            position: const RelativeRect
                                                .fromLTRB(
                                                90, 0, 25, 400),
                                            surfaceTintColor: Colors
                                                .transparent,
                                            color: Theme
                                                .of(context)
                                                .cardColor,
                                            shape: OutlineInputBorder(
                                                borderRadius: BorderRadius
                                                    .circular(10),
                                                borderSide: const BorderSide(
                                                    color: Colors
                                                        .transparent),
                                                gapPadding: 50
                                            )
                                        ).then((value) =>
                                            setState(() {
                                              storageStyle = value ??
                                                  storageStyle;
                                              if(value=="opened"){
                                                countStyles = ['multiple_count'];
                                                countStyle="multiple_count";
                                              }
                                              else{
                                                countStyles = ['multiple_count','single_count'];
                                              }
                                            }));
                                      },
                                      contentPadding: const EdgeInsets
                                          .symmetric(
                                          vertical: 3),
                                      leading: Text(
                                        trs.translate(
                                            "warehouseCondition") ??
                                            "Warehouse condition",
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight
                                                .normal),
                                      ),
                                      trailing: PopupMenuButton<String>(
                                          offset: const Offset(10, 20),
                                          popUpAnimationStyle: AnimationStyle
                                              .noAnimation,
                                          surfaceTintColor: Colors
                                              .transparent,
                                          elevation: 8,
                                          color: Theme
                                              .of(context)
                                              .cardColor,
                                          shape: ContinuousRectangleBorder(
                                              borderRadius: BorderRadius
                                                  .circular(19)
                                          ),
                                          initialValue: storageStyle,
                                          onSelected: (String item) {
                                            setState(() {
                                              storageStyle = item;
                                              if(item=="opened"){
                                                countStyles = ['multiple_count'];
                                                countStyle="multiple_count";
                                              }
                                              else{
                                                countStyles = ['multiple_count','single_count'];
                                              }
                                            });
                                          },
                                          itemBuilder: (
                                              BuildContext context) =>
                                              storageStyles.map((
                                                  value) =>
                                                  PopupMenuItem<String>(
                                                    value: value,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment
                                                          .spaceBetween,
                                                      children: [
                                                        Text(trs
                                                            .translate(
                                                            value) ??
                                                            value),
                                                        storageStyle ==
                                                            value
                                                            ? const Icon(
                                                          Icons.check,
                                                          color: Color(
                                                              0xff003C40),
                                                          size: 20,)
                                                            : const SizedBox
                                                            .shrink()
                                                      ],
                                                    ),
                                                  ),
                                              ).toList(),
                                          child: SizedBox(
                                            width: size.width / 4.5,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .end,
                                              children: [
                                                Text(
                                                  trs.translate(
                                                      storageStyle) ??
                                                      storageStyle,
                                                  style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight
                                                          .normal),),
                                                const Padding(
                                                  padding: EdgeInsets
                                                      .only(
                                                      left: 8.0),
                                                  child: Icon(
                                                    Icons
                                                        .unfold_more_outlined,
                                                    size: 20,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                      ),
                                    ),
                                  ),
                                  Divider(color: Theme
                                      .of(context)
                                      .dividerColor),
                                  // Padding(
                                  //   padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 14),
                                  //   child: Row(
                                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  //     children: [
                                  //       Text(trs.translate("billCode") ?? "Billing Code", style: const TextStyle(fontSize: 16),),
                                  //       const Text("ANHAF-0000000001", style: TextStyle(fontSize: 13),)
                                  //     ],
                                  //   ),
                                  // ),
                                  // Divider(color: Theme.of(context).dividerColor),
                                  ListTile(
                                    contentPadding: EdgeInsets
                                        .fromViewPadding(
                                        ViewPadding.zero, 2),
                                    onTap: pickDateTime,
                                    leading: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0),
                                      child: Text(
                                        trs.translate("countDate") ??
                                            "Counted Date",
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight
                                                .normal),
                                      ),
                                    ),
                                    trailing: TextButton(
                                        onPressed: pickDateTime,
                                        child: Text(DateFormat(
                                            'dd.MM.yyyy  hh:mm').format(
                                            dateTime),
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xff454545),
                                              fontWeight: FontWeight
                                                  .normal),
                                        )
                                    ),
                                  ),
                                  Divider(color: Theme
                                      .of(context)
                                      .dividerColor),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: ListTile(
                                      onTap: () {
                                        showMenu(context: context,
                                            initialValue: storage,
                                            items: state.warehouses
                                                .map((value) =>
                                                PopupMenuItem<
                                                    TblDkWarehouse>(
                                                  value: value,
                                                  child: Theme(
                                                    data: Theme.of(
                                                        context)
                                                        .copyWith(
                                                      highlightColor: const Color(
                                                          0xffC5FCFF),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment
                                                          .spaceBetween,
                                                      children: [
                                                        Text(value
                                                            .WhName),
                                                        storage == value
                                                            ? const Icon(
                                                          Icons.check,
                                                          color: Color(
                                                              0xff003C40),
                                                          size: 20,)
                                                            : const SizedBox
                                                            .shrink()
                                                      ],
                                                    ),
                                                  ),
                                                )).toList(),
                                            position: const RelativeRect
                                                .fromLTRB(
                                                90, 0, 25, 70),
                                            surfaceTintColor: Colors
                                                .transparent,
                                            color: Theme
                                                .of(context)
                                                .cardColor,
                                            shape: OutlineInputBorder(
                                                borderRadius: BorderRadius
                                                    .circular(10),
                                                borderSide: const BorderSide(
                                                    color: Colors
                                                        .transparent),
                                                gapPadding: 50
                                            )

                                        ).then((value) =>
                                            setState(() {
                                              storage = value ??
                                                  storage;
                                            }));
                                      },
                                      contentPadding: const EdgeInsets
                                          .symmetric(
                                          vertical: 3),
                                      leading: Text(
                                        trs.translate("warehouse") ??
                                            "Warehouse",
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight
                                                .normal),
                                      ),
                                      trailing: Theme(
                                        data: Theme.of(context)
                                            .copyWith(
                                          highlightColor: const Color(
                                              0xffC5FCFF),
                                        ),
                                        child: PopupMenuButton<
                                            TblDkWarehouse>(
                                            offset: const Offset(
                                                10, 20),
                                            popUpAnimationStyle: AnimationStyle
                                                .noAnimation,
                                            surfaceTintColor: Colors
                                                .transparent,
                                            elevation: 8,
                                            color: Theme
                                                .of(context)
                                                .cardColor,
                                            shape: ContinuousRectangleBorder(
                                                borderRadius: BorderRadius
                                                    .circular(19)
                                            ),
                                            initialValue: storage,
                                            onSelected: (
                                                TblDkWarehouse item) {
                                              pageOpened = false;
                                              setState(() {
                                                storage = item;
                                              });
                                            },
                                            itemBuilder: (
                                                BuildContext context) =>
                                                state.warehouses.map((
                                                    value) =>
                                                    PopupMenuItem<
                                                        TblDkWarehouse>(
                                                      value: value,
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment
                                                            .spaceBetween,
                                                        children: [
                                                          Text(value
                                                              .WhName),
                                                          storage ==
                                                              value
                                                              ? const Icon(
                                                            Icons.check,
                                                            color: Color(
                                                                0xff003C40),
                                                            size: 20,)
                                                              : const SizedBox
                                                              .shrink()
                                                        ],
                                                      ),
                                                    ),
                                                ).toList(),
                                            child: SizedBox(
                                              width: size.width / 2,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment
                                                    .end,
                                                children: [
                                                  Text(
                                                    storage?.WhName ??
                                                        "",
                                                    style: const TextStyle(
                                                        fontSize: 13,
                                                        fontWeight: FontWeight
                                                            .normal),),
                                                  const Padding(
                                                    padding: EdgeInsets
                                                        .only(
                                                        left: 8.0),
                                                    child: Icon(
                                                      Icons
                                                          .unfold_more_outlined,
                                                      size: 20,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                        ),
                                      ),
                                    ),
                                  ),
                                  Divider(color: Theme
                                      .of(context)
                                      .dividerColor),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: ListTile(
                                      onTap: () {
                                        showMenu(context: context,
                                            initialValue: countStyle,
                                            items: countStyles.map((
                                                value) =>
                                                PopupMenuItem<String>(
                                                  value: value,
                                                  child: Theme(
                                                    data: Theme.of(
                                                        context)
                                                        .copyWith(
                                                      highlightColor: const Color(
                                                          0xffC5FCFF),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment
                                                          .spaceBetween,
                                                      children: [
                                                        Text(trs
                                                            .translate(
                                                            value) ??
                                                            value),
                                                        countStyle ==
                                                            value
                                                            ? const Icon(
                                                          Icons.check,
                                                          color: Color(
                                                              0xff003C40),
                                                          size: 20,)
                                                            : const SizedBox
                                                            .shrink()
                                                      ],
                                                    ),
                                                  ),
                                                )).toList(),
                                            position: const RelativeRect
                                                .fromLTRB(
                                                90, 100, 25, 0),
                                            surfaceTintColor: Colors
                                                .transparent,
                                            color: Theme
                                                .of(context)
                                                .cardColor,
                                            shape: OutlineInputBorder(
                                                borderRadius: BorderRadius
                                                    .circular(10),
                                                borderSide: const BorderSide(
                                                    color: Colors
                                                        .transparent),
                                                gapPadding: 50
                                            )
                                        ).then((value) =>
                                            setState(() {
                                              countStyle = value ??
                                                  countStyle;
                                            }));
                                      },
                                      contentPadding: const EdgeInsets
                                          .symmetric(
                                          vertical: 3),
                                      leading: Text(
                                        trs.translate("countType") ??
                                            "Count type",
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight
                                                .normal),
                                      ),
                                      trailing: Theme(
                                        data: Theme.of(context)
                                            .copyWith(
                                          highlightColor: const Color(
                                              0xffC5FCFF),
                                        ),
                                        child: PopupMenuButton<String>(
                                            offset: const Offset(
                                                10, 20),
                                            popUpAnimationStyle: AnimationStyle
                                                .noAnimation,
                                            surfaceTintColor: Colors
                                                .transparent,
                                            elevation: 8,
                                            color: Theme
                                                .of(context)
                                                .cardColor,
                                            shape: ContinuousRectangleBorder(
                                                borderRadius: BorderRadius
                                                    .circular(19)
                                            ),
                                            initialValue: countStyle,
                                            onSelected: (String item) {
                                              setState(() {
                                                countStyle = item;
                                              });
                                            },
                                            itemBuilder: (
                                                BuildContext context) =>
                                                countStyles.map((
                                                    value) =>
                                                    PopupMenuItem<
                                                        String>(
                                                      value: value,
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment
                                                            .spaceBetween,
                                                        children: [
                                                          Text(trs
                                                              .translate(
                                                              value) ??
                                                              value),
                                                          countStyle ==
                                                              value
                                                              ? const Icon(
                                                            Icons.check,
                                                            color: Color(
                                                                0xff003C40),
                                                            size: 20,)
                                                              : const SizedBox
                                                              .shrink()
                                                        ],
                                                      ),
                                                    ),
                                                ).toList(),
                                            child: SizedBox(
                                              width: size.width / 1.9,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment
                                                    .end,
                                                children: [
                                                  Text(
                                                    trs.translate(
                                                        countStyle) ??
                                                        countStyle,
                                                    style: const TextStyle(
                                                        fontSize: 13,
                                                        fontWeight: FontWeight
                                                            .normal),),
                                                  const Padding(
                                                    padding: EdgeInsets
                                                        .only(
                                                        left: 8.0),
                                                    child: Icon(
                                                      Icons
                                                          .unfold_more_outlined,
                                                      size: 20,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 3, top: 6),
                                    child: TextField(
                                      controller: passwordCtrl,
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
                                        isDense: true,
                                        label: Text(
                                            trs.translate("password") ??
                                                "Password"),
                                        floatingLabelStyle: const TextStyle(
                                            color: Color(0xff0398A2)),
                                        alignLabelWithHint: true,
                                        enabledBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xffCDCDCD)),
                                          borderRadius: BorderRadius
                                              .all(
                                              Radius.circular(5.0)
                                          ),
                                        ),
                                        focusedBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Color(
                                                    0xff0398A2)),
                                            borderRadius: BorderRadius
                                                .all(
                                                Radius.circular(5.0))
                                        ),
                                        border: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Color(
                                                    0xffCDCDCD)),
                                            borderRadius: BorderRadius
                                                .all(
                                                Radius.circular(5.0))
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0),
                                    child: TextField(
                                      controller: firstNoteCtrl,
                                      onTap: () {},
                                      decoration: InputDecoration(
                                        isDense: true,
                                        label: Text(
                                            trs.translate("note1") ??
                                                "Note 1"),
                                        floatingLabelStyle: const TextStyle(
                                            color: Color(0xff0398A2)),
                                        alignLabelWithHint: true,
                                        enabledBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xffCDCDCD)),
                                          borderRadius: BorderRadius
                                              .all(
                                              Radius.circular(5.0)
                                          ),
                                        ),
                                        focusedBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Color(
                                                    0xff0398A2)),
                                            borderRadius: BorderRadius
                                                .all(
                                                Radius.circular(5.0))
                                        ),
                                        border: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Color(
                                                    0xffCDCDCD)),
                                            borderRadius: BorderRadius
                                                .all(
                                                Radius.circular(5.0))
                                        ),
                                      ),
                                    ),
                                  ),
                                  TextField(
                                    controller: secondNoteCtrl,
                                    onTap: () {},
                                    decoration: InputDecoration(
                                      isDense: true,
                                      label: Text(
                                          trs.translate("note2") ??
                                              "Note 2"),
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
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Color(0xff0398A2)),
                                          borderRadius: BorderRadius
                                              .circular(5)
                                      ),
                                      border: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0xffCDCDCD),
                                          ),
                                          borderRadius: BorderRadius
                                              .all(
                                              Radius.circular(5.0))
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 30.0),
                                    child: TextButton(
                                      onPressed: () async {
                                        if (storage != null) {
                                          BlocProvider.of<
                                              ListDataPageBloc>(
                                              context)
                                              .add(SaveListDataEvent(
                                              storageStyle, dateTime,
                                              countStyle,
                                              firstNoteCtrl.text,
                                              secondNoteCtrl.text,
                                              storage!,
                                              passwordCtrl.text
                                          ));
                                          SharedPreferences prefs = await SharedPreferences
                                              .getInstance();
                                          prefs.setBool(SharedPrefKeys
                                              .countingData, true);
                                        }
                                        else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                              const SnackBar(
                                                  backgroundColor: Colors
                                                      .deepOrangeAccent,
                                                  content: Text(
                                                      "There is no selected warehouse"))
                                          );
                                        }
                                      },
                                      style: TextButton.styleFrom(
                                        backgroundColor: Theme
                                            .of(context)
                                            .primaryColor,
                                        fixedSize: Size(
                                            size.width,
                                            size.height / 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius
                                              .circular(
                                              5),
                                        ),
                                      ),
                                      child: const Text("OK",
                                        style: TextStyle(
                                          color: Colors.white,
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
                        ),
                      ),
                    );
                  }
                  else if (state is LoadingListDataState ||
                      state is SavingListDataState) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return const SizedBox.shrink();
                },
              )
            ],
          ),
        ),
      ),
    );
  }
  Future pickDateTime ()async {
    DateTime? date = await pickDate();
    if (date == null) return;

    TimeOfDay? time = await pickTime();
    if (time == null) return;

    final dateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute
    );
    setState(() => this.dateTime = dateTime);
  }

  Future<DateTime?> pickDate() => showDatePicker(
      context: context,
      initialDate: dateTime,
      firstDate: DateTime(1900),
      lastDate: DateTime(3000)
  );

  Future<TimeOfDay?> pickTime() => showTimePicker(
    context: context,
    initialTime: TimeOfDay(hour: dateTime.hour, minute: dateTime.minute),
  );
}






