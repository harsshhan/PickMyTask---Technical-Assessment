import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'features/location/viewmodel/location_viewmodel.dart';
import 'features/location/repository/location_repository.dart';
import 'features/location/screen/location_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(
    ChangeNotifierProvider(
      create: (_) => LocationViewmodel(LocationRepository()),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location Service',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LocationPage(),
    );
  }
}
