import 'dart:io';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:pictora/src/db/database_helper.dart';
import 'package:pictora/src/model/album.dart';

import 'package:flutter_offline/flutter_offline.dart';
import 'package:pictora/src/repository/repository.dart';
import 'package:pictora/src/ui/grid_screen.dart';



class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;
  const DisplayPictureScreen({Key key, this.imagePath}) : super(key: key);

  @override
  _DisplayPictureScreenState createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  DatabaseHelper helper = DatabaseHelper();
  Repository repository = Repository();
  bool _visible = true;
  bool connected = false;
  bool isLoading = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hideBar();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Display the Picture'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.pages), 
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GridViewPage(isConnected: connected,)),
              );
            }
          ),
          IconButton(
            icon: Icon(Icons.cloud_upload), 
            onPressed: (){
              saveInformationToLocal();
            }
          ),
        ],
      ),
      body: isLoading ? Center(child: CircularProgressIndicator(),) : _body(),
    );
  }

  _body(){
    return Builder(
      builder: (BuildContext context) {
        return OfflineBuilder(
          connectivityBuilder: (BuildContext context, ConnectivityResult connectivity, Widget child) {
            connected = connectivity != ConnectivityResult.none;
            checkForSync(connected);
            return Stack(
              fit: StackFit.expand,
              children: [
                child,
                Visibility(
                  visible: _visible,
                  child: Positioned(
                    left: 0.0,
                    right: 0.0,
                    height: 30.0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      color: connected ? Color(0xFF00EE44) : Color(0xFFEE4400),
                      child: connected
                      ?  Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text("ONLINE",style: TextStyle(color: Colors.white),),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text("OFFLINE",style: TextStyle(color: Colors.white),),
                            SizedBox(width: 8.0),
                            SizedBox(
                              width: 12.0,
                              height: 12.0,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                valueColor:AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          ],
                        ),
                    ),
                  ),
                ),
              ],
            );
          },
          child: Image.file(File(widget.imagePath)),
        );
      }
    );
  }

  Future<bool> checkNetworkconnection()async{
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      return true;
    }else {
      return false;
    }
  }

  saveInformationToLocal()async{
    bool isConnected = await checkNetworkconnection();
    print(isConnected);
    setState(() {
      isLoading = true;
    });
    if(isConnected){
      Album album = new Album(url: widget.imagePath, status: "ONLINE");
      bool isUploaded = await _startUpload(album);
      // int result1 = await repository.uploadPhotos(album);
      print("_startUpload"+"$isUploaded");
      if(isUploaded){
        int result2 = await helper.insertImageData(album);
        print("insertImageData"+"$result2");
        if( result2 != 0){
          Fluttertoast.showToast(msg: "Image is uploaded on the server and local.");
        }else {
          Fluttertoast.showToast(msg: "Image uploade fail on local.");
        }
      }else {
        Fluttertoast.showToast(msg: "Image uploade fail on server.");
      }
    }else {
      Album album = new Album(url: widget.imagePath, status: "OFFLINE");
      int result1 = await helper.insertImageData(album);
      print("insertImageData"+"$result1");
      if(result1 != 0){
        Fluttertoast.showToast(msg: "Image is uploaded on local storage.");
      }else {
        Fluttertoast.showToast(msg: "Image uploade fail on local storage.");
      }
      helper.getCount();
    }
    setState(() {
      isLoading = false;
    });
  }

  checkForSync(bool connected)async{
    if(connected){
      List<Album> result = await helper.getAlbumsNotSyncServer();
      print(result);
      if(result.isNotEmpty){
          for(Album album in result){
          bool isUploaded = await _startUpload(album);
          print("_startUpload"+"$isUploaded");
          if(isUploaded){
            int result = await helper.updateImageData(new Album(id: album.id, status: "ONLINE", url: album.url));
            print("${album.id} is umpated $result");
          }else {
            Fluttertoast.showToast(msg: "Image uploade fail.");
          }
        }
        Fluttertoast.showToast(msg: "Offline Images are uploaded on the server.");
      }
    }
  }

  _hideBar() {
    Timer(Duration(seconds: 3), () {
      setState(() {
        _visible = false;
      });
    });
  }

  Future<bool> _startUpload(Album album)async{
    bool reFlag = false;
    try {
      FirebaseStorage _storage = FirebaseStorage(storageBucket: 'gs://firestore-demo-shiv.appspot.com');
      String filePath = "images/${DateTime.now()}.png";
      StorageReference storageReference = _storage.ref().child(filePath);
       StorageUploadTask _uploadTask = storageReference.putFile(File(album.url));
      // storageReference.putFile(File(album.url));
      await _uploadTask.onComplete;
      reFlag = await _addPathToDatabase(filePath);
      print("reFlag $reFlag");
      return reFlag;
    
      // Get image URL from firebase
      // final ref = FirebaseStorage().ref().child(filePath);
      // var imageString = await ref.getDownloadURL();
      // // Add location and url to database
      // await Firestore.instance.collection('storage').document().setData({'url':imageString , 'location':filePath});
    }catch(e){
      Fluttertoast.showToast(msg: "Image uploade fail on server.");
      print(e.message);
    }
    return reFlag;
  }

  Future<bool> _addPathToDatabase(String text) async {
    try {
      // Get image URL from firebase
      final ref = FirebaseStorage().ref().child(text);
      var imageString = await ref.getDownloadURL();

      // Add location and url to database
      await Firestore.instance.collection('storage').document().setData({'url':imageString , 'location':text});
    }catch(e){
      print(e.message);
      Fluttertoast.showToast(msg: "Image uploade fail on server.");
      return false;
    }
    return true;
  }

  // void _startDownload()async{
  //   // FirebaseStorage _storage = FirebaseStorage(storageBucket: 'gs://firestore-demo-shiv.appspot.com');
  //   // var asd;
  //   // String filePath = "images/${DateTime.now()}.png";
  //   // StorageReference storageReference = _storage.ref() ;
  //   // storageReference.child("2020-07-12 19:43:15.433388.png").getData(5).then((value){
  //   //   setState(() {
  //   //     asd = value;
  //   //   });
  //   //   print(asd);
  //   // }).catchError((onError){
  //   //   print("This is error reason:- "+onError);
  //   // });

  //   StorageReference ref = FirebaseStorage.instance.ref().child("images/"+"2020-07-12 20:17:06.677136.png");
  //   String url = (await ref.getDownloadURL()).toString();
  //   print(url);

    
  // }
}