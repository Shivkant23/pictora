import 'package:pictora/src/model/album.dart';
import 'package:pictora/src/repository/repository.dart';
import 'package:rxdart/rxdart.dart';
import 'package:pictora/src/blocs/bloc.dart';


class UploadBloc{
  final _repository = Repository();
  final _controller = PublishSubject<int>();

  Stream<int> get getSuccessNum => _controller.stream;

  uploadPhoto(Album album) async {
    int item = await _repository.uploadPhotos(album);
    _controller.sink.add(item);
  }

  dispose() {
    _controller.close();
  }
}

final uploadPhotosBloc = UploadBloc();
