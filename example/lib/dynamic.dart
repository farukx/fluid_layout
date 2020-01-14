import 'dart:async';
import 'dart:convert';
import 'package:fluid_layout/fluid_layout.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'custom_card.dart';


Future<List<Photo>> fetchPhotos(http.Client client) async {
  final response =
      await client.get('https://jsonplaceholder.typicode.com/posts');

  // Use the compute function to run parsePhotos in a separate isolate.
  return compute(parsePhotos, response.body);
}

// A function that converts a response body into a List<Photo>.
List<Photo> parsePhotos(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Photo>((json) => Photo.fromJson(json)).toList();
}

class Photo {
  final int userId;
  final int id;
  final String title;
  final String url;
  final String body;

  Photo({this.userId, this.id, this.title, this.url, this.body});

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      userId: json['userId'] as int,
      id: json['id'] as int,
      title: json['title'] as String,
      url: json['url'] as String,
      body: json['body'] as String,
    );
  }
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'Isolate Demo';

    return MaterialApp(
      title: appTitle,
      home: MyHomePage(title: appTitle),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;

  MyHomePage({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: FutureBuilder<List<Photo>>(
        future: fetchPhotos(http.Client()),
        builder: (context, snapshot) {
          if (snapshot.hasError) print(snapshot.error);

          return snapshot.hasData
              ? PhotosList(photos: snapshot.data)
              : Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class PhotosList extends StatelessWidget {
  final List<Photo> photos;

  PhotosList({Key key, this.photos}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FluidLayout(
          child: Builder(
            builder: (context) => SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: FluidLayout.of(context).horizontalPadding),
                        child:FluidGridView(
                          shrinkWrap: true, 
           children: photos.map((spacecraft)=>
             FluidCell.withFluidHeight(
                          size: context.fluid(3, m: 3, s: 4, xs: 6),
                          heightSize: context.fluid(3, m: 3, s: 4, xs: 6),
                          child: CustomCard(
                            color: Colors.red,
                            child: Center(child: Text( spacecraft.title)),
                          ))
           ).toList(),
        ),
              ),
            ),
          ),
        )
     );
   
  
  }
}
