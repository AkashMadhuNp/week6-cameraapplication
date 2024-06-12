import 'dart:io';

import 'package:camera/camera.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:media_scanner/media_scanner.dart';

class HomeScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  HomeScreen({super.key, required this.cameras});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late CameraController cameraController;
  late Future<void> cameraValue;
  bool isFlashOn = false;
  bool isRearCamera = true;
  List<File> imageList = [];

  void startCamera(int camera) {
    cameraController = CameraController(
      widget.cameras[camera],
      ResolutionPreset.high,
      enableAudio: false,
    );
    cameraValue = cameraController.initialize();
  }

  Future<File> saveImage(XFile image) async {
    final downloadPath = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOWNLOADS);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File('$downloadPath/$fileName');

    try {
      await file.writeAsBytes(await image.readAsBytes());
    } catch (_) {}

    return file;
  }

  void takePicture() async {
    XFile? image;
    if (cameraController.value.isTakingPicture ||
        !cameraController.value.isInitialized) {
      return;
    } else {
      if (isFlashOn == false) {
        await cameraController.setFlashMode(FlashMode.off);
      } else {
        await cameraController.setFlashMode(FlashMode.torch);
      }
      image = await cameraController.takePicture();
      if (cameraController.value.flashMode == FlashMode.torch) {
        setState(() {
          cameraController.setFlashMode(FlashMode.off);
        });
      }
    }

    final file = await saveImage(image);
    setState(() {
      imageList.add(file);
    });

    MediaScanner.loadMedia(path: file.path);
  }

  @override
  void initState() {
    startCamera(0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromRGBO(255, 255, 255, 0.7),
        shape: CircleBorder(),
        onPressed: takePicture,
        child: Center(
          child: Icon(
            Icons.camera_alt,
            size: 40,
            color: Colors.black87,
          ),
        ),
      ),
      appBar: AppBar(
        title: Text(
          "Camera Application",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: const Color.fromARGB(255, 46, 45, 45),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      backgroundColor: Colors.black45,
                      title: Text(
                        "Are you want to Exit?",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              "Cancel",
                              style: TextStyle(color: Colors.white),
                            )),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              "Okay",
                              style: TextStyle(color: Colors.red),
                            ))
                      ],
                    );
                  },
                );
              },
              icon: Icon(
                Icons.exit_to_app,
                color: Colors.white,
              ))
        ],
      ),
      body: Stack(
        children: [
          FutureBuilder(
            future: cameraValue,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: 100,
                      child: CameraPreview(cameraController),
                    ),
                  ),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.only(
                right: 5,
                top: 10,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isFlashOn = !isFlashOn;
                      });
                    },
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(255, 255, 255, .7),
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: isFlashOn
                            ? Icon(
                                Icons.flash_on,
                                color: Colors.white,
                              )
                            : Icon(
                                Icons.flash_off,
                                color: Colors.white,
                              ),
                      ),
                    ),
                  ),
                  const Gap(10),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isRearCamera = !isRearCamera;
                      });
                      isRearCamera ? startCamera(0) : startCamera(1);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(255, 255, 255, .7),
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: isRearCamera
                            ? Icon(
                                Icons.camera_rear,
                                color: Colors.white,
                              )
                            : Icon(
                                Icons.camera_front,
                                color: Colors.white,
                              ),
                      ),
                    ),
                  ),
                  const Gap(10),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: EdgeInsets.only(left: 7, bottom: 75),
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: imageList.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.all(2),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image(
                                height: 100,
                                width: 100,
                                opacity: AlwaysStoppedAnimation(1),
                                image: FileImage(
                                  File(imageList[index].path),
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
