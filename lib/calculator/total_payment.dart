// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jukto/theme/theme.dart';
import 'package:provider/provider.dart';

class TotalPayments extends StatefulWidget {
  const TotalPayments({Key? key}) : super(key: key);

  @override
  TotalPaymentsState createState() => TotalPaymentsState();
}

class TotalPaymentsState extends State<TotalPayments> {
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;
  String userID = '';

  List<Payment> payments = [];
  String date = '';

  SharedPreferences? _prefs;
  final String _cacheKey = 'cachedPayments';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    if (auth.currentUser != null) {
      user = auth.currentUser;
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user?.email)
          .get();

      List<Payment> fetchedPayments = [];

      for (var doc in querySnapshot.docs) {
        setState(() {
          userID = doc.id;
          List<dynamic> paymentList = doc['payments'];
          fetchedPayments = paymentList
              .map((payment) => Payment(
                    date: payment['date'],
                    amount: payment['amount'],
                  ))
              .toList();
        });
      }

      setState(() {
        payments = fetchedPayments;
      });

      _prefs ??= await SharedPreferences.getInstance();
      _prefs!.setStringList(_cacheKey, paymentListToJson(fetchedPayments));
    }
  }

  void saveData() {
    FirebaseFirestore.instance.collection('users').doc(userID).update({
      'payments': payments.map((payment) {
        return {
          'date': payment.date,
          'amount': payment.amount,
        };
      }).toList(),
    }).then((value) async {
      _prefs ??= await SharedPreferences.getInstance();
      _prefs!.setStringList(_cacheKey, paymentListToJson(payments));

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
          content: Text(
            'Data saved successfully',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Roboto',
            ),
          )));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          content: Text(
            'Failed to save data',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Roboto',
            ),
          )));
    });
  }

  void addPaymentDialog(BuildContext context) async {
    date = '';

    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AddPaymentDialog();
      },
    );

    if (result != null) {
      setState(() {
        payments = [...payments, result];
      });
      saveData();
    }
  }

  void deletePayment(int index) {
    setState(() {
      Payment deletedPayment = payments.removeAt(index);
      saveData();
      deletePaymentFromFirestore(deletedPayment);
    });
  }

  void deletePaymentFromFirestore(Payment payment) {
    FirebaseFirestore.instance.collection('users').doc(userID).update({
      'payments': FieldValue.arrayRemove([
        {
          'date': payment.date,
          'amount': payment.amount,
        }
      ])
    }).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          content: Text(
            'Payment deleted from online',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Roboto',
            ),
          )));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          content: Text(
            'Failed to delete payment from online',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Roboto',
            ),
          )));
    });
  }

  double calculateTotalAmount() {
    double total = 0.0;
    for (Payment payment in payments) {
      total += payment.amount;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Total Payments',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(58, 150, 255, 1),
        iconTheme: const IconThemeData(color: Colors.white, size: 35.0),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: payments.length,
              itemBuilder: (context, index) {
                Payment payment = payments[index];
                return Card(
                  margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
                  color: themeProvider.isDarkMode
                      ? Colors.black12
                      : Colors.blueGrey[50],
                  child: ListTile(
                    title: Text(
                      'Amount: ${payment.amount.toStringAsFixed(2)} TK',
                      style: TextStyle(
                          color: themeProvider.isDarkMode
                              ? Colors.white
                              : Colors.black),
                    ),
                    subtitle: Text(
                      payment.date,
                      style: TextStyle(
                          color: themeProvider.isDarkMode
                              ? Colors.white
                              : Colors.black),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        deletePayment(index);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            'Total Amount: ${calculateTotalAmount().toStringAsFixed(2)} TK',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromRGBO(58, 150, 255, 1),
        onPressed: () {
          addPaymentDialog(context);
        },
        child: Icon(
          Icons.add,
          color: themeProvider.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  String formatDate(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  List<String> paymentListToJson(List<Payment> payments) {
    return payments.map((payment) => payment.toJson()).toList();
  }

  List<Payment> paymentListFromJson(List<String> jsonList) {
    return jsonList.map((json) => Payment.fromJson(json)).toList();
  }
}

class Payment {
  final String date;
  final double amount;

  Payment({required this.date, required this.amount});

  String toJson() {
    return '{"date": "$date", "amount": $amount}';
  }

  factory Payment.fromJson(String json) {
    final Map<String, dynamic> data = jsonDecode(json);
    return Payment(
      date: data['date'],
      amount: data['amount'],
    );
  }
}

class AddPaymentDialog extends StatefulWidget {
  const AddPaymentDialog({super.key});

  @override
  AddPaymentDialogState createState() => AddPaymentDialogState();
}

class AddPaymentDialogState extends State<AddPaymentDialog> {
  double amount = 0.0;
  String date = '';

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return AlertDialog(
      title: Text('Add Payment',
          style: TextStyle(
              color: themeProvider.isDarkMode ? Colors.white : Colors.black)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.white : Colors.black),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Amount',
            ),
            onChanged: (value) {
              amount = double.tryParse(value) ?? 0.0;
            },
          ),
          GestureDetector(
            onTap: () {
              showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              ).then((pickedDate) {
                if (pickedDate != null) {
                  setState(() {
                    date = formatDate(pickedDate);
                  });
                }
              });
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Date',
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(date.isEmpty ? 'Select a date' : date,
                      style: TextStyle(
                          color: themeProvider.isDarkMode
                              ? Colors.white
                              : Colors.black)),
                  const Icon(Icons.calendar_today),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (amount != 0.0) {
              Navigator.pop(context, Payment(date: date, amount: amount));
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }

  String formatDate(DateTime date) {
    final String year = date.year.toString();
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
