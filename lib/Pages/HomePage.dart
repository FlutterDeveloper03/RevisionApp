// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:revision_app/Pages/CountedInvHeadsPage.dart';
import 'package:revision_app/Pages/CurrentCountsPage.dart';
import 'package:revision_app/Pages/ListDataPage.dart';
import 'package:revision_app/Pages/LoginPage.dart';
import 'package:revision_app/bloc/CountedPageBloc.dart';
import 'package:revision_app/bloc/CurrentCountsPageBloc.dart';
import 'package:revision_app/bloc/ListDataPageBloc.dart';
import 'package:revision_app/bloc/LoginPageBloc.dart';
import 'package:revision_app/helpers/localization.dart';
import 'package:revision_app/provider/GlobalVarsProvider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final trs = AppLocalizations.of(context);
    GlobalVarsProvider globalProvider = Provider.of<GlobalVarsProvider>(context);
    Size size = MediaQuery.of(context).size;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop){
        BlocProvider.of<LoginPageBloc>(context).add(UserLogOutEvent());
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text("RevisionApp"),
          titleTextStyle: TextStyle(
              color: Theme.of(context).cardColor, fontSize: 24
          ),
          actions: [
            Icon(Icons.person, color: Theme.of(context).cardColor,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Text(globalProvider.getUser?.UName ?? "",
                style: TextStyle(color: Theme.of(context).cardColor, fontSize: 16),
              ),
            )
          ],
        ),
        body: BlocListener<CurrentCountsBloc, CurrentCountsState>(
          listener: (BuildContext context, CurrentCountsState state) {
            if(state is CurrentCountsLoadedState){
              if(state.params.isNotEmpty){
                globalProvider.setMatCountParams = state.params;
                Navigator.push(context, MaterialPageRoute(builder: (context) => CurrentCountsPage()));
              } else {
                BlocProvider.of<ListDataPageBloc>(context).add(LoadListDataEvent());
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ListDataPage()));
              }
            } else if (state is CurrentCountsLoadErrorState){
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(backgroundColor: Colors.deepOrangeAccent,
                      content: Text('${trs.translate("error_text") ?? "Error"} ${trs.translate("try_again") ?? "Try again"}'))
              );
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              (globalProvider.getUser?.UTypeId==1) ?
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {
                      BlocProvider.of<CurrentCountsBloc>(context).add(LoadCurrentCountsEvent());
                    },
                    child: Container(
                      height: size.height/3.7,
                      width: size.width/2.3,
                      decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          border: Border.all(color: const Color(0xff3B3B3B)),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(color: Theme.of(context).dividerColor, blurRadius: 2, offset: const Offset(2, 2))
                          ]
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SvgPicture.asset("assets/svg/scaner.svg"),
                          Text(trs.translate("start_count") ?? "Start counting", style: const TextStyle(fontSize: 20), textAlign: TextAlign.center,)
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      BlocProvider.of<CountedPageBloc>(context).add(LoadInvHeadsEvent());
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const CountedInvHeadsPage(position: 0.0)));
                    },
                    child: Container(
                      height: size.height/3.7,
                      width: size.width/2.3,
                      decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          border: Border.all(color: const Color(0xff3B3B3B)),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(color: Theme.of(context).dividerColor, blurRadius: 2, offset: const Offset(2, 2))
                          ]
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SvgPicture.asset("assets/svg/list.svg"),
                          Text(trs.translate("show_counted") ?? "Show counted", style: const TextStyle(fontSize: 20), textAlign: TextAlign.center,)
                        ],
                      ),
                    ),
                  )
                ],
              )
              : Center(
                child: InkWell(
                  onTap: () {
                    BlocProvider.of<CurrentCountsBloc>(context).add(LoadCurrentCountsEvent());
                  },
                  child: Container(
                    height: size.height/3,
                    width: size.width/2,
                    decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        border: Border.all(color: const Color(0xff3B3B3B)),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(color: Theme.of(context).dividerColor, blurRadius: 2, offset: const Offset(2, 2))
                        ]
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SvgPicture.asset("assets/svg/scaner.svg",
                          height: size.height/6,
                          width: size.width/4.5,
                        ),
                        Text(trs.translate("start_count") ?? "Start counting",
                          style: const TextStyle(fontSize: 22),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: TextButton(
                  onPressed: (){
                    BlocProvider.of<LoginPageBloc>(context).add(UserLogOutEvent());

                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginPage()), (route)=> false);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    fixedSize: Size(size.width/3, size.height/16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Text(trs.translate("exit") ?? "Exit",
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
      ),
    );
  }
}
