import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oauth2_client/oauth2_helper.dart';
import 'package:smolaton/auth/auth_client.dart';
import 'package:smolaton/auth/auth_http_client.dart';
import 'package:smolaton/bloc/create_art_object_bloc.dart';
import 'package:smolaton/bloc/main_bloc.dart';
import 'package:smolaton/routes/create_art_object_route.dart';
import 'package:smolaton/routes/main_route.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "SmolTour",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      initialRoute: "/index",
      routes: {
        "/index": (context) => BlocProvider(
              create: (context) => MainBloc()..add(MainInitEvent()),
              child: const MainRoute(),
            ),
        "/create_art_object": (context) => BlocProvider(
              create: (context) => CreateArtObjectBloc(),
              child: const CreateArtObjectRoute(),
            ),
      },
    );
  }
}