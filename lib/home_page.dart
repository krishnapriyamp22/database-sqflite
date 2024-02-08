// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, use_key_in_widget_constructors, avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'database_helper.dart';
import 'detail.dart';
import 'input.dart';
import 'dart:io';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final dbHelper = DatabaseHelper();
  File? _selectedImage;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController parentController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  bool isGridView = true;

  void toggleView() {
    setState(() {
      isGridView = !isGridView;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Student Details'), actions: [
        IconButton(
          onPressed: () {
            setState(() {});
          },
          icon: Icon(Icons.refresh),
        ),
        IconButton(
            onPressed: toggleView,
            icon: Icon(isGridView ? Icons.list : Icons.grid_on))
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => InputPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: (query) {
                setState(() {});
              },
              decoration: InputDecoration(
                labelText: 'Search Students',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    // Clear the search field
                    searchController.clear();
                    setState(() {});
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: dbHelper.searchAll(searchController.text),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final data = snapshot.data!;
                if (isGridView == true) {
                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () {
                          showtData(data[index], context);
                        },
                        leading: CircleAvatar(
                          backgroundImage: data[index]['imagePath'] != null
                              ? FileImage(File(data[index]['imagePath']))
                              : null,
                        ),
                        title: Text(data[index]['name']),
                        subtitle: Text('Age: ${data[index]['age']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _editData(data[index], context);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                _showDeleteDialog(data[index]['id'], context);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  return GridView.builder(
                    itemCount: data.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, childAspectRatio: 1 / 1.9),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: InkWell(
                          onDoubleTap: () {
                            _editData(data[index], context);
                          },
                          onTap: () {
                            showtData(data[index], context);
                          },
                          child: Container(
                              child: Column(
                            children: [
                              Image.file(File(data[index]['imagePath'])),
                              Text(data[index]['name']),
                              Text('Age: ${data[index]['age']}')
                            ],
                          )),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(int id, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Data'),
          content: const Text('Are you sure you want to delete this data?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                _deleteData(id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteData(int id) {
    //dtdta mthd id para
    dbHelper.delete(id).then((rowsDeleted) {
      if (rowsDeleted > 0) {
        setState(() {
          // Reload data after deletion
        });
      }
    });
  }

  void _editData(Map<String, dynamic> data, BuildContext context) {
    nameController.text = data['name'];
    ageController.text = data['age'].toString();
    addressController.text = data['address'];
    parentController.text = data['parent'];
    _selectedImage = File(data['imagePath']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Data'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Age'),
              ),
              TextField(
                controller: addressController,
                decoration: InputDecoration(labelText: 'Address'),
              ),
              TextField(
                controller: parentController,
                decoration: InputDecoration(labelText: 'parent'),
              ),
              Row(children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        border: Border.all(width: 2, color: Colors.deepOrange),
                      ),
                      child: _selectedImage != null
                          ? Image.file(_selectedImage!, fit: BoxFit.cover)
                          : Center(
                              child: Text(
                              'Image not selected',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ))),
                ),
                Column(children: [
                  IconButton(
                      onPressed: () {
                        _pickImage();
                      },
                      icon: Icon(Icons.photo)),
                  IconButton(
                      onPressed: () {
                        _photoImage();
                      },
                      icon: Icon(Icons.camera))
                ])
              ]),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                updateData(data['id']);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void updateData(int id) {
    final name = nameController.text;
    final age = int.tryParse(ageController.text) ?? 0;
    final address = addressController.text;
    final parent = parentController.text;
    final imagepath = _selectedImage!.path;

    if (name.isNotEmpty && age > 0) {
      final row = {
        'id': id,
        'name': name,
        'age': age,
        'address': address,
        'parent': parent,
        'imagepath': imagepath
      };
      dbHelper.update(row).then((rowsUpdated) {
        if (rowsUpdated > 0) {
          setState(() {
            nameController.clear();
            ageController.clear();
            addressController.clear();
            parentController.clear();
          });
        }
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _photoImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  void showtData(Map<String, dynamic> data, BuildContext context) {
    var name = data['name'];
    var age = data['age'];
    var address = data['address'];
    var parent = data['parent'];
    var imagePath = data['imagePath'];

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetailsPage(
          name: name,
          age: age,
          address: address,
          parent: parent,
          imagePath: imagePath,
        ),
      ),
    );
  }
}
