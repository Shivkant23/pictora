import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'package:pictora/src/ui/display_image_screen.dart';
import 'package:pictora/src/blocs/select_camera.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  bool waitingFlag = true;

  @override
  void initState() {
    startCamera();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    cameraBloc.fetchCamera();
  }

  startCamera()async{
    // WidgetsFlutterBinding.ensureInitialized();
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _controller = CameraController(firstCamera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
    setState(() {
      waitingFlag = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("PICTORA")),
      floatingActionButton: floatingButton(),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  floatingButton(){
    return FloatingActionButton(
      child: Icon(Icons.camera_alt),
      onPressed: () async {
        try {
          await _initializeControllerFuture;
          final path = join((await getTemporaryDirectory()).path,'${DateTime.now()}.png',);
          await _controller.takePicture(path);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DisplayPictureScreen(imagePath: path),
            ),
          );
        } catch (e) {
          print(e);
        }
      },
    );
  }
}