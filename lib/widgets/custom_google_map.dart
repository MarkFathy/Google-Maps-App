import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:googlemaps/models/place_model.dart';
import 'package:googlemaps/utils/location_service.dart';
import 'dart:ui' as ui;
import 'package:location_platform_interface/location_platform_interface.dart';

class CustomGoogleMap extends StatefulWidget {
  const CustomGoogleMap({super.key});
  @override
  State<CustomGoogleMap> createState() => _CustomGoogleMapState();
}

class _CustomGoogleMapState extends State<CustomGoogleMap> {
  late CameraPosition initialCameraPosition;
  GoogleMapController? googleMapController;
  Set<Marker> markers = {};
  Set<Polyline> polyLines = {};
  Set<Polygon> polygons = {};
  Set<Circle> circles = {};
  late LocationService locationService;
  bool isFirstCall = true;

  @override
  void initState() {
    initialCameraPosition = const CameraPosition(
      zoom: 1,
      target: LatLng(31.03890392341038, 31.37275461038365),
    );
    locationService = LocationService();
    initMarkers();
    initPolyLines();
    initPolygons();
    initCircles();
    updateMyLocation();

    //checkAndRequestLocationService();
    super.initState();
  }

  @override
  void dispose() {
    googleMapController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          //zoomControlsEnabled: false, ///to hide the default + - Zoom buttons from the screen
          initialCameraPosition: initialCameraPosition,
          markers: markers,
          onMapCreated: (controller) {
            googleMapController = controller;
            initMapStyle();
          },
          polylines: polyLines,
          circles: circles,
          polygons: polygons,
        ),
        /*Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: ElevatedButton(
            onPressed: () {
              googleMapController.animateCamera(CameraUpdate.newLatLng(
                const LatLng(31.497424010639026, 31.82921743351619)
              ));
            },
            child: const Text('Change Location'),
          ),
        )*/
      ],
    );
  }

  void initMapStyle() async {
    var nightMapStyle = await DefaultAssetBundle.of(context).loadString(
      'assets/map_styles/night_map_style.json',
    );
    googleMapController!.setMapStyle(nightMapStyle);
  }

  ///its a method that helps me to change the size of custom marker
  Future<Uint8List> getImageFromRawData(String image, double width) async {
    var imageData = await rootBundle.load(image);
    var imageCodec = await ui.instantiateImageCodec(
        imageData.buffer.asUint8List(),
        targetWidth: width.round());
    var imageFrame = await imageCodec.getNextFrame();
    var imageByteData =
        await imageFrame.image.toByteData(format: ui.ImageByteFormat.png);
    return imageByteData!.buffer.asUint8List();
  }

  ///For creating custom markers received from model
  void initMarkers() async {
    // var customMarkerIcon = await BitmapDescriptor.fromAssetImage(
    //     const ImageConfiguration(), 'assets/images/marker.png');

    var customMarkerIcon = BitmapDescriptor.bytes(
        await getImageFromRawData('assets/images/marker.png', 20));
    var myMarkers = places
        .map((placeModel) => Marker(
            icon: customMarkerIcon,
            infoWindow: InfoWindow(
                title: placeModel.name //to show info when user press on marker
                ),
            position: placeModel.latLong,
            markerId: MarkerId(placeModel.id.toString())))
        .toSet();
    markers.addAll(myMarkers);
//use it after change the marker icon
    // setState(() {

    // });
  }

  void initPolyLines() {
    Polyline polyline = const Polyline(
        polylineId: PolylineId('1'),
        color: Colors.blue,
        startCap: Cap.roundCap,
        width: 5,
        points: [
          LatLng(31.04030196508036, 31.369091463444317),
          LatLng(31.037250000134875, 31.376172494606262),
          LatLng(31.042324297595982, 31.37853283832691),
          LatLng(31.047618928329026, 31.380206536601552),

          //Created 3 lines
        ]);
    polyLines.add(polyline);
  }

  // to create a shape like square - connected lines
  void initPolygons() {
    Polygon polygon = Polygon(
        polygonId: const PolygonId('1'),
        fillColor: Colors.black.withValues(
          alpha: 0.5,
        ),
        strokeWidth: 1,
        //holes: [], to make like a hole in polygon This hole should not go outside the frame
        points: const [
          LatLng(30.9646005148827, 31.24268649763915),
          LatLng(30.95728053780054, 31.23509581532031),
          LatLng(30.964555470585612, 31.246311114109737),
        ]);
    polygons.add(polygon);
  }

  void initCircles() {
    Circle elmohamedyService = Circle(
        center: const LatLng(31.039571157538532, 31.37891907744677),
        radius: 1000,

        ///in meters
        strokeWidth: 1,
        fillColor: Colors.black.withOpacity(0.5),
        circleId: const CircleId('1'));
    circles.add(elmohamedyService);
  }

  void updateMyLocation() async {
    await locationService.checkAndRequestLocationService();
    var hasPermission =
        await locationService.checkAndRequestLocationPermission();
    if (hasPermission) {
      locationService.getRealTimeLocation((locationData) {
        var myLocationMarker = Marker(
            markerId: const MarkerId('my_location_marker'),
            position: LatLng(locationData.latitude!, locationData.longitude!));
        markers.add(myLocationMarker);
        setState(() {});
        updateMyCamera(locationData);
      });
    } else {}
  }

  void updateMyCamera(LocationData locationData) {
    ///when the map opend zoom is faraway then zoomed in to the user location by zoom 17
    /// when using the newLatLng user can move free to any place on map 
     if (isFirstCall) {
      CameraPosition cameraPosition = CameraPosition(
          target: LatLng(
            locationData.latitude!,
            locationData.longitude!,
          ),
          zoom: 17);
      googleMapController
          ?.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
          isFirstCall =false;
    } else {
      googleMapController?.animateCamera(CameraUpdate.newLatLng(
          LatLng(locationData.latitude!, locationData.longitude!)));
    }
  }
}

// World view 0 -> 3
// Country view 4 -> 6
// City view 10 -> 12
// Street view 13 -> 17
// Building view 18 -> 20

/// To make bounds for a specified location, we use cameraTargetBounds

/*cameraTargetBounds: CameraTargetBounds(LatLngBounds(
  southwest: const LatLng(31.001243372386632, 31.2965521994721),
  northeast: const LatLng(31.073020935813876, 31.49121619058161),
)),*/

/// To change map type view
// mapType: MapType.hybrid,

/// To change map style
// https://mapstyle.withgoogle.com/
