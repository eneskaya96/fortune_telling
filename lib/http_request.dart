import 'dart:convert';

import 'package:http/http.dart' as http;

String base_url = 'http://localhost:5005/api';

Future<String> send_request(body, endPoint,  isPost) async {
  final http.Response response;
  String url = base_url + endPoint;

  if(isPost){
    response = await http.post(Uri.parse(url),body: body);
  }
  else {
    response = await http.get(Uri.parse(url),);
  }

  if (response.statusCode == 200) { return response.body;}
  else {throw Exception('Failed HTTP REQUEST');}
}


Future<String> get_fortune(email, password) async {
  var body = jsonEncode({ 'email': email,
                          'password': password} );
  return send_request(body, '/login', true);
}
