import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import 'main.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isWorking = false;
  String result = '';
  CameraController? cameraController;
  CameraImage? cameraImage;
  late Interpreter interpreter;


  // Initialize Camera
  initCamera() {
    cameraController = CameraController(
      cameras![0],
      ResolutionPreset.medium,
      enableAudio: false,
    );
    cameraController!.initialize().then((value) {
      if (!mounted) {
        return;
      }

      setState(() {
        cameraController!.startImageStream((imageFromStream) {
          if (!isWorking) {
            isWorking = true;
            cameraImage = imageFromStream;
            runModelOnStreamFrames();
          }
        });
      });
    });
  }

  // Load the model using the new interpreter
  loadModel() async {
    interpreter = await Interpreter.fromAsset('assets/model_unquant.tflite');
  }

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  @override
  void dispose() async {
    super.dispose();
    interpreter.close(); // Close the interpreter when done
    cameraController?.dispose();
  }

  // Run the model on camera stream frames
  runModelOnStreamFrames() async {
    var inputImage = cameraImage!;
    // Convert the image to a format suitable for the model
    var input = await imageToByteList(inputImage);

    var output = List.filled(2, 0); // Number of results expected

    // Run the model
    interpreter.run(input, output);

    result = '';
    
    // Process the results
    for (var i = 0; i < output.length; i++) {
      result +=
          'Label: ${output[i]} Confidence: ${output[i].toStringAsFixed(2)}\n';
    }

    setState(() {
      result;
    });

    isWorking = false;
  }

  // Function to convert image to byte list for the model
  Future<List<int>> imageToByteList(CameraImage image) async {
    // Example transformation, modify based on your model input
    List<int> byteList = [];
    // Process image data here
    return byteList;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('PH Currency Identifier'),
          backgroundColor: Colors.yellowAccent,
          centerTitle: true,
        ),
        body: Container(
          child: Column(
            children: [
              Stack(
                children: [
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(top: 100),
                      height: 220,
                      width: 320,
                    ),
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        initCamera();
                      },
                      child: Container(
                        margin: EdgeInsets.only(top: 65),
                        height: 270,
                        width: 360,
                        child:
                            cameraImage == null
                                ? SizedBox(
                                  height: 270,
                                  width: 360,
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: Colors.black,
                                    size: 50,
                                  ),
                                )
                                : AspectRatio(
                                  aspectRatio:
                                      cameraController!.value.aspectRatio,
                                  child: CameraPreview(cameraController!),
                                ),
                      ),
                    ),
                  ),
                ],
              ),
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 55),
                  child: SingleChildScrollView(
                    child: Text(
                      result,
                      style: TextStyle(
                        backgroundColor: Colors.black,
                        fontSize: 25,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
