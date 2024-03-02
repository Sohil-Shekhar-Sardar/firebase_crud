import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'generated/assets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // snackBar Widget
  snackBar(String? message,int? status) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor:status == 0?Colors.red:status == 1?Colors.green:Colors.purple,
        content: Text(message!),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  File? itemImage;


  addItem() async {


    if(itemImage != null && titleTxtController.text != "" && descTxtController.text !=""){

      UploadTask uploadTask = FirebaseStorage.instance.ref().child("itemsImage").child(Uuid().v1()).putFile(itemImage!);

      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      DateTime now = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd , HH:mm:ss').format(now);

      Map<String,dynamic> itemData = {
        "title":titleTxtController.text.trim(),
        "description":descTxtController.text.trim(),
        "image":downloadUrl,
        "createdAt":formattedDate
      };

      try {
        FirebaseFirestore.instance.collection("crud").add(itemData);
        snackBar("Item Add Successfully",1);
      } on FirebaseException catch (e){
        snackBar(e.message,0);
      }
    }
  }

  updateItem(String id) async {


    if(itemImage != null && titleTxtController.text != "" && descTxtController.text !=""){

      UploadTask uploadTask = FirebaseStorage.instance.ref().child("itemsImage").child(Uuid().v1()).putFile(itemImage!);

      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      Map<String,dynamic> itemData = {
        "title":titleTxtController.text.trim(),
        "description":descTxtController.text.trim(),
        "image":downloadUrl,
      };

      try {
        await FirebaseFirestore.instance.collection('crud').doc(id).update(itemData);
        snackBar("Item Updated Successfully",1);
      } on FirebaseException catch (e){
        snackBar(e.message,0);
      }
    }

  }

  TextEditingController titleTxtController = TextEditingController();
  TextEditingController descTxtController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Center(child: Text("ITEM")),
          backgroundColor: Colors.deepPurple,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection("crud").orderBy('createdAt', descending: true).snapshots(),
            builder:(context,snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting){
              return const Center(
                child: Expanded(child: CircularProgressIndicator(color: Colors.deepPurple,value: 2,)),
              );

            }else{
              if(snapshot.data != null && snapshot.hasData){
                return  ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder:(context,index){
                      Map<String,dynamic> item = snapshot.data!.docs[index].data() as Map<String,dynamic>;
                      List<String> documentIds = snapshot.data!.docs.map((doc) => doc.id).toList();
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Dismissible(
                          key: UniqueKey(),
                          background: Card(
                            elevation: 4,
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)
                              ),
                              leading: const Padding(
                                padding: EdgeInsets.only(top: 15.0),
                                child: Icon(Icons.delete,size: 40,color: Colors.white,),
                              ),
                              tileColor: Colors.red,
                            ),
                          ),
                          confirmDismiss: (DismissDirection direction) async {
                            return true;
                          },
                          onDismissed: (DismissDirection direction) async {
                            await FirebaseFirestore.instance.collection('crud').doc(documentIds[index]).delete();
                          },
                          direction: DismissDirection.startToEnd, // or other DismissDirection values
                          dragStartBehavior: DragStartBehavior.start, // or any unique key for tracking items
                          child: Card(
                            elevation: 4,
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)
                              ),
                              leading: Image.network(item["image"],height: 50,width: 60,fit: BoxFit.contain,),
                              title: Text(item['title']),
                              subtitle: Text(item["description"]),
                              trailing: GestureDetector(
                                onTap: () async{
                                  titleTxtController.text = item['title'];
                                  descTxtController.text = item['description'];
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return StatefulBuilder(
                                          builder: (BuildContext context, StateSetter setState) {
                                            return Padding(
                                              padding: const EdgeInsets.all(20.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  SizedBox(height: 20),

                                                  Text("Edit Item"),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                        height: 70,width: 70,
                                                        decoration: BoxDecoration(
                                                            border: Border.all(color: Colors.deepPurple),
                                                            borderRadius: BorderRadius.circular(15)
                                                        ),
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(8.0),
                                                          child: GestureDetector(
                                                              onTap: () async{
                                                                XFile? selectedImg = await ImagePicker().pickImage(source: ImageSource.gallery);
                                                                if(selectedImg != null){
                                                                  File image = File(selectedImg.path);
                                                                  setState(() {
                                                                    itemImage = image;
                                                                  });
                                                                  snackBar("Image selected successfully",1);
                                                                }else{
                                                                  snackBar("Image not selected !",0);
                                                                }
                                                              },
                                                              child: itemImage == null ?  Image.network(item["image"]!,fit: BoxFit.cover) :
                                                              Image.file(itemImage!,fit: BoxFit.cover)
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  SizedBox(height: 20),
                                                  Padding(
                                                    padding: const EdgeInsets.all(20.0),
                                                    child: TextFormField(
                                                      controller:titleTxtController,
                                                      keyboardType: TextInputType.text,
                                                      decoration: const InputDecoration(
                                                        labelText: "Title",
                                                        floatingLabelBehavior: FloatingLabelBehavior.always,
                                                        hintText: "Enter title number",
                                                        border: OutlineInputBorder(
                                                            borderSide: BorderSide(color: Colors.black)
                                                        ),
                                                      ),
                                                      validator: (value){
                                                        if(value!.isEmpty){
                                                          return "please enter title";
                                                        }else {
                                                          return null;
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.all(20.0),
                                                    child: TextFormField(
                                                      controller:descTxtController,
                                                      keyboardType: TextInputType.text,
                                                      decoration: const InputDecoration(
                                                        labelText: "Description",
                                                        floatingLabelBehavior: FloatingLabelBehavior.always,
                                                        hintText: "Enter description",
                                                        border: OutlineInputBorder(
                                                            borderSide: BorderSide(color: Colors.black)
                                                        ),
                                                      ),
                                                      validator: (value){
                                                        if(value!.isEmpty) {
                                                          return "please enter description";
                                                        }else {
                                                          return null;
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: (){
                                                      updateItem(documentIds[index]);
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text('Save'),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                      );
                                    },
                                  );
                                },
                                child: const CircleAvatar(
                                  child: Center(
                                    child: Icon(Icons.edit),
                                  ),
                                ),
                              ),
                            ),
                          ), // or DragStartBehavior.down
                        ),
                      );
                    }
                );
              }
              else{
                return const Center(
                  child: Text("No Data Found !"),
                );
              }
            }
            }
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: (){
              titleTxtController.clear();
              descTxtController.clear();
              itemImage = null;
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            SizedBox(height: 20),

                            Text("Add Item"),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                              height: 70,width: 70,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.deepPurple),
                                    borderRadius: BorderRadius.circular(15)
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GestureDetector(
                                      onTap: () async{
                                        XFile? selectedImg = await ImagePicker().pickImage(source: ImageSource.gallery);
                                        if(selectedImg != null){
                                          File image = File(selectedImg.path);
                                          setState(() {
                                           itemImage = image;
                                          });
                                          snackBar("Image selected successfully",1);
                                        }else{
                                          snackBar("Image not selected !",0);

                                        }
                                      },
                                        child: itemImage == null ?Image.asset(Assets.imagesMedia,fit: BoxFit.cover):
                                    Image.file(itemImage!,fit: BoxFit.cover)
                                    ),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: TextFormField(
                                controller:titleTxtController,
                                keyboardType: TextInputType.text,
                                decoration: const InputDecoration(
                                  labelText: "Title",
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  hintText: "Enter title number",
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.black)
                                  ),
                                ),
                                validator: (value){
                                  if(value!.isEmpty){
                                    return "please enter title";
                                  }else {
                                    return null;
                                  }
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: TextFormField(
                                controller:descTxtController,
                                keyboardType: TextInputType.text,
                                decoration: const InputDecoration(
                                  labelText: "Description",
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  hintText: "Enter description",
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.black)
                                  ),
                                ),
                                validator: (value){
                                  if(value!.isEmpty) {
                                    return "please enter description";
                                  }else {
                                    return null;
                                  }
                                },
                              ),
                            ),
                            ElevatedButton(
                              onPressed: (){
                                addItem();
                                Navigator.pop(context);
                              },
                              child: const Text('Save'),
                            ),
                          ],
                        ),
                      );
                    }
                  );
                },
              );
            },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
