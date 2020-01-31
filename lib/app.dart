import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:load_more_flutter/generated/l10n.dart';
import 'package:load_more_flutter/pages/comics/comics_page.dart';
import 'package:load_more_flutter/pages/home_page/home_page.dart';
import 'package:load_more_flutter/pages/rx_redux/rx_redux_page.dart';
import 'package:load_more_flutter/pages/simple/simple_page.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var _locale = const Locale('en', '');

  @override
  Widget build(BuildContext context) {
    const localeEn = Locale('en', '');

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      locale: _locale,
      debugShowCheckedModeBanner: false,
      supportedLocales: S.delegate.supportedLocales,
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
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: RaisedButton(
                        padding: const EdgeInsets.all(16),
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
                    ),
                    SizedBox(height: 8),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: RaisedButton(
                        padding: const EdgeInsets.all(16),
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
                    ),
                    SizedBox(height: 8),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: RaisedButton(
                        padding: const EdgeInsets.all(16),
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
                    ),
                    SizedBox(height: 8),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: RaisedButton(
                        padding: const EdgeInsets.all(16),
                        child: Text('Comics page'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ComicsPage(),
                            ),
                          );
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 12,
                      ),
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
