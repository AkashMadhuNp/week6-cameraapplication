import 'dart:io';
import 'package:flutter/material.dart';

class GalleryScreen extends StatelessWidget {
  final List<File> imageList;

  const GalleryScreen({super.key, required this.imageList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Gallery",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: const Color.fromARGB(255, 46, 45, 45),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // Number of columns in the grid
          crossAxisSpacing: 8, // Spacing between columns
          mainAxisSpacing: 8, // Spacing between rows
        ),
        itemCount: imageList.length,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              imageList[index],
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}
