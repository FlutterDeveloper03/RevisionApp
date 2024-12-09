// ignore_for_file: must_be_immutable

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:revision_app/Pages/ListPage.dart';
import 'package:revision_app/bloc/ListPageBLoc.dart';
import 'package:revision_app/bloc/ProductCountsPageBloc.dart';
import 'package:revision_app/helpers/localization.dart';
import 'package:revision_app/models/v_dk_material_count.dart';
import 'package:revision_app/provider/GlobalVarsProvider.dart';

class ProductCountsPage extends StatefulWidget {
  final VDkMaterialCount materialCount;
  const ProductCountsPage({super.key, required this.materialCount});

  @override
  State<ProductCountsPage> createState() => _ProductCountsPageState();
}

class _ProductCountsPageState extends State<ProductCountsPage> {
  List<VDkMaterialCount> matCounts = [];
  Map<int, double> countTotals = {};
  double totalCount = 0;
  double totalDiff = 0;

  @override
  void initState() {
    super.initState();
    context.read<ProductCountsPageBloc>().add(
        LoadProductCountsEvent(
            widget.materialCount.MatCountParams!,
            widget.materialCount.MatId,
            widget.materialCount.UserId
        )
    );
  }

  void _updateTotalCount(double change) {
    setState(() {
      totalCount += change;
      totalDiff = totalCount - matCounts.last.MatWhTotalAmount;
    });
  }

  @override
  Widget build(BuildContext context) {
    final trs = AppLocalizations.of(context);
    Size size = MediaQuery.of(context).size;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop){
        context.read<ListPageBloc>().add(LoadListEvent(widget.materialCount.MatCountParams!));
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => ListPage(params: widget.materialCount.MatCountParams!, provider: Provider.of<GlobalVarsProvider>(context))), (route) => false);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        floatingActionButton: BlocBuilder<ProductCountsPageBloc, ProductCountsPageState>(
          builder: (BuildContext context, ProductCountsPageState state) {
            if(state is UpdatingMatCountState) {
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
            else {
              return FloatingActionButton(
                  shape: const CircleBorder(),
                  backgroundColor: Theme
                      .of(context)
                      .cardColor,
                  onPressed: () async{
                    await _saveDialog(context);
                  },
                  child: Icon(Icons.save, color: Theme
                      .of(context)
                      .primaryColor)
              );
            }
          },
        ),
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: (){
              context.read<ListPageBloc>().add(LoadListEvent(widget.materialCount.MatCountParams!));
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => ListPage(params: widget.materialCount.MatCountParams!, provider: Provider.of<GlobalVarsProvider>(context))), (route) => false);
            },
            icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).cardColor),
          ),
          title: Text(widget.materialCount.MatName),
          titleTextStyle: TextStyle(color: Theme.of(context).cardColor, fontSize: 20),
        ),
        body: BlocConsumer<ProductCountsPageBloc, ProductCountsPageState>(
          listener: (BuildContext context, ProductCountsPageState state) {
            if (state is ProductCountsLoadedState){
              matCounts = state.materialCounts;
              totalCount = 0;
              totalDiff = 0;
              setState(() {
                for (var count in state.materialCounts){
                 totalCount += count.MatCountTotal;
                }
                totalDiff = totalCount - matCounts.last.MatWhTotalAmount;
              });
            }
            else if(state is UpdatedMatCountState){
              context.read<ListPageBloc>().add(LoadListEvent(widget.materialCount.MatCountParams!));
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => ListPage(params: widget.materialCount.MatCountParams!, provider: Provider.of<GlobalVarsProvider>(context))), (route) => false);
            }
            else if (state is UpdateErrorMatCountState) {
              _errorUpdateDialog(context, state.errorText);
            }
          },
          builder: (context, state) {
            if (state is ProductCountsLoadedState){
              return SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.only(top: 5, bottom: 10),
                  child: Column(
                    children: [
                      RefreshIndicator(
                        onRefresh: () async{
                          context.read<ProductCountsPageBloc>().add(LoadProductCountsEvent(widget.materialCount.MatCountParams!, widget.materialCount.MatId, widget.materialCount.UserId));
                        },
                        child: SizedBox(
                          height: size.height / 1.25,
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: state.materialCounts.length,
                              itemBuilder: (context, index) {
                                final count = state.materialCounts[index];
                                return ProductCountsItem(materialCount: count, countTotals: countTotals, onCountChanged: _updateTotalCount);
                              }
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15.0, left: 12),
                        child: Row(
                          children: [
                            Container(
                              width: size.width/2.8,
                              height: size.height/19,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(5)
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              child: FittedBox(
                                fit: BoxFit.fitWidth,
                                child: Text("${trs.translate("counted") ?? "Counted"}: ${totalCount.toInt().toString()}",
                                  style: TextStyle(
                                    color: Theme.of(context).cardColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: Container(
                                width: size.width/2.8,
                                height: size.height/19,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: (totalDiff < 0) ? const Color(0xffE41313) : (totalDiff == 0) ? const Color(0xffFFDB23) : const Color(0xff13E499),
                                    borderRadius: BorderRadius.circular(5)
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 3),
                                child: FittedBox(
                                  fit: BoxFit.fitWidth,
                                  child: Text("${trs.translate("diff") ?? "Difference"}: ${totalDiff.toInt()}",
                                    style: TextStyle(
                                      color: Theme.of(context).cardColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            }
            else if (state is LoadingProductCountsState){
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            else if (state is ProductCountsLoadErrorState){
              return Center(
                child: Column(
                  children: [
                    Text(state.errorText),
                    TextButton(
                        onPressed: (){
                          context.read<ProductCountsPageBloc>().add(LoadProductCountsEvent(widget.materialCount.MatCountParams!, widget.materialCount.MatId, widget.materialCount.UserId));
                        },
                        child: Text(trs.translate("try_again") ?? "Try again")
                    )
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Future<void> _saveDialog(BuildContext context) async {
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
                  BlocProvider.of<ProductCountsPageBloc>(context).add(UpdateMatCountEvent(matCounts, countTotals));
                },
                child: Text(trs.translate("confirm") ?? "Confirm"),
              ),
            ],
          );
        }
    );
  }

  Future<bool> _errorUpdateDialog(BuildContext context, String errorText) async {
    final trs = AppLocalizations.of(context);
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(trs.translate("error_text") ?? "Error"),
            content: Text("${trs.translate("save_error") ?? 'Error while saving'}: $errorText. ${trs.translate("try_again") ?? "Try again"}"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: const Text("Ok"),
              ),
            ],
          );
        }
    );
  }
}

class ProductCountsItem extends StatefulWidget {
  final VDkMaterialCount materialCount;
  Map<int, double>? countTotals = {};
  final Function(double) onCountChanged;
  ProductCountsItem({super.key, required this.materialCount, this.countTotals, required this.onCountChanged});

  @override
  State<ProductCountsItem> createState() => _ProductCountsItemState();
}

class _ProductCountsItemState extends State<ProductCountsItem> {
  double count = 0;
  TextEditingController countCtrl = TextEditingController();
  FocusNode countFocusNode = FocusNode();
  bool pressed = false;
  double _fontSize = 24;

  @override
  void initState() {
    super.initState();
    count = widget.countTotals?[widget.materialCount.CountId] ?? widget.materialCount.MatCountTotal;
    countCtrl = TextEditingController(text: count.toInt().toString());
    countCtrl.selection = TextSelection.fromPosition(TextPosition(offset: countCtrl.text.length));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    countCtrl.addListener(_adjustFontSizeToFit);
  }

  @override
  void dispose() {
    countCtrl.removeListener(_adjustFontSizeToFit);
    countCtrl.dispose();
    countFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trs = AppLocalizations.of(context);
    Size size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 5),
      child: Container(
        height: (widget.materialCount.MatName.length < 35) ? size.height/4.5 : (widget.materialCount.MatName.length < 70) ? size.height/4 : size.height/3.5,
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                  color: Theme.of(context).dividerColor,
                  blurRadius: 2,
                  offset: const Offset(1, 1))
            ]),
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
                    width: size.width / 1.5,
                    child: Text(
                      widget.materialCount.MatName,
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
                        width: size.width/1.7,
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
                        const Icon(Icons.calendar_month_outlined, size: 22,),
                        Padding(
                          padding: const EdgeInsets.only(left: 3.0),
                          child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(widget.materialCount.MatCountDate.toString())),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, right: 5),
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
                        Padding(
                          padding: const EdgeInsets.only(left: 3.0),
                          child: Text(widget.materialCount.UName),
                        ),
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
                            child: Text(
                              "${trs.translate("stock") ?? "Stock"} : ${widget.materialCount.MatWhTotalAmount.toInt()}",
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: SizedBox(
                          width: size.width/3,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "${trs.translate("counted") ?? "Counted"} : ${count.toInt()}",
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
              width: size.width / 5,
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).primaryColor),
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: (widget.materialCount.MatName.length < 35) ? size.height / 17 : (widget.materialCount.MatName.length < 70) ? size.height / 14 : size.height / 13,
                    width: double.infinity,
                    child: IconButton(
                      iconSize: size.width / 12,
                      onPressed: () {
                        increment();
                      },
                      style: IconButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(4),
                              topLeft: Radius.circular(4),
                            )),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      icon: Icon(Icons.add, color: Theme.of(context).cardColor),
                    ),
                  ),
                  TextField(
                    cursorColor: Colors.black,
                    style: TextStyle(fontSize: _fontSize, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                    controller: countCtrl,
                    focusNode: countFocusNode,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    maxLength: 9,
                    onChanged: (value) {
                      if (value.startsWith('0') && value.length > 1) {
                        countCtrl.text = value.substring(1);
                        countCtrl.selection = TextSelection.fromPosition(TextPosition(offset: countCtrl.text.length));
                      }
                      updateCount(value);
                    },
                    onSubmitted: (value) {
                      updateCount(value);
                    },

                    decoration: InputDecoration(
                      counterText: "",
                      border: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      focusColor: Theme.of(context).scaffoldBackgroundColor,
                      disabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: (widget.materialCount.MatName.length < 35) ? size.height / 17 : (widget.materialCount.MatName.length < 70) ? size.height / 14 : size.height / 13,
                    width: double.infinity,
                    child: IconButton(
                      iconSize: size.width / 12,
                      onPressed: () {
                        decrement();
                      },
                      style: IconButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(4),
                                bottomRight: Radius.circular(4))),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      icon: Icon(Icons.remove, color: Theme.of(context).cardColor),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void increment() {
    setState(() {
      count++;
      countCtrl.text = count.toInt().toString();
    });
    widget.onCountChanged(1);
    widget.countTotals![widget.materialCount.CountId] = count;
  }

  void decrement() {
    if (count > 0) {
      setState(() {
        count--;
        countCtrl.text = count.toInt().toString();
      });
      widget.onCountChanged(-1);
      widget.countTotals![widget.materialCount.CountId] = count;
    }
  }

  void updateCount(String value) {
    if(value.isNotEmpty) {
      final double parsedValue = double.parse(value);
      if (parsedValue != count) {
        widget.onCountChanged(parsedValue - count);
        setState(() {
          count = parsedValue;
        });
        widget.countTotals![widget.materialCount.CountId] = count;
      }
    }
  }




  void _adjustFontSizeToFit() {
    double textWidth = _calculateTextWidth(countCtrl.text, _fontSize, Colors.black);

    while (textWidth > MediaQuery.sizeOf(context).width / 6 && _fontSize > 6) {
      _fontSize -= 2;
      textWidth = _calculateTextWidth(countCtrl.text, _fontSize, Colors.black);
    }
    while (textWidth < MediaQuery.sizeOf(context).width / 7 && _fontSize < 24){
      _fontSize += 2;
      textWidth = _calculateTextWidth(countCtrl.text, _fontSize, Colors.black);
    }
  }

  double _calculateTextWidth(String text, double fontSize, Color textColor) {
    final paragraphStyle = ui.ParagraphStyle(
      textAlign: TextAlign.left,
      fontSize: fontSize,
      maxLines: 1,
    );

    final textStyle = ui.TextStyle(
      fontSize: fontSize,
      color: textColor,
    );

    final paragraphBuilder = ui.ParagraphBuilder(paragraphStyle)
      ..pushStyle(textStyle)
      ..addText(text);

    final paragraph = paragraphBuilder.build();
    paragraph.layout(const ui.ParagraphConstraints(width: double.infinity));

    return paragraph.maxIntrinsicWidth;
  }

  // void _adjustFontSize(){
  //   setState(() {
  //     final textSpan = TextSpan(
  //       text: countCtrl.text,
  //       style: TextStyle(fontSize: _fontSize)
  //     );
  //       final textPainter = TextPainter(
  //         text: textSpan,
  //         maxLines: 1,
  //
  //       );
  //     textPainter.layout(minWidth: 0, maxWidth: context.size!.width);
  //
  //     if(textPainter.width > context.size!.width && _fontSize > _minFontSize){
  //       _fontSize -=1;
  //     }
  //   });
  // }
}


