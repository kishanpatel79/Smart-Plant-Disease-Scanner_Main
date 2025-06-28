import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class WeatherInfoScreen extends StatefulWidget {
  const WeatherInfoScreen({Key? key}) : super(key: key);

  @override
  State<WeatherInfoScreen> createState() => _WeatherInfoScreenState();
}

class _WeatherInfoScreenState extends State<WeatherInfoScreen> {
  String _weather = "Loading...";
  String _icon = "☁️";
  List<Map<String, String>> _forecast = [];

  final String apiKey = '14c38b6a8beba685908752d6cb9841a7';

  Future<void> fetchWeather() async {
    const city = 'Gujarat';
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric');
    final forecastUrl = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric');

    try {
      final response = await http.get(url);
      final forecastResponse = await http.get(forecastUrl);

      if (response.statusCode == 200 && forecastResponse.statusCode == 200) {
        final data = json.decode(response.body);
        final forecastData = json.decode(forecastResponse.body);

        String condition = data['weather'][0]['main'];
        String temp = data['main']['temp'].toString();
        String description = data['weather'][0]['description'];

        List<Map<String, String>> forecastList = [];
        for (int i = 0; i < forecastData['list'].length; i += 8) {
          final dayData = forecastData['list'][i];
          DateTime date = DateTime.parse(dayData['dt_txt']);
          String day = DateFormat('EEE').format(date);
          String temp = dayData['main']['temp'].toString();
          String condition = dayData['weather'][0]['main'];
          String icon = _getWeatherIcon(condition);

          forecastList.add({"day": day, "temp": "$temp°C", "icon": icon});
        }

        setState(() {
          _weather = "$temp°C — $description";
          _icon = _getWeatherIcon(condition);
          _forecast = forecastList;
        });
      } else {
        setState(() => _weather = "Failed to load weather.");
      }
    } catch (e) {
      setState(() => _weather = "Error: $e");
    }
  }

  String _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return "☀️";
      case 'rain':
        return "🌧️";
      case 'clouds':
        return "☁️";
      case 'thunderstorm':
        return "⛈️";
      case 'snow':
        return "❄️";
      default:
        return "🌦️";
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Weather Info"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(_icon, style: const TextStyle(fontSize: 64)),
                    const SizedBox(height: 10),
                    Text(_weather, style: const TextStyle(fontSize: 20)),
                    const SizedBox(height: 10),
                    const Text(
                      "Live weather from OpenWeatherMap",
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text("5-Day Forecast",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _forecast.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: _forecast.map((day) {
                      return Column(
                        children: [
                          Text(day["day"]!,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(day["icon"]!,
                              style: const TextStyle(fontSize: 24)),
                          Text(day["temp"]!,
                              style: const TextStyle(fontSize: 16)),
                        ],
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }
}
