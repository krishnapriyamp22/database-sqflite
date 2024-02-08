

// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors, prefer_const_constructors

import 'package:datastudent_dart/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class InputPage extends StatefulWidget {
  @override
  _InputPageState createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  File? _selectedImage;
  final dbHelper = DatabaseHelper();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController parentController =TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Entry📝'),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
              onPressed: () {
                _insertData(context);
              },
              icon: Icon(Icons.save))
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: validateName,
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: validateAge,
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Age'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: validateAddress,
                controller: addressController,
                decoration: InputDecoration(labelText: 'Address'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: validateParent,
                controller: parentController,
                decoration: InputDecoration(labelText: 'parent'),
              ),
            ),
            Row(children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 2, color: const Color.fromARGB(255, 34, 86, 255)),
                  ),
                  child: _selectedImage != null
                      ? Image.file(_selectedImage!, fit: BoxFit.cover)
                      : Center(
                          child: Text(
                            'Image not selected',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          )),
                ),
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
      ),
    );
  }

  void _insertData(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      final name = nameController.text;
      final age = int.tryParse(ageController.text) ?? 0;
      final address = addressController.text;
      final parent =parentController.text;

      if (name.isNotEmpty &&
          age > 0 &&
          address.isNotEmpty &&parent.isNotEmpty&&
          _selectedImage != null) {
        final imageFileName =
            'student_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final imageFile =
            File('${(await getTemporaryDirectory()).path}/$imageFileName');
        await _selectedImage!.copy(imageFile.path);

        final row = {
          'name': name,
          'age': age,
          'address': address,
          'parent':parent,
          'imagePath': imageFile.path,
        };
        dbHelper.insert(row).then((id) {
          setState(() {
            nameController.clear();
            ageController.clear();
            addressController.clear();
            parentController.clear();
            _selectedImage = null;
          });
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Include an Image'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(10),
          duration: Duration(seconds: 2),
        ));
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }else{
    
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

  // Validate email
  String? validateAddress(String? value) {
    final trimmedValue = value?.trim();

    if (trimmedValue == null || trimmedValue.isEmpty) {
      return 'Enter address';
    }
    return null;
  }
  String? validateParent(String? value) {
    final trimmedValue = value?.trim();

    if (trimmedValue == null || trimmedValue.isEmpty) {
      return 'Enter parent name';
    }
    return null;
  }


  // Validate age
  String? validateAge(String? value) {
    final trimmedValue = value?.trim();

    if (trimmedValue == null || trimmedValue.isEmpty) {
      return 'Enter your Age';
    }

    final RegExp ageRegExp = RegExp(r'^[0-9]+$');

    if (!ageRegExp.hasMatch(trimmedValue)) {
      return 'Enter a valid Age';
    }
    return null;
  }

  // Validate name
  String? validateName(String? value) {
    final trimmedValue = value?.trim();

    if (trimmedValue == null || trimmedValue.isEmpty) {
      return 'Enter name';
    }
    return null;
  }
}
