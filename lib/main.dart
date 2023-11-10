import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smolaton/bloc/main_bloc.dart';
import 'package:smolaton/routes/main_route.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Smolaton",
      theme: ThemeData(
        useMaterial3: true,
      ),
      initialRoute: "/index",
      routes: {
        "/index": (context) => BlocProvider(
              create: (context) => MainBloc()..add(MainInitEvent()),
              child: const MainRoute(),
            ),

      },
    );
  }
}
