import 'package:pictora/src/model/album.dart';
import 'package:pictora/src/repository/repository.dart';
import 'package:rxdart/rxdart.dart';
import 'package:pictora/src/blocs/bloc.dart';


class PhotosBloc{
  final _repository = Repository();
  final _controller = PublishSubject<List<Album>>();

  Stream<List<Album>> get getPhotos => _controller.stream;

  fetchAllPhotos() async {
    List<Album> itemModel = await _repository.getPhotos();
    _controller.sink.add(itemModel);
  }

  dispose() {
    _controller.close();
  }
}

final photosListBloc = PhotosBloc();
