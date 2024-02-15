import 'dart:math';

import 'package:flutter/material.dart';
import 'package:notes_app/src/models/note.dart';
import 'package:notes_app/src/sample_feature/details_view.dart';

import '../models/colors.dart';

class TabListView extends StatefulWidget {
  TabListView(
      {super.key,
      required this.items,
      required this.condition,
      required this.id,
      required this.checkboxCallback,
      required this.deleteCallback});
  List<Note> items;
  final int id;
  final Function(Note)? condition;
  final Function(int)? checkboxCallback;
  final Function(int)? deleteCallback;

  @override
  State<TabListView> createState() => _TabListViewState();
}

class _TabListViewState extends State<TabListView> {
  getRandomColor() {
      Random random = Random();

    return backgroundColors[random.nextInt(backgroundColors.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scrollbar(
        child: ListView.builder(
          // Providing a restorationId allows the ListView to restore the
          // scroll position when a user leaves and returns to the app after it
          // has been killed while running in the background.
          restorationId: 'View ${widget.id}',
          itemCount: widget.items.length,
          itemBuilder: (BuildContext context, int index) {
            final item = widget.items[index];
            if (widget.items[index].title.isEmpty) {
              widget.items[index].title = 'Untitled Note ${item.id}';
            }

            if (widget.items[index].color == null) {
              widget.items[index].color = getRandomColor();
              //widget.items[index].color = Colors.white;
            }

            return (widget.condition != null && !widget.condition!(item))
                ? const SizedBox()
                : Card(
                    color: item.color,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: RichText(
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                              text: item.title,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                height: 1.5,
                              ),
                              children: [
                                TextSpan(
                                  text: '\n${item.data}',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 16,
                                    height: 1.3,
                                  ),
                                )
                              ]),
                        ),
                        subtitle: Text(
                          "Edited: ${item.created}",
                          style: TextStyle(
                            fontSize: 10,
                            height: 1.7,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        // leading: const CircleAvatar(
                        //   // Display the Flutter Logo image asset.
                        //   foregroundImage: AssetImage(
                        //       'assets/images/flutter_logo.png'),
                        // ),
                        // leading: IconButton(icon: Icon(Icons.check_box_outline_blank, size: 30,), onPressed: () {},),
                        onTap: () {
                          // Navigate to the details page. If the user leaves and returns to
                          // the app after it has been killed while running in the
                          // background, the navigation stack is restored.
                          Navigator.restorablePushNamed(
                            context,
                            DetailView.routeName,
                            arguments: item.toMap()
                          );
                        },
                        trailing: Wrap(
                          spacing: 12,
                          children: [
                            IconButton(
                              onPressed: () {
                                if (widget.checkboxCallback != null) {
                                  widget.checkboxCallback!(item.id);
                                }
                              },
                              icon: item.completed == true
                                  ? const Icon(Icons.check_box)
                                  : const Icon(Icons.check_box_outline_blank),
                            ),
                            IconButton(
                              onPressed: () {
                                if (widget.deleteCallback != null) {
                                  widget.deleteCallback!(item.id);
                                }
                              },
                              icon: const Icon(Icons.delete),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
          },
        ),
      ),
    );
  }
}
