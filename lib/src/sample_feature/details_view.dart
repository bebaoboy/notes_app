import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/src/sample_feature/home_view.dart';

import '../../main.dart';
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
  final _contentController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _remindController = TextEditingController();
  final _idController = TextEditingController();

  @override
  void initState() {
    _titleController.value = TextEditingValue(
      text: widget.item.title,
      selection: TextSelection.fromPosition(
        TextPosition(offset: _newValue.length),
      ),
    );
    _contentController.value = TextEditingValue(
      text: widget.item.data,
      selection: TextSelection.fromPosition(
        TextPosition(offset: _newValue.length),
      ),
    );
    _dateController.value = TextEditingValue(
      text: widget.item.alarmed == null
          ? "Indefinitely"
          : DateFormat("dd/MM/yyyy").format(widget.item.alarmed!),
      selection: TextSelection.fromPosition(
        TextPosition(offset: _newValue.length),
      ),
    );
    _timeController.value = TextEditingValue(
      text: widget.item.alarmed == null
          ? ""
          : DateFormat("HH:mm").format(widget.item.alarmed!),
      selection: TextSelection.fromPosition(
        TextPosition(offset: _newValue.length),
      ),
    );
    _idController.value = TextEditingValue(
      text: '${widget.item.id}',
      selection: TextSelection.fromPosition(
        TextPosition(offset: _newValue.length),
      ),
    );
    super.initState();
  }

  final _newValue = "New value";
  List<int> remindList = [5, 10, 15, 20];
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _scrollController2 = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 74, 120, 246),
        title: const Text('Note Details'),
        actions: [
          IconButton(
            tooltip: "Get a demo notification",
            icon: const Icon(Icons.notifications_active),
            onPressed: () {
              notificationService.showNotification(
                cb,
                  title: "Notification for note id=${widget.item.id}",
                  body:
                      "${widget.item.title}\n\n${widget.item.data}\nAlarmed at ${widget.item.alarmed}",
                  payload: "${widget.item.id}");
            },
          ),
        ],
      ),
      floatingActionButton: const SpeedDial(
        label: Text("Edit"),
        tooltip: "Edit",
        elevation: 10,
        backgroundColor: Color.fromARGB(255, 74, 120, 246),
        child: Icon(Icons.edit),
      ),
      body: Container(
          margin: const EdgeInsets.fromLTRB(5, 30, 10, 30),
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
                          readOnly: true,
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
                            readOnly: true,
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
                                //getDateFromUser();
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
                                  hintText: widget.item.alarmed == null
                                      ? "Indefinitely"
                                      : DateFormat("dd/MM/yyyy")
                                          .format(widget.item.alarmed!),
                                  hintStyle: const TextStyle(
                                      color: Colors.black, fontSize: 20)),
                            ),
                          ),
                          Container(
                            child: IconButton(
                              icon: const Icon(Icons.calendar_month),
                              onPressed: () {
                                //getDateFromUser();
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
                                //getTimeFromUser();
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
                                  hintText: widget.item.alarmed == null
                                      ? ""
                                      : DateFormat("HH:mm")
                                          .format(widget.item.alarmed!),
                                  hintStyle: const TextStyle(
                                      color: Colors.black, fontSize: 20)),
                            ),
                          ),
                          Container(
                            child: IconButton(
                              icon: const Icon(Icons.access_time),
                              onPressed: () {
                                //getTimeFromUser();
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
                                  hintText: widget.item.alarmed == null
                                      ? ""
                                      : widget.item.remindBefore == 1 ? "Immediately" : "${widget.item.remindBefore} minutes",
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
                                // setState(() {
                                //   _selectedRemind = int.parse(value!);
                                // });
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
