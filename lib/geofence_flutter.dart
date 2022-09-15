library geofence_flutter;

import 'dart:async';
import 'package:geolocator/geolocator.dart';

/// Geofence events state
/// init: this is triggered when geofence service started
/// enter: this is triggered when the device current location is in the allocated geofence area
/// exit: this is triggered when the device current location is outside of the allocated geofence area
enum GeofenceEvent { init, enter, exit }

/// Geofence plugin class
class Geofence {
  /// [ _positionStream ] is for getting stream position on location updates
  static StreamSubscription<Position>? _positionStream;

  /// [_geostream] is for geofence event stream
  static Stream<GeofenceEvent>? _geostream;

  /// [_controller] is Stream controller for geofence event stream
  static StreamController<GeofenceEvent> _controller =
      StreamController<GeofenceEvent>();

  /// Parser method which is basically for parsing [String] values
  /// to [double] values
  static double _parser(String value) {
    return double.parse(value);
  }

  /// For getting geofence event stream property which is basically returns [_geostream]
  static Stream<GeofenceEvent>? getGeofenceStream() {
    return _geostream;
  }

  /// [startGeofenceService] To start the geofence service
  /// this method takes this required following parameters
  /// pointedLatitude is the latitude of geofencing area center which is [String] datatype
  /// pointedLongitude is the longitude of geofencing area center which is [String] datatype
  /// radiusMeter is the radius of geofencing area in meters
  /// radiusMeter takes value is in [String] datatype and
  /// eventPeriodInSeconds will determine whether the stream listener period in seconds
  /// eventPeriodInSeconds takes value in [int]
  /// The purpose of this method is to initialize and start the geofencing service.
  /// At first it will check location permission and if enabled then it will start listening the current location changes
  /// then calculate the distance of changes point to the allocated geofencing area points
  static startGeofenceService(
      {required String pointedLatitude,
      required String pointedLongitude,
      required String radiusMeter,
      required int eventPeriodInSeconds}) async {
    double latitude = _parser(pointedLatitude);
    double longitude = _parser(pointedLongitude);
    double radiusInMeter = _parser(radiusMeter);
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;
    if (_positionStream == null) {
      _geostream = _controller.stream;
      _positionStream = Geolocator.getPositionStream(
              locationSettings:
                  LocationSettings(accuracy: LocationAccuracy.best))
          .listen((Position? position) {
        if (position != null) {
          double distanceInMeters = Geolocator.distanceBetween(
              latitude, longitude, position.latitude, position.longitude);
          _checkGeofence(distanceInMeters, radiusInMeter);
          _positionStream!
              .pause(Future.delayed(Duration(seconds: eventPeriodInSeconds)));
        }
      });
      _controller.add(GeofenceEvent.init);
    }
  }

  /// [_checkGeofence] is for checking whether current location is in
  /// or
  /// outside of the geofence area
  /// this takes two parameters which is [double] distanceInMeters
  /// distanceInMeters parameters is basically the calculated distance between
  /// geofence area points and the current location points
  /// radiusInMeter take value in [double] and it's the radius of geofence area in meters
  static _checkGeofence(double distanceInMeters, double radiusInMeter) {
    if (distanceInMeters <= radiusInMeter) {
      _controller.add(GeofenceEvent.enter);
    } else {
      _controller.add(GeofenceEvent.exit);
    }
  }

  /// [stopGeofenceService] to stop the geofencing service
  /// if the [_positionStream] is not null then
  /// it will cancel the subscription of the stream
  static stopGeofenceService() {
    if (_positionStream != null) {
      _positionStream!.cancel();
    }
  }
}
