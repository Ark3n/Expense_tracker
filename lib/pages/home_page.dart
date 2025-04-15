import 'package:expense_tracker/components/my_list_tile.dart';
import 'package:expense_tracker/database/expense_database.dart';
import 'package:expense_tracker/helpers/helper_functions.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // text controller
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    // read all expenses
    Provider.of<ExpenseDatabase>(context, listen: false).readExpenses();
    super.initState();
  }

  // open new expense box
  void openNewExpenseBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('New Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min, // make column heigh minimum
          children: [
            //user input -> expense name
            TextField(
              controller: nameController,
              decoration: InputDecoration(hintText: 'Name'),
            ),
            // user input -> expense amount
            TextField(
              controller: amountController,
              decoration: InputDecoration(hintText: 'Amount'),
            )
          ],
        ),
        actions: [
          // cancel button
          _cancelButton(),
          // save button
          _createNewExpense(),
        ],
      ),
    );
  }

  // open edit box
  void openEditBox(Expense expense) {
    // pre-file existing values into textfields
    String existingName = expense.name;
    String existingAmount = formatAmount(expense.amount);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit expense'),
        content: Column(
          children: [
            // user input -> expense name
            TextField(
              controller: nameController,
              decoration: InputDecoration(hintText: existingName),
            ),

            // user input -> amount
            TextField(
              controller: amountController,
              decoration: InputDecoration(hintText: existingAmount),
            )
          ],
        ),
        actions: [
          // Cancel Button
          _cancelButton(),

          // Edit expense button
          _editExpenseButton(expense)
        ],
      ),
    );
  }

  // open delete box
  void openDeleteBox(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete expense?'),
        actions: [
          // Cancel button
          _cancelButton(),

          // Delete expense button
          _deleteExpenseButton(expense.id)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseDatabase>(
        builder: (context, value, child) => Scaffold(
              floatingActionButton: FloatingActionButton(
                onPressed: openNewExpenseBox,
                child: const Icon(Icons.add),
              ),
              body: ListView.builder(
                  itemCount: value.allExpense.length,
                  itemBuilder: (context, index) {
                    // get individual expense
                    Expense individualExpense = value.allExpense[index];

                    // return list tile
                    return MyListTile(
                      title: individualExpense.name,
                      trailing: formatAmount(individualExpense.amount),
                      onEditPressed: (context) =>
                          openEditBox(individualExpense),
                      onDeletePressed: (context) =>
                          openDeleteBox(individualExpense),
                    );
                  }),
            ));
  }

  // MARK: - Cancel button
  Widget _cancelButton() {
    return MaterialButton(
      onPressed: () {
        // pop the box
        Navigator.pop(context);

        // clear controllers
        nameController.clear();
        amountController.clear();
      },
      child: Text('Cancel'),
    );
  }

  // MARK: - Save button -> create new expense
  Widget _createNewExpense() {
    return MaterialButton(
      onPressed: () async {
        // only save if there is something in the text fields to save
        if (nameController.text.isNotEmpty &&
            amountController.text.isNotEmpty) {
          // pop the box
          Navigator.pop(context);

          // create new expense
          Expense newExpense = Expense(
            name: nameController.text,
            amount: convertStringToDouble(amountController.text),
            date: DateTime.now(),
          );

          // save to db
          await context.read<ExpenseDatabase>().createNewExpense(newExpense);

          // clear controllers
          nameController.clear();
          amountController.clear();
        }
      },
      child: Text('Save'),
    );
  }

  // MARK: - Save button -> edits selected expense
  Widget _editExpenseButton(Expense expense) {
    return MaterialButton(
      onPressed: () async {
        // save as long as at least one textfield has been changed
        if (nameController.text.isNotEmpty ||
            amountController.text.isNotEmpty) {
          // pop box
          Navigator.pop(context);

          // create new updated expense
          Expense updatedExpense = Expense(
            name: nameController.text.isNotEmpty
                ? nameController.text
                : expense.name,
            amount: amountController.text.isNotEmpty
                ? convertStringToDouble(amountController.text)
                : expense.amount,
            date: DateTime.now(),
          );

          // old expense id
          int existingId = expense.id;

          // save to db
          await context
              .read<ExpenseDatabase>()
              .updateExpense(existingId, updatedExpense);
        }
      },
      child: Text('Save'),
    );
  }

  // MARK: Delete button -> deletes selected expense
  Widget _deleteExpenseButton(int id) {
    return MaterialButton(
      onPressed: () async {
        // pop the box
        Navigator.pop(context);

        // delete expense
        await context.read<ExpenseDatabase>().deleteExpense(id);
      },
      child: Text('Delete'),
    );
  }
}
