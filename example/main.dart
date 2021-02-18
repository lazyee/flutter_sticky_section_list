import 'package:flutter/material.dart';
import 'package:flutter_sticky_section_list/sticky_section_list.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StickySectionList',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'StickySectionList'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Container(
          // height: 100,
          color: Colors.blue,
          child: StickySectionList(
              delegate: StickySectionListDelegate(
            getSectionCount: () => 10,
            getItemCount: (sectionIndex) => 10,
            buildSection: (context, sectionIndex) => Container(
              color: Colors.red,
              child: Text("section:$sectionIndex"),
              padding: EdgeInsets.all(10),
            ),
            buildItem: (context, sectionIndex, itemIndex) => Container(
              color: Colors.white,
              child: Text("item:$itemIndex"),
              padding: EdgeInsets.all(10),
            ),
          )),
        ));
  }
}
