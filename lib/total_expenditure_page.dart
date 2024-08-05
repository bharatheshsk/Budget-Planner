import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class TotalExpenditurePage extends StatefulWidget {
  final String userEmail;

  TotalExpenditurePage({required this.userEmail});

  @override
  _TotalExpenditurePageState createState() => _TotalExpenditurePageState();
}

class _TotalExpenditurePageState extends State<TotalExpenditurePage> {
  String _selectedMonth = 'January';
  double monthlySalary = 0.0;
  double totalExpenditure = 0.0;
  double balance = 0.0;
  List<Map<String, dynamic>> _expenditures = [];

  @override
  void initState() {
    super.initState();
    _fetchMonthlySalary();
    _fetchExpenditures(_selectedMonth);
  }

  Future<void> _fetchMonthlySalary() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(widget.userEmail).get();

      if (userDoc.exists) {
        setState(() {
          monthlySalary = userDoc['monthly_salary'];
        });
      }
    } catch (e) {
      print('Error fetching monthly salary: $e');
    }
  }

  Future<void> _fetchExpenditures(String month) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      QuerySnapshot snapshot = await firestore
          .collection('users')
          .doc(widget.userEmail)
          .collection('expenditures')
          .where('month', isEqualTo: month)
          .get();

      List<Map<String, dynamic>> expenditures = [];
      double total = 0.0;

      snapshot.docs.forEach((doc) {
        List<dynamic> details = doc['details'];
        details.forEach((item) {
          expenditures.add({
            'name': item['name'],
            'amount': item['amount'],
          });
          total += item['amount'];
        });
      });

      setState(() {
        _expenditures = expenditures;
        totalExpenditure = total;
        balance = monthlySalary - totalExpenditure;
      });
    } catch (e) {
      print('Error fetching expenditures: $e');
    }
  }

  String generateReport() {
    return '''
    This month, you have spent ₹${totalExpenditure.toStringAsFixed(2)} out of your monthly salary of ₹${monthlySalary.toStringAsFixed(2)}.
    Your remaining balance for this month is ₹${balance.toStringAsFixed(2)}.
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Total Expenditure'),
      ),
      body: monthlySalary == 0
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 4.0,
                      margin: EdgeInsets.only(bottom: 16.0),
                      color: Colors.lightBlue[
                          50], // Light background for the Monthly Expenditure section
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            DropdownButtonFormField<String>(
                              value: _selectedMonth,
                              items: [
                                'January',
                                'February',
                                'March',
                                'April',
                                'May',
                                'June',
                                'July',
                                'August',
                                'September',
                                'October',
                                'November',
                                'December'
                              ]
                                  .map((month) => DropdownMenuItem(
                                        value: month,
                                        child: Text(month),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedMonth = value!;
                                  _fetchExpenditures(_selectedMonth);
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Select Month',
                                border: OutlineInputBorder(),
                                labelStyle: TextStyle(color: Colors.black),
                              ),
                              dropdownColor: Colors.lightBlue[100],
                              style: TextStyle(color: Colors.black),
                            ),
                            SizedBox(height: 16.0),
                            Text(
                              'Monthly Expenditures for $_selectedMonth',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      elevation: 4.0,
                      color: Colors.lightBlue[50],
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Monthly Salary is: ₹${monthlySalary.toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Total Expenditure: ₹${totalExpenditure.toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Balance: ₹${balance.toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Card(
                      elevation: 4.0,
                      color: Colors.blueGrey[
                          900], // Dark background for the Pie Chart section
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              'Monthly Expenditure Breakdown',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            SizedBox(height: 16),
                            AspectRatio(
                              aspectRatio: 1.5,
                              child: PieChart(
                                PieChartData(
                                  sections: [
                                    PieChartSectionData(
                                      color: Colors.blue,
                                      value: monthlySalary,
                                      title: 'Salary',
                                      radius: 50,
                                      titleStyle: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      showTitle: true,
                                    ),
                                    PieChartSectionData(
                                      color: Colors.red,
                                      value: totalExpenditure,
                                      title: 'Expenditure',
                                      radius: 50,
                                      titleStyle: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      showTitle: true,
                                    ),
                                    PieChartSectionData(
                                      color: Colors.green,
                                      value: balance,
                                      title: 'Balance',
                                      radius: 50,
                                      titleStyle: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      showTitle: true,
                                    ),
                                  ],
                                  borderData: FlBorderData(show: false),
                                  sectionsSpace: 0,
                                  centerSpaceRadius: 40,
                                  pieTouchData: PieTouchData(touchCallback:
                                      (FlTouchEvent event, pieTouchResponse) {
                                    if (!event.isInterestedForInteractions ||
                                        pieTouchResponse == null ||
                                        pieTouchResponse.touchedSection ==
                                            null) {
                                      return;
                                    }
                                  }),
                                ),
                                swapAnimationDuration:
                                    Duration(milliseconds: 150), // Optional
                                swapAnimationCurve: Curves.linear, // Optional
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Card(
                      elevation: 4.0,
                      margin: EdgeInsets.only(bottom: 16.0),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Expenditure Details:',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8.0),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                              ),
                              child: SizedBox(
                                height:
                                    200.0, // Set a fixed height for the ListView
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _expenditures.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      title: Text(_expenditures[index]['name']),
                                      subtitle: Text(
                                          '₹${_expenditures[index]['amount'].toStringAsFixed(2)}'),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Card(
                      elevation: 4.0,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Monthly Expenditure Report:',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              generateReport(),
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
