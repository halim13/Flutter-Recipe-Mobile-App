import 'package:flutter/material.dart';

class Company with ChangeNotifier {
  int id;
  String name;

  Company(
    this.id, 
    this.name
  );

  static List<Company> getCompanies() {
    return <Company>[
      Company(1, 'Apple'),
      Company(2, 'Google'),
      Company(3, 'Samsung')
    ];
  }
}