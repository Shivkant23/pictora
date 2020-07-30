

import 'package:pictora/src/model/album.dart';
import 'package:pictora/src/repository/api_provider.dart';

class Repository{
  final apiProvider =  ApiProvider();
  
  Future<int> uploadPhotos(Album album) => apiProvider.uploadPhotos(album);

  Future<List<Album>> getPhotos() => apiProvider.getPhotos();
}