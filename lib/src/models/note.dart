// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';

class Note {
  int id;
  String title = "";
  String data = "";
  DateTime? created = DateTime.now();
  DateTime? modified = DateTime.now();
  DateTime? alarmed;
  bool completed = false; //0: To-do, 1: Completed
  Color? color;
  int remindBefore;
  Note(
      {this.title = "",
      required this.data,
      this.completed = false,
      this.created,
      this.modified,
      required this.id,
      this.color,
      this.alarmed,
      this.remindBefore = 10});

  Note copyWith({
    String? data,
    bool? completed,
  }) {
    return Note(
      id: id,
      data: data ?? this.data,
      title: title,
      completed: completed ?? this.completed,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'data': data,
      'completed': completed,
      'created': created != null ? created.toString() : '',
      'modified': modified != null ? modified.toString() : '',
      'id': id,
      'alarmed': alarmed != null ? alarmed.toString() : '',
      'color': color != null ? '${color!.value}' : "",
      'remindBefore': remindBefore,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as int,
      remindBefore: map['remindBefore'] == null ? 10 : map['remindBefore'] as int,
      data: map['data'] as String,
      title: map['title'] as String,
      completed: map['completed'] as bool,
      created: map['created'] == '' ? null : DateTime.parse(map['created']),
      modified: map['modified'] == '' ? null : DateTime.parse(map['modified']),
      alarmed: map['alarmed'] == '' ? null : DateTime.parse(map['alarmed']),
      color: map['color'] == '' ? null : Color(int.parse(map['color'])),
    );
  }

  String toJson() => json.encode(toMap());

  factory Note.fromJson(String source) =>
      Note.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'Note #$id: \n\ttitle: $title, \n\tdata: $data, \n\tcompleted: $completed, \n\tcreated: $created, \n\talarm: $alarmed, \n\tbefore: $remindBefore)';

  @override
  bool operator ==(covariant Note other) {
    if (identical(this, other)) return true;

    return other.data == data && other.completed == completed;
  }

  @override
  int get hashCode => data.hashCode ^ completed.hashCode;

  static String encode(List<Note> notes) => json.encode(
        notes.map<Map<String, dynamic>>((note) => note.toMap()).toList(),
      );

  static List<Note> decode(String notes) =>
      (json.decode(notes) as List<dynamic>)
          .map<Note>((item) => Note.fromMap(item))
          .toList();
}
