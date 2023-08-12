import 'package:syncfusion_flutter_charts/charts.dart';

wykresDisEle(daneDisEle) {
  return SfCartesianChart(
      enableAxisAnimation: true,
      //zoomPanBehavior: _zoomPanBehavior,
      // Initialize category axis
      primaryXAxis: CategoryAxis(
          //edgeLabelPlacement: EdgeLabelPlacement.shift
          ),
      series: <LineSeries<Wykres, double>>[
        LineSeries<Wykres, double>(
            markerSettings: const MarkerSettings(isVisible: false),
            name: 'Chart Distance Elements',
            dataSource: daneDisEle,
            xValueMapper: (Wykres wysokosc, _) => wysokosc.droga,
            yValueMapper: (Wykres wysokosc, _) => wysokosc.wysokosc)
      ]);
}

class Wykres {
  Wykres(this.droga, this.wysokosc);
  final double? droga;
  final int? wysokosc;
}
