import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TotalPayments extends StatefulWidget {
  const TotalPayments({Key? key}) : super(key: key);

  @override
  _TotalPaymentsState createState() => _TotalPaymentsState();
}

class _TotalPaymentsState extends State<TotalPayments> {
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;
  String userID = '';

  List<Payment> payments = [];
  String date = '';

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

      List<Payment> fetchedPayments = []; // Create a temporary list

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
        payments =
            fetchedPayments; // Update the payments list with fetched data
      });
    }
  }

  void saveData() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userID) // Use the UserID obtained from the fetchData() method
        .update({
          'payments': payments.map((payment) {
            return {
              'date': payment.date,
              'amount': payment.amount,
            };
          }).toList(),
        })
        .then((value) => print('Data saved successfully.'))
        .catchError((error) => print('Failed to save data: $error'));
  }

  void addPaymentDialog(BuildContext context) async {
    double amount = 0.0;
    date = '';

    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddPaymentDialog();
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
      saveData(); // Save the updated payments list after removing the payment locally
      deletePaymentFromFirestore(
          deletedPayment); // Delete the payment from Firestore
    });
  }

  void deletePaymentFromFirestore(Payment payment) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userID)
        .update({
          'payments': FieldValue.arrayRemove([
            {
              'date': payment.date,
              'amount': payment.amount,
            }
          ])
        })
        .then((value) => print('Payment deleted from Firestore.'))
        .catchError((error) =>
            print('Failed to delete payment from Firestore: $error'));
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Total Payments',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: payments.length,
              itemBuilder: (context, index) {
                Payment payment = payments[index];
                return Card(
                  margin: EdgeInsets.only(left: 20, right: 20, top: 20),
                  color: Colors.blue[100],
                  child: ListTile(
                    title:
                        Text('Amount: ${payment.amount.toStringAsFixed(2)} TK'),
                    subtitle: Text(payment.date),
                    trailing: IconButton(
                      icon: Icon(
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
          SizedBox(
            height: 20,
          ),
          Text(
            'Total Amount: ${calculateTotalAmount().toStringAsFixed(2)} TK',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addPaymentDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  String formatDate(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

class Payment {
  final String date;
  final double amount;

  Payment({required this.date, required this.amount});
}

class AddPaymentDialog extends StatefulWidget {
  @override
  _AddPaymentDialogState createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends State<AddPaymentDialog> {
  double amount = 0.0;
  String date = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Payment'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
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
              decoration: InputDecoration(
                labelText: 'Date',
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(date.isEmpty ? 'Select a date' : date),
                  Icon(Icons.calendar_today),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (amount != 0.0) {
              Navigator.pop(context, Payment(date: date, amount: amount));
            }
          },
          child: Text('Add'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
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