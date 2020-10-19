import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: TfLiteHome(),
      )
  );
}

class TfLiteHome extends StatefulWidget {
  @override
  _TfLiteHomeState createState() => _TfLiteHomeState();
}

class _TfLiteHomeState extends State<TfLiteHome> {
  File _image;

  bool busy = false;

  List _recognitions;


  @override
  void initState() {
    super.initState();
    busy = true;
    loadModel().then((val) {
      setState(() {
        busy = false;
      });
    });
  }

  loadModel() async {
      try {
        await Tflite.loadModel(
            model: 'assets/tflite/model_unquant.tflite',
            labels: 'assets/tflite/labels.txt'
        );
      } on Exception catch (e) {
        print("couldn't load model");
      }
  }

  classifyImage(image) async{
    if(image==null)return;

    await customModel(image);

    setState(() {
      _image = image;
      busy = false;
    });
  }

  selectFromImagePicker() async{
    final picker = ImagePicker();
    var image = await picker.getImage(source: ImageSource.gallery);
    if(image == null)return;
    setState(() {
      busy = true;
    });
    //using "image" which is "picked file" and making it into "file" in "_image"
    File _image = File(image.path);
    classifyImage(_image);
  }



  customModel(image) async{
    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
      numResults: 2,
    );
    setState(() {
      _recognitions = recognitions;
    });
  }



  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text('Dog Breed Classification'),
          centerTitle: true,
          backgroundColor: Colors.blue[800],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.image),
          tooltip: 'pick image from gallery',
          onPressed: selectFromImagePicker,
        ),
        body: busy
            ? Container(
          alignment: Alignment.center,
          child: CircularProgressIndicator(),
        )
            : Container(

          width: size.width,
          height: size.height - 30.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _image == null ? Container() : Image.file(_image),
              SizedBox(
                height: 10.0,
              ),
              _recognitions != null
                  ? Text(
                "${_recognitions[0]["label"]}",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                  background: Paint()..color = Colors.white,
                ),
              )
                  : Container()
            ],
          ),

        )
    );
  }

}
