import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CrudApp extends StatefulWidget {
  const CrudApp({super.key});

  @override
  State<CrudApp> createState() => _CrudAppState();
}

class _CrudAppState extends State<CrudApp> {
  String baseUrl = "https://api.nstack.in/v1/todos";
  List data = [];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _updatedTitleController = TextEditingController();
  final TextEditingController _updatedDescriptionController = TextEditingController();

  Future<void> _createdata(String title, String description) async {
    final response = await http.post(Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "title": title,
          "description": description,
          "is_completed": false
        }));
    if (response.statusCode == 201) {
      _titleController.clear();
      _descriptionController.clear();
      _fetchdata();
    }
  }

  Future<void> _fetchdata() async {
    final response = await http.get(Uri.parse(baseUrl));
    final json = jsonDecode(response.body);
    setState(() {
      data = json['items'];
    });
  }

  Future<void> _updatedata(String id, String title, String description) async {
    final response = await http.put(Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "title": title,
          "description": description,
          "is_completed": false
        }));
    if (response.statusCode == 200) {
      Navigator.pop(context);
      _fetchdata();
    }
  }

  Future<void> _deletedata(String id) async {
    await http.delete(Uri.parse('$baseUrl/$id'));
    _fetchdata();
  }

  @override
  void initState() {
    _fetchdata();
    super.initState();
  }

  void _showUpdateDialog(String id, String title, String description) {
    _updatedTitleController.text = title;
    _updatedDescriptionController.text = description;

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Update Todo"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _updatedTitleController,
                  decoration: const InputDecoration(
                    labelText: "Title",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _updatedDescriptionController,
                  decoration: const InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel")),
              ElevatedButton(
                  onPressed: () => _updatedata(
                      id, _updatedTitleController.text, _updatedDescriptionController.text),
                  child: const Text("Update"))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: const Text("Todo App", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchdata,
                child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (_, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 3,
                      child: ListTile(
                        title: Text(
                          data[index]['title'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Text(data[index]['description']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                onPressed: () => _showUpdateDialog(
                                    data[index]['_id'],
                                    data[index]['title'],
                                    data[index]['description']),
                                icon: const Icon(Icons.edit, color: Colors.blue)),
                            IconButton(
                                onPressed: () => _deletedata(data[index]['_id']),
                                icon: const Icon(Icons.delete, color: Colors.red))
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Add New Todo"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: "Title",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: "Description",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel")),
                    ElevatedButton(
                        onPressed: () => _createdata(
                            _titleController.text, _descriptionController.text),
                        child: const Text("Add"))
                  ],
                );
              });
        },
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
}
