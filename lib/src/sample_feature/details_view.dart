import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';

import '../models/note.dart';

/// Displays detailed information about a SampleItem.
class DetailView extends StatefulWidget {
  const DetailView({super.key, required this.item});

  static const routeName = '/detail';
  final Note item;

  @override
  State<DetailView> createState() => _DetailViewState();
}

class _DetailViewState extends State<DetailView> {
  final _titleController = TextEditingController();
  final _dataController = TextEditingController();
    final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _remindController = TextEditingController();

  @override
  void initState() {
    _titleController.value = TextEditingValue(
      text: widget.item.title,
      selection: TextSelection.fromPosition(
        TextPosition(offset: _newValue.length),
      ),
    );
    _dataController.value = TextEditingValue(
      text: widget.item.data,
      selection: TextSelection.fromPosition(
        TextPosition(offset: _newValue.length),
      ),
    );
    _dateController.value = TextEditingValue(
      text: widget.item.created == null ? "" : DateFormat().format(widget.item.created!),
      selection: TextSelection.fromPosition(
        TextPosition(offset: _newValue.length),
      ),
    );
    _timeController.value = TextEditingValue(
      text: widget.item.alarmed == null ? "" : DateFormat().format(widget.item.alarmed!),
      selection: TextSelection.fromPosition(
        TextPosition(offset: _newValue.length),
      ),
    );
    super.initState();
  }

  final _newValue = "New value";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 74, 120, 246),
        title: const Text('Note Details'),
      ),
      floatingActionButton: const SpeedDial(
        label: Text("Edit"),
        tooltip: "Edit",
        elevation: 10,
        backgroundColor: Color.fromARGB(255, 74, 120, 246),
        child: Icon(Icons.edit),
      ),
      body: Container(
        margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Center(
            child: ListView(
          children: [
            TextField(
              readOnly: true,
              controller: _titleController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 50,
                  fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Title",
                  hintStyle:
                      TextStyle(color: Colors.grey.shade800, fontSize: 50)),
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              readOnly: true,
              controller: _dataController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              textAlign: TextAlign.justify,
              style: const TextStyle(
                height: 1.5,
                color: Colors.black,
                fontSize: 20,
              ),
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Content",
                  hintStyle:
                      TextStyle(color: Colors.grey.shade800, fontSize: 20)),
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              readOnly: true,
              controller: _dateController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              textAlign: TextAlign.justify,
              style: const TextStyle(
                height: 1.5,
                color: Colors.black,
                fontSize: 20,
              ),
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Created Date",
                  hintStyle:
                      TextStyle(color: Colors.grey.shade800, fontSize: 20)),
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              readOnly: true,
              controller: _timeController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              textAlign: TextAlign.justify,
              style: const TextStyle(
                height: 1.5,
                color: Colors.black,
                fontSize: 20,
              ),
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Reminder Time",
                  hintStyle:
                      TextStyle(color: Colors.grey.shade800, fontSize: 20)),
            ),
            
          ],
        )
            // Text(widget.item.toString()),
            ),
      ),
    );
  }
}
