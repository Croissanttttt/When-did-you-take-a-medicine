import 'dart:convert';
import 'dart:core';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '언제 약 먹었니?',
      theme: ThemeData(
        inputDecorationTheme: InputDecorationTheme(
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black)
            )
        )
      ),
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ScrollController scrollController;
  List<Medicine> list = new List<Medicine>();
  int length = 10;
  SharedPreferences sharedPreferences;

  DateTime now = DateTime.now();
  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black54,
        title: Text('언제 약 먹었니?'),
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 100,
              child: Column(
                children: <Widget>[
                  Text('가장 최근 약 먹은 날',style: TextStyle(fontSize: 25),),
                  Flexible(child: list.isEmpty ? emptyList() : recentlyListView())
                ],
              ),
            ),
            SizedBox(height: 30),
            Container(
              width: 400,
              height: 50,
              child: RaisedButton(
                  elevation: 0,
                  onPressed: () =>goToNewItemView(),
                  child: Text('지금 먹었다!')),
            ),
            SizedBox(height: 30),
            Flexible(child: buildListView()),
          ],
        ),
      ),
    );
  }

  Widget emptyList(){
    return SafeArea(
      child: Center(
          child:  Text(
            '없음',
            style: TextStyle(fontSize: 30),
          )
      ),
    );
  }

  @override
  void initState() {
    loadSharedPreferencesAndData();
    super.initState();
  }

  void loadSharedPreferencesAndData() async {
    sharedPreferences = await SharedPreferences.getInstance();
    loadData();
  }

  Widget buildListView() {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (BuildContext context,int index){
        return buildListTile(list[index], index);
      },
    );
  }

  Widget recentlyListView () {
    return ListView.builder(
      itemCount: 1,
      itemBuilder: (BuildContext context,int index){
        return buildListTile(list[0], 0);
      },
    );
  }

  Widget buildListTile(Medicine item, int index){
    return Card(
        child: ListTile(
          title: Column(
            children: <Widget>[
              Text(
                item.date,
                style: TextStyle(
                  fontSize: 15
                ),
              ),
              Text(
                item.title,
                key: Key('item-$index'),
                style: TextStyle(
                    fontSize: 15,
                ),
              ),
            ],
          ),
          trailing:FlatButton(
              child:Text("삭제",style: TextStyle(fontSize: 15),),
              onPressed: () {
                setState(() {
                  removeItem(item);
                  loadSharedPreferencesAndData();
                });
              },
          ),
        ));
  }

  void goToNewItemView(){
    // Here we are pushing the new view into the Navigator stack. By using a
    // MaterialPageRoute we get standard behaviour of a Material app, which will
    // show a back button automatically for each platform on the left top corner
    Navigator.of(context).push(MaterialPageRoute(builder: (context){
      return NewMedicineView();
    })).then((title){
      if(title != null) {
        addItem(Medicine(title: title,date: formattedDate));
      }
    });
  }

  void addItem(Medicine item){
    // Insert an item into the top of our list, on index zero
    list.insert(0, item);
    saveData();
  }

  void removeItem(Medicine item){
    list.remove(item);
    saveData();
  }

  void loadData() {
    List<String> listString = sharedPreferences.getStringList('list');
    if(listString != null){
      list = listString.map(
              (item) => Medicine.fromMap(json.decode(item))
      ).toList();
      setState((){});
    }
  }

  void saveData(){
    List<String> stringList = list.map(
            (item) => json.encode(item.toMap()
        )).toList();
    sharedPreferences.setStringList('list', stringList);
  }
}

class Medicine {
  String title;
  String date;

  Medicine({
    this.title,
    this.date,
  });

  Medicine.fromMap(Map map) :
        this.title = map['title'],
        this.date = map['date'];

  Map toMap(){
    return {
      'title': this.title,
      'date': this.date,
    };
  }
}

class NewMedicineView extends StatefulWidget {
  final Medicine item;

  NewMedicineView({ this.item });

  @override
  _NewMedicineViewState createState() => _NewMedicineViewState();
}

class _NewMedicineViewState extends State<NewMedicineView> {
  TextEditingController titleController;

  @override
  void initState() {
    super.initState();
    titleController = new TextEditingController(
        text: widget.item != null ? widget.item.title : null
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "무슨 약 먹었어?",
              style: TextStyle(fontSize: 30),
            ),
            SizedBox(height: 25.0,),
            TextField(
              cursorColor: Colors.black26,
              style: TextStyle(fontSize: 30),
              controller: titleController,
              autofocus: true,
              onSubmitted: (value) => submit(),
            ),
            SizedBox(height: 50.0,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FlatButton(
                  color: Colors.black26,
                  child: Container(
                    height: 30,
                    width: 50,
                    child: Center(
                      child: Text(
                        '취소',
                        style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).primaryTextTheme.title.color
                        ),
                      ),
                    ),
                  ),
                  onPressed: (){
                    setState(() {
                      titleController.clear();
                      Navigator.pop(context);
                    });
                  },
                ),
                SizedBox(width: 50,),
                FlatButton(
                  color: Colors.black26,
                  child: Container(
                    height: 30,
                    width: 50,
                    child: Center(
                      child: Text(
                        '저장',
                        style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).primaryTextTheme.title.color
                        ),
                      ),
                    ),
                  ),
                  onPressed: () => submit(),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void submit(){
    Navigator.of(context).pop(titleController.text);
  }
}