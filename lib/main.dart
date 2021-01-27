import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geofence/geofence.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Geofence',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Geofence'),
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

  StreamSubscription<GeofenceEvent> geofenceEventStream;
  String geofenceEvent = '';

  TextEditingController latitudeController = new TextEditingController();
  TextEditingController longitudeController = new TextEditingController();
  TextEditingController radiusController = new TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Geofence Event: " + geofenceEvent,
            ),
            TextField(
              controller: latitudeController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter pointed latitude'
              ),
            ),
            TextField(
              controller: longitudeController,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter pointed longitude'
              ),
            ),
            TextField(
              controller: radiusController,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter radius meter'
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RaisedButton(
                  child: Text("Start"),
                  onPressed: (){
                    print("start");
                    Geofence.startGeofenceService(
                        pointedLatitude: latitudeController.text,
                        pointedLongitude: longitudeController.text,
                        radiusMeter: radiusController.text
                    );
                    geofenceEventStream = Geofence.getGeofenceStream().listen((GeofenceEvent event) {
                      print(event.toString());
                      setState(() {
                        geofenceEvent = event.toString();
                      });
                    });
                  },
                ),
                SizedBox(width: 10.0,),
                RaisedButton(
                  child: Text("Stop"),
                  onPressed: (){
                    print("stop");
                    Geofence.stopGeofenceService();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    latitudeController.dispose();
    longitudeController.dispose();
    radiusController.dispose();
    super.dispose();
  }

}
