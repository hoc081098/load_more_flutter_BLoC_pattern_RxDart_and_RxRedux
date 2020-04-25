import 'package:flutter/material.dart';

class HeaderItem extends StatelessWidget {
  const HeaderItem({
    Key key,
    @required this.headerText,
  }) : super(key: key);

  final String headerText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: const Color(0xff3A3A3A),
            boxShadow: const [
              BoxShadow(
                color: Color(0xff5A5A5A),
                blurRadius: 2,
                offset: Offset(1, 1),
              )
            ],
          ),
          child: Text(
            headerText,
            style: Theme.of(context).textTheme.subtitle2.copyWith(
                  color: const Color(0xffFFAB00),
                ),
          ),
        ),
        Expanded(child: Container()),
      ],
    );
  }
}
