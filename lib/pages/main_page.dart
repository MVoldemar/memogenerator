import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:memogenerator/blocs/main_bloc.dart';
import 'package:memogenerator/pages/create_meme_page.dart';
import 'package:memogenerator/resources/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class MainPage extends StatefulWidget {
  MainPage({
    Key? key,
  }) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late CreateMainBloc bloc;
  @override
  void initState() {
    super.initState();
    bloc = CreateMainBloc();
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: bloc,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: AppColors.lemon,
          foregroundColor: AppColors.darkGrey,
          title: Text(
            "Мемогенератор",
            style: GoogleFonts.seymourOne(fontSize: 24),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => CreateMemePage(),
          ),
            );
          },
          label: Text("Создать"),
          backgroundColor: AppColors.fuchsia,
          icon: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: MainPageContent(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }
}

class MainPageContent extends StatefulWidget {
  @override
  _MainPageContentState createState() => _MainPageContentState();
}

class _MainPageContentState extends State<MainPageContent> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(),
    );
  }
}
