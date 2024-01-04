import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

class DatabaseFileRoutines {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/local_persistence.json');
  }

  Future<String> readJournals() async {
    try {
      final file = await _localFile;
      if (!file.existsSync()) {
        print("File does not Exist: ${file.absolute}");
        await writeJournals('{"journals": []}');
      }
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      print("error readJournals: $e");
      return "";
    }
  }

  Future<File> writeJournals(String json) async {
    final file = await _localFile;
    return file.writeAsString('$json');
  }

  Database databaseFromJson(String str) {
    final dataFromJson = json.decode(str);
    return Database.fromJson(dataFromJson);
  }

  String databaseToJson(Database data) {
    final dataToJson = data.toJson();
    return json.encode(dataToJson);
  }
}

class Database {
  List<Journal> journal;

  Database({
    required this.journal,
  });

  factory Database.fromJson(Map<String, dynamic> json) {
    return Database(
      journal: List<Journal>.from(
        (json["journals"] as List<dynamic>? ?? []).map((x) => Journal.fromJson(x)),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    "journals": List<dynamic>.from(journal.map((x) => x.toJson())),
  };
}

class Journal {
  String title;
  String body;
  DateTime date;

  Journal({
    required this.title,
    required this.body,
    required this.date,
  });

  factory Journal.fromJson(Map<String, dynamic> json) {
    return Journal(
      title: json["title"] as String? ?? "", // Provide a default value if needed
      body: json["body"] as String? ?? "",   // Provide a default value if needed
      date: DateTime.parse(json["date"] as String? ?? ""), // Provide a default value if needed
    );
  }

  Map<String, dynamic> toJson() => {
    "title": title,
    "body": body,
    "date": date.toIso8601String(),
  };
}

class JournalEdit {
  String action;
  Journal? journal;

  JournalEdit({required this.action, this.journal});
}
