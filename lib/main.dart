import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // if (kIsWeb) {
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyAEI2yVJF_ooXaYl7ya8vbAA2K8ze3nEPI",
          appId: "1:362107198579:web:8aecc67bc525c25b971e06",
          messagingSenderId: "362107198579",
          projectId: "futter-web1"));
  // } else {
  //   await Firebase.initializeApp();
  // }
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TextFields(),
    );
  }
}

class TextFields extends StatefulWidget {
  const TextFields({super.key});

  @override
  State<TextFields> createState() => _TextFieldsState();
}

class _TextFieldsState extends State<TextFields> {
  // final TextEditingController _textController = TextEditingController();
  String str = 'Hello';
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final CollectionReference _products =
      FirebaseFirestore.instance.collection('products');

  // Updated method
  Future<void> _update([DocumentSnapshot? document]) async {
    if (document != null) {
      _nameController.text = document['name'];
      _priceController.text = document['price'].toString();
    }
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    onPressed: () async {
                      final String name = _nameController.text;
                      final double? price =
                          double.tryParse(_priceController.text);
                      if (price != null) {
                        await _products.doc(document!.id).update({
                          'name': name,
                          "price": price,
                        });
                        _nameController.text = '';
                        _priceController.text = '';
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Update'))
              ],
            ),
          );
        });
  }

  //Create The Products
  Future<void> _create([DocumentSnapshot? document]) async {
    if (document != null) {
      _nameController.text = document['name'];
      _priceController.text = document['price'].toString();
    }
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    onPressed: () async {
                      final String name = _nameController.text;
                      final double? price =
                          double.tryParse(_priceController.text);
                      if (price != null) {
                        await _products.add({'name': name, 'price': price});
                        _nameController.text = '';
                        _priceController.text = '';
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Create'))
              ],
            ),
          );
        });
  }

  //Delete Products
  Future<void> _delete(String productId) async {
    await _products.doc(productId).delete();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.redAccent,
        elevation: 6.0,
        content: Text(
          'You have Successfuly Deleted',
          style: TextStyle(
            color: Colors.black,
            fontSize: 30.0,
          ),
        )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('FireBase'),
        ),
        body: StreamBuilder(
          stream: _products.snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> stramSnapshot) {
            if (stramSnapshot.hasData) {
              return ListView.builder(
                  itemCount: stramSnapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final DocumentSnapshot document =
                        stramSnapshot.data!.docs[index];
                    return Card(
                      child: ListTile(
                        title: Text(
                          document['name'],
                          style: const TextStyle(
                            fontSize: 20.0,
                          ),
                        ),
                        subtitle: Text(
                          document['price'].toString(),
                          style: const TextStyle(
                            fontSize: 15.0,
                          ),
                        ),
                        trailing: SizedBox(
                          width: 200.0,
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  _update(document);
                                },
                                icon: const Icon(Icons.edit),
                              ),
                              IconButton(
                                  onPressed: () async {
                                    await _delete(document.id);
                                  },
                                  icon: const Icon(Icons.delete))
                            ],
                          ),
                        ),
                      ),
                    );
                  });
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _create(),
          child: const Icon(
            Icons.add,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat);
  }
}
