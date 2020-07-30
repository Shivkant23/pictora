import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pictora/src/db/database_helper.dart';
import 'package:pictora/src/model/album.dart';
import 'package:pictora/src/repository/repository.dart';
import 'package:pictora/src/ui/widgets/album_cell.dart';

class GridViewPage extends StatefulWidget {
  bool isConnected;
  GridViewPage({this.isConnected}) : super();

  @override
  GridViewPageState createState() => GridViewPageState();
}

class GridViewPageState extends State<GridViewPage> {
  DatabaseHelper dbHelper;
  Repository repository;
  bool isLoading = true;
  List<Album> albums = [];

  @override
  void initState() {
    super.initState();
    dbHelper = DatabaseHelper();
    repository = Repository();
    getFromLocalStorage(widget.isConnected);
  }

  getFromLocalStorage(bool isConnected)async{
    if(isConnected){
      setState(() {
        isLoading = false;
      });
      // fetch photos from online server
    }else{
      List<Album> result1 = await dbHelper.getAlbums();
      setState(() {
        albums=result1;
        isLoading = false;
      });
      print(result1);
    }
    // List<Album> result2 = await dbHelper.getAlbumsNotSyncServer();
    // print(result2);
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Photos"),
      ),
      body: isLoading  ? Center(child: CircularProgressIndicator(),)
      :
       Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Flexible(
            child: widget.isConnected ? _buildBody(context) : gridview1(albums),
          )
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('storage').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        return _buildList(context, snapshot);
      },
    );
  }

  Widget _buildList(BuildContext context, snapshot) {
    return gridview(snapshot.data.documents);
  }

  gridview(List<DocumentSnapshot> snapshot) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        children: snapshot.map((album) {
          // print(album.data.);
          Album abm = Album(url: album.data['url']);
          return GridTile(
            child: AlbumCell(abm, true),
          );
        }).toList(),
      ),
    );
  }

  gridview1(List<Album> list) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        children: list.map((album) {
          return GridTile(
            child: AlbumCell(album, false),
          );
        }).toList(),
      ),
    );
  }
}