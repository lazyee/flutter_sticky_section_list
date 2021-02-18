# flutter_sticky_section_list

```dart
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
```


![](https://raw.githubusercontent.com/lazyee/ImageHosting/master/img/%E6%88%AA%E5%B1%8F2021-02-18%20%E4%B8%8A%E5%8D%889.46.11.png)
