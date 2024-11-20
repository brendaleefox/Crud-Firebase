import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crudfirebase_flutter/services/firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService firestoreService = FirestoreService();

  //Text Controller
  final TextEditingController textController = TextEditingController();

  //Open de note dialog
  void openNoteBox(String? docID) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController,
        ),
        actions: [
          //Save button
          ElevatedButton(
              onPressed: () {
                // Check if the text is not empty
                if (textController.text.isNotEmpty) {
                  //add a note
                  //If the docId is null we will create a new note
                  if (docID == null) {
                    firestoreService.addNote(textController.text);
                  }
                  //else, will update an existing note
                  else {
                    firestoreService.updateNote(docID, textController.text);
                  }

                  //clear the text controller
                  textController.clear();

                  //close the add note box
                  Navigator.pop(context);
                } else {
                  //Message is display if note is empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('The note is empty, please add information to continue')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[900],
                foregroundColor: Colors.white,
              ),
              child: Text("Add"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Crud en Firebase",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[900],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[900],
        onPressed: () => openNoteBox(null),
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: firestoreService.getNotesStream(),
          builder: (context, snapshot) {
            //Here we will check if we have date to get all the documents
            if (snapshot.hasData) {
              List noteList = snapshot.data!.docs;

              //Display the information as a list
              return ListView.builder(
                  itemCount: noteList.length,
                  itemBuilder: (context, index) {
                    //get each individual document
                    DocumentSnapshot document = noteList[index];
                    String docID = document.id;

                    //get note from each document
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    String noteText = data['note'];

                    //display as a list tile
                    return ListTile(
                      title: Text(noteText),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        //Update button
                        IconButton(
                          onPressed: () => openNoteBox(docID),
                          icon: Icon(
                            Icons.settings,
                            color: Colors.green[900],
                          ),
                        ),
                        //delete button
                        IconButton(
                          onPressed: () => firestoreService.deleteNote(docID),
                          icon: const Icon(Icons.delete),
                          color: Colors.green[900],
                        ),
                      ]),
                    );
                  });
            }
            //if there is no data we will return nothing
            else {
              return const Center(child: Text("There are no notes."));
            }
          }),
    );
  }
}
