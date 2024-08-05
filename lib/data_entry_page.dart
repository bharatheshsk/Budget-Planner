import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard_page.dart';

class DataEntryPage extends StatefulWidget {
  final String userEmail;

  DataEntryPage({required this.userEmail});

  @override
  _DataEntryPageState createState() => _DataEntryPageState();
}

class _DataEntryPageState extends State<DataEntryPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _monthlySalaryController =
      TextEditingController();

  Future<void> _storeUserData() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      await firestore.collection('users').doc(widget.userEmail).set({
        'name': _nameController.text,
        'email': _emailController.text,
        'bank_name': _bankNameController.text,
        'monthly_salary': double.parse(_monthlySalaryController.text),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submitted successfully')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardPage(userEmail: widget.userEmail),
        ),
      );
    } catch (e) {
      print('Error storing user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error storing user data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Entry'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: "Name",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _bankNameController,
                      decoration: InputDecoration(
                        labelText: "Bank Name",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _monthlySalaryController,
                      decoration: InputDecoration(
                        labelText: "Monthly Salary",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _storeUserData,
                      child: Text("Submit"),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 24.0),
                        textStyle: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
