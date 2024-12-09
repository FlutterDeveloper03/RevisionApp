// ignore_for_file: file_names, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:revision_app/Pages/CountedProductsPage.dart';
import 'package:revision_app/Pages/HomePage.dart';
import 'package:revision_app/bloc/CountedPageBloc.dart';
import 'package:revision_app/bloc/CountedProductsBloc.dart';
import 'package:revision_app/helpers/SharedPrefKeys.dart';
import 'package:revision_app/helpers/localization.dart';
import 'package:revision_app/models/tbl_dk_inv_head.dart';
import 'package:revision_app/provider/GlobalVarsProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CountedInvHeadsPage extends StatefulWidget {
  final double position;

  const CountedInvHeadsPage({super.key, required this.position});

  @override
  State<CountedInvHeadsPage> createState() => _CountedInvHeadsPageState();
}

class _CountedInvHeadsPageState extends State<CountedInvHeadsPage> {
  DateTimeRange dateRange = DateTimeRange(
    start: DateTime.now(),
    end: DateTime.now(),
  );
  final ScrollController _scrollController =
      ScrollController(keepScrollOffset: true);

  TextEditingController searchContrl = TextEditingController();
  bool hasText = false;
  List<TblDkInvHead> invHeads = [];
  DateFormat dateFormat = DateFormat('dd-MM-yyyy');
  String startDate = '';
  String endDate = '';

  double? _scrollOffset;

  @override
  void initState() {
    searchContrl.addListener(() {
      setState(() {
        hasText = searchContrl.text.isNotEmpty;
      });
    });
    getDataFromPrefs();
    super.initState();
  }

  void getDataFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    startDate = prefs.getString(SharedPrefKeys.countedInvHeadsStartDate) ?? '';
    endDate = prefs.getString(SharedPrefKeys.countedInvHeadsEndDate) ?? '';
    searchContrl.text =
        prefs.getString(SharedPrefKeys.countedInvHeadsSearchText) ?? '';
    if (startDate.isNotEmpty && endDate.isNotEmpty) {
      setState(() {
        dateRange = DateTimeRange(
          start: DateTime.parse(startDate),
          end: DateTime.parse(endDate),
        );
      });
    }
  }

  @override
  void dispose() {
    searchContrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        if (_scrollOffset != null) {
          _scrollController.jumpTo(_scrollOffset!);
        } else {
          _scrollController.jumpTo(widget.position);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final trs = AppLocalizations.of(context);
    final start = dateRange.start;
    final end = dateRange.end;
    GlobalVarsProvider globalProvider =
        Provider.of<GlobalVarsProvider>(context);
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        final prefs = await SharedPreferences.getInstance();
        prefs.remove(SharedPrefKeys.countedInvHeadsStartDate);
        prefs.remove(SharedPrefKeys.countedInvHeadsEndDate);
        prefs.remove(SharedPrefKeys.countedInvHeadsSearchText);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const HomePage()));
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          leadingWidth: 30,
          automaticallyImplyLeading: false,
          leading: Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: IconButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                prefs.remove(SharedPrefKeys.countedInvHeadsStartDate);
                prefs.remove(SharedPrefKeys.countedInvHeadsEndDate);
                prefs.remove(SharedPrefKeys.countedInvHeadsSearchText);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const HomePage()));
              },
              icon: Icon(Icons.arrow_back_ios,
                  color: Theme.of(context).cardColor),
            ),
          ),
          backgroundColor: Theme.of(context).primaryColor,
          title: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                  "${trs.translate("show_counted") ?? "Show counted products"} (${globalProvider.getInvHeads.length})")),
          titleTextStyle:
              TextStyle(color: Theme.of(context).cardColor, fontSize: 17),
          actions: [
            GestureDetector(
              onTap: () async {
                await pickDateRange();
              },
              child: Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dateFormat.format(start),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                      Text(
                        dateFormat.format(end),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Icon(Icons.date_range,
                        color: Theme.of(context).cardColor, size: 40),
                  ),
                ],
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size(size.width, size.height / 15),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                child: Container(
                  height: size.height / 18,
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
                      hintText: (trs.translate("click_to_search") ??
                          "Click to search"),
                      hintStyle: const TextStyle(
                          color: Color(0xffCDCDCD), fontSize: 15),
                      suffixIcon: hasText
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: () async {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                prefs.setString(
                                    SharedPrefKeys.countedInvHeadsSearchText,
                                    '');
                                primaryFocus!.unfocus();
                                searchContrl.clear();
                                debugPrint(
                                    "Pressed close button search text: ${searchContrl.text}");
                                BlocProvider.of<CountedPageBloc>(context)
                                    .add(SearchInvHeadsEvent(invHeads, ''));
                                setState(() {
                                  hasText = false;
                                });
                              },
                            )
                          : const Icon(Icons.search, size: 20),
                      suffixIconColor: const Color(0xffCDCDCD),
                    ),
                    cursorColor: Colors.black,
                    onSubmitted: (value) async {
                      final prefs = await SharedPreferences.getInstance();
                      BlocProvider.of<CountedPageBloc>(context)
                          .add(SearchInvHeadsEvent(invHeads, value));
                      prefs.setString(
                          SharedPrefKeys.countedInvHeadsSearchText, value);
                      prefs.remove(SharedPrefKeys.countedInvHeadsStartDate);
                      prefs.remove(SharedPrefKeys.countedInvHeadsEndDate);
                      setState(() {
                        dateRange = DateTimeRange(start: DateTime.now(), end: DateTime.now());
                        startDate = '';
                        endDate = '';
                      });
                    },
                    onChanged: (value) {
                      setState(() {
                        hasText = value.isNotEmpty;
                      });
                      if (value.isEmpty) {
                        BlocProvider.of<CountedPageBloc>(context)
                            .add(SearchInvHeadsEvent(invHeads, value));
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        body: BlocConsumer<CountedPageBloc, CountedPageBlocState>(
          listener: (context, state) async {
            if (state is LoadErrorInvHeadsState) {
              _loadingErrorDialog(
                  context, MediaQuery.of(context).size, state.errorText);
            } else if (state is LoadedInvHeadsState) {
              globalProvider.setInvHeads = state.invHeads;
              invHeads = state.invHeads;
            } else if (state is LoadedInvHeadsWithDateState) {
              globalProvider.setInvHeads = state.invHeads;
            } else if (state is LoadEmptyInvHeadsState) {
              globalProvider.setInvHeads = [];
            } else if (state is ProductsDeletedState) {
              final removedItemId = state.invHead.MatInvHeadId;
              double? scrollOffset = _scrollController.hasClients ? _scrollController.offset : null;
              setState(() {
                globalProvider.getInvHeads.removeWhere(
                        (element) => element.MatInvHeadId == removedItemId);
              });
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollController.hasClients && scrollOffset != null) {
                  _scrollController.jumpTo(scrollOffset);
                }
              });
            } else if (state is SearchingInvHeadsCompletedState) {
              globalProvider.setInvHeads = state.invHeads;
            } else if (state is SearchInvHeadsResultEmptyState) {
              globalProvider.setInvHeads = [];
            } else if (state is DeleteErrorState) {
              _loadingErrorDialog(
                  context, MediaQuery.sizeOf(context), state.error);
            }
          },
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () async {
                if (searchContrl.text.isNotEmpty) {
                  BlocProvider.of<CountedPageBloc>(context).add(
                      SearchInvHeadsEvent(
                          globalProvider.getInvHeads, searchContrl.text));
                } else if (startDate.isNotEmpty && endDate.isNotEmpty) {
                  BlocProvider.of<CountedPageBloc>(context).add(
                      LoadInvHeadsWithDateEvent(
                          dateRange.start, dateRange.end));
                } else {
                  BlocProvider.of<CountedPageBloc>(context)
                      .add(LoadInvHeadsEvent());
                }
              },
              child: state is LoadingInvHeadsState
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
                  : state is LoadEmptyInvHeadsState
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(trs.translate("noData") ??
                                    "No Data Available"),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: globalProvider.getInvHeads.length,
                          itemBuilder: (context, index) {
                            final item = globalProvider.getInvHeads[index];
                            return Dismissible(
                              key: UniqueKey(),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                child: Icon(Icons.delete,
                                    color: Theme.of(context).cardColor,
                                    size: 30),
                              ),
                              confirmDismiss: (direction) async {
                                final bool shouldDismiss = await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(trs.translate("confirm") ??
                                        'Confirm Delete'),
                                    content: Text(
                                        '${trs.translate("delete_txt") ?? "Are you sure you want to delete"} ${item.MatInvCode}?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: Text(trs.translate("cancel") ??
                                            'Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          BlocProvider.of<CountedPageBloc>(
                                                  context)
                                              .add(DeleteProductsEvent(item));
                                          Navigator.of(context).pop(true);
                                        },
                                        child: Text(trs.translate("delete") ??
                                            'Delete'),
                                      ),
                                    ],
                                  ),
                                );
                                return shouldDismiss;
                              },
                              child: CountedProductsItem(
                                invHead: globalProvider.getInvHeads[index],
                                scrollController: _scrollController,
                              ),
                            );
                          },
                        ),
            );
          },
        ),
      ),
    );
  }

  Future<void> pickDateRange() async {
    DateTimeRange? newDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: dateRange,
      firstDate: DateTime(2024),
      lastDate: DateTime(2080),
    );
    setState(() {
      dateRange = newDateRange ?? dateRange;
      searchContrl.text = '';
      if (newDateRange == null) return;
    });
    BlocProvider.of<CountedPageBloc>(context)
        .add(LoadInvHeadsWithDateEvent(dateRange.start, dateRange.end));
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
        SharedPrefKeys.countedInvHeadsStartDate, dateRange.start.toString());
    prefs.setString(
        SharedPrefKeys.countedInvHeadsEndDate, dateRange.end.toString());
    prefs.remove(SharedPrefKeys.countedInvHeadsSearchText);
    startDate = prefs.getString(SharedPrefKeys.countedInvHeadsStartDate) ?? '';
    endDate = prefs.getString(SharedPrefKeys.countedInvHeadsEndDate) ?? '';
  }
}

Future<void> _loadingErrorDialog(
    BuildContext context, Size size, String errorText) async {
  final trs = AppLocalizations.of(context);
  await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) {
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
              child: Text(trs.translate("error_text") ?? 'Error'),
            ),
            content: SizedBox(
              height: size.height / 5,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                        "${trs.translate("error_text") ?? 'Error'}: $errorText"),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
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
                    )
                  ],
                ),
              ),
            ));
      });
}

class CountedProductsItem extends StatefulWidget {
  final TblDkInvHead invHead;
  final ScrollController scrollController;

  const CountedProductsItem(
      {super.key, required this.invHead, required this.scrollController});

  @override
  State<CountedProductsItem> createState() => _CountedProductsItemState();
}

class _CountedProductsItemState extends State<CountedProductsItem> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final trs = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
      child: Builder(
        builder: (BuildContext context) {
          return InkWell(
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              bool result = await prefs.setDouble(SharedPrefKeys.scrollPosition,
                  widget.scrollController.position.pixels);
              debugPrint(
                  "I am here: $result and ${widget.scrollController.position.pixels}");
              BlocProvider.of<CountedProductsBloc>(context)
                  .add(LoadProductsEvent(widget.invHead));
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      CountedProductsPage(invHead: widget.invHead),
                ),
              );
            },
            child: Container(
              height: 116,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                        color: Theme.of(context).dividerColor,
                        blurRadius: 2,
                        offset: const Offset(1, 1))
                  ]),
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat("yyyy-MM-dd HH:mm:ss")
                              .format(widget.invHead.MatInvDate!),
                          style: TextStyle(
                              fontSize: 17,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          width: size.width / 1.5,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                widget.invHead.MatInvCode,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              trs.translate("note1") ?? "Note 1",
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                            SizedBox(
                              width: size.width / 2,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    ": ${widget.invHead.MatInvDesc}",
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              trs.translate("note2") ?? "Note 2",
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                            SizedBox(
                              width: size.width / 2,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    ": ${widget.invHead.GroupCode}",
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      alignment: Alignment.center,
                      height: size.height,
                      width: size.width / 4.3,
                      decoration: BoxDecoration(
                          color: (widget.invHead.MatInvTypeId == 14)
                              ? const Color(0xffE41313)
                              : const Color(0xff13E499),
                          borderRadius: BorderRadius.circular(5)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(trs.translate("total") ?? "Total",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).cardColor)),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                                (widget.invHead.MatInvTypeId == 14)
                                    ? "- ${widget.invHead.MatInvTotal.toStringAsFixed(2)} TMT"
                                    : "${widget.invHead.MatInvTotal.toStringAsFixed(2)} TMT",
                                style: TextStyle(
                                    color: Theme.of(context).cardColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
