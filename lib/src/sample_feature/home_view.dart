import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:notes_app/src/models/data.dart';
import 'package:notes_app/src/models/note.dart';
import 'package:notes_app/src/sample_feature/add_view.dart';
import 'package:notes_app/src/sample_feature/tab_list_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../settings/settings_view.dart';

Future<String> addToSP(List<Note> notes, {String code = 'allNotes'}) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    String s = Note.encode(notes);
    prefs.setString(code, s);
    return s;
  } catch (e) {
    SharedPreferences.setMockInitialValues({});
  }
  return "";
}

Future<List<Note>> getSP({String code = 'allNotes'}) async {
  final prefs = await SharedPreferences.getInstance();
  // print("sp: " + (prefs.getString('graphLists') ?? "[]"));
  print(code);
  final List<Note> jsonData = Note.decode(prefs.getString(code) ?? '[]');
  return jsonData;
}

/// Displays a list of SampleItems.
class HomeView extends StatefulWidget {
  const HomeView({
    super.key,
    required this.items,
  });

  static const routeName = '/';

  final List<Note> items;

  @override
  State<HomeView> createState() => _HomeViewState();
}

bool _showFab = true;

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    if (widget.items.isEmpty) {
      getSP().catchError((e) => print(e)).then((value) {
        sortData(value);
      });
      getSP(code: "deleted").catchError((e) => print(e)).then((value) {
        setState(() {
          deletedItems = value;
          print("deleted:" + deletedItems.toString());
        });
      });
    }
    super.initState();
  }

  void sortData(value) {
    setState(() {
      print(value);

      sampleData = value;
      widget.items.clear();
      widget.items.addAll(sampleData);
      widget.items.sort((Note a, Note b) {
        // print(a);
        // print("and");
        // print(b);
        if (a.alarmed == null) {
          return 1;
        } else {
          if (b.alarmed == null) return -1;
          return b.alarmed!.compareTo(a.alarmed!);
        }
      });

      widget.items.sort((Note a, Note b) {
        if (a.created == null) {
          return 1;
        } else {
          if (b.created == null) return -1;
          return b.created!.compareTo(a.created!);
        }
      });

      widget.items.sort((Note a, Note b) {
        if (a.alarmed != null && a.alarmed!.compareTo(DateTime.now()) == -1) {
          return 1;
        }
        return 0;
      });
    });
  }

  String searchVal = "";
  final duration = const Duration(milliseconds: 300);
  List<Note> currentItems = [];
  List<Note> deletedItems = [];

  void onSearchTextChanged(String value) {
    searchVal = value;
    setState(() {
      currentItems = widget.items
          .where((item) =>
              (value.isNotEmpty &&
                  item.title
                      .toLowerCase()
                      .contains(value.trim().toLowerCase())) ||
              (value.isEmpty))
          .toList();
    });

    print(currentItems);
  }

  void onCheckboxCallback(int id) {
    if (id >= 0) {
      setState(() {
        int i = widget.items.indexWhere((e) => e.id == id);
        if (i != -1) {
          widget.items[i].completed = !widget.items[i].completed;
          currentItems = widget.items
              .where((item) =>
                  (searchVal.isNotEmpty &&
                      item.title
                          .toLowerCase()
                          .contains(searchVal.trim().toLowerCase())) ||
                  (searchVal.isEmpty))
              .toList();
        }
      });
    }
  }

  void onDeleteCallback(int id) {
    if (id >= 0) {
      setState(() {
        int i = widget.items.indexWhere((e) => e.id == id);
        if (i != -1) {
          widget.items[i].title = 'Deleted: ${widget.items[i].title}';
          deletedItems = deletedItems +
              widget.items
                  .where(
                    (element) => element.title.startsWith("Deleted"),
                  )
                  .toList();
          widget.items.removeAt(i);
          currentItems = widget.items
              .where((item) =>
                  (searchVal.isNotEmpty &&
                      item.title
                          .toLowerCase()
                          .contains(searchVal.trim().toLowerCase())) ||
                  (searchVal.isEmpty))
              .toList();

          print(deletedItems);
        }
      });
      addToSP(widget.items);

      addToSP(deletedItems, code: 'deleted');
    }
  }

  void onRestoreCallback(int id) {
    if (id >= 0) {
      setState(() {
        int i = deletedItems.indexWhere((e) => e.id == id);
        if (i != -1) {
          deletedItems[i].title =
              deletedItems[i].title.substring('Deleted: '.length);

          widget.items.add(deletedItems[i]);

          deletedItems.removeAt(i);
          currentItems = widget.items
              .where((item) =>
                  (searchVal.isNotEmpty &&
                      item.title
                          .toLowerCase()
                          .contains(searchVal.trim().toLowerCase())) ||
                  (searchVal.isEmpty))
              .toList();

          print(deletedItems);
        }
      });
      addToSP(widget.items);
      addToSP(deletedItems, code: 'deleted');
    }
  }

  void onDeleteForeverCallback(int id) {
    if (id >= 0) {
      setState(() {
        deletedItems.removeWhere((element) => element.id == id);
      });
      addToSP(deletedItems, code: 'deleted');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: deletedItems.isNotEmpty ? 5 : 4,
        initialIndex: 0,
        child: Scaffold(
            // appBar: AppBar(
            //   title: const Text('My note'),
            //   actions: [
            //     IconButton(
            //       icon: const Icon(Icons.settings),
            //       onPressed: () {
            //         // Navigate to the settings page. If the user leaves and returns
            //         // to the app after it has been killed while running in the
            //         // background, the navigation stack is restored.
            //         Navigator.restorablePushNamed(
            //             context, SettingsView.routeName);
            //       },
            //     ),
            //   ],
            //   bottom: const TabBar(
            //     tabs: [
            //       Tab(
            //         icon: Icon(Icons.chat_bubble),
            //         text: "All",
            //       ),
            //       Tab(
            //         icon: Icon(Icons.video_call),
            //         text: "Today",
            //       ),
            //       Tab(
            //         icon: Icon(Icons.video_call),
            //         text: "Upcoming",
            //       ),
            //       Tab(
            //         icon: Icon(Icons.video_call),
            //         text: "Completed",
            //       )
            //     ],
            //   ),
            // ),

            // To work with lists that may contain a large number of items, it’s best
            // to use the ListView.builder constructor.
            //
            // In contrast to the default ListView constructor, which requires
            // building all Widgets up front, the ListView.builder constructor lazily
            // builds Widgets as they’re scrolled into view.
            floatingActionButton: AnimatedSlide(
              duration: duration,
              offset: _showFab ? Offset.zero : const Offset(0, 2),
              child: AnimatedOpacity(
                duration: duration,
                opacity: _showFab ? 1 : 0,
                child: SpeedDial(
                  backgroundColor: const Color.fromARGB(255, 74, 120, 246),

                  renderOverlay: true,
                  spaceBetweenChildren: 3,
                  closeDialOnPop: true,
                  closeManually: false,
                  useRotationAnimation: true,
                  animatedIcon: AnimatedIcons.menu_close,
                  icon: Icons.add,

                  animatedIconTheme: const IconThemeData(size: 22.0),
                  tooltip: 'Open Speed Dial',
                  heroTag: 'speed-dial-hero-tag',
                  // foregroundColor: Colors.black,
                  // backgroundColor: Colors.white,
                  // activeForegroundColor: Colors.red,
                  // activeBackgroundColor: Colors.blue,
                  elevation: 10.0,
                  animationCurve: Curves.elasticInOut,
//provide here features of your parent FAB
                  children: [
                    SpeedDialChild(
                      child: const Icon(Icons.add),
                      label: 'Add a note',
                      onTap: () async {
                        await Navigator.pushNamed(context, AddView.routeName)
                            .then(
                          (value) {
                            print("add");
                            setState(() {
                              addToSP(sampleData).then((value) => print(value));
                            });
                          },
                        );
                      },
                    ),
                    SpeedDialChild(
                      child: const Icon(Icons.settings),
                      label: 'Setting',
                      onTap: () {
                        Navigator.restorablePushNamed(
                            context, SettingsView.routeName);
                      },
                    ),
                    SpeedDialChild(
                      child: const Icon(Icons.sort),
                      label: 'Sort Date Desc',
                      onTap: null,
                    ),
                    SpeedDialChild(
                      child: const Icon(Icons.sort_by_alpha),
                      label: 'Sort Date Asc',
                      onTap: null,
                    ),
                  ],
                ),
              ),
            ),
            body: NotificationListener<UserScrollNotification>(
              onNotification: (notification) {
                final ScrollDirection direction = notification.direction;
                // setState(() {
                //   if (direction == ScrollDirection.reverse) {
                //     _showFab = false;
                //   } else {
                //     _showFab = true;
                //   }
                // });
                return true;
              },
              child: Column(
                children: [
                  Container(
                      color: const Color.fromARGB(255, 74, 120, 246),
                      child: Container(
                        margin: const EdgeInsets.only(top: 30),
                        child: Column(
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: TextField(
                                maxLines: 1,
                                onChanged: onSearchTextChanged,
                                textAlignVertical: TextAlignVertical.center,
                                style: const TextStyle(color: Colors.black),
                                onTapOutside: (event) {
                                  //print('onTapOutside');
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                decoration: InputDecoration(
                                    hintText: "Search notes...",
                                    hintStyle:
                                        const TextStyle(color: Colors.grey),
                                    prefixIcon: const Icon(
                                      Icons.search,
                                      color: Colors.grey,
                                    ),
                                    fillColor: Colors.white,
                                    contentPadding:
                                        const EdgeInsets.symmetric(vertical: 0),
                                    // suffix: IconButton(

                                    //   icon: Icon(Icons.close,
                                    //   color: Colors.grey,
                                    //   ),
                                    //   onPressed: () {},
                                    // ),
                                    filled: true,
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: const BorderSide(
                                            color: Colors.transparent))),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Material(
                              color: const Color.fromARGB(255, 74, 120, 246),
                              child: Theme(
                                //<-- SEE HERE
                                data: ThemeData()
                                    .copyWith(splashColor: Colors.white),
                                child: TabBar(
                                  onTap: (value) {
                                    getSP()
                                        .catchError((e) => print(e))
                                        .then((value) {
                                      sortData(value);
                                      ScaffoldMessenger.of(context)
                                          .removeCurrentSnackBar();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text('Loading Data'),
                                          duration: Duration(seconds: 1),
                                        ),
                                      );
                                    });
                                  },
                                  indicatorColor: Colors.white,
                                  labelColor: Colors.white,
                                  unselectedLabelColor: Colors.grey.shade800,
                                  labelStyle: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                  unselectedLabelStyle: const TextStyle(
                                    fontWeight: FontWeight.normal,
                                  ),
                                  tabs: deletedItems.isNotEmpty
                                      ? const [
                                          Tab(
                                            icon: Icon(Icons.upcoming),
                                            text: "Upcoming",
                                          ),
                                          
                                          Tab(
                                            icon: Icon(Icons.calendar_today),
                                            text: "Today",
                                          ),
                                          Tab(
                                            icon: Icon(
                                              Icons.chat_bubble,
                                            ),
                                            text: "All",
                                          ),
                                          Tab(
                                            icon: Icon(Icons.done_all),
                                            text: "Completed",
                                          ),
                                          Tab(
                                            icon: Icon(Icons.delete),
                                            text: "Deleted",
                                          ),
                                        ]
                                      : const [
                                          Tab(
                                            icon: Icon(Icons.upcoming),
                                            text: "Upcoming",
                                          ),
                                          
                                          Tab(
                                            icon: Icon(Icons.calendar_today),
                                            text: "Today",
                                          ),
                                          Tab(
                                            icon: Icon(
                                              Icons.chat_bubble,
                                            ),
                                            text: "All",
                                          ),
                                          Tab(
                                            icon: Icon(Icons.done_all),
                                            text: "Completed",
                                          ),
                                        ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                  Expanded(
                    flex: 1,
                    child: TabBarView(
                      children: deletedItems.isNotEmpty
                          ? [
                              TabListView(
                                id: 0,
                                items: searchVal.isEmpty
                                    ? widget.items
                                    : currentItems,
                                condition: (n) => !n.completed,
                                checkboxCallback: onCheckboxCallback,
                                deleteCallback: onDeleteCallback,
                              ),
                              TabListView(
                                id: 1,
                                items: searchVal.isEmpty
                                    ? widget.items
                                    : currentItems,
                                condition: (n) =>
                                    n.alarmed != null &&
                                    n.alarmed!.day == DateTime.now().day &&
                                    !n.completed,
                                checkboxCallback: onCheckboxCallback,
                                deleteCallback: onDeleteCallback,
                              ),
                              TabListView(
                                id: 2,
                                items: searchVal.isEmpty
                                    ? widget.items
                                    : currentItems,
                                condition: (n) => !n.completed,
                                checkboxCallback: onCheckboxCallback,
                                deleteCallback: onDeleteCallback,
                              ),
                              TabListView(
                                id: 3,
                                items: searchVal.isEmpty
                                    ? widget.items
                                    : currentItems,
                                condition: (n) => n.completed,
                                checkboxCallback: onCheckboxCallback,
                                deleteCallback: onDeleteCallback,
                              ),
                              TabListView(
                                id: 4,
                                items: deletedItems,
                                condition: (n) => n.title.startsWith("Deleted"),
                                checkboxCallback: onRestoreCallback,
                                deleteCallback: onDeleteForeverCallback,
                              ),
                            ]
                          : [
                              TabListView(
                                id: 0,
                                items: searchVal.isEmpty
                                    ? widget.items
                                    : currentItems,
                                condition: (n) => !n.completed,
                                checkboxCallback: onCheckboxCallback,
                                deleteCallback: onDeleteCallback,
                              ),
                              TabListView(
                                id: 1,
                                items: searchVal.isEmpty
                                    ? widget.items
                                    : currentItems,
                                condition: (n) =>
                                    n.alarmed != null &&
                                    n.alarmed!.day == DateTime.now().day &&
                                    !n.completed,
                                checkboxCallback: onCheckboxCallback,
                                deleteCallback: onDeleteCallback,
                              ),
                              TabListView(
                                id: 2,
                                items: searchVal.isEmpty
                                    ? widget.items
                                    : currentItems,
                                condition: (n) => !n.completed,
                                checkboxCallback: onCheckboxCallback,
                                deleteCallback: onDeleteCallback,
                              ),
                              TabListView(
                                id: 3,
                                items: searchVal.isEmpty
                                    ? widget.items
                                    : currentItems,
                                condition: (n) => n.completed,
                                checkboxCallback: onCheckboxCallback,
                                deleteCallback: onDeleteCallback,
                              ),
                            ],
                    ),
                  ),
                ],
              ),
            )));
  }
}
