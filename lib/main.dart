import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'debouce_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Debounce Provider for Autocomplete',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Debounce Provider for Autocomplete'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DebounceProvider _debounceProvider =
      DebounceProvider(const Duration(milliseconds: 300));

  @override
  void dispose() {
    super.dispose();

    // IMPORTANT
    _debounceProvider.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'This example searches universities in hipolabs.com after 300ms.\n\nStart typing: Unit... or Eur... or Bra...',
            ),
            Autocomplete<String>(
              optionsMaxHeight: 300,
              optionsBuilder: (textEditingValue) async {
                return _debounceProvider.debounce(
                  () => _doSearch(textEditingValue.text),
                );
              },
              onSelected: (p) {
                debugPrint(p);
              },
            ),
            const Text(
              '*Note that hipolabs.com api searches string in any part of name.',
            ),
          ],
        ),
      ),
    );
  }

  Future<Iterable<String>> _doSearch(String searchValue) async {
    if (searchValue.isEmpty) return [];
    try {
      debugPrint('call $searchValue');

      var result = await http.get(Uri.parse(
          "http://universities.hipolabs.com/search?name=$searchValue"));

      var map = jsonDecode(result.body);

      return (map as List).map<String>((item) => item['name']);
    } catch (e) {
      debugPrint(e.toString());
      return ["Error on call"];
    }
  }
}
