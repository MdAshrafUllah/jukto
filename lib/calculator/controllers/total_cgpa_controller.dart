import 'package:flutter/material.dart';
import 'package:jukto/calculator/models/cgpa.dart';

class TotalCGPAController extends ChangeNotifier {
  double totalCGPA = 0;

  void calculateTotalCGPA(List<Cgpa> cgpaList) {
    totalCGPA = 3.5;
    notifyListeners();
  }
}
