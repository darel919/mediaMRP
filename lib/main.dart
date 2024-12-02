import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_redux/flutter_redux.dart'; 
import 'store.dart';

Future main() async {
  await dotenv.load(fileName: ".env");

  runApp(
    StoreProvider( 
      store: store, 
      child: MyApp(), 
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return fluent.FluentApp(
      home: fluent.NavigationView(
        appBar: fluent.NavigationAppBar(
          title: const Text("MediaMRP"),
        ),
        pane: fluent.NavigationPane(
          displayMode: fluent.PaneDisplayMode.minimal,
          items: [
            fluent.PaneItem(
              icon: const fluent.Icon(fluent.FluentIcons.home),
              title: const Text("Home"),
              body: const HomeScreen(),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedItem = '';

  @override
  Widget build(BuildContext context) {
    return fluent.ScaffoldPage(
      content: Column(
        children: [
          const Text(
            "Welcome, Guest",
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          Expanded(child: NewestContent(selectedItem: selectedItem, onSelect: (item) {
            setState(() {
              selectedItem = item;
            });
          })),
        ],
      ),
    );
  }
}

class NewestContent extends StatefulWidget {
  final String selectedItem;
  final Function(String) onSelect;

  const NewestContent({required this.selectedItem, required this.onSelect, super.key});

  @override
  _NewestContentState createState() => _NewestContentState();
}

class _NewestContentState extends State<NewestContent> {
  late Future<List<dynamic>> _musicList;

  @override
  void initState() {
    super.initState();
    _musicList = fetchMusicList();
  }

  Future<List<dynamic>> fetchMusicList() async {
    String? backendUrl = kDebugMode ? dotenv.env['BE_LOCAL_URL'] : dotenv.env['BE_URL'];
    final response = await http.get(Uri.parse('$backendUrl/music'));
    List<dynamic> newestResponse = [];
    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      newestResponse = jsonData;
      return newestResponse;
    } else {
      throw Exception('Failed to load music');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _musicList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: fluent.ProgressRing());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No music available'));
        } else {
          final items = snapshot.data!;
          return fluent.ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return fluent.ListTile.selectable(
                leading: SizedBox(
                height: 100,
                child: AspectRatio(
                  aspectRatio: 1 / 1,
                  child: Image.network(item['imgThumbUrl'] ?? "")
                ),
              ),
                title: Text(item['Name']),
                subtitle: Text(item['AlbumArtist'] ?? 'Unknown artist'),  // Example usage of another field
                selectionMode: fluent.ListTileSelectionMode.single,
                selected: widget.selectedItem == item['Name'],
                onSelectionChange: (v) => {
                  widget.onSelect(item['Id']),
                  print(item['Id'])
                  },
              );
            },
          );
        }
      },
    );
  }
}
