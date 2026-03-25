import 'dart:io';

void main() async {
  final result = await Process.run('dart', ['analyze', '--format=machine']);
  final lines = result.stdout.toString().split('\n');
  final errors = lines.where((l) => l.contains('transaction_form_view')).toList();
  for (var err in errors) print(err);
}
