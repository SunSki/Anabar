import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'dart:convert';
import 'package:anabar_new/pref.dart';
import 'package:anabar_new/unit.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Anabar'),
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
  bool loading_state = true;
  int _barNum = 0;
  String _prefname = '福岡県';
  List<Unit> _units = [];
  List<Pref> _prefs = [];
  List _drawerItems = <Widget>[];

  //-----データ取得--------
  //都道府県名
  void fetchPrefs() async {
    var url =
        'https://api.gnavi.co.jp/master/PrefSearchAPI/v3/?keyid=730c680e25249d6f5942eadf3f512b06';
    var response = await http.get(url);
    setState(() {
      List list = json.decode(response.body)["pref"];
      _prefs = List<Pref>.generate(
          list.length,
          (int i) => Pref(
                name: list[i]['pref_name'],
                code: list[i]['pref_code'],
              ));
    });
  }

  //バー
  void fetchPosts(int index) async {
    var page = 100;
    var url =
        'https://api.gnavi.co.jp/RestSearchAPI/20150630/?keyid=730c680e25249d6f5942eadf3f512b06&format=json&freeword_condition=2&freeword=bar,バー&midnight=1&hit_per_page=' +
            page.toString() +
            '&pref=' +
            _prefs[index].code;

    var response = await http.get(url);
    print("total_hit_count:" + json.decode(response.body)["total_hit_count"]);
    var total_hit_count =
        int.parse(json.decode(response.body)["total_hit_count"]);
    _barNum = total_hit_count;
    if (total_hit_count < page) {
      page = total_hit_count;
    }

    setState(() {
      List list = json.decode(response.body)["rest"];
      _units = List<Unit>.generate(page, (int i) {
        var address = list[i]["address"];
        var address_len = address.length;
        address = address.substring(10 + _prefname.length, address_len);
        return Unit(
          name: list[i]["name"],
          imageUrl: list[i]["image_url"]["shop_image1"].toString(),
          address: address,
          opentime: list[i]["opentime"].toString(),
          pr: list[i]["pr"]["pr_short"].toString(),
        );
      });
      loading_state = false;
    });
  }

  //最初のデータ取得
  void firstFetch() async {
    var preFirst = 39;
    await fetchPrefs();
    for (var i = 0; i < _prefs.length; i++) {
      var drawerItem = _drawerItem(i);
      _drawerItems.add(drawerItem);
    }
    fetchPosts(preFirst);
  }
  //------------------------

  Widget _drawerItem(int index) {
    return ListTile(
      title: Text(_prefs[index].name),
      onTap: () {
        Navigator.pop(context);
        fetchPosts(index);
        _prefname = _prefs[index].name;
        print(_prefname);
      },
    );
  }

  Widget _barInfo(String head, String detail) {
    return Container(
      margin: EdgeInsets.all(20.0),
      child: Column(
        children: <Widget>[
          Text(
            head,
            style: TextStyle(
              fontSize: 18.0,
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 10.0),
            child: Text(detail),
          ),
        ],
      ),
    );
  }

  Widget _barList(List units) {
    return Scrollbar(
        child: ListView.builder(
      itemCount: units.length,
      itemBuilder: (context, int index) {
        return Container(
          margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(5.0),
              //highlightColor: Colors.black12,
              splashColor: Colors.black12,
              onTap: () => _navigate(units[index]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      (index + 1).toString() +
                          ": " +
                          units[index].name, //トップ画面のバーの店名
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Divider(color: Color.fromARGB(255, 237, 224, 190)),
                  Container(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      units[index].address,
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                  Divider(color: Color.fromARGB(255, 237, 224, 190)),
                  Container(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      units[index].pr,
                      style: TextStyle(
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ));
  }

  void _navigate(Unit bar) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Scaffold(
                appBar: AppBar(
                  title: Text(
                    bar.name,
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
                body: SingleChildScrollView(
                  child: Column(
                    //crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      _barImage(bar),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 40.0, vertical: 10.0),
                        child: Column(
                          children: <Widget>[
                            _barInfo("<Address>", bar.address),
                            _barInfo("<Opentime>", bar.opentime),
                          ],
                        ),
                      ),
                    ],
                  ),
                ))));
  }

  Widget _barImage(Unit bar) {
    if (bar.imageUrl.length < 10) {
      return Image.network(
        'http://www.town.minamiechizen.lg.jp/kurasi/103/bunka/p001445_d/img/022.jpg',
        width: MediaQuery.of(context).size.width,
        fit: BoxFit.fitWidth,
      );
    } else {
      return Image.network(
        bar.imageUrl,
        width: MediaQuery.of(context).size.width,
        fit: BoxFit.fitWidth,
      );
    }
  }

  Widget loading() {
    return Scaffold(
      body: Container(
        decoration: new BoxDecoration(color: Colors.blue),
        child: Center(
          child: Text(
            'Anabar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget main_display() {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title + ' in' + _prefname + _barNum.toString()),
      ),
      body: Container(
        decoration:
            new BoxDecoration(color: Color.fromARGB(128, 237, 224, 190)),
        child: _barList(_units),
      ),
      drawer: Drawer(
        child: ListView(
          shrinkWrap: true,
          children: _drawerItems,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    if (loading_state) {
      return loading();
    } else {
      return main_display();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    firstFetch();
    super.initState();
  }
}
