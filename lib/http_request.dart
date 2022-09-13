import 'dart:convert';

import 'package:http/http.dart' as http;

String base_url = 'http://localhost:8000/fortune_teller/v1/';

Future<String> send_get_request(endPoint) async {
  final http.Response response;
  String url = base_url + endPoint;
  response = await http.get(Uri.parse(url),);

  /*
  if(isPost){
    response = await http.post(Uri.parse(url),body: body);
  }
  else {
    response = await http.get(Uri.parse(url),);
  }
  */
  if (response.statusCode == 200) {
    print(response.body);
    return response.body;
  }
  else {
    throw Exception('Failed HTTP REQUEST');
  }
}


Future<String> get_fortune_() async {
  String url = '/fortune';
  return send_get_request(url);
}
