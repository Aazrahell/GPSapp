import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:praca/podsumowanie.dart';

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

checkService(Location location) async {
  var serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {
      return;
    }
  }
}

askPermission(Location location) async {
  var _permissiongranted = await location.hasPermission();
  if (_permissiongranted == PermissionStatus.denied) {
    _permissiongranted = await location.requestPermission();
    if (_permissiongranted != PermissionStatus.granted) {
      return;
    }
  }
}

final _stopWatchTimer = StopWatchTimer(
  onChange: (seconds) {
    final displayTime = StopWatchTimer.getDisplayTime(seconds);
    //print('displayTime $displayTime');
  },
  onChangeRawSecond: (seconds) => seconds,
  onChangeRawMinute: (minutes) => minutes,
);

//FUNKCJA DO MERGORWANIA URL DO WYSOKOSCI
String mergeURL(String URL, String LAT, String LONG) {
  String mergedUrl = URL + LAT + ',' + LONG;
  return mergedUrl;
}

//FUNKCJA DO WYCIAGANIA WYSOKOSCI Z URL
Future<int> fetchElevation(url1) async {
  final response = await get(Uri.parse(url1));
  Map<String, dynamic> jsonData = jsonDecode(response.body);
  //print(jsonData["results"][0]["elevation"].toInt());
  var elevation = jsonData["results"][0]["elevation"].toInt();
  return elevation;
}

String url = 'https://api.opentopodata.org/v1/eudem25m?locations=';

class MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controllerMap = Completer();
  final controllerBase = TextEditingController();
  Location location = new Location();
  var latitude;
  var longitude;
  var elevation; //zmienna wysokosci geograficznej
  var mergedURL; // zmienna przechowujaca url zmergowany
  var distance = 0.0;
  late var dist = 0.0;

  bool check = true;
  bool isWalking = false;

  String timer = '';
  String seconds = '';

  // List<int> elevationList = <int>[];
  // List<double> distanceList = <double>[];

  Set<Marker> _marker = Set<Marker>();
  Set<Polyline> _polyline = {};
  Set<Polygon> _polygon = {};

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = Set<Polyline>();
  Set<Polygon> _polygons = Set<Polygon>();
  List<LatLng> polygonLatLngs = <LatLng>[];

  List<LatLng> tab = <LatLng>[];
  void addTab(List tab, double lat, double long) {
    tab.add(LatLng(lat, long));
  }

  // void addElevation(List elevationList, int elevation) {
  //   elevationList.add(elevation);
  // }

  // void addDistance(List distanceList, double distance) {
  //   distanceList.add(distance);
  // }

//funkcja wyliczajaca odległość
  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    var wynik = 12742 * asin(sqrt(a));
    // if (wynik > 5000) {
    //   wynik = 0.0;
    // }
    //wynik *= 1000;
    return wynik;
  }

  void _onMapCreated(GoogleMapController) {
    setState(() {
      _polyline.add(Polyline(
        polylineId: const PolylineId('Trasa'),
        color: Colors.black,
        points: tab,
        width: 9,
      ));
      _polyline.add(Polyline(
          polylineId: const PolylineId('TrasaBorder'),
          color: Colors.white,
          points: tab,
          width: 4));
    });
  }

  // @override
  // void dispose() {
  //   controllerBase.dispose();
  //   //dystans.dispose();
  //   // ignore: avoid_print
  //   //print('Dispose used');
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 0), () {
      setState(() {
        lokalizacja();
      });
    });
    return Scaffold(
        appBar: AppBar(
            title: const Text('Praca Inzynierska - Google Maps'),
            centerTitle: true),
        body: Stack(
          //alignment: AlignmentDirectional.bottomCenter,
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            GoogleMap(
                mapType: MapType.hybrid,
                onMapCreated: (GoogleMapController controllerMap) {
                  _controllerMap.complete(controllerMap);
                },
                myLocationEnabled: true,
                polylines: _polyline,
                polygons: _polygon,
                initialCameraPosition: const CameraPosition(
                    target: const LatLng(53.4482, 14.5701), zoom: 17)),
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Container(
                  height: 150,
                  width: 300,
                  //alignment: Alignment.,
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(42)),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(0, 50),
                          blurRadius: 40,
                          spreadRadius: -5,
                        ),
                      ],
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.blue[200]!,
                            Colors.blue[300]!,
                            Colors.blue[600]!,
                            Colors.blue[800]!,
                            Colors.blue[800]!,
                          ],
                          stops: const [
                            0.1,
                            0.3,
                            0.6,
                            0.9,
                            1.0
                          ])),
                  child: Center(
                      child: Wrap(children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Text('Trasa [km]'),
                              Padding(padding: EdgeInsets.all(5)),
                              Text('$dist',
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                              //color: Colors.red,

                              children: [
                                Text('Czas'),
                                Padding(padding: EdgeInsets.all(5)),
                                StreamBuilder<int>(
                                    stream: _stopWatchTimer.rawTime,
                                    initialData: 0,
                                    builder: (context, snap) {
                                      //int value = snap.data ?? 0;
                                      timer = StopWatchTimer.getDisplayTime(
                                          snap.data ?? 0);
                                      //timer = displayTime;
                                      //print('Listen every second. $value');
                                      return Text(timer.toString(),
                                          style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold));
                                    }),
                              ]),
                          Column(
                            children: [
                              Text('Wysokość'),
                              Padding(padding: EdgeInsets.all(5)),
                              Text('${elevation}',
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                            ],
                          )
                        ]),
                    Padding(padding: EdgeInsets.all(10)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.lightBlue,
                                shape: const StadiumBorder()),
                            onPressed: () async {
                              isWalking = true;
                              _stopWatchTimer.onExecute
                                  .add(StopWatchExecute.start);
                            },
                            child: const Text(
                              'Start',
                              style: TextStyle(color: Colors.white),
                            )),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.lightBlue,
                                shape: StadiumBorder()),
                            onPressed: () {
                              _stopWatchTimer.onResetTimer();
                              distance = 0.0;
                              dist = 0.0;
                              elevation = 0;
                              //elev = 0;
                              usunDane();
                              tab.clear();
                            },
                            child: const Text('Reset')),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.lightBlue,
                                shape: StadiumBorder()),
                            onPressed: () {
                              if (isWalking && seconds != 0) {
                                _stopWatchTimer.onExecute
                                    .add(StopWatchExecute.stop);
                                isWalking = false;

                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Podsumowanie(
                                              //elevationList: elevationList,
                                              //distanceList: distanceList,
                                              timer: timer,
                                              seconds: seconds,
                                            )));
                              }
                            },
                            child: const Text(
                              'Stop',
                              style: TextStyle(color: Colors.white),
                            ))
                      ],
                    ),
                    StreamBuilder<int>(
                        stream: _stopWatchTimer.secondTime,
                        initialData: 0,
                        builder: (context, sec) {
                          int secc = sec.data ?? 0;
                          seconds = secc.toString();
                          return const Text("");
                        }),
                  ]))),
            )
            //Padding(padding: EdgeInsets.only(bottom: 50))
          ],
        ));
  }

  var prev_lat = 0.0;
  var prev_long = 0.0;
  List tablica = [];

  Future<void> lokalizacja() async {
    final GoogleMapController controllerMap = await _controllerMap.future;
    LocationData currentLocation = await location.getLocation();
    latitude = currentLocation.latitude!;
    longitude = currentLocation.longitude!;
    // var idk = CameraPosition(
    //     target: LatLng(latitude, longitude),
    //     bearing: 0.0,
    //     tilt: 0.0,
    //     zoom: 19);
    //print(latitude);
    //print(longitude);

    location.onLocationChanged.listen((LocationData currentLocation) async {
      if (elevation == null) {
        elevation = 0;
      }
      mergedURL = mergeURL(url, latitude.toString(), longitude.toString());
      elevation = await fetchElevation(mergedURL);

      latitude = currentLocation.latitude!;
      longitude = currentLocation.longitude!;
      //elevation = fetchElevation(mergedURL);
      //print('Lat: $latitude');
      //print('Long: $longitude');
      //print('Tab: $tablica');
      if ((prev_lat - latitude).abs() > 0.0001 ||
          (prev_long - longitude).abs() > 0.0001) {
        //print('Location changed !!');
        //print(prev_lat - latitude);
        var cameraPosition = CameraPosition(
            target: LatLng(latitude, longitude),
            bearing: 0.0,
            tilt: 0.0,
            zoom: 19);
        //await new Future.delayed(const Duration(milliseconds: 1000));
        controllerMap
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
        //tablica.add(LatLng(latitude, longitude));

        //var diff1 = (prev_lat - latitude).abs();
        //var diff2 = (prev_long - longitude).abs();
        //print('Difference lat: $diff1');
        //print('Difference long: $diff2');
        prev_lat = latitude;
        prev_long = longitude;
        //print(prev_long);
        //print(prev_lat);

        _onMapCreated(controllerMap);
      }
      // var diff1 = (prev_lat - latitude).abs();
      // var diff2 = (prev_long - longitude).abs();
      // _onMapCreated(controllerMap);
    });
    if (isWalking) {
      distance = calculateDistance(prev_lat, prev_long, latitude, longitude);
      addTab(tab, latitude, longitude);
      //addElevation(elevationList, elevation);
      //addDistance(distanceList, distance);
      final dystans = controllerBase.text;
      zapiszDane(dystans: dystans);

      // DocumentReference reference =
      //     FirebaseFirestore.instance.collection('Lukasz').doc("Run");
      // reference.snapshots().listen((querySnapshot) {
      //   setState(() {
      //     elev = querySnapshot.get("ele$i");
      //   });
      // });

      // print('Dystans: ${distance}');
      // print('Lat: $latitude');
      // print('Long: $longitude');
      // print('elevation: $elevation');
      // //print('Tab: $PointsTable');
      // print('URL: $mergedURL');
      // print('ElTab: $elevationList');
      // print('DistTab: $distanceList');
    }
  }

  int i = 0;
  Future zapiszDane({required String dystans}) async {
    final saveData = FirebaseFirestore.instance
        .collection('Lukasz')
        .doc('Run')
        .set({'dist$i': distance, 'ele$i': elevation}, SetOptions(merge: true));

    //dist += distance / 1000;
    dist += distance;
    String distString = dist.toStringAsFixed(2);
    dist = double.parse(distString);

    i = i + 1;
  }

  void usunDane() {
    final deleteData =
        FirebaseFirestore.instance.collection("Lukasz").doc('Run').delete();
  }
}
