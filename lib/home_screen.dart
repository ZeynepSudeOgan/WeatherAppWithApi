import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lab88/consts.dart/const.dart';
import 'package:weather/weather.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherFactory _wf = WeatherFactory(OpenWeather_ApiKey);

  List<Map<String, dynamic>>? _dailyForecast;
  String _cityName = "";
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("lib/assets/back.jpg"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        _buildUI(),
      ]),
    );
  }

  Widget _buildUI() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      height: MediaQuery.sizeOf(context).height,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _cityInputField(),
          if (_dailyForecast == null)
            const Center(
              child: Text(
                "Press the search button",
                style: TextStyle(
                    color: Colors.white70, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _dailyForecast?.length ?? 0,
                itemBuilder: (context, index) {
                  return _weatherCard(_dailyForecast![index]);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _cityInputField() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        color: Colors.white70,
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: "City Name",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _getForecast,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _getForecast() {
    setState(() {
      _cityName = _controller.text;
    });

    _wf.fiveDayForecastByCityName(_cityName).then((forecast) {
      Map<String, List<double>> groupedTemps = {};
      for (var weather in forecast) {
        String day = DateFormat('yyyy-MM-dd').format(weather.date!);
        groupedTemps.putIfAbsent(day, () => []);
        groupedTemps[day]!.add(weather.temperature!.celsius!);
      }

      List<Map<String, dynamic>> dailyForecast =
          groupedTemps.entries.map((entry) {
        double avgTemp =
            entry.value.reduce((a, b) => a + b) / entry.value.length;
        return {
          "date": DateTime.parse(entry.key),
          "avgTemp": avgTemp,
          "icon": forecast
              .firstWhere(
                  (w) => DateFormat('yyyy-MM-dd').format(w.date!) == entry.key)
              .weatherIcon,
          "description": forecast
              .firstWhere(
                  (w) => DateFormat('yyyy-MM-dd').format(w.date!) == entry.key)
              .weatherDescription,
        };
      }).toList();

      setState(() {
        _dailyForecast = dailyForecast;
      });
    }).catchError((error) {
      setState(() {
        _dailyForecast = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enter a valid city name"),
        ),
      );
    });
  }

  Widget _weatherCard(Map<String, dynamic> dayForecast) {
    DateTime date = dayForecast["date"];
    double avgTemp = dayForecast["avgTemp"];
    String icon = dayForecast["icon"];
    String description = dayForecast["description"];

    return Card(
      color: Colors.white70,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat("EEEE, d MMM y").format(date),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.network(
                      "http://openweathermap.org/img/wn/$icon@2x.png",
                      height: 50,
                      width: 50,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                Text(
                  "${avgTemp.toStringAsFixed(0)}°C",
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
