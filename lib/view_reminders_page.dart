import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ViewRemindersPage extends StatelessWidget {
  final String userEmail;

  ViewRemindersPage({required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reminders'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userEmail)
            .collection('reminders')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No reminders found.'));
          }

          var remindersData = snapshot.data!.docs;
          return ListView.builder(
            itemCount: remindersData.length,
            itemBuilder: (context, index) {
              var reminder = remindersData[index];
              var reminderName = reminder['name'];
              var reminderDate = reminder['date'].toDate();

              return Card(
                elevation: 4.0,
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  title: Text(
                    reminderName,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    DateFormat('yyyy-MM-dd – kk:mm').format(reminderDate),
                    style: TextStyle(color: Colors.blueGrey),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      bool? confirmDelete = await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Confirm Delete'),
                            content: Text(
                                'Are you sure you want to delete this reminder?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: Text('Delete',
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirmDelete == true) {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(userEmail)
                            .collection('reminders')
                            .doc(reminder.id)
                            .delete();
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
