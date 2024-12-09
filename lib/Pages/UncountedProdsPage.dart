// ignore_for_file: file_names

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:revision_app/Pages/ListPage.dart';
import 'package:revision_app/bloc/ListPageBLoc.dart';
import 'package:revision_app/bloc/MaterialBloc.dart';
import 'package:revision_app/bloc/UncountedProductsBloc.dart';
import 'package:revision_app/helpers/localization.dart';
import 'package:revision_app/models/tbl_dk_unit.dart';
import 'package:revision_app/models/v_dk_mat_count_params.dart';
import 'package:revision_app/models/v_dk_material_count.dart';
import 'package:revision_app/models/v_dk_materials.dart';
import 'package:revision_app/provider/GlobalVarsProvider.dart';

class UncountedProdsPage extends StatefulWidget {
  final VDkMatCountParams params;
  final List<VDkMaterialCount> matCounts;
  const UncountedProdsPage({super.key, required this.matCounts, required this.params});

  @override
  State<UncountedProdsPage> createState() => _UncountedProdsPageState();
}

class _UncountedProdsPageState extends State<UncountedProdsPage> {
  bool _value = false;
  List<VDkMaterials> materials = [];
  List<VDkMaterials> secondList = [];
  final List<bool> _itemChecked = List<bool>.filled(100000, false);
  TextEditingController searchContrl = TextEditingController();
  bool hasText = false;
  String filterOption = "";
  List<VDkMaterials> filteredCounts = [];

  @override
  void initState() {
    searchContrl.addListener(() {
      setState(() {
        hasText = searchContrl.text.isNotEmpty;
      });
    });
    filterOption = "None";
    super.initState();
  }

  @override
  void dispose() {
    searchContrl.dispose();
    super.dispose();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openEndDrawerSorting() {
    _scaffoldKey.currentState!.openEndDrawer();
  }

  void _toggleAllCheckboxes(bool value) {
    setState(() {
      _value = value;
      for (int i = 0; i < _itemChecked.length; i++) {
        _itemChecked[i] = value;
      }
    });
  }

  void _toggleSingleCheckbox(int index, bool value) {
    setState(() {
      _itemChecked[index] = value;
      _value = _itemChecked.every((element) => element == true);
    });
  }
  @override
  Widget build(BuildContext context) {
    final trs = AppLocalizations.of(context);
    GlobalVarsProvider globalProvider = Provider.of<GlobalVarsProvider>(context);
    Size size = MediaQuery.of(context).size;
    return PopScope(
        canPop: false,
        onPopInvoked: (didPop){
      BlocProvider.of<ListPageBloc>(context).add(LoadListEvent(widget.params));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ListPage(params: widget.params, provider: globalProvider,)));
    },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: IconButton(
              onPressed: () {
                BlocProvider.of<ListPageBloc>(context).add(LoadListEvent(widget.params));
                Navigator.push(context, MaterialPageRoute(builder: (context) => ListPage(params: widget.params, provider: globalProvider)),
                );
              },
              icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).cardColor),
            ),
          ),
          leadingWidth: size.width/12,
          backgroundColor: Theme.of(context).primaryColor,
          title: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text("${trs.translate("unc_prods") ?? "Uncounted Products"} (${globalProvider.getUncountedMats.length})"),
          ),
          titleTextStyle: TextStyle(color: Theme.of(context).cardColor, fontSize: 20),
          actions: [
            Transform.translate(
              offset: const Offset(15, 0),
              child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: (){
                    _showSaveDialog();
                  },
                  icon: Icon(Icons.save, color: Theme.of(context).cardColor),
                iconSize: 25,
              ),
            ),
            Transform.translate(
              offset: const Offset(5, 0),
              child: PopupMenuButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)
                ),
                color: Theme.of(context).cardColor,
                splashRadius: 3,
                position: PopupMenuPosition.under,
                iconSize: 30,
                padding: EdgeInsets.zero,
                iconColor: Theme.of(context).cardColor,
                itemBuilder: (_) => <PopupMenuItem<String>>[
                  PopupMenuItem<String>(
                      value: "Sorting",
                      onTap: () => _openEndDrawerSorting(),
                      child: Text(trs.translate("sorting") ?? "Sorting")
                  )
                ],
              ),
            )
          ],
          bottom: PreferredSize(
            preferredSize: Size(size.width, size.height/15),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12,0,12,10),
                child: Container(
                  height: size.height/18,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: TextField(
                    controller: searchContrl,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(36.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                      hintText: (trs.translate("click_to_search") ?? "Click to search"),hintStyle: const TextStyle(color: Color(0xffCDCDCD), fontSize: 15),
                      suffixIcon: hasText
                          ? IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () {
                          searchContrl.clear();
                          setState(() {
                            hasText = false;
                          });
                          BlocProvider.of<UncountedProductsBloc>(context).add(SearchUncountedProdsEvent(materials, ''));
                        },
                      )
                          : const Icon(Icons.search, size: 20),
                      suffixIconColor: const Color(0xffCDCDCD),
                    ),
                    cursorColor: Colors.black,
                    onSubmitted: (value){
                      BlocProvider.of<UncountedProductsBloc>(context).add(SearchUncountedProdsEvent(filteredCounts, value));
                    },
                    onChanged: (value){
                      setState(() {
                        hasText = value.isNotEmpty;
                      });
                      if(value.isEmpty){
                        BlocProvider.of<UncountedProductsBloc>(context).add(SearchUncountedProdsEvent(materials, value));
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        endDrawer: Drawer(
          backgroundColor: const Color(0xffF6F6F6),
          width: size.width/1.15,
          child: Column(
            children: [
              SizedBox(
                height: size.height/1.08,
                child: Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: ListView(
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      Text("${trs.translate("name") ?? "Name"}:",
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)
                      ),
                      RadioListTile(
                          dense: true,
                          value: "From A to Z",
                          groupValue: filterOption,
                          title: Text(trs.translate("a_z") ?? "From A to Z",
                            style: const TextStyle(fontSize: 16),
                          ),
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (val) {
                            setState(() {
                              filterOption = val!;
                            });
                          }),
                      RadioListTile(
                          dense: true,
                          value: "From Z to A",
                          groupValue: filterOption,
                          title: Text(trs.translate("z_a") ?? "From Z to A",
                            style: const TextStyle(fontSize: 16),
                          ),
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (val) {
                            setState(() {
                              filterOption = val!;
                            });
                          }),
                      Text("${trs.translate("order") ?? "Order"}:",
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)
                      ),
                      RadioListTile(
                          dense: true,
                          value: "From less to more",
                          groupValue: filterOption,
                          title: Text(trs.translate("less_more") ?? "From less to more",
                            style: const TextStyle(fontSize: 16),
                          ),
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (val) {
                            setState(() {
                              filterOption = val!;
                            });
                          }),
                      RadioListTile(
                          dense: true,
                          value: "From more to less",
                          groupValue: filterOption,
                          title: Text(trs.translate("more_less") ?? "From more to less",
                            style: const TextStyle(fontSize: 16),
                          ),
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (val) {
                            setState(() {
                              filterOption = val!;
                            });
                          }),
                      RadioListTile(
                          dense: true,
                          value: "Only less",
                          groupValue: filterOption,
                          title: Text(trs.translate("only_less") ?? "Only less",
                            style: const TextStyle(fontSize: 16),
                          ),
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (val) {
                            setState(() {
                              filterOption = val!;
                            });
                          }),
                      RadioListTile(
                          dense: true,
                          value: "Only more",
                          groupValue: filterOption,
                          title: Text(trs.translate("only_more") ?? "Only more",
                            style: const TextStyle(fontSize: 16),
                          ),
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (val) {
                            setState(() {
                              filterOption = val!;
                            });
                          }),
                      RadioListTile(
                          dense: true,
                          value: "Only zero",
                          groupValue: filterOption,
                          title: Text(trs.translate("only_zero") ?? "Equals",
                            style: const TextStyle(fontSize: 16),
                          ),
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (val) {
                            setState(() {
                              filterOption = val!;
                            });
                          }),
                      RadioListTile(
                          value: "None",
                          groupValue: filterOption,
                          title: Text(trs.translate("none") ?? "None",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (val) {
                            setState(() {
                              filterOption = val!;
                            });
                          }),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: TextButton(
                  onPressed: (){
                    filterListForUncounts(context);
                    _scaffoldKey.currentState!.closeEndDrawer();
                  },
                  style: TextButton.styleFrom(
                    shape: LinearBorder.bottom(size: 0),
                    fixedSize: Size(size.width, size.height/13.5),
                    backgroundColor: const Color(0xff01A9B4),
                  ),
                  child: Text(trs.translate("sorting") ?? "Sorting",
                    style: TextStyle(
                      color: Theme.of(context).cardColor,
                      fontSize: 20,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        body: BlocListener<MaterialBloc, MaterialBlocState>(
          listener: (BuildContext context, MaterialBlocState state) async{
            if(state is SavedMaterialState) {
              setState(() {
                globalProvider.getUncountedMats.removeWhere((element) => element.MatId==state.material.MatId);
                filteredCounts.removeWhere((element) => element.MatId==state.material.MatId);
                materials.removeWhere((element) => element.MatId==state.material.MatId);
              });
              // BlocProvider.of<ListPageBloc>(context).add(LoadListEvent(widget.params));
              // Completer<bool> completer = Completer();
              // StreamSubscription subscription;
              // subscription = BlocProvider.of<ListPageBloc>(context).stream.listen((state) {
              //   if (state is ListLoadedState) {
              //     completer.complete(true);
              //   }
              //   else if(state is LoadErrorListState){
              //     completer.completeError("Error loading list");
              //   }
              // });
              // final loadedState = await completer.future;
              // await subscription.cancel();
              // if (loadedState) {
              //   setState(() {
              //     searchContrl.text = '';
              //   });
              //   BlocProvider.of<UncountedProductsBloc>(context).add(
              //       LoadUncountedProdsEvent(globalProvider.getCounts));
              // }
            }
            else if(state is SaveErrorMaterialCountState) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(backgroundColor: Colors.deepOrangeAccent,
                      content: Text("${trs.translate("error_text") ?? "Error"}: ${state.errorText}. ${trs.translate('try_again') ?? "Try again"}")
                  )
              );
            }
          },
          child: BlocListener<UncountedProductsBloc, UncountedProductsState>(
            listener: (BuildContext context, UncountedProductsState state) {
              if(state is UncountedProdsLoadedState){
                globalProvider.setUncountedMats = state.materials;
                materials = state.materials;
                filteredCounts = state.materials;
              }
              else if (state is UncountedProdsLoadErrorState){
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(backgroundColor: Colors.deepOrangeAccent,
                        content: Text("${trs.translate("error_text") ?? "Error"}: ${trs.translate('try_again') ?? "Try again"}")
                    )
                );
                BlocProvider.of<UncountedProductsBloc>(context).add(LoadUncountedProdsEvent(widget.matCounts, widget.params.WhId));
              }
              else if(state is UncountedProdsSetToZeroState){
                for(var mat in state.addedMats){
                  globalProvider.getUncountedMats.removeWhere((element) => element.MatId==mat.MatId);
                  materials.removeWhere((element) => element.MatId==mat.MatId);
                }
                BlocProvider.of<ListPageBloc>(context).add(LoadListEvent(widget.params));
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context)=> ListPage(params: widget.params, provider: globalProvider)),(route) => false);
              }
              else if(state is SearchingUncountedProdsCompletedState){
                globalProvider.setUncountedMats = state.materials;
                filteredCounts = state.materials;
              }
              else if(state is SearchUncountedProdsEmptyState){
                globalProvider.setUncountedMats = [];
                filteredCounts = [];
              }
                },
            child: RefreshIndicator(
              onRefresh: ()async{
                if(searchContrl.text.isNotEmpty){
                  BlocProvider.of<UncountedProductsBloc>(context).add(SearchUncountedProdsEvent(filteredCounts,searchContrl.text));
                }
                else {
                  BlocProvider.of<UncountedProductsBloc>(context).add(
                      (LoadUncountedProdsEvent(globalProvider.getCounts, widget.params.WhId)));
                }
              },
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor
                      ),
                      child: CheckboxListTile(
                        tileColor: Theme.of(context).scaffoldBackgroundColor,
                        contentPadding: const EdgeInsets.only(left: 22),
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(trs.translate("select_all") ?? "Select all",
                          style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        autofocus: false,
                        activeColor: const Color(0xff01A9B4),
                        checkColor: Colors.white,
                        selected: _value,
                        value: _value,
                        onChanged: (value) {
                          _toggleAllCheckboxes(value!);
                          if(value==true){
                            secondList.addAll(materials);
                          }
                          else{
                            secondList.clear();
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 7.0),
                      child: SizedBox(
                        height: size.height / 1.32,
                        child: ListView.builder(
                            physics: const BouncingScrollPhysics().applyTo(const ClampingScrollPhysics()),
                            itemCount: filteredCounts.length,
                            itemBuilder: (context, index) {
                              return UncountedProdsItem(
                                params: widget.params,
                                material: filteredCounts[index],
                                item: _itemChecked[index],
                                onChanged: (value) {
                                  _toggleSingleCheckbox(index, value!);
                                  if(value==true){
                                    secondList.add(filteredCounts[index]);
                                  }
                                  else{
                                    secondList.remove(filteredCounts[index]);
                                  }
                                },
                              );
                            }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void filterListForUncounts(BuildContext context) {
    setState(() {
      filteredCounts = Provider.of<GlobalVarsProvider>(context, listen: false).getUncountedMats.toList();

      // Apply sorting criteria sequentially
      filteredCounts.sort((a, b) {
        int result = 0;

        // Name sorting
        switch (filterOption) {
          case "From A to Z":
            result = a.MatName.compareTo(b.MatName);
            break;
          case "From Z to A":
            result = b.MatName.compareTo(a.MatName);
            break;
          case "From less to more":
            result = (0-a.MatWhTotalAmount).compareTo(0-b.MatWhTotalAmount);
            break;
          case "From more to less":
            result = (0-b.MatWhTotalAmount).compareTo(0-a.MatWhTotalAmount);
            break;
        }
        return result;
      });
      switch (filterOption) {
        case "Only less":
          filteredCounts = filteredCounts.where((item) => (0-item.MatWhTotalAmount) <0).toList();
          break;
        case "Only more":
          filteredCounts = filteredCounts.where((item) => (0-item.MatWhTotalAmount) >0).toList();
          break;
        case "Only zero":
          filteredCounts = filteredCounts.where((item) => (0-item.MatWhTotalAmount) ==0).toList();
          break;
      }
    });
  }

  Future<void> _showSaveDialog() async {
    final trs = AppLocalizations.of(context);
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(trs.translate("confirmation") ?? "Confirmation"),
            content: Text(trs.translate("save_txt") ?? 'Are you sure you want to save?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(trs.translate("cancel") ?? "Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  BlocProvider.of<UncountedProductsBloc>(context).add(SetUncountedProdsToZeroEvent(secondList, widget.params));
                },
                child: Text(trs.translate("confirm") ?? "Confirm"),
              ),
            ],
          );
        }
    );
  }
}

class UncountedProdsItem extends StatefulWidget {
  final VDkMaterials material;
  final bool item;
  final VDkMatCountParams params;
  final ValueChanged<bool?>? onChanged;

  const UncountedProdsItem({super.key, required this.onChanged, required this.material, required this.item, required this.params});

  @override
  State<UncountedProdsItem> createState() => _UncountedProdsItemState();
}

class _UncountedProdsItemState extends State<UncountedProdsItem> {
  TextEditingController descCtrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final trs = AppLocalizations.of(context);
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 6),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5)
        ),
        minVerticalPadding: 0,
        minLeadingWidth: size.width/12,
        contentPadding: EdgeInsets.zero,
        selected: widget.item,
        tileColor: Theme.of(context).cardColor,
        selectedTileColor: Theme.of(context).cardColor,
        leading: Checkbox(
          value: widget.item,
          onChanged: widget.onChanged,
          autofocus: false,
          activeColor: Theme.of(context).primaryColor,
          checkColor: Colors.white,
          shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        title: InkWell(
          onTap: () {
            BlocProvider.of<MaterialBloc>(context)
                .add(LoadMaterialEvent(
                widget.params.WhId, widget.material.Barcode));
            countDialog(context, size);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                SizedBox(
                  width: size.width/1.9,
                  child: Text(
                  widget.material.MatName,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(fontSize: 17, fontWeight: FontWeight.w600),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                children: [
                Padding(
                padding: const EdgeInsets.only(right: 7.0, left: 3),
                child: SvgPicture.asset("assets/svg/barcode.svg"),
                ),
                SizedBox(
                  width: size.width/2,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                      widget.material.Barcode,
                      style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ),
                ],
                ),
                Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Row(
                children: [
                SizedBox(
                  width: size.width/4,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                      "${trs.translate("stock") ?? "Stock"}: ${widget.material.MatWhTotalAmount.toInt()}",
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
                Padding(
                padding: const EdgeInsets.only(left: 17.0),
                child: Text(
                "${trs.translate("counted") ?? "Counted"}: 0",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                )
                ],
                ),
                ),
                ],
              ),
              Container(
                alignment: Alignment.center,
                height: size.height/8,
                width: size.width / 5.7,
                decoration: BoxDecoration(
                    color: (0-widget.material.MatWhTotalAmount < 0) ? const Color(0xffE41313) : (0-widget.material.MatWhTotalAmount == 0) ? const Color(0xffFFDB23) : const Color(0xff13E499),
                    borderRadius: BorderRadius.circular(5)),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text("${(0-widget.material.MatWhTotalAmount).toInt()}",
                      style: TextStyle(
                          color: Theme.of(context).cardColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
  Future<void> countDialog(BuildContext context, Size size ) async {
    int number = 1;
    bool tapped =false;
    final trs = AppLocalizations.of(context);
    await showDialog(
        context: context, builder: (_) {
      TextEditingController countController = TextEditingController(
          text: number.toString());
      return BlocBuilder<MaterialBloc,MaterialBlocState>(
          builder: (context,state) {
            if(state is MaterialLoadedState) {
              TblDkUnit dropdownValue = state.units.first;
              return StatefulBuilder(
                  builder: (context, set) {
                    countController.text = number.toString();
                    if (tapped == false) countController.selectAll(0);
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
                          fontSize: (state.material.MatName.length < 35) ? 22 : (state.material.MatName.length < 70) ? 20 : 18,
                          color: Theme.of(context).cardColor
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
                        height: (state.material.MatName.length < 35) ? size.height / 14 : (state.material.MatName.length < 70) ? size.height / 12 : size.height / 9,
                        alignment: Alignment.center,
                        child: Text(state.material.MatName, textAlign: TextAlign.center,),
                      ),
                      content: SizedBox(
                        height: size.height / 2.7,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              height: size.height/14,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0xffCDCDCD),
                                      )
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0xffCDCDCD),
                                      )
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton <TblDkUnit>(
                                      dropdownColor: Theme.of(context).cardColor,
                                      icon: const Icon(Icons.arrow_drop_down),
                                      iconSize: 25,
                                      isExpanded: true,
                                      alignment: Alignment.center,
                                      value: dropdownValue,
                                      items: state.units.map((TblDkUnit unit) {
                                        return DropdownMenuItem(
                                          alignment: Alignment.center,
                                          value: unit,
                                          child: Text(unit.UnitDetCode),
                                        );
                                      }).toList(),
                                      onChanged: (TblDkUnit? newValue) {
                                        set(() {
                                          dropdownValue = newValue!;
                                        });
                                      }),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: TextField(
                                controller: descCtrl,
                                maxLines: 2,
                                onTap: () {},
                                decoration: InputDecoration(
                                  isDense: true,
                                  label: Text(
                                      trs.translate("description") ??
                                          "Description"),
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
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Container(
                                width: size.width / 1.7,
                                height: size.height / 18,
                                color: Theme
                                    .of(context)
                                    .scaffoldBackgroundColor,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceBetween,
                                  children: [
                                    IconButton(
                                      iconSize: size.width / 12,
                                      onPressed: () {
                                        if (number > 1) {
                                          set(() {
                                            number--;
                                          });
                                          tapped = true;
                                        }
                                      },
                                      style: IconButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5)
                                        ),
                                        backgroundColor: Theme
                                            .of(context)
                                            .primaryColor,
                                      ),
                                      icon: Icon(Icons.remove,
                                          color: Theme
                                              .of(context)
                                              .cardColor),
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      width: size.width / 4,
                                      height: size.height / 18,
                                      color: Theme
                                          .of(context)
                                          .scaffoldBackgroundColor,
                                      child: TextField(
                                        enableInteractiveSelection: false,
                                        cursorColor: Colors.black,
                                        autofocus: true,
                                        style: TextStyle(
                                            color: Theme
                                                .of(context)
                                                .primaryColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 22
                                        ),
                                        textAlign: TextAlign.center,
                                        controller: countController,
                                        keyboardType: TextInputType.number,
                                        maxLength: 6,
                                        inputFormatters: <
                                            TextInputFormatter>[
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                        onChanged: (value) {
                                          number = int.parse(value);
                                        },
                                        onSubmitted: (value) {
                                          number = int.parse(value);
                                        },
                                        decoration: InputDecoration(
                                          counterText: "",
                                          border: const UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.transparent),
                                          ),
                                          focusedBorder: const UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.transparent),
                                          ),
                                          focusColor: Theme
                                              .of(context)
                                              .scaffoldBackgroundColor,
                                          disabledBorder: const UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.transparent),
                                          ),
                                          enabledBorder: const UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.transparent),
                                          ),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      iconSize: size.width / 12,
                                      onPressed: () {
                                        set(() {
                                          number++;
                                        });
                                        tapped = true;
                                      },
                                      style: IconButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5)
                                        ),
                                        backgroundColor: Theme
                                            .of(context)
                                            .primaryColor,
                                      ),
                                      icon: Icon(Icons.add,
                                          color: Theme
                                              .of(context)
                                              .cardColor),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                BlocProvider.of<MaterialBloc>(context).add(SaveMaterialEvent(
                                    descCtrl.text,
                                    state.material,
                                    number.toDouble(),
                                    dropdownValue.UnitDetId,
                                    widget.params));
                                Navigator.pop(context);
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Theme
                                    .of(context)
                                    .primaryColor,
                                fixedSize: Size(size.width / 2, size.height / 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              child: Text(trs.translate("save") ?? "Save",
                                style: TextStyle(
                                  color: Theme
                                      .of(context)
                                      .cardColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
              );
            }
            else if(state is LoadErrorMaterialState){
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
                      fontSize: 20, color: Theme
                      .of(context)
                      .cardColor
                  ),
                  title: Container(
                    decoration: const BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(30),
                            topLeft: Radius.circular(30)
                        )
                    ),
                    width: size.width,
                    height: size.height / 15,
                    alignment: Alignment.center,
                    child: Text(trs.translate("load_error") ?? "Loading Error"),
                  ),
                  content: SizedBox(
                    height: size.height/5,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text("${trs.translate("error_text") ?? 'Error'}: ${state.errorText}"),
                          TextButton(onPressed: (){
                            Navigator.pop(context);
                          },
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.red,
                              fixedSize: Size(size.width / 2, size.height / 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: Text(trs.translate("ok") ?? "Ok",
                              style: TextStyle(
                                color: Theme
                                    .of(context)
                                    .cardColor,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
              );
            }
            else if(state is SaveErrorMaterialCountState){
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
                      fontSize: 20, color: Theme
                      .of(context)
                      .cardColor
                  ),
                  title: Container(
                    decoration: const BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(30),
                            topLeft: Radius.circular(30)
                        )
                    ),
                    width: size.width,
                    height: size.height / 15,
                    alignment: Alignment.center,
                    child: Text(trs.translate("save_error") ?? "Saving Error"),
                  ),
                  content: SizedBox(
                    height: size.height/5,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text("${trs.translate("error_text") ?? "Error"} : ${state.errorText}"),
                          TextButton(onPressed: (){
                            Navigator.pop(context);
                          },
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.red,
                              fixedSize: Size(size.width / 2, size.height / 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: Text(trs.translate("ok") ?? "Ok",
                              style: TextStyle(
                                color: Theme
                                    .of(context)
                                    .cardColor,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
              );
            }
            else if(state is LoadingMaterialState || state is SavingMaterialCountState){
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
                      fontSize: 20, color: Theme
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
                    height: size.height / 15,
                    alignment: Alignment.center,
                    child: Text("${trs.translate("loading") ?? "Loading"}..."),
                  ),
                  content: SizedBox(
                    height: size.height/5,
                    child: const Center(
                        child: CircularProgressIndicator()
                    ),
                  )
              );
            }
            return const SizedBox.shrink();
          }
      );
    }
    );
  }
}

// IntrinsicHeight(
// child: Row(
// children: [
// Expanded(
// child: CheckboxListTile(
// selectedTileColor: Theme.of(context).cardColor,
// shape: ContinuousRectangleBorder(
// borderRadius: BorderRadius.circular(5)),
// activeColor: Theme.of(context).primaryColor,
// autofocus: false,
// checkColor: Colors.white,
// selected: widget.item,
// onChanged: widget.onChanged,
// value: widget.item,
// contentPadding: EdgeInsets.only(bottom: 5),
// controlAffinity: ListTileControlAffinity.leading,
// tileColor: Theme.of(context).cardColor,
// title: Column(
// mainAxisAlignment: MainAxisAlignment.spaceAround,
// crossAxisAlignment: CrossAxisAlignment.start,
// children: [
// Text(
// widget.material.MatName,
// style: Theme.of(context)
//     .textTheme
//     .bodyMedium!
//     .copyWith(fontSize: 17, fontWeight: FontWeight.w600),
// ),
// Row(
// children: [
// Padding(
// padding: const EdgeInsets.only(right: 7.0, left: 3),
// child: SvgPicture.asset("assets/svg/barcode.svg"),
// ),
// Text(
// widget.material.Barcode,
// style: Theme.of(context).textTheme.bodyMedium,
// ),
// ],
// ),
// Padding(
// padding: const EdgeInsets.only(top: 12.0),
// child: Row(
// children: [
// Text(
// "${trs.translate("stock") ?? "Stock"}: ${widget.material.MatWhTotalAmount.toInt()}",
// style: Theme.of(context)
//     .textTheme
//     .bodyMedium!
//     .copyWith(fontSize: 16, fontWeight: FontWeight.w600),
// ),
// Padding(
// padding: const EdgeInsets.only(left: 55.0),
// child: Text(
// "${trs.translate("counted") ?? "Counted"}: 0",
// style: Theme.of(context)
//     .textTheme
//     .bodyMedium!
//     .copyWith(fontSize: 16, fontWeight: FontWeight.w600),
// ),
// )
// ],
// ),
// ),
// ],
// ),
// ),
// ),
// InkWell(
// onTap: () {
// widget.onChanged!(!widget.item);
// },
// child: Container(
// alignment: Alignment.center,
// height: size.height / 8,
// width: size.width / 5.7,
// decoration: BoxDecoration(
// color: (0-widget.material.MatWhTotalAmount < 0) ? const Color(0xffE41313) : (0-widget.material.MatWhTotalAmount == 0) ? const Color(0xffFFDB23) : const Color(0xff13E499),
// borderRadius: BorderRadius.circular(5)),
// child: FittedBox(
// fit: BoxFit.scaleDown,
// child: Text("${(0-widget.material.MatWhTotalAmount).toInt()}",
// style: TextStyle(
// color: Theme.of(context).cardColor,
// fontSize: 20,
// fontWeight: FontWeight.w600)),
// ),
// ),
// ),
// ],
// ),
// ),