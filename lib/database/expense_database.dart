import 'package:expense_tracker/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class ExpenseDatabase extends ChangeNotifier {
  static late Isar isar;
  List<Expense> _allExpenses = [];

  /*

  S E T UP

  */
  // initialize db
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([ExpenseSchema], directory: dir.path);
  }

  /*

  G E T T E R S
  
  */

  List<Expense> get allExpense => _allExpenses;

  /*

  O P E R A T I O N S
  
  */

  // Create - add a new expense to db
  Future<void> createNewExpense(Expense newExpense) async {
    // add new expense to db
    await isar.writeTxn(() => isar.expenses.put(newExpense));

    // re-read from db
    await readExpenses();
  }

  // Read - expenses from db
  Future<void> readExpenses() async {
    // fetch all existing expenses from db
    List<Expense> fetchedExpenses = await isar.expenses.where().findAll();

    // give to local expense list
    _allExpenses.clear();
    _allExpenses.addAll(fetchedExpenses);

    // update UI
    notifyListeners();
  }

  // Update - edit an expense in db
  Future<void> updateExpense(Id id, Expense updatedExpense) async {
    // make sure new expense haas same id as existing expense
    updatedExpense.id = id;

    // update in db
    await isar.writeTxn(() => isar.expenses.put(updatedExpense));

    // re-read from db
    await readExpenses();
  }

  // Delete - an expense
  Future<void> deleteExpense(int id) async {
    await isar.writeTxn(() => isar.expenses.delete(id));

    // re-read expenses from db
    await readExpenses();
  }
  /*

  H E L P E R 
  
  */
}
