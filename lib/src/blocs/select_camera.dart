import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';
import 'package:pictora/src/blocs/bloc.dart';


class SelctCameraBloc extends Bloc{
  final _controller = PublishSubject<CameraDescription >();

  Stream<CameraDescription> get getCamera => _controller.stream;

  fetchCamera() async {
    WidgetsFlutterBinding.ensureInitialized();
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _controller.sink.add(firstCamera);
  }

  dispose() {
    _controller.close();
  }
}

final cameraBloc = SelctCameraBloc();
