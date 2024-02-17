import 'package:flutter/material.dart';
import 'package:notes_app/src/sample_feature/home_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_controller.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends StatefulWidget {
  const SettingsView({super.key, required this.controller});

  static const routeName = '/settings';

  final SettingsController controller;

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final ScrollController _scrollController2 = ScrollController();
  final _contentController = TextEditingController();
  final _contentController2 = TextEditingController();
  final _newValue = "New value";

  getLog() async {
    await getSP().then((data) {
      StringBuffer sb = StringBuffer();
      sb.writeAll(data, "\n\n");

      _contentController.value = TextEditingValue(
        text: sb.toString(),
        selection: TextSelection.fromPosition(
          TextPosition(offset: _newValue.length),
        ),
      );
    });
    final prefs = await SharedPreferences.getInstance();
    String s = prefs.getString("currentID") ?? "0";

    _contentController2.value = TextEditingValue(
        text: s,
        selection: TextSelection.fromPosition(
          TextPosition(offset: _newValue.length),
        ),
      );
  }

  @override
  void initState() {
    getLog();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color.fromARGB(255, 74, 120, 246),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        // Glue the SettingsController to the theme selection DropdownButton.
        //
        // When a user selects a theme from the dropdown list, the
        // SettingsController is updated, which rebuilds the MaterialApp.
        child: Column(
          children: [
            DropdownButton<ThemeMode>(
              // Read the selected themeMode from the controller
              value: widget.controller.themeMode,
              // Call the updateThemeMode method any time the user selects a theme.
              onChanged: widget.controller.updateThemeMode,
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('System Theme'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text('Light Theme'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text('Dark Theme'),
                )
              ],
            ),
            const SizedBox(height: 10,),
            Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: TextFormField(
                      readOnly: true,
                      controller: _contentController2,
                      keyboardType: TextInputType.multiline,
                      maxLines: 1,
                      minLines: 1,
                      textAlign: TextAlign.justify,
                      style: const TextStyle(
                        height: 1.5,
                        color: Colors.black,
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(left: 20),
                          // filled: true,
                          label: const Text("Current ID"),
                          labelStyle: const TextStyle(
                              color: Color.fromARGB(255, 74, 120, 246),
                              fontSize: 20,
                              fontWeight: FontWeight.w600),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          border: InputBorder.none,
                          hintText: "Type your content",
                          hintStyle: TextStyle(
                              color: Colors.grey.shade800, fontSize: 20)),
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
                      scrollController: _scrollController2,
                      controller: _contentController,
                      keyboardType: TextInputType.multiline,
                      maxLines: 20,
                      minLines: 2,
                      textAlign: TextAlign.justify,
                      style: const TextStyle(
                        height: 1.5,
                        color: Colors.black,
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(left: 20),
                          // filled: true,
                          label: const Text("Data log"),
                          labelStyle: const TextStyle(
                              color: Color.fromARGB(255, 74, 120, 246),
                              fontSize: 20,
                              fontWeight: FontWeight.w600),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          border: InputBorder.none,
                          hintText: "Type your content",
                          hintStyle: TextStyle(
                              color: Colors.grey.shade800, fontSize: 20)),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
