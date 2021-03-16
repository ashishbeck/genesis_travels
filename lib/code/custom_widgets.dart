import 'package:flutter/material.dart';
import 'package:genesis_travels/code/constants.dart';

typedef Disposer = void Function();

Widget customLoadingModule(String text) {
  return Center(
    child: Container(
      margin: EdgeInsets.only(top: 16),
      child: Chip(
        avatar: CircularProgressIndicator(),
        label: Text(text,
          style: TextStyle(color: appColor, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: appWhite,
      ),
    ),
  );
}

Widget customDivider(double width) {
  return Center(
    child: Container(
      height: 5,
      width: width,
      decoration: ShapeDecoration(
          shape: roundShape,
          color: appGrey
      ),
    ),
  );
}

class CustomStatefulBuilder extends StatefulWidget {
  const CustomStatefulBuilder({Key key,
    @required this.builder,
    @required this.dispose,
  })
      : assert(builder != null),
        super(key: key);

  final StatefulWidgetBuilder builder;
  final Disposer dispose;

  @override
  _CustomStatefulBuilderState createState() => _CustomStatefulBuilderState();
}

class _CustomStatefulBuilderState extends State<CustomStatefulBuilder> {
  @override
  Widget build(BuildContext context) => widget.builder(context, setState);

  @override
  void dispose() {
    super.dispose();
    widget.dispose();
  }
}