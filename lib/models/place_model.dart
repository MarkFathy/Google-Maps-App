import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceModel{
  final int id;
  final String name;
  final LatLng latLong;

  PlaceModel({
    required this.id,
    required this.name,
    required this.latLong,
  });

}
List<PlaceModel> places=[
  PlaceModel(id:1 , name: 'plaza mall', latLong:const LatLng(31.038483749999994, 31.358510248028264)),
  PlaceModel(id:2 , name: 'Mary George Church', latLong:const LatLng(31.040496928668386, 31.38057677935165)),
  PlaceModel(id:3 , name: 'المحمدي للمشويات', latLong:const LatLng(31.03949507140983, 31.378895714806468))


];
