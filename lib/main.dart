import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: PetListScreen(),
    );
  }
}

class PetListScreen extends StatelessWidget {
  final CollectionReference petsCollection =
      FirebaseFirestore.instance.collection('Pets');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("สัตว์เลี้ยงของคุณ"),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 5,
      ),
      body: StreamBuilder(
        stream: petsCollection.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          return Padding(
            padding: EdgeInsets.all(10),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.8,
              ),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var pet = snapshot.data!.docs[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.teal.shade200,
                        child: Icon(Icons.pets, color: Colors.white, size: 30),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "${pet['name']}",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text("อายุ: ${pet['age']} ปี"),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              _editPet(context, pet.id, pet['name'], pet['age']);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              petsCollection.doc(pet.id).delete();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () {
          _addPet(context);
        },
      ),
    );
  }

  void _addPet(BuildContext context) {
    String name = "";
    String breed = "";
    int age = 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("เพิ่มสัตว์เลี้ยง"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(labelText: "ชื่อสัตว์เลี้ยง"),
              onChanged: (value) => name = value,
            ),
            TextField(
              decoration: InputDecoration(labelText: "สายพันธุ์"),
              onChanged: (value) => breed = value,
            ),
            TextField(
              decoration: InputDecoration(labelText: "อายุ"),
              keyboardType: TextInputType.number,
              onChanged: (value) => age = int.tryParse(value) ?? 0,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text("ยกเลิก"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text("บันทึก"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () {
              if (name.isNotEmpty && breed.isNotEmpty && age > 0) {
                petsCollection.add({'name': name, 'breed': breed, 'age': age});
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _editPet(BuildContext context, String id, String currentName, int currentAge) {
    TextEditingController nameController = TextEditingController(text: currentName);
    TextEditingController ageController = TextEditingController(text: currentAge.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("แก้ไขข้อมูลสัตว์เลี้ยง"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(labelText: "ชื่อสัตว์เลี้ยง"),
              controller: nameController,
            ),
            TextField(
              decoration: InputDecoration(labelText: "อายุ"),
              keyboardType: TextInputType.number,
              controller: ageController,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text("ยกเลิก"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text("บันทึก"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () {
              String newName = nameController.text;
              int newAge = int.tryParse(ageController.text) ?? currentAge;
              if (newName.isNotEmpty && newAge > 0) {
                petsCollection.doc(id).update({'name': newName, 'age': newAge});
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
