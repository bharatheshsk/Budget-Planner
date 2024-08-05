import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DailyExpenditurePage extends StatefulWidget {
  final String userEmail;

  DailyExpenditurePage({required this.userEmail});

  @override
  _DailyExpenditurePageState createState() => _DailyExpenditurePageState();
}

class _DailyExpenditurePageState extends State<DailyExpenditurePage> {
  final _formKey = GlobalKey<FormState>();
  final List<Map<String, dynamic>> _expenditures = [];
  String _selectedMonth = 'January';
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _expenditureNameController =
      TextEditingController();
  final TextEditingController _expenditureAmountController =
      TextEditingController();

  void _addExpenditure() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _expenditures.add({
          'name': _expenditureNameController.text,
          'amount': double.parse(_expenditureAmountController.text),
        });
        _expenditureNameController.clear();
        _expenditureAmountController.clear();
      });
    }
  }

  void _saveExpenditures() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      await firestore
          .collection('users')
          .doc(widget.userEmail)
          .collection('expenditures')
          .add({
        'month': _selectedMonth,
        'date': _selectedDate,
        'details': _expenditures,
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Expenditures saved successfully')));
      setState(() {
        _expenditures.clear();
      });
    } catch (e) {
      print('Error saving expenditures: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving expenditures: $e')));
    }
  }

  void _deleteExpenditure(int index) {
    setState(() {
      _expenditures.removeAt(index);
    });
  }

  @override
  void dispose() {
    _expenditureNameController.dispose();
    _expenditureAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Expenditure'),
        backgroundColor: Colors.deepOrange,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 4.0,
                  color: Colors.orange[100],
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
                                  value: month, child: Text(month)))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedMonth = value!;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Month',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 8.0),
                        ListTile(
                          title: Text('Select Date'),
                          subtitle: Text(
                              DateFormat('yyyy-MM-dd').format(_selectedDate)),
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (picked != null && picked != _selectedDate) {
                              setState(() {
                                _selectedDate = picked;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                Card(
                  elevation: 4.0,
                  color: Colors.lightGreen[100],
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _expenditureNameController,
                          decoration: InputDecoration(
                            labelText: 'Expenditure Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an expenditure name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 8.0),
                        TextFormField(
                          controller: _expenditureAmountController,
                          decoration: InputDecoration(
                            labelText: 'Amount',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an amount';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.0),
                        ElevatedButton(
                          onPressed: _addExpenditure,
                          child: Text('Add Expenditure'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                Card(
                  elevation: 4.0,
                  color: Colors.blueGrey[50],
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _expenditures.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_expenditures[index]['name']),
                        subtitle: Text('${_expenditures[index]['amount']}'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Delete Expenditure'),
                                  content: Text(
                                      'Are you sure you want to delete this expenditure?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        _deleteExpenditure(index);
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Delete'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _saveExpenditures,
                  child: Text('Save Expenditures'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
