import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart'as http;
import 'dart:async';
import 'dart:convert';

import 'package:pictora/src/model/album.dart';
import 'package:pictora/src/repository/api.dart';

class ApiProvider{
  Api api = Api();

  Future<int> uploadPhotos(Album album) async {
    try {
      final response = await http.post(api.baseUrl + api.uploadPhotosUrl, body: album);
      if (200 == response.statusCode) {
        Fluttertoast.showToast(msg: "Image is uploaded on the server.");
        return 1;
      } else {
        Fluttertoast.showToast(msg: "Image uploade fail.");
      }
    } catch (e) {
        Fluttertoast.showToast(msg: "Image uploade fail.");
    }
    return 0;
  }
 
  Future<List<Album>> getPhotos() async {
    List<Album> albums = [];
    try {
      final response = await http.get(api.baseUrl + api.getPhotosUrl);
      if (200 == response.statusCode) {
        albums = parsePhotos(response.body);
        return albums;
      } else {
        return albums;
      }
    } catch (e) {
      return albums;
    }
  }
 
  static List<Album> parsePhotos(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    List<Album> albums =
        parsed.map<Album>((json) => Album.fromJson(json)).toList();
    List<Album> a = [];
    a.addAll(albums);
    return a;
  }
}