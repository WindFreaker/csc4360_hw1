import 'package:http/http.dart';
import 'dart:convert';

class WorldTime {

  String location;  // location name for the UI
  late String time;  // the time in the given location
  String flag;  // url to the flag image
  String url;  // location url for API endpoint

  WorldTime({required this.location, required this.flag, required this.url}) {
    getTime();
  }

  Future<void> getTime() async {

    try {

      // make the request to the World Time API
      Response res = await get(Uri.parse('https://worldtimeapi.org/api/timezone/$url'));

      // decode the JSON data
      Map data = json.decode(res.body);

      // get properties from the data
      DateTime now = DateTime.parse(data['datetime']);
      int offset = int.parse(data['utc_offset'].substring(0, 3));

      // add the offset
      now = now.add(Duration(hours: offset));

      // store the time in the proper variable
      time = now.toString();

    } catch (error) {

      print('world_time.dart Error: $error');
      time = 'Could not get time data.';

    }

  }

}