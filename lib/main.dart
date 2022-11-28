import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Status Stories',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: HomeScreen(),
    );
  }
}

// ListView.builder(
// shrinkWrap: true,
// physics: const NeverScrollableScrollPhysics(),
// itemCount: images.length,
// itemBuilder: (context, index) => Container(
// margin: const EdgeInsets.all(5),
// height: 200,
// decoration: BoxDecoration(
// image: DecorationImage(
// image: NetworkImage(
// images[index],
// ),
// fit: BoxFit.scaleDown),
// color: Colors.grey.withOpacity(0.5),
// borderRadius: BorderRadius.circular(10),
// ),
// ),
// ),
