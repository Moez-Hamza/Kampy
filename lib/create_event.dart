import 'dart:io';
import 'dart:async';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/crud.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:random_string/random_string.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateEvent extends StatefulWidget {
  const CreateEvent({Key? key}) : super(key: key);

  @override
  State<CreateEvent> createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEvent> {
  // firebase_storage.FirebaseStorage storage =
  //     firebase_storage.FirebaseStorage.instance;
  // final controller = TextEditingController();
  // TextEditingController? startingDate = TextEditingController();
  // TextEditingController? endingDate = TextEditingController();

  final FirebaseAuth auth = FirebaseAuth.instance;

  DateTime startingDate = DateTime.now();
  DateTime endingDate = DateTime.now();

  String? eventName,
      destination,
      nbrPlace,
      requiredEquipment,
      group,
      description,
      username,
      userImage,
      eventLikes,
      eventUsersList;

  File? _photo;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  CrudMethods crudMethods = new CrudMethods();
  Future imgFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  uploadEvent() async {
    // get current user connected
    final User? user = auth.currentUser;
    final uid = user?.uid;
    //  create firestore instance
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    // grab the collection for the users
    CollectionReference users = firestore.collection('users');

    if (_photo != null) {
      setState(() {
        _isLoading = true;
      });

      FirebaseStorage _storage = FirebaseStorage.instance;
      Reference ref = _storage
          .ref()
          .child("eventImages")
          .child("${randomAlphaNumeric(9)}.jpg");
      UploadTask uploadTask = ref.putFile(_photo!);

      // get docs from user reference
      QuerySnapshot querySnapshot = await users.get();

      for (var i = 0; i < querySnapshot.docs.length; i++) {
        if (querySnapshot.docs[i]['uid'] == uid) {
          username = querySnapshot.docs[i]['name'];
          userImage = querySnapshot.docs[i]['photoUrl'];
        }
      }

      var downloadUrl = await (await uploadTask).ref.getDownloadURL();
      print("this is url $downloadUrl");
      // uploadTask.then((res) {
      //   res.ref.getDownloadURL();
      // });
      Map<String, dynamic>? eventMap = {
        "imgUrl": downloadUrl,
        "eventName": eventName ?? "",
        "destination": destination ?? "",
        "startingDate": startingDate,
        "endingDate": endingDate,
        "nbrPlace": nbrPlace ?? "",
        "requiredEquipment": requiredEquipment ?? "",
        "group": group ?? "",
        "description": description ?? "",
        "username": username ?? "",
        "userImage": userImage ?? "",
        "eventLikes": [],
        "eventUsersList": [],
      };
      crudMethods.addData(eventMap).then((result) {
        Navigator.pop(context);
      });
    } else {}
  }

  //function to pick starting date from calender with showDatePicker()
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: startingDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != startingDate) {
      setState(() {
        startingDate = picked;
        endingDate = picked;
      });
    }
  }

   //function to pick ending date from calender with showDatePicker()
  Future<void> _selectEndingDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: endingDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != endingDate) {
      setState(() {
       
        endingDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(55.0),
        child: AppBar(
          centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [HexColor('#675975'), HexColor('#7b94c4')]),
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text("Add", style: TextStyle(fontSize: 22)),
              Text(" Event",
                  style: TextStyle(fontSize: 22, color: Colors.white))
            ],
          ),
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          //upload data with clicking on the icon.file_upload
          actions: <Widget>[
            GestureDetector(
                onTap: () {
                  uploadEvent();
                },
                child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Icon(Icons.file_upload)))
          ],
        ),
      ),
      body: _isLoading
          ? Container(
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  const SizedBox(
                    height: 10,
                  ),
                  // create input for selecting an image from gallery
                  GestureDetector(
                      onTap: () {
                        imgFromGallery();
                      },
                      child: _photo != null
                          ? Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              height: 150,
                              width: MediaQuery.of(context).size.width,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _photo!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              height: 150,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8)),
                              width: MediaQuery.of(context).size.width,
                              child: const Icon(
                                Icons.photo,
                                color: Colors.black45,
                              ),
                            )),
                  const SizedBox(
                    height: 8,
                  ),
                  //create a form input to write data
                  SingleChildScrollView(
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8)),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 15),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8.0),
                      child: Column(
                        children: <Widget>[
                          //put event name
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 16),
                            child: TextFormField(
                              decoration: const InputDecoration(
                                border: UnderlineInputBorder(),
                                labelText: 'Enter your event name',
                              ),
                              onChanged: (val) {
                                eventName = val;
                              },
                            ),
                          ),
                          //select destination
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 16),
                            child: TextFormField(
                              decoration: const InputDecoration(
                                icon: Icon(Icons.map),
                                border: UnderlineInputBorder(),
                                labelText: 'Destination',
                              ),
                              onChanged: (val) {
                                destination = val;
                              },
                            ),
                          ),
                          //Select starting date from calender
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 16),
                            child: Column(
                              children: [
                                Text("${startingDate.toLocal()}".split(' ')[0]),
                                const SizedBox(
                                  height: 20.0,
                                ),
                                ElevatedButton(
                                  onPressed: () => _selectDate(context),
                                  child: const Text('Select Starting date'),
                                ),
                              ],
                            ),
                          ),
                          //Select ending date from calender
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 16),
                            child: Column(
                              children: [
                                Text("${endingDate.toLocal()}".split(' ')[0]),
                                const SizedBox(
                                  height: 20.0,
                                ),
                                ElevatedButton(
                                  onPressed: () => _selectEndingDate(context),
                                  child: const Text('Select Ending date'),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 16),
                            child: TextFormField(
                              decoration: const InputDecoration(
                                border: UnderlineInputBorder(),
                                labelText: 'Number of places',
                              ),
                              onChanged: (val) {
                                nbrPlace = val;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 16),
                            child: TextFormField(
                              decoration: const InputDecoration(
                                border: UnderlineInputBorder(),
                                labelText: 'Required equipment',
                              ),
                              onChanged: (val) {
                                requiredEquipment = val;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 16),
                            child: TextFormField(
                              decoration: const InputDecoration(
                                icon: Icon(Icons.people),
                                border: UnderlineInputBorder(),
                                labelText: 'Group',
                              ),
                              onChanged: (val) {
                                group = val;
                              },
                            ),
                          ),
                          SingleChildScrollView(
                            child: TextField(
                              decoration: const InputDecoration(
                                  hintText: "Description",
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.only(
                                      left: 10, top: 10, bottom: 10)),
                              maxLines: 4,
                              onChanged: (val) {
                                description = val;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
      backgroundColor: HexColor('#7b94c4'),
    );
  }
}
