import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

//
Future<Restaurant> fetchRestaurant(lat, long) async {
  
  final response = '{ "location": { "entity_type": "subzone", "entity_id": 123532, "title": "Fair Park", "latitude": "43.0160031766", "longitude": "-88.0107514723", "city_id": 1267, "city_name": "Milwaukee", "country_id": 216, "country_name": "United States" }, "popularity": { "popularity": "2.31", "nightlife_index": "1.80", "nearby_res": ["17176185", "17180021"], "top_cuisines": ["American", "Pizza", "Fast Food", "Bar Food", "Sandwich"], "popularity_res": "100", "nightlife_res": "10", "subzone": "Fair Park", "subzone_id": 123532, "city": "Milwaukee" }, "link": "https://www.zomato.com/milwaukee/fair-park-restaurants", "nearby_restaurants": [ { "restaurant": { "R": { "res_id": 17180021 }, "apikey": "", "id": "17180021", "name": "Monkey\'s Sports Bar & Grill", "url": "https://www.zomato.com/milwaukee/monkeys-sports-bar-grill-west-allis?utm_source=api_basic_user&utm_medium=api&utm_campaign=v2.1", "location": { "address": "8028 West National Avenue, West Allis 53214", "locality": "Fair Park", "city": "Milwaukee", "city_id": 1267, "latitude": "43.0110420000", "longitude": "-88.0127200000", "zipcode": "53214", "country_id": 216, "locality_verbose": "Fair Park, Milwaukee" }, "switch_to_order_menu": 0, "cuisines": "Bar Food, Sandwich", "average_cost_for_two": 25, "price_range": 2, "currency": "dollar", "offers": [], "opentable_support": 0, "is_zomato_book_res": 0, "mezzo_provider": "OTHER", "is_book_form_web_view": 0, "book_form_web_view_url": "", "book_again_url": "", "thumb": "", "user_rating": { "aggregate_rating": "2.7", "rating_text": "Average", "rating_color": "FFBA00", "votes": "10" }, "photos_url": "https://www.zomato.com/milwaukee/monkeys-sports-bar-grill-west-allis/photos?utm_source=api_basic_user&utm_medium=api&utm_campaign=v2.1#tabtop", "menu_url": "https://www.zomato.com/milwaukee/monkeys-sports-bar-grill-west-allis/menu?utm_source=api_basic_user&utm_medium=api&utm_campaign=v2.1&openSwipeBox=menu&showMinimal=1#tabtop", "featured_image": "", "has_online_delivery": 0, "is_delivering_now": 0, "include_bogo_offers": true, "deeplink": "zomato://restaurant/17180021", "is_table_reservation_supported": 0, "has_table_booking": 0, "events_url": "https://www.zomato.com/milwaukee/monkeys-sports-bar-grill-west-allis/events#tabtop?utm_source=api_basic_user&utm_medium=api&utm_campaign=v2.1" } }] } ';
  
  // if(response.statusCode == 200){
    // final restaurants = parseRestaurants(response.body);
    final restaurants = parseRestaurants(response);
    return restaurants[0];
  // } 

    // throw Exception('Failed to load');
  
}

List<Restaurant> parseRestaurants(String responseBody){
  final decoded = json.decode(responseBody);
  // final parsed = decoded.cast<Map<String, dynamic>>();
  return decoded['nearby_restaurants'].map<Restaurant>((json) => Restaurant.fromJson(json['restaurant'])).toList();
}

List<City> parseCities(String responseBody){
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<City>((json) => City.fromJson(json)).toList();
}

class City {
  final String id;
  final String name;
  final String countryId;
  final String countryName;
  final String isState;
  final String stateId;
  final String stateName;
  final String stateCode;

  City({this.id, this.name, this.countryId, this.countryName, this.isState, this.stateId, this.stateName, this.stateCode});

  
  factory City.fromJson(Map<String, dynamic> json){
    return City(
      id: json['id'],
      name: json['name'],
      countryId: json['country_id'],
      countryName: json['country_name'],
      isState: json['is_state'],
      stateId: json['state_id'],
      stateName: json['state_name'],
      stateCode: json['state_code']
      );
  }
}

class Restaurant{
  final String restaurantName;

  Restaurant ({this.restaurantName});

  factory Restaurant.fromJson(Map<String, dynamic> json){
    return Restaurant(restaurantName: json['name']);
  }
}

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'WTFSWE?!',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.green,
      ),
      home: new MyHomePage(title: 'WTFSWE?!'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
   Map<String, double> _startLocation;
  Map<String, double> _currentLocation;

  StreamSubscription<Map<String, double>> _locationSubscription;

  Location _location = new Location();
  String error;
  @override
  void initState() {
    super.initState();

    initPlatformState();

    _locationSubscription =
        _location.onLocationChanged.listen((Map<String,double> result) {
          setState(() {
            _currentLocation = result;
          });
        });
  }
 // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    Map<String, double> location;
    // Platform messages may fail, so we use a try/catch PlatformException.

    try {
      location = await _location.getLocation;

      error = null;
    } on Exception catch (e) {
      error = e.toString();

      location = null;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    //if (!mounted) return;

    setState(() {
        _startLocation = location;
    });

  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text(widget.title),
      ),
      body: new Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: new Column(
          // Column is also layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug paint" (press "p" in the console where you ran
          // "flutter run", or select "Toggle Debug Paint" from the Flutter tool
          // window in IntelliJ) to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(
              'How about?',
            ),
            FutureBuilder<Restaurant>(
              future: fetchRestaurant(_currentLocation == null ? "0" : _currentLocation["latitude"],_currentLocation == null ? "0" : _currentLocation["longitude"]),
              builder: (context, snapshot){
                if(snapshot.hasData){
                  return Text(snapshot.data.restaurantName);
                } else if(snapshot.hasError){
                  return Text("${snapshot.error}");
                }
              }
            ),
          ],
        ),
      ),
      // floatingActionButton: new FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: new Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
