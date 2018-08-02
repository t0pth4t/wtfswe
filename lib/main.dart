import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

//
Future<Restaurant> fetchRestaurant(lat, long) async {
  final prefs = await SharedPreferences.getInstance();
  var restaurantJson = prefs.getString('rest_json');
  if (restaurantJson == null) {
    final response = await http.get(
        'https://developers.zomato.com/api/v2.1/geocode?lat=43.01668&lon=-88.00703',
        headers: {'user-key': ''});
    if (response.statusCode == 200) {
      restaurantJson = response.body;
      prefs.setString('rest_json', restaurantJson);
    }
  }

  if (restaurantJson == null) {
    throw Exception('Failed to load');
  }
  final restaurants = parseRestaurants(restaurantJson);
  final rand = new Random();
  return restaurants[rand.nextInt(restaurants.length - 1)];
}

List<Restaurant> parseRestaurants(String responseBody) {
  final decoded = json.decode(responseBody);
  
  return decoded['nearby_restaurants']
      .map<Restaurant>((json) => Restaurant.fromJson(json['restaurant']))
      .toList();
}

class Restaurant {
  final String restaurantName;

  Restaurant({this.restaurantName});

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(restaurantName: json['name']);
  }
}

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'WTFSWE?!',
      theme: new ThemeData(
        primarySwatch: Colors.green,
      ),
      home: new MyHomePage(title: 'WTFSWE?!'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

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
        _location.onLocationChanged.listen((Map<String, double> result) {
      setState(() {
        _currentLocation = result;
      });
    });
  }

  initPlatformState() async {
    Map<String, double> location;

    try {
      location = await _location.getLocation;

      error = null;
    } on Exception catch (e) {
      error = e.toString();

      location = null;
    }

    setState(() {
      _startLocation = location;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(
              'How about?',
            ),
            FutureBuilder<Restaurant>(
                future: fetchRestaurant(
                    _currentLocation == null
                        ? "0"
                        : _currentLocation["latitude"],
                    _currentLocation == null
                        ? "0"
                        : _currentLocation["longitude"]),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(snapshot.data.restaurantName);
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }
                }),
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
