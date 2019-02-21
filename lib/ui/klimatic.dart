import 'dart:convert';

import 'package:flutter/material.dart';
import '../util/utils.dart' as util;
import 'dart:async';
import 'package:http/http.dart' as http;

class Klimatic extends StatefulWidget {
  @override
  _KlimaticState createState() => _KlimaticState();
}

class _KlimaticState extends State<Klimatic> {
  String _cityEntered;
  Future _goToNextScreen(BuildContext context) async{
    Map results = await Navigator.of(context).push(
      new MaterialPageRoute<Map>(
          builder: (BuildContext context) => new ChangeCity())
    );

    if(results != null && results.containsKey('newCity')){
      print(results['newCity'].toString());
      _cityEntered = results['newCity'].toString();
    }else{
      debugPrint('it is empty');
    }
  }
  void populatResponse() async {
    Map _data = await getWeather(util.apiId, util.defaultCity);
    print(_data.toString());
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('224 Méteo'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        actions: <Widget>[
          new IconButton(
              icon: new Icon(Icons.menu),
              onPressed:  () => _goToNextScreen(context),
          )
        ],
      ),

      body: new Stack(
        children: <Widget>[
          new Center(
            child: new Image.asset(
              'images/umbrella.png',
              width: 490.0,
              height: 1200.0,
              fit: BoxFit.fill,
            ),
          ),

          new Container(
            alignment: Alignment.topRight,
            margin: const EdgeInsets.fromLTRB(0.0, 10.9, 20.9, 0.0),
            child: new Text(
              '${_cityEntered == null ? util.defaultCity : _cityEntered}',
              style: cityStyles(),
            ),
          ),

          new Container(
            alignment: Alignment.center,
            child: new Image.asset('images/light_rain.png'),
          ),
          updateTempWidget(_cityEntered),

          /*new Container(
            alignment: Alignment.center,
            child:
          ),*/
        ],
      ),
    );
  }
}
Future<Map> getWeather( String apiId, String city) async{
  String apiUrl = 'http://api.openweathermap.org/data/2.5/weather?q=$city&APPID=$apiId&units=metric';
  http.Response response = await http.get(apiUrl);
  return jsonDecode(response.body);
}

Widget updateTempWidget(String city) {
  return new FutureBuilder(
    future: getWeather(util.apiId, city == null ? util.defaultCity
        : city),
    builder: (BuildContext context, AsyncSnapshot<Map> snapshot){
      if(snapshot.hasData) {
        Map content = snapshot.data;
        return new Container(
          margin: const EdgeInsets.fromLTRB(145.0, 280.0, 0.0, 0.0),
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new ListTile(
                title: new Text('${content['main']['temp'].toString()}°C',
                  style: tempStyles(),
                ),
                subtitle: new ListTile(
                  title: new Text(
                    'Humidity: ${content['main']['humidity'].toString()}%\n'
                    'Min: ${content['main']['temp_min'].toString()}°C\n'
                    'Max: ${content['main']['temp_max'].toString()}°C\n',
                    style: extraTempStyles(),
                  ),
                ),
              )
            ],
          ),
        );
      }else {
        return new Container(

        );
      }
    }
  );
}

class ChangeCity extends StatelessWidget {
  var _cityFieldController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.purple,
        title: new Text('Change City'),
        centerTitle: true,
      ),

      body: new Stack(
        children: <Widget>[
          new Center(
            child:  new Image.asset('images/white_snow.png',
              width: 490.0,
              height: 1200.0,
              fit: BoxFit.fill,
            ),
          ),

          new ListView(
            children: <Widget>[
              new ListTile(
                title: new TextField(
                  decoration: new InputDecoration(
                    hintText: 'Enter City Name',
                  ),
                  controller: _cityFieldController,
                  keyboardType: TextInputType.text,
                ),
              ) ,
              new ListTile(
                title: new FlatButton(
                  onPressed: () => Navigator.pop(context, {
                    'newCity': _cityFieldController.text
                  }),
                  textColor: Colors.white70,
                  color: Colors.purpleAccent,
                  child: new Text('Get Weather')),
              )
            ],
          ),
        ],
      ),
    );
  }
}

TextStyle cityStyles() {
  return new TextStyle(
    color: Colors.white,
    fontSize: 22.9,
    fontWeight: FontWeight.bold,
    fontStyle: FontStyle.italic,
  );
}

TextStyle tempStyles() {
  return new TextStyle(
    color: Colors.white,
    fontSize: 49.9,
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.normal,
  );
}

TextStyle extraTempStyles() {
  return new TextStyle(
    color: Colors.white70,
    fontSize: 14.9,
    fontStyle: FontStyle.normal,
  );
}
