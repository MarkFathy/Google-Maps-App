
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:googlemaps/models/place_model.dart';
import 'package:location/location.dart';

class CustomGoogleMap extends StatefulWidget {
  const CustomGoogleMap({super.key});
  @override
  State<CustomGoogleMap> createState() => _CustomGoogleMapState();
}

class _CustomGoogleMapState extends State<CustomGoogleMap> {
  late CameraPosition initialCameraPosition;
   GoogleMapController? googleMapController;
  late Location location;
  Set<Marker> markers = {};
  Set<Polyline>  polyLines={};
  Set<Polygon>  polygons={};
  Set<Circle>  circles={};



  @override
  void initState() {
    initialCameraPosition = const CameraPosition(
      zoom: 12,
      target: LatLng(31.03890392341038, 31.37275461038365),
    );


    //initMarkers();
    initPolyLines();
    //initPolygons();
    initCircles();
    location =Location();
    updateMyLocation();

    checkAndRequestLocationService();
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
          ///to hide the default + - buttons from the screen
          //zoomControlsEnabled: false,
          initialCameraPosition: initialCameraPosition,
          markers: markers,
          onMapCreated: (controller) {
            googleMapController = controller;
            initMapStyle();

          },
          polylines:polyLines,
          circles: circles,


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

///For creating custom markers received from model
  void initMarkers() async{
    //var customMarkerIcon=await BitmapDescriptor.fromAssetImage(const ImageConfiguration(),'assets/images/marker.png');
    var myMarkers=places.map((placeModel) => Marker(
      //icon:customMarkerIcon ,
      infoWindow: InfoWindow(
        title: placeModel.name //to show info when user press on marker
      ),
      position: placeModel.latLong,
        markerId: MarkerId(placeModel.id.toString()))).toSet();
    markers.addAll(myMarkers);

    // setState(() {
    //
    // });
  }

  void initPolyLines() {
    Polyline polyline=const Polyline(polylineId: PolylineId('1'),
      color: Colors.blue,
      startCap: Cap.roundCap,
      width: 5,

      points: [
        LatLng(31.04030196508036, 31.369091463444317),
        LatLng(31.037250000134875, 31.376172494606262),
        LatLng(31.042324297595982, 31.37853283832691),
        LatLng(31.047618928329026, 31.380206536601552),

        //Created 3 lines

      ]
    );
    polyLines.add(polyline);
  }

  // to create a shape like square - connected lines
  void initPolygons() {
    Polygon polygon=Polygon(
        polygonId:const PolygonId('1'),
      fillColor: Colors.black.withOpacity(0.5),
      //holes: [], to make like a hole in polygon This hole should not go outside the frame
      points: const[
        LatLng(31.04699388309403, 31.385399292736764),
        LatLng(31.045743780298523, 31.353770686880075),
        LatLng(31.035609068890274, 31.392265747409287),
      ]

    );
    polygons.add(polygon);

    }

  void initCircles() {
    Circle elmohamedyService=Circle(
    center:const LatLng(31.039571157538532, 31.37891907744677),
        radius: 1000,
        strokeWidth: 1,
        fillColor: Colors.black.withOpacity(0.5),
        circleId:const CircleId('1')
    );
    circles.add(elmohamedyService);


  }

  Future<void> checkAndRequestLocationService() async{
    var isServiceEnabled=await location.serviceEnabled();
    if(!isServiceEnabled){
      await location.requestService();
      isServiceEnabled=await location.requestService();
      if(!isServiceEnabled ){
        //ToDo : show error bar
      }
      checkAndRequestLocationPermission();
    }



  }

  Future<bool> checkAndRequestLocationPermission() async{
    var permissionStatus=await location.hasPermission();
    if(permissionStatus ==PermissionStatus.deniedForever){
      return false;
    }

      if(permissionStatus ==PermissionStatus.denied)
      {
        permissionStatus=await location.requestPermission();
        if(permissionStatus !=PermissionStatus.granted)
        {
          return false;
        }
      }
      return true;


  }
  void getLocationData(){
    location.onLocationChanged.listen((locationData) {
      var cameraPosition=CameraPosition(
        zoom:15 ,
          target: LatLng(
              locationData.latitude!,
              locationData.longitude!
          )
      );
      var myLocationMarker=Marker(
      markerId: const MarkerId('my location marker'),
      position: LatLng(locationData.latitude!,
      locationData.longitude!)
      );
      markers.add(myLocationMarker);
      setState(() {
      });
      googleMapController?.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    });
  }

  void updateMyLocation() async{
    await checkAndRequestLocationService();
    var hasPermission =await checkAndRequestLocationPermission();
    if(hasPermission)
      {
        getLocationData();
      }else{

    }
    await checkAndRequestLocationPermission();
    getLocationData();
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
