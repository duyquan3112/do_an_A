import 'dart:ffi';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../api/firebase_api.dart';
import '../pages/upLoadVideo.dart';

const List<String> list = <String>['Musics', 'Games', 'Movies'];

class selectAndUploadFiles extends StatefulWidget {
  const selectAndUploadFiles({super.key});

  @override
  State<selectAndUploadFiles> createState() => _selectAndUploadFilesState();
}

class _selectAndUploadFilesState extends State<selectAndUploadFiles> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  UploadTask? task;
  File? file;

  String? urlDownload;

  String dropdownValue = list.first;
  @override
  Widget build(BuildContext context) {
    final fileName = file != null ? basename(file!.path) : 'No File Selected';
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          title(),
          description(),
          TextButton(
            onPressed: () {
              selectFile();
            },
            child: Text('Select Files'),
          ),
          Text(
            fileName,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          DropdownButton<String>(
            value: dropdownValue,
            icon: const Icon(Icons.arrow_downward),
            elevation: 16,
            style: const TextStyle(color: Colors.blue),
            underline: Container(
              height: 2,
              color: Colors.blue,
            ),
            onChanged: (String? value) {
              // This is called when the user selects an item.
              setState(() {
                dropdownValue = value!;
              });
            },
            items: list.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          TextButton(
            onPressed: () async {
              await upLoadFile();
              // pushFile();
              pushData();
            },
            child: Text('UpLoadVideo'),
          ),
          task != null ? buildUploadStatus(task!) : Container(),
          
        ],
      ),
    );
  }

  // build title
  Widget title() => Container(
        margin: EdgeInsets.all(15),
        child: TextField(
          controller: titleController,
          decoration: InputDecoration(
            labelText: 'Title',
            hintText: 'Title',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
        ),
      );

  // build Discription
  Widget description() => Container(
        margin: EdgeInsets.all(15),
        child: TextField(
          controller: descriptionController,
          decoration: InputDecoration(
            labelText: 'Description',
            hintText: 'Description',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
        ),
      );

  Future pushData() async {
    pushFile(titleController.text, descriptionController.text);
  }

  Future pushFile(String title, String description) async {
    await FirebaseFirestore.instance.collection('video_list').add({
      'title': title,
      'description': description,
      'videoUrl': urlDownload,
      // 'type':
    });
  }
  // Sring getTypeVideo(){

  // };
  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result == null) return;
    final path = result.files.single.path!;

    setState(() => file = File(path));
  }

  Future upLoadFile() async {
    if (file == null) return;

    final fileName = basename(file!.path);
    final destination = 'files/$fileName';

    task = FirebaseApi.uploadFile(destination, file!);
    setState(() {});

    if (task == null) return;

    final snapshot = await task!.whenComplete(() {});
    urlDownload = await snapshot.ref.getDownloadURL();

    print('Download-Link: $urlDownload');
  }

  Widget buildUploadStatus(UploadTask task) => StreamBuilder<TaskSnapshot>(
        stream: task.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final snap = snapshot.data!;
            final progress = snap.bytesTransferred / snap.totalBytes;
            final percentage = (progress * 100).toStringAsFixed(2);

            return Text(
              '$percentage %',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            );
          } else {
            return Container();
          }
        },
      );
}