import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:todo_list/main.dart';

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
