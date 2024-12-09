// ignore_for_file: file_names, use_build_context_synchronously

import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:revision_app/Pages/HomePage.dart';
import 'package:revision_app/Pages/ListDataPage.dart';
import 'package:revision_app/Pages/ProductCountsPage.dart';
import 'package:revision_app/Pages/UncountedProdsPage.dart';
import 'package:revision_app/bloc/ListDataPageBloc.dart';
import 'package:revision_app/bloc/ListPageBLoc.dart';
import 'package:revision_app/bloc/MaterialBloc.dart';
import 'package:revision_app/bloc/UncountedProductsBloc.dart';
import 'package:revision_app/helpers/SharedPrefKeys.dart';
import 'package:revision_app/helpers/localization.dart';
import 'package:revision_app/models/tbl_dk_unit.dart';
import 'package:revision_app/models/v_dk_mat_count_params.dart';
import 'package:revision_app/models/v_dk_material_count.dart';
import 'package:revision_app/provider/GlobalVarsProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListPage extends StatelessWidget {
  final MaterialBloc materialBloc;
  final VDkMatCountParams params;
  final GlobalVarsProvider provider;
  ListPage({super.key, required this.params, required this.provider}): materialBloc= MaterialBloc(provider);

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
        value: materialBloc,
        child: ListPageView(params: params));
  }
}

class ListPageView extends StatefulWidget{
  final VDkMatCountParams params;
  const ListPageView({super.key, required this.params});

  @override
  State<ListPageView> createState() => _ListPageViewState();
}

class _ListPageViewState extends State<ListPageView> with TickerProviderStateMixin {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'Barcode');
  QRViewController? controller2;
  final GlobalKey qrKey2 = GlobalKey(debugLabel: 'Search barcode');
  final myController = TextEditingController();
  TextEditingController descCtrl = TextEditingController();
  FocusNode submitFocus = FocusNode();
  late AnimationController animationController;
  late Animation<Offset> offsetAnimation;
  bool cameraVisible = false;
  bool searchVisible =false;
  bool _hasShownCountDialog = false;
  bool productSearched = false;
  String warehouseCondition = "";
  String countingType = "";
  String deviceName = "";
  AudioPlayer audioPlayer = AudioPlayer();
  String? firstBarcode;
  String? firstSearchBarcode;
  Timer? _barcodeTimer;
  DateTime? firstBarcodeTime;
  int timerDuration = 1;
  TextEditingController searchContrl = TextEditingController();
  List<VDkMaterialCount> matCounts = [];
  bool hasText = false;
  String saveOption = "";
  String nameOption = "";
  bool makeNull = false;
  int userTypeId = 0;
  String selectedItem = "";
  bool isSearchView = false;
  List<VDkMaterialCount> filteredCounts = [];
  @override
  void initState() {
    animationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -50),
      end: const Offset(0, 50),
    ).animate(animationController);
    searchContrl.addListener(() {
      setState(() {
        hasText = searchContrl.text.isNotEmpty;
      });
    });
    saveOption = "Your device";
    nameOption = "None";
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    animationController.dispose();
    submitFocus.dispose();
    myController.dispose();
    audioPlayer.dispose();
    searchContrl.dispose();
    super.dispose();
  }
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openEndDrawer() {
    _scaffoldKey.currentState!.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final trs = AppLocalizations.of(context);
    GlobalVarsProvider globalProvider = Provider.of<GlobalVarsProvider>(context);
    Size size = MediaQuery.of(context).size;
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
        MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 420.0;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async{
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool(SharedPrefKeys.countingData, true);
        Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage()));
      },
      child: Scaffold(
        key: _scaffoldKey,
        floatingActionButton: Visibility(
          visible: (userTypeId==1),
          child: BlocBuilder<ListPageBloc, ListPageBlocState>(
              builder: (context, state) {
                if (state is SavingInvoiceState) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: SizedBox(
                      width: size.width / 15,
                      height: size.height / 35,
                      child: CircularProgressIndicator(
                        color: Theme
                            .of(context)
                            .primaryColor,
                        strokeWidth: 3,
                      ),
                    ),
                  );
                }
                return FloatingActionButton(
                    shape: const CircleBorder(),
                    backgroundColor: Theme
                        .of(context)
                        .cardColor,
                    onPressed: () async{
                        await savingOptionDialog(context);
                    },
                    child: Icon(Icons.save, color: Theme
                        .of(context)
                        .primaryColor)
                );
              }
          ),
        ),
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          automaticallyImplyLeading: false,
          title: FittedBox(
            fit: BoxFit.cover,
            child: Padding(
              padding: const EdgeInsets.only(left: 7.0),
              child: Text(trs.translate("counting") ?? "Counting"),
            ),
          ),
          titleTextStyle: TextStyle(color: Theme.of(context).cardColor,fontSize: 20),
          actions: [
            Container(
              width: size.width/2,
              height: size.height/22,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: TextField(
                controller: searchContrl,
                decoration: InputDecoration(
                  prefixIcon: IconButton(
                    visualDensity: const VisualDensity(horizontal: -4),
                    padding: EdgeInsets.zero,
                    onPressed: () async{
                      setState(() {
                        cameraVisible = false;
                        firstSearchBarcode = null;
                        searchVisible = !searchVisible;
                        animationController.repeat(reverse: true);
                      });
                    },
                    icon: (searchVisible==false) ? SvgPicture.asset("assets/svg/barcode.svg",colorFilter: const ColorFilter.mode(Color(0xffCDCDCD), BlendMode.srcIn),
                      height: size.height/40,
                      width: size.width/75,)
                        : SvgPicture.asset("assets/svg/no_barcode.svg",
                      colorFilter: const ColorFilter.mode(Color(0xffCDCDCD), BlendMode.srcIn),
                      height: size.height/40,
                      width: size.width/75,
                      fit: BoxFit.cover,
                    ),
                  ),
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
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () {
                      primaryFocus!.unfocus();
                      searchContrl.clear();
                      setState(() {
                        hasText = false;
                        nameOption = "None";
                      });
                      BlocProvider.of<ListPageBloc>(context).add(SearchCountsEvent(matCounts, ''));
                    },
                  )
                      : const Icon(Icons.search, size: 16),
                  suffixIconColor: const Color(0xffCDCDCD),
                ),
                cursorColor: Colors.black,
                onSubmitted: (value){
                  BlocProvider.of<ListPageBloc>(context).add(SearchCountsEvent(filteredCounts, value));
                },
                onChanged: (value){
                  setState(() {
                    hasText = value.isNotEmpty;
                  });
                  if(value.isEmpty){
                    setState(() {
                      nameOption = "None";
                    });
                    BlocProvider.of<ListPageBloc>(context).add(SearchCountsEvent(matCounts, value));
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: IconButton(
                visualDensity: const VisualDensity(horizontal: -4),
                padding: EdgeInsets.zero,
                onPressed: () async{
                  setState(() {
                    searchVisible = false;
                    searchContrl.text = '';
                    cameraVisible = !cameraVisible;
                    animationController.repeat(reverse: true);
                  });
                },
                icon: (cameraVisible==false) ? SvgPicture.asset("assets/svg/barcode.svg",colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn))
                    : SvgPicture.asset("assets/svg/no_barcode.svg",
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  height: size.height/27,
                  width: size.width/58,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            (userTypeId==1) ?
            PopupMenuButton(
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
                  value: "Uncounted",
                  onTap: (){
                    BlocProvider.of<UncountedProductsBloc>(context).add(LoadUncountedProdsEvent(matCounts, widget.params.WhId));
                    Navigator.push(context, MaterialPageRoute(builder: (context) => UncountedProdsPage(params: widget.params, matCounts: matCounts)));
                  },
                  child: Text(trs.translate("show_uncounted") ?? "Show uncounted products"),
                ),
                PopupMenuItem<String>(
                  value: "Delete",
                  onTap: () => _showExitDialog(),
                  child: Text(trs.translate("delete_exit") ?? "Delete and exit"),
                ),
                PopupMenuItem<String>(
                    value: "Sorting",
                    onTap: () => _openEndDrawer(),
                    child: Text(trs.translate("sorting") ?? "Sorting")
                )
              ],

            )
                : PopupMenuButton(
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
                      value: "Uncounted",
                      onTap: (){
                        BlocProvider.of<UncountedProductsBloc>(context).add(LoadUncountedProdsEvent(matCounts, widget.params.WhId));
                        Navigator.push(context, MaterialPageRoute(builder: (context) => UncountedProdsPage(params: widget.params, matCounts: matCounts)));
                      },
                      child: Text(trs.translate("show_uncounted") ?? "Show uncounted products"),
                    ),
                    PopupMenuItem<String>(
                        value: "Sorting",
                        onTap: () => _openEndDrawer(),
                        child: Text(trs.translate("sorting") ?? "Sorting")
                    )
              ],
            )
          ],
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
                          groupValue: nameOption,
                          title: Text(trs.translate("a_z") ?? "From A to Z",
                            style: const TextStyle(fontSize: 16),
                          ),
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (val) {
                            setState(() {
                              nameOption = val!;
                            });
                          }),
                      RadioListTile(
                          dense: true,
                          value: "From Z to A",
                          groupValue: nameOption,
                          title: Text(trs.translate("z_a") ?? "From Z to A",
                            style: const TextStyle(fontSize: 16),
                          ),
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (val) {
                            setState(() {
                              nameOption = val!;
                            });
                          }),
                      Text("${trs.translate("counted") ?? "Counted"}:",
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)
                      ),
                      RadioListTile(
                          dense: true,
                          value: "From low to high",
                          groupValue: nameOption,
                          title: Text(trs.translate("low_high") ?? "From low to high",
                            style: const TextStyle(fontSize: 16),
                          ),
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (val) {
                            setState(() {
                              nameOption = val!;
                            });
                          }),
                      RadioListTile(
                          dense: true,
                          value: "From high to low",
                          groupValue: nameOption,
                          title: Text(trs.translate("high_low") ?? "From high to low",
                            style: const TextStyle(fontSize: 16),
                          ),
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (val) {
                            setState(() {
                              nameOption = val!;
                            });
                          }),
                      Text("${trs.translate("order") ?? "Order"}:",
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)
                      ),
                      RadioListTile(
                          dense: true,
                          value: "From less to more",
                          groupValue: nameOption,
                          title: Text(trs.translate("less_more") ?? "From less to more",
                            style: const TextStyle(fontSize: 16),
                          ),
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (val) {
                            setState(() {
                              nameOption = val!;
                            });
                          }),
                      RadioListTile(
                          dense: true,
                          value: "From more to less",
                          groupValue: nameOption,
                          title: Text(trs.translate("more_less") ?? "From more to less",
                            style: const TextStyle(fontSize: 16),
                          ),
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (val) {
                            setState(() {
                              nameOption = val!;
                            });
                          }),
                      RadioListTile(
                          dense: true,
                          value: "Only less",
                          groupValue: nameOption,
                          title: Text(trs.translate("only_less") ?? "Only less",
                            style: const TextStyle(fontSize: 16),
                          ),
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (val) {
                            setState(() {
                              nameOption = val!;
                            });
                          }),
                      RadioListTile(
                          dense: true,
                          value: "Only more",
                          groupValue: nameOption,
                          title: Text(trs.translate("only_more") ?? "Only more",
                            style: const TextStyle(fontSize: 16),
                          ),
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (val) {
                            setState(() {
                              nameOption = val!;
                            });
                          }),
                      RadioListTile(
                          value: "None",
                          groupValue: nameOption,
                          title: Text(trs.translate("none") ?? "None",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (val) {
                            setState(() {
                              nameOption = val!;
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
                    filterList(context);
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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: BlocListener<MaterialBloc,MaterialBlocState>(
          listener: (BuildContext context, MaterialBlocState state) {
            if(state is LoadErrorMaterialState) {
              if(countingType=='single_count'){
                errorDialog(context, MediaQuery.sizeOf(context), state.errorText);
              }
            }
            else if(state is SavedMaterialState) {
              setState(() {
                searchContrl.text = '';
                nameOption = "None";
              });
              debugPrint("Saved state params: ${widget.params}");
              BlocProvider.of<ListPageBloc>(context).add(LoadListEvent(widget.params));
            }
            else if(state is SaveErrorMaterialCountState) {
                errorDialog(context, MediaQuery.sizeOf(context), state.errorText);
            }
          },
          child: BlocListener<ListPageBloc,ListPageBlocState>(
            listener: (BuildContext context, ListPageBlocState state) async{
              if(state is LoadErrorListState){
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(backgroundColor: Colors.deepOrangeAccent,
                        content: Text("${trs.translate("error_text") ?? "Error"}: ${trs.translate('try_again') ?? "Try again"}")
                    )
                );
                BlocProvider.of<ListDataPageBloc>(context).add(LoadListDataEvent());
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=> const ListDataPage()));
              }
              else if(state is ListLoadedState){
                globalProvider.setCounts = state.materialCounts;
                warehouseCondition = state.params.WhType;
                countingType = state.params.CountType;
                deviceName = state.deviceName;
                matCounts = state.materialCounts;
                userTypeId = state.userTypeId;
                filteredCounts = state.materialCounts;
              }
              else if(state is SearchingCompletedState){
                setState(() {
                  filteredCounts = state.counts;
                  searchContrl.text = state.barcode;
                });
              }
              else if(state is SearchResultEmptyState){
                setState(() {
                  filteredCounts = [];
                  searchContrl.text = state.barcode;
                });
              }
              else if(state is SaveErrorInvoiceState){
                errorDialog(context, MediaQuery.of(context).size, state.errorText);
              }
              else if(state is SavedInvoiceState){
                globalProvider.getCounts.clear();
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setBool(SharedPrefKeys.countingData, false);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage()));
              }
              else if(state is MaterialDeletedState){
                setState(() {
                  searchContrl.text = '';
                  nameOption = "None";
                  filteredCounts.removeWhere((element) => (element.MatId==state.materialCount.MatId && element.UserId==state.materialCount.UserId && element.DeviceId==state.materialCount.DeviceId));
                });
              }
              else if(state is CountsDeletedState){
                globalProvider.getCounts.clear();
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const HomePage()));
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setBool(SharedPrefKeys.countingData, false);
              }
              else if(state is ErrorDeleteState){
                errorDialog(context, MediaQuery.of(context).size, state.error);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          Text(trs.translate("deviceName") ??
                              "Device name",
                            style: const TextStyle(
                                color: Color(0xff787878), fontSize: 15),
                          ),
                          Text(": ${widget.params.DeviceName}",
                            style: const TextStyle(
                                color: Color(0xff787878), fontSize: 13),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                        height: (cameraVisible == true || searchVisible == true)
                            ? size.height / 4.5
                            : 0,
                        child: Stack(
                          children: [
                            (searchVisible==true) ? QRView(
                              key: qrKey2,
                              onQRViewCreated: _onSearchQRViewCreated,
                              overlay: QrScannerOverlayShape(
                                  overlayColor: Colors.white,
                                  borderColor: Colors.black,
                                  borderRadius: 10,
                                  borderLength: 30,
                                  borderWidth: 10,
                                  cutOutSize: scanArea
                              ),
                              onPermissionSet: (ctrl, p) =>
                                  _onPermissionSet(context, ctrl, p),
                            )
                                : QRView(
                              key: qrKey,
                              onQRViewCreated: _onQRViewCreated,
                              overlay: QrScannerOverlayShape(
                                  overlayColor: Colors.white,
                                  borderColor: Colors.black,
                                  borderRadius: 10,
                                  borderLength: 30,
                                  borderWidth: 10,
                                  cutOutSize: scanArea
                              ),
                              onPermissionSet: (ctrl, p) =>
                                  _onPermissionSet(context, ctrl, p),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: SlideTransition(
                                position: offsetAnimation,
                                child: Container(
                                  height: 2,
                                  width: size.width / 1.2,
                                  decoration: const BoxDecoration(
                                    color: Colors.redAccent,
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      stops: [0.0, 1],
                                      colors: [
                                        Colors.redAccent,
                                        Colors.redAccent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        )
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 25.0, bottom: 5),
                      child: TextField(
                        focusNode: submitFocus,
                        controller: myController,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                            enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(0xff0398A2)
                                )
                            ),
                            focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(0xff0398A2)
                                )
                            ),
                            border: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(0xff0398A2)
                                )
                            ),
                            isDense: true,
                            hintText: trs.translate("write_barcode") ??
                                "Write barcode",
                            hintStyle: const TextStyle(
                                fontSize: 20, color: Color(0xffADADAD)),
                            suffixIcon: SizedBox(
                              width: size.width / 4,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        myController.text = "";
                                      });
                                    },
                                    icon: const Icon(
                                        Icons.close, color: Colors.red,
                                        size: 20),
                                  ),
                                  BlocBuilder<MaterialBloc,MaterialBlocState>(
                                    builder: (context, state){
                                      if(state is LoadingMaterialState){
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 5.0),
                                          child: SizedBox(
                                              width: size.width/30,
                                              height: size.height/60,
                                              child: CircularProgressIndicator(
                                                color: Theme.of(context).primaryColor,
                                                strokeWidth: 2,
                                              )
                                          ),
                                        );
                                      }
                                      return IconButton(
                                          onPressed: () async{
                                            submitFocus.unfocus();
                                            if(myController.text.isNotEmpty){
                                              BlocProvider.of<MaterialBloc>(context)
                                                  .add(LoadMaterialEvent(
                                                  widget.params.WhId, myController.text));
                                              if(countingType=='multiple_count') {
                                                setState(() {
                                                  myController.text = "";
                                                });
                                                countDialog(context,
                                                    MediaQuery.sizeOf(context));
                                              }
                                              else{
                                                Completer<MaterialLoadedState> completer = Completer();
                                                BlocProvider.of<MaterialBloc>(context).stream.listen((state) {
                                                  if(state is MaterialLoadedState){
                                                    completer.complete(state);
                                                  }
                                                  else if(state is LoadErrorMaterialState){
                                                    completer.completeError("Error loading material...");
                                                  }
                                                });
                                                final loadedState = await completer.future;
                                                setState(() {
                                                  myController.text = "";
                                                });
                                                BlocProvider.of<MaterialBloc>(
                                                    context).add(
                                                    SaveMaterialEvent(
                                                        "",
                                                        loadedState.material,
                                                        1,
                                                        loadedState.material.UnitDetId,
                                                        widget.params
                                                    ));
                                              }
                                            }
                                          },
                                          icon: Icon(
                                            Icons.task_alt_sharp, color: Theme
                                              .of(context)
                                              .primaryColor, size: 20,)
                                      );
                                    },
                                  )
                                ],
                              ),
                            )
                        ),
                      ),
                    ),
                    RefreshIndicator(
                      onRefresh: ()async{
                        if(searchContrl.text.isNotEmpty){
                          String newString = searchContrl.text.replaceAll('\n', '');
                          BlocProvider.of<ListPageBloc>(context).add(SearchCountsEvent(filteredCounts,newString));
                        }
                        else {
                          setState(() {
                            nameOption = "None";
                          });
                          BlocProvider.of<ListPageBloc>(context).add(
                              LoadListEvent(widget.params));
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 10),
                        child: SizedBox(
                          height: size.height / 1.33,
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: filteredCounts.length,
                              itemBuilder: (context, index) {
                                final count = filteredCounts[index];
                                return Dismissible(
                                  key: UniqueKey(),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    color: Colors.red,
                                    alignment: Alignment.centerRight,
                                    child: Icon(Icons.delete, color: Theme.of(context).cardColor, size: 30),
                                  ),
                                  confirmDismiss: (direction) async {
                                    // Show confirmation dialog
                                    final bool shouldDismiss = await showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text(trs.translate("confirm") ?? 'Confirm Delete'),
                                        content: Text('${trs.translate("delete_txt") ?? 'Are you sure you want to delete'} ${count.MatName}?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(false),
                                            child: Text(trs.translate("cancel") ?? 'Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(true);
                                              context.read<ListPageBloc>().add(DeleteMaterialEvent(count, widget.params, count.UserId));
                                            },
                                            child: Text(trs.translate("delete") ?? 'Delete'),
                                          ),
                                        ],
                                      ),
                                    );

                                    return shouldDismiss; // Return true to dismiss, false to keep
                                  },
                                  child: ProductsItem(
                                      countingType:countingType,
                                      warehouseCondition:warehouseCondition,
                                      materialCount: filteredCounts[index]),
                                );
                              }
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
      ),
    );
  }

  void filterList(BuildContext context) {
    setState(() {
      filteredCounts = Provider.of<GlobalVarsProvider>(context, listen: false).getCounts.toList();

      // Apply sorting criteria sequentially
      filteredCounts.sort((a, b) {
        int result = 0;

        // Name sorting
        switch (nameOption) {
          case "From A to Z":
            result = a.MatName.compareTo(b.MatName);
            break;
          case "From Z to A":
            result = b.MatName.compareTo(a.MatName);
            break;
          case "From low to high":
            result = a.MatCountTotal.compareTo(b.MatCountTotal);
            break;
          case "From high to low":
            result = b.MatCountTotal.compareTo(a.MatCountTotal);
            break;
          case "From less to more":
            result = (a.MatCountTotal-a.MatWhTotalAmount).compareTo(b.MatCountTotal-b.MatWhTotalAmount);
            break;
          case "From more to less":
            result = (b.MatCountTotal-b.MatWhTotalAmount).compareTo(a.MatCountTotal-a.MatWhTotalAmount);
            break;
        }
        return result;
      });
      switch (nameOption) {
        case "Only less":
          filteredCounts = filteredCounts.where((item) => (item.MatCountTotal-item.MatWhTotalAmount) <0).toList();
          break;
        case "Only more":
          filteredCounts = filteredCounts.where((item) => (item.MatCountTotal-item.MatWhTotalAmount) >0).toList();
          break;
      }
    });
  }

  void _onSearchQRViewCreated(QRViewController controller2) {
    setState(() {
      this.controller2 = controller2;
    });

    controller2.scannedDataStream.listen((scanData) async {
      setState(() {
        result = scanData;
        searchContrl.text = result?.code ?? "";
      });

      if (result != null && !productSearched) {
        if (firstSearchBarcode == null) {
          firstSearchBarcode = searchContrl.text;
          await _playSound();
          firstBarcodeTime = DateTime.now();
          _startBarcodeTimer();
          productSearched=true;
          String newString = searchContrl.text.replaceAll('\n', '');
          BlocProvider.of<ListPageBloc>(context).add(SearchCountsEvent(filteredCounts, newString));
        }
        else {
          if (searchContrl.text == firstSearchBarcode) {
            if (_barcodeTimer?.isActive ?? false) {}
          }
          else {
            firstSearchBarcode = searchContrl.text;
            firstBarcodeTime = DateTime.now();
            _barcodeTimer?.cancel();
            await _playSound();
            _startBarcodeTimer();
            productSearched=true;
            String newString = searchContrl.text.replaceAll('\n', '');
            BlocProvider.of<ListPageBloc>(context).add(SearchCountsEvent(matCounts, newString));
          }
        }
        setState(() {
          productSearched = false;
        });
      }
    });
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });

    controller.scannedDataStream.listen((scanData) async {
      setState(() {
        result = scanData;
        myController.text = result?.code ?? "";
      });

      if (result != null && !_hasShownCountDialog) {
        _hasShownCountDialog = true;
        await _handleTimer();
      }
    });
  }

  Future<void> _handleTimer() async{
    if (myController.text.isNotEmpty) {
      if (countingType == 'multiple_count') {
        String newString = myController.text.replaceAll('\n', '');
        BlocProvider.of<MaterialBloc>(context).add(
          LoadMaterialEvent(widget.params.WhId, newString),
        );
        await _playSound();
        await countDialog(context, MediaQuery.sizeOf(context));
        setState(() {
          myController.text = "";
        });
      }
      else{
        if (firstBarcode == null) {
          firstBarcode = myController.text;
          await _playSound();
          firstBarcodeTime = DateTime.now();
          _startBarcodeTimer();
          await _handleMultipleCount();
        }
        else {
          if (myController.text == firstBarcode) {
            setState(() {
              myController.text = "";
            });
            if (_barcodeTimer?.isActive ?? false) {}
          }
          else {
            firstBarcode = myController.text;
            firstBarcodeTime = DateTime.now();
            _barcodeTimer?.cancel();
            await _playSound();
            _startBarcodeTimer();
            await _handleMultipleCount();
          }
        }
      }
      setState(() {
        _hasShownCountDialog = false;
      });
    }
  }

  void _startBarcodeTimer() {
    _barcodeTimer = Timer(Duration(seconds: timerDuration), () async {
      firstBarcode = null;
    });
  }

  Future<void> _handleMultipleCount() async {
    String newString = myController.text.replaceAll('\n', '');
    BlocProvider.of<MaterialBloc>(context).add(
      LoadMaterialEvent(widget.params.WhId, newString),
    );
    Completer<MaterialLoadedState> completer = Completer();
    StreamSubscription subscription;
    subscription = BlocProvider.of<MaterialBloc>(context).stream.listen((state) {
      if (state is MaterialLoadedState) {
        completer.complete(state);
      }
      else if(state is LoadErrorMaterialState){

        completer.completeError("Error loading material");
        setState(() {
          _hasShownCountDialog = true;
        });
      }
    });

    final loadedState = await completer.future;
    setState(() {
      myController.text = "";
    });
    await subscription.cancel();
    BlocProvider.of<MaterialBloc>(context).add(
      SaveMaterialEvent(
          "",
          loadedState.material,
          1,
          loadedState.material.UnitDetId,
          widget.params
      ),
    );
  }

  Future<void> _playSound() async {
    await audioPlayer.play(AssetSource('sounds/beep.mp3'));
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    debugPrint('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  Future<void> countDialog(BuildContext context, Size size ) async {
    int number = 1;
    bool tapped =false;
    final trs = AppLocalizations.of(context);
    await showDialog(
        barrierDismissible: false,
        context: context, builder: (_) {
      TextEditingController countController = TextEditingController(
          text: number.toString());
      return BlocProvider.value(
        value: context.watch<MaterialBloc>(),
        child: BlocBuilder<MaterialBloc,MaterialBlocState>(
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
                                  _hasShownCountDialog = false;
                                  BlocProvider.of<MaterialBloc>(context).add(SaveMaterialEvent(descCtrl.text,state.material,number.toDouble(), dropdownValue.UnitDetId, widget.params));
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
        ),
      );
    }
    );
  }

  Future<void> errorDialog(BuildContext context, Size size, String errorText) async {
    final trs = AppLocalizations.of(context);
    await audioPlayer.play(AssetSource('sounds/error.mp3'));
    await showDialog(
        barrierDismissible: false,
        context: context, builder: (_) {
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
            child: Text(trs.translate("error_text") ?? "ERROR"),
          ),
          content: SizedBox(
            height: size.height/5,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("${trs.translate("error") ?? "Error"}: $errorText"),
                  TextButton(onPressed: (){
                    setState(() {
                      _hasShownCountDialog = false;
                    });
                    setState(() {
                      myController.text = "";
                    });
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
    );
  }

  Future<void> savingOptionDialog(BuildContext context) async {
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
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  RadioListTile(
                      value: "Your device",
                      groupValue: saveOption,
                      title: Text(trs.translate("save_this") ?? "Save only my invoices"),
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (val) {
                        set(() {
                          saveOption = val!;
                        });
                      }),
                  RadioListTile(
                      value: "Others device",
                      groupValue: saveOption,
                      title: Text(trs.translate("save_all") ?? "Save all invoices"),
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (val) {
                        set(() {
                          saveOption = val!;
                        });
                      }),
                ],
              ),
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
                  Navigator.pop(context, true);
                  bool isOnlyAdminDevice = (saveOption=="Your device") ? true : false;
                  BlocProvider.of<ListPageBloc>(context).add(SaveInvoiceEvent(matCounts, isOnlyAdminDevice, widget.params));
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

  Future<bool> _showExitDialog() async {
    final trs = AppLocalizations.of(context);
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(trs.translate("confirmation") ?? "Confirmation"),
            content: Text(trs.translate('exit_app_txt') ?? 'Are you sure you want to delete all materials and exit?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(trs.translate("cancel") ?? "Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context, true);
                  BlocProvider.of<ListPageBloc>(context).add(DeleteCountsEvent(widget.params));
                },
                child: Text(trs.translate("confirm") ?? "Confirm"),
              ),
            ],
          );
        }
    );
  }
}

class ProductsItem extends StatefulWidget {
  final String countingType;
  final String warehouseCondition;
  final VDkMaterialCount materialCount;
  const ProductsItem({super.key, required this.materialCount, required this.countingType, required this.warehouseCondition});

  @override
  State<ProductsItem> createState() => _ProductsItemState();
}

class _ProductsItemState extends State<ProductsItem> {
  @override
  Widget build(BuildContext context) {
    final trs = AppLocalizations.of(context);
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => ProductCountsPage(materialCount: widget.materialCount)));
        },
        child: Container(
          height: (widget.materialCount.MatName.length < 35) ? size.height/5.1 : (widget.materialCount.MatName.length < 70) ? size.height/4.5 : size.height/4,
          decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                    color: Theme.of(context).dividerColor,
                    blurRadius: 2, offset: const Offset(1,1)
                )
              ]
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: size.width/1.5,
                      child: Text(widget.materialCount.MatName,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
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
                          width: size.width/1.6,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(widget.materialCount.BarcodeValue)),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          const Icon(Icons.phone_iphone_rounded),
                          SizedBox(
                            width: size.width/1.7,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(widget.materialCount.DeviceId)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 7.0),
                      child: Row(
                        children: [
                          const Icon(Icons.person),
                          Text(widget.materialCount.UName),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: size.width/3.5,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text("${trs.translate("stock") ?? "Stock"} : ${widget.materialCount.MatWhTotalAmount.toInt()}",
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 13.0),
                          child: SizedBox(
                            width: size.width/2.7,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text("${trs.translate("counted") ?? "Counted"} : ${widget.materialCount.MatCountTotal.toInt()}",
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              Container(
                alignment: Alignment.center,
                height: size.height,
                width: size.width/5,
                decoration: BoxDecoration(
                    color: (widget.materialCount.MatCountTotal-widget.materialCount.MatWhTotalAmount < 0) ? const Color(0xffE41313)
                        : (widget.materialCount.MatCountTotal-widget.materialCount.MatWhTotalAmount == 0) ? const Color(0xffFFDB23) : const Color(0xff13E499),
                    borderRadius: BorderRadius.circular(5)
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text((widget.materialCount.MatCountTotal-widget.materialCount.MatWhTotalAmount).toInt().toString(),
                      style: TextStyle(color: Theme.of(context).cardColor, fontSize: 20, fontWeight: FontWeight.w600)
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

extension TextEditingControllerExt on TextEditingController {
  void selectAll(int baseOffset) {
    if (text.isEmpty) return;
    selection = TextSelection(baseOffset: baseOffset, extentOffset: text.length);
  }
}


