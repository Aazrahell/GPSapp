import 'package:flutter/material.dart';
import 'package:praca/mapa.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text('Praca Inzynierska - Google Maps'),
            centerTitle: true),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text('Homepage'),
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.lightBlue,
                      shape: StadiumBorder()),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => MapSample()));
                  },
                  child: const Text(
                    'Rozpocznij trening',
                    style: TextStyle(color: Colors.white),
                  ))
            ],
          ),
        ));
  }
}
