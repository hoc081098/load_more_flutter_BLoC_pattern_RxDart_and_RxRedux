import 'package:flutter/material.dart';
import 'package:load_more_flutter/data/model/person.dart';

class PersonListItem extends StatefulWidget {
  final int index;
  final int length;
  final Person item;

  const PersonListItem({
    Key key,
    @required this.index,
    @required this.length,
    @required this.item,
  }) : super(key: key);

  @override
  _PersonListItemState createState() => _PersonListItemState();
}

class _PersonListItemState extends State<PersonListItem>
    with TickerProviderStateMixin<PersonListItem> {
  AnimationController _scaleController;
  Animation<double> _scale;

  Animation<Offset> _position;
  AnimationController _positionController;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    _scale = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeOut,
      ),
    );

    _positionController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    _position = Tween(begin: Offset(2.0, 0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _positionController,
        curve: Curves.easeOut,
      ),
    );

    _scaleController.forward();
    _positionController.forward();
  }

  @override
  void dispose() {
    _positionController.dispose();
    _scaleController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final index = widget.index;
    final length = widget.length;

    return ScaleTransition(
      child: SlideTransition(
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: Colors.grey.shade800,
              spreadRadius: 2,
              blurRadius: 10,
            )
          ]),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(item.name),
              subtitle: Text(item.bio),
              leading: CircleAvatar(
                child: Text(item.emoji),
                foregroundColor: Colors.white,
                backgroundColor: Colors.purple,
              ),
              trailing: CircleAvatar(
                child: Text(
                  '${index + 1}/$length',
                  style: Theme.of(context).textTheme.overline,
                ),
                foregroundColor: Colors.white,
                backgroundColor: Colors.teal,
              ),
            ),
          ),
        ),
        position: _position,
      ),
      scale: _scale,
    );
  }
}
