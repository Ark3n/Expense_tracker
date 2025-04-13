import 'package:isar/isar.dart';

// this line is needed to generate isar file
// run this command in terminal: dart run build_runner build
part 'expense.g.dart';

@Collection()
class Expense {
  Id id = Isar.autoIncrement; // 1, 2, 3, 4 ...
  final String name;
  final double amount;
  final DateTime date;

  Expense({
    required this.name,
    required this.amount,
    required this.date,
  });
}
