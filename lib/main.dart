import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Test Download',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Image Test Download'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String imageUrl =
      'https://show-up-dev.s3.amazonaws.com/files/company/082b91a6-4cbc-4e3a-8c7a-59a7002bf2b6/event/fe5afe41-01fb-495b-b2d3-9662bc2e2ab0/static/google-bg.png';
  final String fileImageName = 'imagem_app';
  late String localImagePath;

  late Future<void> downloadFuture;

  Future<void> downloadAndSaveImage() async {
    try {
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        final temporaryDirectory = await getTemporaryDirectory();
        final String fullPath = '${temporaryDirectory.path}/$fileImageName';

        final File file = File(fullPath);
        await file.writeAsBytes(response.bodyBytes);

        setState(() {
          localImagePath = fullPath;
        });

        debugPrint('Imagem baixada e salva em: $fullPath');
      } else {
        debugPrint('Erro ao baixar a imagem: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro ao baixar e salvar a imagem: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    downloadFuture = downloadAndSaveImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: FutureBuilder(
        future: downloadFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Erro'));
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 1.2,
                child: Image.file(
                  File(localImagePath),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
