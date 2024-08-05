import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MonthlyExpenditurePage extends StatefulWidget {
  final String userEmail;

  MonthlyExpenditurePage({required this.userEmail});

  @override
  _MonthlyExpenditurePageState createState() => _MonthlyExpenditurePageState();
}

class _MonthlyExpenditurePageState extends State<MonthlyExpenditurePage> {
  String _selectedMonth = 'January';
  List<Map<String, dynamic>> _expenditures = [];
  double _totalExpenditure = 0.0;

  void _fetchExpenditures(String month) async {
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
        _totalExpenditure = total;
      });
    } catch (e) {
      print('Error fetching expenditures: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchExpenditures(_selectedMonth);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Monthly Expenditure'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4.0,
                margin: EdgeInsets.only(bottom: 16.0),
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
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        'Monthly Expenditures for $_selectedMonth',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2.0),
                  ),
                  child: DataTable(
                    columns: [
                      DataColumn(
                        label: Text(
                          'Expenditure Name',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Amount',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    rows: _expenditures
                        .map(
                          (expenditure) => DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  expenditure['name'],
                                  style: TextStyle(color: Colors.black87),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '₹${expenditure['amount'].toStringAsFixed(2)}',
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Card(
                elevation: 4.0,
                color: Colors.lightGreen[100],
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Expenditure:',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '₹${_totalExpenditure.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
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
