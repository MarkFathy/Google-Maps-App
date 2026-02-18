import 'package:location/location.dart';

class LocationService {
  Location location = Location();

  Future<bool> checkAndRequestLocationService() async {
    var isServiceEnabled = await location.serviceEnabled();
    if (!isServiceEnabled) {
      await location.requestService();
      isServiceEnabled = await location.requestService();
      if (!isServiceEnabled) {
        return false;
      }
      checkAndRequestLocationPermission();
    }
    return true;
  }

  Future<bool> checkAndRequestLocationPermission() async {
    var permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.deniedForever) {
      return false;
    }

    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
      if (permissionStatus != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  void getRealTimeLocation(void Function(LocationData)? onData) async {
    await location.changeSettings(distanceFilter: 2);
    location.onLocationChanged.listen((onData));
  }
}
