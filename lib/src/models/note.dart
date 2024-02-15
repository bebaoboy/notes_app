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
  Note(
      {this.title = "",
      required this.data,
      this.completed = false,
      this.created,
      this.modified,
      required this.id,
      this.color,
      this.alarmed});

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
      'modified': modified != null ? modified.toString(): '',
      'id': id,
      'alarmed': alarmed != null ? alarmed.toString() : ''
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as int,
      data: map['data'] as String,
      title: map['title'] as String,
      completed: map['completed'] as bool,
      created: map['created'] == '' ? null : DateTime.parse(map['created']),
      modified: map['modified'] == '' ? null : DateTime.parse(map['modified']),
      alarmed: map['alarmed'] == '' ? null : DateTime.parse(map['alarmed']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Note.fromJson(String source) =>
      Note.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Note(title: $title, data: $data, completed: $completed, created: $created, alarm: $alarmed)';

  @override
  bool operator ==(covariant Note other) {
    if (identical(this, other)) return true;

    return other.data == data && other.completed == completed;
  }

  @override
  int get hashCode => data.hashCode ^ completed.hashCode;
}
