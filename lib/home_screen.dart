import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<WeatherData> weatherDataList = [];

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  Future<void> fetchWeatherData() async {
    List<String> cities = ['New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix'];
    String apiKey = 'fd80244eb438a5e523f948e21723406f';
    for (String city in cities) {
      Uri url = Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=$city,US&appid=$apiKey');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        WeatherData weatherData = WeatherData.fromJson(data);
        setState(() {
          weatherDataList.add(weatherData);
        });
      } else {
        throw Exception('Failed to load weather data');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: weatherDataList.length,
        itemBuilder: (context, index) {
          return WeatherCard(weatherData: weatherDataList[index]);
        },
      ),
    );
  }
}

class WeatherData {
  final String cityName;
  final double temperature;
  final String weatherDescription;

  WeatherData({required this.cityName, required this.temperature, required this.weatherDescription});

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      cityName: json['name'],
      temperature: (json['main']['temp'] - 273.15) * 9 / 5 + 32,
      weatherDescription: json['weather'][0]['description'],
    );
  }
}

class WeatherCard extends StatelessWidget {
  final WeatherData weatherData;

  const WeatherCard({Key? key, required this.weatherData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: ListTile(
        title: Text(weatherData.cityName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Temperature: ${weatherData.temperature.toStringAsFixed(1)}°F'),
            Text('Weather: ${weatherData.weatherDescription}'),
          ],
        ),
      ),
    );
  }
}
