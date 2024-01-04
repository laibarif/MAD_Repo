import 'package:flutter/material.dart';
import 'database.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DatabaseFileRoutines _databaseFileRoutines = DatabaseFileRoutines();
  List<Journal> journals = [];

  @override
  void initState() {
    super.initState();
    _loadJournals();
  }

  Future<void> _loadJournals() async {
    try {
      String jsonContents = await _databaseFileRoutines.readJournals();
      Database database = _databaseFileRoutines.databaseFromJson(jsonContents);

      setState(() {
        journals = database.journal;
      });
    } catch (e) {
      print("Error loading journals: $e");
    }
  }

  Widget _buildListViewSeparated() {
    return ListView.builder(
      itemCount: journals.length,
      itemBuilder: (context, index) {
        final journal = journals[index];
        return ListTile(
          title: Text(journal.title),
          subtitle: Text(journal.date.toIso8601String()),
          // Add more details as needed
        );
      },
    );
  }

  void _addOrEditJournal({required bool add, required int index, required Journal journal}) async {
    if (add) {
      setState(() {
        journals.add(journal);
      });
    } else {
      setState(() {
        journals[index] = journal;
      });
    }

    await _saveJournals();
  }

  Future<void> _saveJournals() async {
    try {
      Database database = Database(journal: journals);
      String jsonContents = _databaseFileRoutines.databaseToJson(database);
      await _databaseFileRoutines.writeJournals(jsonContents);
    } catch (e) {
      print("Error saving journals: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Journal App'),
      ),
      body: _buildListViewSeparated(),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Padding(padding: const EdgeInsets.all(24.0)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Journal Entry',
        child: Icon(Icons.add),
        onPressed: () {
          _addOrEditJournal(
              add: true, index: -1, journal: Journal(date: DateTime.now(), title: 'New Entry', body: ''));
        },
      ),
    );
  }
}
