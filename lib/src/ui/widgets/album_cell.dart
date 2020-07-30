import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pictora/src/model/album.dart';
 
class AlbumCell extends StatelessWidget {
  const AlbumCell(this.album, this.isOnlineAlbum):assert(album != null);
 
  @required
  final Album album;
  @required
  final bool isOnlineAlbum;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(0.0),
        child: Container(
          child: this.isOnlineAlbum 
          ? Image.network(album.url, fit: BoxFit.cover,)
          : Image.file(File(album.url), fit: BoxFit.cover,),
        ),
      ),
    );
  }
}