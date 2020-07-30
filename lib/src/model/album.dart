import 'package:pictora/src/db/database_helper.dart';

class Album {
  int id;
  String url;
  String status;

  Album({this.id, this.url, this.status});

  Album.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    url = json['url'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['url'] = this.url;
    data['status'] = this.status;
    return data;
  }
}
