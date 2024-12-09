// ignore_for_file: file_names, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:revision_app/Pages/CountedInvHeadsPage.dart';
import 'package:revision_app/bloc/CountedProductsBloc.dart';
import 'package:revision_app/helpers/SharedPrefKeys.dart';
import 'package:revision_app/helpers/localization.dart';
import 'package:revision_app/models/tbl_dk_inv_head.dart';
import 'package:revision_app/models/v_dk_inv_line.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CountedProductsPage extends StatefulWidget {
  final TblDkInvHead invHead;
  const CountedProductsPage({super.key, required this.invHead});

  @override
  State<CountedProductsPage> createState() => _CountedProductsPageState();
}

class _CountedProductsPageState extends State<CountedProductsPage> {
  bool hasText = false;
  List<VDkInvLine> invLineProducts = [];
  TextEditingController searchContrl = TextEditingController();
  String startDate = '';
  String endDate = '';
  String searchText = '';

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
    Size size = MediaQuery.of(context).size;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        double position = prefs.getDouble(SharedPrefKeys.scrollPosition) ?? 0;
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => CountedInvHeadsPage(position: position)));
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).cardColor),
            onPressed: () async{
              SharedPreferences prefs = await SharedPreferences.getInstance();
              double position = prefs.getDouble(SharedPrefKeys.scrollPosition) ?? 0;
              Navigator.push(context, MaterialPageRoute(builder: (context) => CountedInvHeadsPage(position: position)));
            },
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(trs.translate("counting") ?? "Counting"),
              Container(
                width: size.width/1.9,
                height: size.height/20,
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
                    hintText: (trs.translate("click_to_search") ?? "Click to search"),
                    hintStyle: const TextStyle(color: Color(0xffCDCDCD), fontSize: 15),
                    suffixIcon: hasText
                        ? IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          onPressed: () {
                          primaryFocus!.unfocus();
                          searchContrl.clear();
                          setState(() {
                            hasText = false;
                         });
                        BlocProvider.of<CountedProductsBloc>(context).add(SearchProductsEvent(invLineProducts, ""));
                      },
                    )
                        : const Icon(Icons.search, size: 16),
                    suffixIconColor: const Color(0xffCDCDCD),
                  ),
                  cursorColor: Colors.black,
                  onSubmitted: (value){
                    BlocProvider.of<CountedProductsBloc>(context).add(SearchProductsEvent(invLineProducts, value));
                  },
                  onChanged: (value){
                    setState(() {
                      hasText = value.isNotEmpty;
                    });
                    if(value.isEmpty){
                      BlocProvider.of<CountedProductsBloc>(context).add(SearchProductsEvent(invLineProducts, value));
                    }
                  },
                ),
              ),
            ],
          ),
          titleTextStyle: TextStyle(color: Theme.of(context).cardColor,fontSize: 20),
        ),
        body: BlocBuilder<CountedProductsBloc, CountedProductsState>(
          builder: (context, state){
            if(state is LoadedProductsState){
              invLineProducts = state.invLines;
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0, left: 15),
                      child: Text("#${widget.invHead.MatInvCode}",
                        style: const TextStyle(color: Color(0xff787878)),
                      ),
                    ),
                    RefreshIndicator(
                      onRefresh: ()async{
                        BlocProvider.of<CountedProductsBloc>(context).add(LoadProductsEvent(widget.invHead));
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: SizedBox(
                          height: size.height / 1.2,
                          child: ListView.builder(
                            itemCount: state.invLines.length,
                            itemBuilder: (context, index) {
                              return ProductsItem(
                                  invLine: state.invLines[index],
                                  invHead: widget.invHead
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            if(state is SearchingCompletedState){
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0, left: 15),
                      child: Text("#${widget.invHead.MatInvCode}",
                        style: const TextStyle(color: Color(0xff787878)),
                      ),
                    ),
                    RefreshIndicator(
                      onRefresh: ()async{
                        BlocProvider.of<CountedProductsBloc>(context).add(SearchProductsEvent(invLineProducts,searchContrl.text));
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: SizedBox(
                          height: size.height / 1.2,
                          child: ListView.builder(
                            itemCount: state.invLineProducts.length,
                            itemBuilder: (context, index) {
                              return ProductsItem(
                                  invLine: state.invLineProducts[index],
                                  invHead: widget.invHead
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            else if(state is LoadingProductsState){
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            else if(state is LoadErrorProductsState){
              return Padding(
                padding: const EdgeInsets.only(top: 300.0),
                child: Center(
                  child: Column(
                    children: [
                      Text(state.errorText,
                          style: const TextStyle(color: Colors.black, fontSize: 16)
                      ),
                      TextButton(
                          onPressed: (){
                            BlocProvider.of<CountedProductsBloc>(context).add(LoadProductsEvent(widget.invHead));
                          },
                          child: Text(trs.translate("try_again") ?? 'Try again',
                              style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16, fontWeight: FontWeight.bold)
                          )
                      )
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class ProductsItem extends StatefulWidget {
  final VDkInvLine invLine;
  final TblDkInvHead invHead;
  const ProductsItem({super.key, required this.invLine, required this.invHead});

  @override
  State<ProductsItem> createState() => _ProductsItemState();
}

class _ProductsItemState extends State<ProductsItem> {
  @override
  Widget build(BuildContext context) {
    final trs = AppLocalizations.of(context);
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
      child: Container(
        height: (widget.invLine.MatName.length < 35) ? size.height/5.1 : (widget.invLine.MatName.length < 70) ? size.height/4.5 : size.height/4,
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
                    width: size.width / 1.5,
                    child: Text(
                      maxLines: 3,
                      widget.invLine.MatName, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0, right: 6),
                        child: SvgPicture.asset("assets/svg/barcode.svg"),
                      ),
                      Text(widget.invLine.Barcode),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.phone_iphone_rounded),
                        Text(widget.invLine.SpeCode, overflow: TextOverflow.ellipsis)
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 5),
                    child: Row(
                      children: [
                        const Icon(Icons.person),
                        Text(widget.invLine.SecurityCode),
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
                            child: Text("${trs.translate('stock') ?? "Stock"} : ${widget.invLine.MatWhTotalAmount.toInt()}",
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 25.0),
                        child: (widget.invHead.MatInvTypeId==14) ?
                        SizedBox(
                          width: size.width/3.5,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text("${trs.translate('counted') ?? "Counted"} : ${(widget.invLine.MatCountDiff-widget.invLine.MatWhTotalAmount).abs().toInt()}",
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        )
                            : Text("${trs.translate('counted') ?? "Counted"} : ${(widget.invLine.MatCountDiff+widget.invLine.MatWhTotalAmount).abs().toInt()}",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                  color: (widget.invHead.MatInvTypeId ==14) ? const Color(0xffE41313)  : const Color(0xff13E499),
                  borderRadius: BorderRadius.circular(5)
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text((widget.invHead.MatInvTypeId==14) ? "-${widget.invLine.MatCountDiff.toInt().toString()}" : widget.invLine.MatCountDiff.toInt().toString(),
                    style: TextStyle(color: Theme.of(context).cardColor, fontSize: 20, fontWeight: FontWeight.w600)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
