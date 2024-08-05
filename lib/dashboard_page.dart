import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'daily_expenditure_page.dart';
import 'monthly_expenditure_page.dart';
import 'total_expenditure_page.dart';
import 'login_page.dart';
import 'view_reminders_page.dart';

class DashboardPage extends StatefulWidget {
  final String userEmail;

  DashboardPage({required this.userEmail});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String? name;
  String? email;
  String? bankName;
  double? monthlySalary;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _getUserData();
    _getExpenditures();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: null,
      macOS: null,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _scheduleNotification(DateTime date, String reminderName) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'reminder_channel',
      'Reminder Notifications',
      channelDescription: 'Channel for reminder notifications',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    var tz;
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Reminder',
      reminderName,
      tz.TZDateTime.from(date, tz.local),
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _getUserData() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      DocumentSnapshot docSnapshot =
          await firestore.collection('users').doc(widget.userEmail).get();
      setState(() {
        name = docSnapshot['name'];
        email = docSnapshot['email'];
        bankName = docSnapshot['bank_name'];
        monthlySalary = docSnapshot['monthly_salary'];
      });
    } catch (e) {
      print('Error retrieving user data: $e');
    }
  }

  Future<void> _getExpenditures() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      QuerySnapshot expendituresSnapshot = await firestore
          .collection('users')
          .doc(widget.userEmail)
          .collection('expenditures')
          .orderBy('date')
          .get();
    } catch (e) {
      print('Error retrieving expenditures: $e');
    }
  }

  void _showExpenditureDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Expenditure'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Daily Expenditure'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DailyExpenditurePage(userEmail: widget.userEmail),
                    ),
                  );
                },
              ),
              ListTile(
                title: Text('Monthly Expenditure'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MonthlyExpenditurePage(userEmail: widget.userEmail),
                    ),
                  );
                },
              ),
              ListTile(
                title: Text('Total Expenditure'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          TotalExpenditurePage(userEmail: widget.userEmail),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddReminderDialog() {
    TextEditingController nameController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Reminder'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Reminder Name'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null && picked != selectedDate)
                    setState(() {
                      selectedDate = picked;
                    });
                },
                child: Text('Select date'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String reminderName = nameController.text;

                if (reminderName.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.userEmail)
                      .collection('reminders')
                      .add({
                    'name': reminderName,
                    'date': selectedDate,
                  });

                  _scheduleNotification(selectedDate, reminderName);

                  _showSuccessDialog('Reminder added successfully.');
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Success"),
          content: Text(message),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildExpenditureList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userEmail)
          .collection('expenditures')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No expenditures found.'));
        }

        var expenditureData = snapshot.data!.docs;
        Map<String, List<Map<String, dynamic>>> monthlyExpenditures = {};

        for (var doc in expenditureData) {
          var month = doc['month'];
          var details = List<Map<String, dynamic>>.from(doc['details']);
          if (!monthlyExpenditures.containsKey(month)) {
            monthlyExpenditures[month] = [];
          }
          monthlyExpenditures[month]!.add({
            'id': doc.id,
            'date': doc['date'],
            'details': details,
          });
        }

        return ListView.builder(
          itemCount: monthlyExpenditures.keys.length,
          itemBuilder: (context, index) {
            String month = monthlyExpenditures.keys.elementAt(index);
            List<Map<String, dynamic>> monthDetails =
                monthlyExpenditures[month]!;

            return Card(
              child: ExpansionTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      month,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        // Delete all expenditures for this month
                        for (var expenditure in monthDetails) {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(widget.userEmail)
                              .collection('expenditures')
                              .doc(expenditure['id'])
                              .delete();
                        }
                      },
                    ),
                  ],
                ),
                children: monthDetails.map((expenditure) {
                  var details = expenditure['details'];
                  var date = expenditure['date'];
                  if (date is String) {
                    date = DateTime.parse(date);
                  } else if (date is Timestamp) {
                    date = date.toDate();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(
                            'Date: ${DateFormat('yyyy-MM-dd').format(date)}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: details.map<Widget>((detail) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(detail['name']),
                                  Text('₹${detail['amount']}'),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () async {
                                      var docRef = FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(widget.userEmail)
                                          .collection('expenditures')
                                          .doc(expenditure['id']);
                                      var newDetails =
                                          List<Map<String, dynamic>>.from(
                                              details)
                                            ..remove(detail);
                                      if (newDetails.isEmpty) {
                                        await docRef.delete();
                                      } else {
                                        await docRef.update({
                                          'details': newDetails,
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }

  void _logout() async {
    try {
      // Here you can perform any additional logout logic
      // For example, clearing cached data, etc.
      // Navigate to Login page
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false, // Prevent going back to DashboardPage
      );
    } catch (e) {
      print('Error logging out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.simpleCurrency(locale: 'en_IN');

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Dashboard'),
        leading: IconButton(
          icon: Icon(Icons.logout),
          onPressed: _logout,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.alarm),
            onPressed: _showAddReminderDialog,
          ),
          IconButton(
            icon: Icon(Icons.view_list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ViewRemindersPage(userEmail: widget.userEmail),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.blue[50],
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (name != null)
                      Text('Name: $name', style: TextStyle(fontSize: 18)),
                    if (email != null)
                      Text('Email: $email', style: TextStyle(fontSize: 18)),
                    if (bankName != null)
                      Text('Bank Name: $bankName',
                          style: TextStyle(fontSize: 18)),
                    if (monthlySalary != null)
                      Text(
                          'Monthly Salary: ${currencyFormatter.format(monthlySalary)}',
                          style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(child: _buildExpenditureList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showExpenditureDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
