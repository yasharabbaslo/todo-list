import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_list/data.dart';
import 'package:todo_list/edit.dart';

const taskBoxName = 'taks';
const Color primaryColor = Color(0xff794cff);
const Color primaryContainerColor = Color(0xff5c0aff);
const secondaryTextColor = Color(0xffafbed0);
const normalPriorityColor = Color(0xfff09819);
const lowPriorityColor = Color(0xff3be1f1);
const highPriorityColor = primaryColor;

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(PriorityAdapter());
  await Hive.openBox<TaskData>(taskBoxName);
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: primaryContainerColor));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const primaryTextColor = Color(0xff1d2830);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(
            TextTheme(headline6: TextStyle(fontWeight: FontWeight.bold))),
        inputDecorationTheme: const InputDecorationTheme(
          floatingLabelBehavior: FloatingLabelBehavior.never,
          labelStyle: TextStyle(color: secondaryTextColor),
          prefixIconColor: secondaryTextColor,
          border: InputBorder.none,
        ),
        colorScheme: const ColorScheme.light(
          primary: primaryColor,
          onPrimary: Colors.white,
          background: Color(0xfff3f5f8),
          onSurface: primaryTextColor,
          onBackground: primaryTextColor,
          secondary: primaryColor,
          onSecondary: Colors.white,
          primaryContainer: primaryContainerColor,
        ),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);
  final TextEditingController _controller = TextEditingController();
  final ValueNotifier<String> searchKeywordNotifier = ValueNotifier('');

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<TaskData>(taskBoxName);
    final themeData = Theme.of(context);
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TaskEditScreen(
                  task: TaskData(),
                ),
              ),
            );
          },
          label: const Text('Add New Task')),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 110,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    themeData.colorScheme.primary,
                    themeData.colorScheme.primaryContainer,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'To Do List',
                          style: themeData.textTheme.headline6!.apply(
                            color: themeData.colorScheme.onPrimary,
                          ),
                        ),
                        Icon(
                          CupertinoIcons.share,
                          color: themeData.colorScheme.onPrimary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 38,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(19),
                        color: themeData.colorScheme.onPrimary,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: TextField(
                        onChanged: (value) {
                          searchKeywordNotifier.value = _controller.text;
                        },
                        controller: _controller,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(CupertinoIcons.search),
                          label: Text('Search tasks...'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<String>(
                valueListenable: searchKeywordNotifier,
                builder: (context, value, child) {
                  return ValueListenableBuilder<Box<TaskData>>(
                    valueListenable: box.listenable(),
                    builder: (context, box, child) {
                      final List<TaskData> items;
                      if (_controller.text.isEmpty) {
                        items = box.values.toList();
                      } else {
                        items = box.values
                            .where(
                                (task) => task.title.contains(_controller.text))
                            .toList();
                      }
                      if (items.isNotEmpty) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                          child: ListView.builder(
                            itemCount: items.length + 1,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Today',
                                          style: themeData.textTheme.headline6,
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          width: 70,
                                          height: 3,
                                          decoration: BoxDecoration(
                                            color: primaryColor,
                                            borderRadius:
                                                BorderRadius.circular(1.5),
                                          ),
                                        )
                                      ],
                                    ),
                                    MaterialButton(
                                      color: const Color(0xffeaeff5),
                                      textColor: secondaryTextColor,
                                      elevation: 0,
                                      onPressed: (() {
                                        box.clear();
                                      }),
                                      child: Row(
                                        children: const [
                                          Text('Delete all'),
                                          SizedBox(width: 4),
                                          Icon(
                                            CupertinoIcons.delete_solid,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                final TaskData task = items.toList()[index - 1];
                                return TaskItem(task: task);
                              }
                            },
                          ),
                        );
                      } else {
                        return const EmptyState();
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskItem extends StatefulWidget {
  const TaskItem({
    Key? key,
    required this.task,
  }) : super(key: key);
  static const double taskItemHeight = 70;
  final TaskData task;

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    final Color priorityColor;

    switch (widget.task.priority) {
      case Priority.low:
        priorityColor = lowPriorityColor;
        break;
      case Priority.normal:
        priorityColor = normalPriorityColor;
        break;
      case Priority.high:
        priorityColor = highPriorityColor;
        break;
    }

    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => TaskEditScreen(task: widget.task)));
      },
      onLongPress: () => widget.task.delete(),
      child: Container(
        height: TaskItem.taskItemHeight,
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.only(left: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: themeData.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(0.01),
            ),
          ],
        ),
        child: Row(
          children: [
            MyCheckBox(
              value: widget.task.isCompleted,
              onTap: () {
                setState(() {
                  widget.task.isCompleted = !widget.task.isCompleted;
                });
              },
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                widget.task.title,
                style: TextStyle(
                    decoration: widget.task.isCompleted
                        ? TextDecoration.lineThrough
                        : null),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 5,
              height: TaskItem.taskItemHeight,
              decoration: BoxDecoration(
                  color: priorityColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

class MyCheckBox extends StatefulWidget {
  final bool value;
  final GestureTapCallback onTap;

  const MyCheckBox({Key? key, required this.value, required this.onTap})
      : super(key: key);

  @override
  State<MyCheckBox> createState() => _MyCheckBoxState();
}

class _MyCheckBoxState extends State<MyCheckBox> {
  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          border: widget.value
              ? null
              : Border.all(color: secondaryTextColor, width: 2),
          color: widget.value ? primaryColor : null,
          borderRadius: BorderRadius.circular(9),
        ),
        child: widget.value
            ? Icon(
                CupertinoIcons.check_mark,
                color: themeData.colorScheme.onPrimary,
                size: 12,
              )
            : null,
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/empty_state.svg',
          width: 160,
        ),
        const SizedBox(height: 16),
        const Text('Your Task is empty'),
      ],
    );
  }
}
