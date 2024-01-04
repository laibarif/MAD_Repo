import 'package:flutter/material.dart';
import 'package:ch13_local_persistence/pages/database.dart';
import 'package:intl/intl.dart'; // Format Dates
import 'dart:math'; // Random() numbers

class EditEntry extends StatefulWidget {
  final bool add;
  final int index;
  final JournalEdit journalEdit;

  const EditEntry({
    Key? key,
    required this.add,
    required this.index,
    required this.journalEdit,
  }) : super(key: key);

  @override
  _EditEntryState createState() => _EditEntryState();
}

class _EditEntryState extends State<EditEntry> {
  late JournalEdit _journalEdit;
  late String _title;
  late DateTime? _selectedDate;
  late TextEditingController _moodController;
  late TextEditingController _noteController;
  late FocusNode _moodFocus;
  late FocusNode _noteFocus;

  @override
  void initState() {
    super.initState();
    _journalEdit = widget.journalEdit;
    _title = widget.add ? 'Add' : 'Edit';
    _selectedDate = widget.add ? DateTime.now() : DateTime.parse(_journalEdit.journal?.date ?? '');
    _moodController = TextEditingController(text: widget.add ? '' : _journalEdit.journal?.mood ?? '');
    _noteController = TextEditingController(text: widget.add ? '' : _journalEdit.journal?.note ?? '');
    _moodFocus = FocusNode();
    _noteFocus = FocusNode();
  }

  @override
  dispose() {
    _moodController.dispose();
    _noteController.dispose();
    _moodFocus.dispose();
    _noteFocus.dispose();
    super.dispose();
  }

  Future<DateTime?> _selectDate(DateTime? selectedDate) async {
    DateTime initialDate = selectedDate ?? DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (pickedDate != null) {
      selectedDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        initialDate.hour,
        initialDate.minute,
        initialDate.second,
        initialDate.millisecond,
        initialDate.microsecond,
      );
    }

    return selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$_title Entry'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextButton(
                onPressed: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  DateTime? pickerDate = await _selectDate(_selectedDate);
                  if (pickerDate != null) {
                    setState(() {
                      _selectedDate = pickerDate;
                    });
                  }
                },
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.calendar_today,
                      size: 22.0,
                      color: Colors.black54,
                    ),
                    SizedBox(width: 16.0,),
                    Text(
                      DateFormat.yMMMEd().format(_selectedDate ?? DateTime.now()),
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
              TextField(
                controller: _moodController,
                autofocus: true,
                textInputAction: TextInputAction.next,
                focusNode: _moodFocus,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Mood',
                  icon: Icon(Icons.mood),
                ),
                onSubmitted: (submitted) {
                  FocusScope.of(context).requestFocus(_noteFocus);
                },
              ),
              TextField(
                controller: _noteController,
                textInputAction: TextInputAction.newline,
                focusNode: _noteFocus,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Note',
                  icon: Icon(Icons.subject),
                ),
                maxLines: null,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      _journalEdit.action = 'Cancel';
                      Navigator.pop(context, _journalEdit);
                    },
                    child: Text('Cancel'),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                    ),
                  ),
                  SizedBox(width: 8.0),
                  TextButton(
                    onPressed: () {
                      _journalEdit.action = 'Save';
                      String _id = widget.add ? Random().nextInt(9999999).toString() : _journalEdit.journal?.id ?? '';
                      _journalEdit.journal = Journal(
                        id: _id,
                        date: _selectedDate?.toString() ?? '',
                        mood: _moodController.text,
                        note: _noteController.text,
                      );
                      Navigator.pop(context, _journalEdit);
                    },
                    child: Text('Save'),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.lightGreen.shade100,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
