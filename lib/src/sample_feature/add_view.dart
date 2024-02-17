import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/main.dart';
import 'package:notes_app/src/models/data.dart';
import 'package:notes_app/src/sample_feature/tab_list_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:vibration/vibration.dart';

import '../models/note.dart';
import 'details_view.dart';

/// Displays detailed information about a SampleItem.
class AddView extends StatefulWidget {
  const AddView({super.key, required this.id});

  static const routeName = '/add';
  final int id;

  @override
  State<AddView> createState() => _AddViewState();
}

timer(context, newNote) {
  int counter = 100;
  Timer.periodic(
      const Duration(
        seconds: 1,
      ), (timer) {
    Vibration.cancel();

    counter--;
    print(counter);
    if (counter == 0) {
      timer.cancel();
      Vibration.cancel();
    }
    Vibration.vibrate(pattern: [100, 200, 400], repeat: 1);
    notificationService.showPersistentNotification((payload) async {
      if (context != null) {
        Navigator.restorablePushNamed(context, DetailView.routeName,
            arguments: newNote.toMap());
        notificationService.mainPlugin.cancel(1000);
        timer.cancel();
        Vibration.cancel();
      }
    },
        title: "Follow-up attack: id=${newNote.id}",
        body:
            "Tap to dismiss!\n${newNote.title}\n${newNote.data}\nGO OFF at ${newNote.alarmed}",
        payload: "${newNote.id}");
  });
}

class _AddViewState extends State<AddView> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _remindController = TextEditingController();
  final _idController = TextEditingController();

  DateTime? _selectedDate = null;
  // String _selectedTime = DateFormat("HH:mm").format(DateTime.now());
  String _selectedTime = "";
  int _selectedRemind = 1;
  List<int> remindList = [1, 5, 10, 15, 20];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _titleController.value = TextEditingValue(
      text: "",
      selection: TextSelection.fromPosition(
        TextPosition(offset: _newValue.length),
      ),
    );
    _contentController.value = TextEditingValue(
      text: "",
      selection: TextSelection.fromPosition(
        TextPosition(offset: _newValue.length),
      ),
    );
    _idController.value = TextEditingValue(
      text: '${widget.id}',
      selection: TextSelection.fromPosition(
        TextPosition(offset: _newValue.length),
      ),
    );
    super.initState();
  }

  final _newValue = "New value";
  final ScrollController _scrollController = ScrollController();
  final ScrollController _scrollController2 = ScrollController();

  getDateFromUser() async {
    DateTime? picker = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1990),
        lastDate: DateTime(2099));
    if (picker != null) {
      setState(() {
        if (_selectedDate != null) {
          _selectedDate = DateTime(picker.year, picker.month, picker.day,
              _selectedDate!.hour, _selectedDate!.minute);
        } else {
          _selectedDate = DateTime(picker.year, picker.month, picker.day);
        }
      });
      if (_selectedDate != null && _selectedDate!.day < DateTime.now().day) {
        final snackBar = SnackBar(
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.red,
          content: const Text(
            'Warning: You are choosing date in the past!',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          action: SnackBarAction(
            textColor: Colors.white,
            label: 'OK',
            onPressed: () {
              // Some code to undo the change.
            },
          ),
        );

        // Find the ScaffoldMessenger in the widget tree
        // and use it to show a SnackBar.
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  getTimeFromUser() async {
    TimeOfDay t = TimeOfDay.now();
    DateTime d = DateTime.now();
    TimeOfDay? picker = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child ?? Container(),
        );
      },
    );
    if (picker != null) {
      if (_selectedDate == null) {
        final snackBar = SnackBar(
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.red,
          content: const Text(
            'Warning: Choose a date first!',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          action: SnackBarAction(
            textColor: Colors.white,
            label: 'OK',
            onPressed: () {
              // Some code to undo the change.
            },
          ),
        );

        // Find the ScaffoldMessenger in the widget tree
        // and use it to show a SnackBar.
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else if (_selectedDate!.day <= d.day &&
          (picker.hour < t.hour && picker.minute < t.minute)) {
        final snackBar = SnackBar(
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.red,
          content: const Text(
            'Warning: You are choosing time in the past!',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          action: SnackBarAction(
            textColor: Colors.white,
            label: 'OK',
            onPressed: () {
              // Some code to undo the change.
            },
          ),
        );

        // Find the ScaffoldMessenger in the widget tree
        // and use it to show a SnackBar.
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        setState(() {
          TimeOfDay t = picker;
          _selectedDate = DateTime(_selectedDate!.year, _selectedDate!.month,
              _selectedDate!.day, t.hour, t.minute);
          _selectedTime = DateFormat("HH:mm").format(_selectedDate!);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 74, 120, 246),
        title: const Text('Note Details'),
      ),
      floatingActionButton: SpeedDial(
        label: const Text("Save"),
        tooltip: "Save",
        elevation: 10,
        backgroundColor: const Color.fromARGB(255, 74, 120, 246),
        child: const Icon(Icons.save),
        onPress: () async {
          // Validate returns true if the form is valid, or false otherwise.
          if (_formKey.currentState!.validate()) {
            if (_selectedDate != null &&
                _selectedDate!
                        .subtract(Duration(minutes: _selectedRemind))
                        .compareTo(DateTime.now()) <=
                    0) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Please choose the reminder after ${DateFormat("dd/MM/yyyy HH:mm").format(DateTime.now().add(Duration(minutes: _selectedRemind)))}'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }
            var newNote = Note(
                data: _contentController.text,
                id: widget.id + 1,
                title: _titleController.text,
                created: DateTime.now(),
                modified: DateTime.now(),
                alarmed: _selectedDate,
                color: getRandomColor(),
                remindBefore: _selectedRemind);
            print(newNote);

            final prefs = await SharedPreferences.getInstance();
            prefs.setString("currentID", '${widget.id + 1}');

            if (newNote.alarmed != null) {
              var tzd = TZDateTime(
                  tz.local,
                  newNote.alarmed!.year,
                  newNote.alarmed!.month,
                  newNote.alarmed!.day,
                  newNote.alarmed!.hour,
                  newNote.alarmed!.minute);
              print(tzd);

              notificationService.showScheduleNotification((payload) async {
                if (navigatorKey.currentState == null) return;
                int i = int.parse(payload);
                timer(navigatorKey.currentState!.context, newNote);
                //print(widget.items.firstWhere((element) => element.id == i));
                Navigator.restorablePushNamed(
                    navigatorKey.currentState!.context, DetailView.routeName,
                    arguments: newNote.toMap());
              },
                  title: "Id=${newNote.id}",
                  body:
                      "Scheduled note: ${newNote.title}\n\n${newNote.data}\nGO OFF at ${newNote.alarmed}",
                  payload: "${newNote.id}",
                  duration: tzd
                      .subtract(Duration(minutes: newNote.remindBefore))
                      .add(const Duration(seconds: 1)));
            }

            setState(() {
              sampleData.insert(0, newNote);
            });

            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Done! Alarm is set at ${newNote.alarmed == null ? "Indefinitely" : newNote.alarmed!}'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please fill in the text!'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
      body: Container(
          margin: const EdgeInsets.fromLTRB(5, 30, 10, 10),
          child: Scrollbar(
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: TextFormField(
                        controller: _idController,
                        readOnly: true,
                        maxLines: 1,
                        style: const TextStyle(
                          height: 1.5,
                          color: Colors.black,
                          fontSize: 20,
                        ),
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(left: 20),
                            // filled: true,
                            label: const Text("Id"),
                            labelStyle: const TextStyle(
                                color: Color.fromARGB(255, 74, 120, 246),
                                fontSize: 20,
                                fontWeight: FontWeight.w600),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            border: InputBorder.none,
                            hintText: "Id",
                            hintStyle: TextStyle(
                                color: Colors.grey.shade800, fontSize: 20)),
                      ),
                    ),
                  ),
                  Scrollbar(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null &&
                                _titleController.text.isEmpty) {
                              return "Either title or content must be entered!";
                            }
                          },
                          scrollController: _scrollController,
                          controller: _titleController,
                          keyboardType: TextInputType.multiline,
                          maxLines: 2,
                          minLines: 1,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 50,
                              fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                              //filled: true,
                              label: const Text("Title"),
                              labelStyle: const TextStyle(
                                  color: Color.fromARGB(255, 74, 120, 246),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              contentPadding: const EdgeInsets.only(left: 5),
                              // border: const UnderlineInputBorder(
                              //     //Outline border type for TextFeild
                              //     borderRadius:
                              //         BorderRadius.all(Radius.circular(10)),
                              //     borderSide: BorderSide(
                              //       color: Colors.black,
                              //       width: 1,
                              //     )),
                              // enabledBorder: const UnderlineInputBorder(
                              //     //Outline border type for TextFeild
                              //     borderRadius:
                              //         BorderRadius.all(Radius.circular(10)),
                              //     borderSide: BorderSide(
                              //       color: Colors.black,
                              //       width: 1,
                              //     )),
                              border: InputBorder.none,
                              hintText: "Title",
                              hintStyle: TextStyle(
                                  color: Colors.grey.shade800, fontSize: 50)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Scrollbar(
                      thumbVisibility: true,
                      interactive: true,
                      controller: _scrollController2,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: TextFormField(
                            validator: (value) {
                              if ((value == null || value.isEmpty) &&
                                  _titleController.text.isEmpty) {
                                return "Either title or content must be entered!";
                              }
                            },
                            scrollController: _scrollController2,
                            controller: _contentController,
                            keyboardType: TextInputType.multiline,
                            maxLines: 7,
                            minLines: 2,
                            textAlign: TextAlign.justify,
                            style: const TextStyle(
                              height: 1.5,
                              color: Colors.black,
                              fontSize: 20,
                            ),
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.only(left: 20),
                                // filled: true,
                                label: const Text("Content"),
                                labelStyle: const TextStyle(
                                    color: Color.fromARGB(255, 74, 120, 246),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                border: InputBorder.none,
                                hintText: "Type your content",
                                hintStyle: TextStyle(
                                    color: Colors.grey.shade800, fontSize: 20)),
                          ),
                        ),
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              onTap: () {
                                getDateFromUser();
                              },
                              readOnly: true,
                              controller: _dateController,
                              keyboardType: TextInputType.multiline,
                              maxLines: 1,
                              textAlign: TextAlign.justify,
                              style: const TextStyle(
                                height: 1.5,
                                color: Colors.black,
                                fontSize: 20,
                              ),
                              decoration: InputDecoration(
                                  contentPadding:
                                      const EdgeInsets.only(left: 20),
                                  // filled: true,
                                  label: const Text("Date"),
                                  labelStyle: const TextStyle(
                                      color: Color.fromARGB(255, 74, 120, 246),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                  border: InputBorder.none,
                                  hintText: _selectedDate == null
                                      ? "Choose a date"
                                      : DateFormat("dd/MM/yyyy")
                                          .format(_selectedDate!),
                                  hintStyle: const TextStyle(
                                      color: Colors.black, fontSize: 20)),
                            ),
                          ),
                          Container(
                            child: IconButton(
                              icon: const Icon(Icons.calendar_month),
                              onPressed: () {
                                getDateFromUser();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              onTap: () {
                                getTimeFromUser();
                              },
                              readOnly: true,
                              controller: _timeController,
                              keyboardType: TextInputType.multiline,
                              maxLines: 1,
                              textAlign: TextAlign.justify,
                              style: const TextStyle(
                                height: 1.5,
                                color: Colors.black,
                                fontSize: 20,
                              ),
                              decoration: InputDecoration(
                                  contentPadding:
                                      const EdgeInsets.only(left: 20),
                                  // filled: true,
                                  label: const Text("Reminder time"),
                                  labelStyle: const TextStyle(
                                      color: Color.fromARGB(255, 74, 120, 246),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                  border: InputBorder.none,
                                  hintText: _selectedTime.isNotEmpty
                                      ? _selectedTime
                                      : "Choose a reminder time",
                                  hintStyle: const TextStyle(
                                      color: Colors.black, fontSize: 20)),
                            ),
                          ),
                          Container(
                            child: IconButton(
                              icon: const Icon(Icons.access_time),
                              onPressed: () {
                                getTimeFromUser();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              onTap: () {},
                              readOnly: true,
                              controller: _remindController,
                              keyboardType: TextInputType.multiline,
                              maxLines: 1,
                              textAlign: TextAlign.justify,
                              style: const TextStyle(
                                height: 1.5,
                                color: Colors.black,
                                fontSize: 20,
                              ),
                              decoration: InputDecoration(
                                  contentPadding:
                                      const EdgeInsets.only(left: 20),
                                  // filled: true,
                                  label: const Text("Reminder before..."),
                                  labelStyle: const TextStyle(
                                      color: Color.fromARGB(255, 74, 120, 246),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                  border: InputBorder.none,
                                  hintText: _selectedRemind == 1
                                      ? "Immediately"
                                      : "$_selectedRemind minutes",
                                  hintStyle: const TextStyle(
                                      color: Colors.black, fontSize: 20)),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 10),
                            child: DropdownButton(
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                              ),
                              underline: Container(height: 0),
                              iconSize: 32,
                              elevation: 4,
                              onChanged: (value) {
                                setState(() {
                                  _selectedRemind = int.parse(value!);
                                  print(_selectedRemind);
                                });
                              },
                              items: remindList.map<DropdownMenuItem<String>>(
                                (int value) {
                                  return DropdownMenuItem<String>(
                                    value: value.toString(),
                                    child: Text(value.toString()),
                                  );
                                },
                              ).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          // Text(widget.item.toString()),
          ),
    );
  }
}
