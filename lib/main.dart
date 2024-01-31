import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  int _counter = 0;
  String _weather = "Querying";
  String _temp = "Querying";
  String _city = 'Atlanta';
  String _ip = "";
  String _username ="";

  // void _incrementCounter() {
  //   setState(() {
  //     _counter++;
  //   });
  // }

  Future<Map<String, dynamic>> getWeatherData(String city) async {
    final apiKey = '576ab16d26e14d18885144958243001';
    final apiUrl = 'https://api.weatherapi.com/v1/current.json?q=$city&key=$apiKey';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        print('Failed to load weather data: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      print('Error loading weather data: $e');
      return {};
    }
  }


  Future<Map<String, dynamic>> getIp() async {
    final apiUrl = 'http://124.221.179.133:5000/get_ip';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        print('Failed to load weather data: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      print('Error loading weather data: $e');
      return {};
    }
  }

  Future<void> submitPunchData(String name, String weather, String temperature) async {
    final apiUrl = 'http://124.221.179.133:5000/save_punch';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'weather': weather,
          'temperature': temperature,
        }),
      );

      if (response.statusCode == 200) {
        print('Punch data submitted successfully');
        // You can handle success response here
      } else {
        print('Failed to submit punch data. Status code: ${response.statusCode}');
        // You can handle error response here
      }
    } catch (e) {
      print('Error while submitting punch data: $e');
      // You can handle network or other errors here
    }
  }

  @override
  void initState() {
    super.initState();
    //_loadWeatherData();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _loadWeatherData();
    });
  }

  Future<void> _loadWeatherData() async {
    try {
      final Map<String, dynamic> weatherData = await getWeatherData(
          _city);
      setState(() {
        if (weatherData.isNotEmpty) {
          print(weatherData);
          final location = weatherData['location']['name'];
          _temp = weatherData['current']['temp_c'].toString() ;
          _weather = weatherData['current']['condition']['text'];

          print('Current weather in $location: $_weather');
          print('Temperature in $location: $_temp°C');
        } else {
          print('Unable to fetch weather data for $_city.');
        }
        print('Weather data loaded: $weatherData');
      });
    }
    catch (e) {
      print('Error while loading weather data: $e');
    }
  }

  void _check_in() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Form is valid, perform button click actions here
      try {
        //String city ='Atlanta';
        _city = 'Atlanta';
        final Map<String, dynamic> ip_data = await getIp();
        setState(() {

          if (ip_data.isNotEmpty) {
            print(ip_data);
            _ip = ip_data['client_ip'];
            print('IP: $_ip');


          } else {
            print('Unable to fetch weather data for $_city.');
          }
        });

        submitPunchData( _username, _weather,  _temp);

      } catch (e) {
        print('Error while fetching weather data: $e');
      }
      // You can also include other logic here based on the form being valid
    }

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),


      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                onChanged: (value) {
                  setState(() {
                    _username = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'please input username',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Username cannot be empty';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(height: 20),

            Text(
              'Welcome to check in',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Colors.blue,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          SizedBox(height: 20),
            Text(
              '$_city, $_weather, $_temp°C',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 20),
            Text(
              _ip.isNotEmpty ? 'Hi $_username, you check in success!!!' : '',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.green,
              ),
            ),
            Text(
              _ip.isNotEmpty ? 'Check in IP: $_ip' : '',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.green,
              ),
            ),
            Text(
              _ip.isNotEmpty ?'Current Time: ${DateFormat('HH:mm:ss').format(DateTime.now().toLocal())}':'',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.green,
              ),
            )
          ],
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _check_in,
          style: ElevatedButton.styleFrom(
            primary: Theme.of(context).colorScheme.primary,
            padding: EdgeInsets.all(16.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: 8),
              Text('Check in',
                style: TextStyle(color: Colors.white),
        ),
            ],
          ),
        ),
      ),
    );
  }

}
