import 'package:camera/camera.dart';
import 'package:camera_applications/home.dart';
import 'package:flutter/material.dart';

Future<void> main()async{
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MyApp(cameras: cameras,));
}


class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
   MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(cameras: cameras,),
      debugShowCheckedModeBanner: false,
      title: "Camera-App",

    );
  }
}