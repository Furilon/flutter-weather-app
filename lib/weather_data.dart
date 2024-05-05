import 'package:flutter/material.dart';

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

class WeatherForecast {
  final double temperature;
  final String weatherDescription;
  final DateTime date;

  WeatherForecast({required this.temperature, required this.weatherDescription, required this.date});

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    return WeatherForecast(
      temperature: (json['main']['temp'] - 273.15) * 9 / 5 + 32,
      weatherDescription: json['weather'][0]['description'],
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000, isUtc: true),
    );
  }
}

class WeatherCard extends StatelessWidget {
  final WeatherData weatherData;

  const WeatherCard({super.key, required this.weatherData});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
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