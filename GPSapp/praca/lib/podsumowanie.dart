import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'mapa.dart';

class Podsumowanie extends StatefulWidget {
  late String timer;
  late String seconds;
  //late List<int> elevationList;
  //late List<double> distanceList;

  Podsumowanie({
    //required this.elevationList,
    //required this.distanceList,
    required this.timer,
    required this.seconds,
  });

  @override
  State<Podsumowanie> createState() => _PodsumowanieState();
}

class _PodsumowanieState extends State<Podsumowanie> {
  late int sec = int.parse(widget.seconds);

  List<Wykres> daneDisEle = [];

  //late int maxEle = widget.elevationList.reduce(max);

  //late int minEle = widget.elevationList.reduce(min);

  //late int sumEle = widget.elevationList.reduce((a, b) => a + b);

  //late double sumDistance = widget.distanceList.reduce((a, b) => a + b);

  //late String sumDistance1 = sumDistance.toStringAsFixed(2);

  //late double sumDist = double.parse(sumDistance1);

  //late double averageEle = sumEle / widget.elevationList.length;

  late double minutes = sec / 60;

  late double hour = minutes / 60;

  late double aveDistance = dyst / hour;

  //late String aveDist = aveDistance.toStringAsFixed(2);

  late var eleSum = 0;
  late var minEle;
  late int minElev = 0;
  late int maxElev = 0;
  late double aveElevation = 0.0;
  late int minElement;

  //late String aveEle = averageEle.toStringAsFixed(2);

  // Wykresy
  late double dyst = 0.0;
  //late ZoomPanBehavior _zoomPanBehavior;
  List<Wykres> chartData = <Wykres>[];

  var value;
  bool check = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 5), () {
      //aveDistance = (dyst / 1000) / hour;
      setState(() {
        //aveDistance = (dyst / 1000) / hour;
        //print(daneDisEle.length);
        // odczytajDane();
        //print('dist: ${data['dist3']}, ele:${data['ele3']}');
      });
    });
    return Scaffold(
        appBar: AppBar(
            title: const Text('Praca Inzynierska - Google Maps'),
            centerTitle: true),
        body: Column(

            //width: 75,
            //height: 750,
            children: [
              Container(
                  padding: const EdgeInsets.all(20),
                  child: const Text('PODSUMOWANIE',
                      style: TextStyle(
                          fontSize: 30, fontWeight: FontWeight.bold))),
              Container(
                  padding:
                      const EdgeInsets.only(bottom: 10, left: 20, right: 20),
                  child: Table(
                      columnWidths: const {
                        0: FlexColumnWidth(4),
                        1: FlexColumnWidth(4),
                      },

                      //padding: const EdgeInsets.all(8),
                      border: TableBorder.all(),
                      children: [
                        TableRow(
                          //decoration: Padding.,
                          children: [
                            const Padding(
                                padding: EdgeInsets.all(10),
                                child: Center(child: Text('t [h:m:s]'))),
                            Padding(
                                padding: const EdgeInsets.all(10),
                                child: Center(child: Text(widget.timer)))
                          ],
                        ),
                        TableRow(children: [
                          //height: 15),
                          const Padding(
                              padding: EdgeInsets.all(10),
                              child: Center(child: Text('s [km]'))),
                          Padding(
                              padding: const EdgeInsets.all(10),
                              child:
                                  Center(child: Text(dyst.toStringAsFixed(2))))
                        ]),
                        TableRow(children: [
                          const Padding(
                              padding: EdgeInsets.all(10),
                              child: Center(child: Text('V [km/h]'))),
                          Padding(
                              padding: const EdgeInsets.all(10),
                              child: Center(
                                  child: Text(aveDistance.toStringAsFixed(2))))
                        ]),
                        TableRow(children: [
                          const Padding(
                              padding: EdgeInsets.all(10),
                              child: Center(child: Text('h [max]'))),
                          Padding(
                              padding: const EdgeInsets.all(10),
                              child: Center(child: Text('$maxElev')))
                        ]),
                        TableRow(children: [
                          const Padding(
                              padding: EdgeInsets.all(10),
                              child: Center(child: Text('h [min]'))),
                          Padding(
                              padding: const EdgeInsets.all(10),
                              child: Center(child: Text('$minElev')))
                        ]),
                        TableRow(children: [
                          const Padding(
                              padding: EdgeInsets.all(10),
                              child: Center(child: Text('h [average]'))),
                          Padding(
                              padding: const EdgeInsets.all(10),
                              child: Center(
                                  child: Text(aveElevation.toStringAsFixed(2))))
                        ]),
                      ])),
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('Lukasz')
                    .doc('Run')
                    .snapshots(),
                builder: (_, snapshot) {
                  if (snapshot.hasError)
                    return Text('Error = ${snapshot.error}');

                  if (snapshot.hasData) {
                    var output = snapshot.data!.data();
                    //value = output!['dist0']; // <-- Your value
                    //final int count = doc('Run3').size;

                    if (check) {
                      int i = 0;
                      while (output!['dist$i'] != null) {
                        //print(output!['dist$i']);
                        //double dataDist = data['dist$i'];
                        //int dataEle = data['ele$i'];
                        if (i == 0) {
                          minElev = output['ele0'];
                          maxElev = output['ele0'];
                        }

                        if (i > 0) {
                          dyst += output['dist$i'];
                        } else if (i == 0) {
                          dyst = output['dist0'];
                        }

                        if (i > 0) {
                          int sumele = output['ele$i'];
                          eleSum += sumele;
                        } else if (i == 0) {
                          eleSum = output['ele0'];
                        }

                        if (output['ele$i'] < minElev) {
                          minElev = output['ele$i'];
                        }

                        if (output['ele$i'] > maxElev) {
                          maxElev = output['ele$i'];
                          //maxElev = max(output['ele$i'], maxElev);
                        }

                        final dystString = dyst.toStringAsFixed(2);
                        double dystDouble = double.parse(dystString);
                        daneDisEle.add(Wykres(dystDouble, output['ele$i']));

                        i = i + 1;
                      }
                      aveDistance = dyst / hour;
                      aveElevation = eleSum / i;
                      check = false;
                    }
                    return SfCartesianChart(
                        primaryXAxis: CategoryAxis(minimum: 0),
                        primaryYAxis: NumericAxis(
                          minimum: minElev - 5,
                          maximum: maxElev + 5,
                        ),
                        series: <LineSeries<Wykres, double>>[
                          LineSeries<Wykres, double>(
                              markerSettings:
                                  const MarkerSettings(isVisible: false),
                              name: 'Elevation',
                              dataSource: daneDisEle,
                              xValueMapper: (Wykres wysokosc, _) =>
                                  wysokosc.droga,
                              yValueMapper: (Wykres wysokosc, _) =>
                                  wysokosc.wysokosc)
                        ]);
                  }

                  return Center(child: CircularProgressIndicator());
                },
              ),
              Center(
                  child: Column(children: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.lightBlue,
                        shape: StadiumBorder()),
                    onPressed: () {
                      // if (isWalking && seconds != 0) {
                      //   _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
                      //   isWalking = false;

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MapSample(
                                  //elevationList: elevationList,
                                  //distanceList: distanceList,
                                  //timer: timer,
                                  //seconds: seconds,
                                  )));
                      //}
                    },
                    child: const Text(
                      'Wyświetl mape',
                      style: TextStyle(color: Colors.white),
                    ))
              ]))
            ]));
  }
}

class Wykres {
  Wykres(this.droga, this.wysokosc);
  final double? droga;
  final int? wysokosc;
}
