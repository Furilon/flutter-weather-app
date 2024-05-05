import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'weather_data.dart';
import 'individual_city_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

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
      Uri url = Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$city,US&appid=$apiKey'
      );
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
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CityForecastScreen(cityName: weatherDataList[index].cityName),
                ),
              );
            },
            child: WeatherCard(weatherData: weatherDataList[index]),
          );
        },
      ),
    );
  }
}



