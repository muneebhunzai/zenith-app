import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import '../models/transaction_item.dart';

class CsvExportService {
  static Future<String> exportTransactions(List<TransactionItem> transactions) async {
    final List<List<dynamic>> rows = [
      ['ID', 'Type', 'Amount', 'Category', 'Date', 'Note', 'Created At']
    ];

    for (var tx in transactions) {
      rows.add([
        tx.id,
        tx.type.toUpperCase(),
        tx.amount.toStringAsFixed(2),
        tx.category,
        tx.date,
        tx.note.replaceAll('\n', ' '),
        tx.createdAt,
      ]);
    }

    final String csvData = const ListToCsvConverter().convert(rows);

    final directory = await getApplicationDocumentsDirectory();
    final String timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').substring(0, 19);
    final String filePath = '${directory.path}/zenith_transactions_$timestamp.csv';

    final File file = File(filePath);
    await file.writeAsString(csvData);

    return filePath;
  }
}
