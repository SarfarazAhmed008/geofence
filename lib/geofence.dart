import 'dart:async';

import 'package:geolocator/geolocator.dart';

enum GeofenceEvent{
  init,
  enter,
  exit
}

class Geofence {

  static StreamSubscription<Position> _positionStream;

  static Stream<GeofenceEvent> _geostream;
  static StreamController<GeofenceEvent> _controller = StreamController<GeofenceEvent>();

  static double _parser(String value){
    return double.parse(value);
  }

  static Stream<GeofenceEvent> getGeofenceStream(){
    return _geostream;
  }

  static startGeofenceService({String pointedLatitude, String pointedLongitude, String radiusMeter}){
    double latitude = _parser(pointedLatitude);
    double longitude = _parser(pointedLongitude);
    double radiusInMeter = _parser(radiusMeter);

    _geostream = _controller.stream;

    _positionStream = Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.best).listen(
            (Position position) {
          double distanceInMeters = Geolocator.distanceBetween(latitude, longitude, position.latitude, position.longitude);
          print(position == null ? 'Unknown' : position.latitude.toString() + ', ' + position.longitude.toString());
          print(distanceInMeters);
          _checkGeofence(distanceInMeters, radiusInMeter);

        });

    _controller.add(GeofenceEvent.init);
  }


  static _checkGeofence(double distanceInMeters, double radiusInMeter){
    if(distanceInMeters <= radiusInMeter){
      _controller.add(GeofenceEvent.enter);
    }else{
      _controller.add(GeofenceEvent.exit);
    }

  }

  static stopGeofenceService(){
    if(_positionStream != null){
      _positionStream.cancel();
    }
  }

}