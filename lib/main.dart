import 'package:built_value/built_value.dart' hide Builder;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:load_more_flutter/generated/i18n.dart';
import 'package:load_more_flutter/pages/home_page/home_page.dart';
import 'package:load_more_flutter/pages/rx_redux/rx_redux_page.dart';
import 'package:load_more_flutter/pages/simple/simple_page.dart';

int _indentingBuiltValueToStringHelperIndent = 0;

class CustomIndentingBuiltValueToStringHelper
    implements BuiltValueToStringHelper {
  StringBuffer _result = new StringBuffer();

  CustomIndentingBuiltValueToStringHelper(String className) {
    _result..write(className)..write(' {\n');
    _indentingBuiltValueToStringHelperIndent += 2;
  }

  @override
  void add(String field, Object value) {
    if (value != null) {
      _result
        ..write(' ' * _indentingBuiltValueToStringHelperIndent)
        ..write(value is Iterable ? '$field.length' : field)
        ..write('=')
        ..write(value is Iterable ? value.length : value)
        ..write(',\n');
    }
  }

  @override
  String toString() {
    _indentingBuiltValueToStringHelperIndent -= 2;
    _result..write(' ' * _indentingBuiltValueToStringHelperIndent)..write('}');
    final stringResult = _result.toString();
    _result = null;
    return stringResult;
  }
}

void main() async {
  newBuiltValueToStringHelper =
      (className) => CustomIndentingBuiltValueToStringHelper(className);
  await Firestore.instance.settings(timestampsInSnapshotsEnabled: true);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var _locale = const Locale('en', '');

  @override
  Widget build(BuildContext context) {
    const localeEn = const Locale('en', '');

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      locale: _locale,
      debugShowCheckedModeBanner: false,
      supportedLocales: S.delegate.supportedLocales,
      localeListResolutionCallback:
          S.delegate.listResolution(fallback: localeEn),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: Text(S.of(context).flutter_demo),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SwitchListTile(
                      value: _locale == localeEn,
                      onChanged: (value) {
                        if (_locale == localeEn) {
                          _locale = const Locale('vi', '');
                        } else {
                          _locale = localeEn;
                        }
                        setState(() {});
                      },
                      title: Text('Vietnamese / English'),
                    ),
                    RaisedButton(
                      padding: const EdgeInsets.all(24),
                      child: Text('Home page'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyHomePage(),
                          ),
                        );
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 12,
                    ),
                    SizedBox(height: 8),
                    RaisedButton(
                      padding: const EdgeInsets.all(24),
                      child: Text('Simple page'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SimplePage(),
                          ),
                        );
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 12,
                    ),
                    SizedBox(height: 8),
                    RaisedButton(
                      padding: const EdgeInsets.all(24),
                      child: Text('RxRedux page'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RxReduxPage(),
                          ),
                        );
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 12,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
