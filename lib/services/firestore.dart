import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService{
  //This will get the collection of note
  final CollectionReference notes = FirebaseFirestore.instance.collection('notes');

  //Create:
  //This will create a new note on the database
  Future<void> addNote(String note){
    return notes.add({
      'note': note,
      'timestamp': Timestamp.now()
    });
   }
  
  //Read:
  //This will get the notes we create from the database
  Stream<QuerySnapshot> getNotesStream(){
    final notesStream =
    notes.orderBy('timestamp', descending: true).snapshots();

    return notesStream;
  }

  //Update
  //This will update the notes we create givin a document id.
  Future<void> updateNote(String docID, String newNote){
    return notes.doc(docID).update({
      'note': newNote,
      'timestamp': Timestamp.now(),
  });
  }

  //Delete
  //This will delete the notes we create given a document id.
  Future<void> deleteNote(String docID){
    return notes.doc(docID).delete();
  }
}