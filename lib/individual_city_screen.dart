import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'weather_data.dart';

class CityForecastScreen extends StatefulWidget {
  final String cityName;

  const CityForecastScreen({super.key, required this.cityName});

  @override
  State<CityForecastScreen> createState() => _CityForecastScreenState();
}

class _CityForecastScreenState extends State<CityForecastScreen> {
  late Future<List<WeatherForecast>> futureForecast;

  @override
  void initState() {
    super.initState();
    futureForecast = fetchForecastData();
  }

  Future<List<WeatherForecast>> fetchForecastData() async {
    String apiKey = 'fd80244eb438a5e523f948e21723406f';
    Uri url = Uri.parse('https://api.openweathermap.org/data/2.5/forecast?q=${widget.cityName}&appid=$apiKey');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON.
      List<dynamic> data = jsonDecode(response.body)['list'];
      List<WeatherForecast> forecasts = [];
      DateTime currentDate = DateTime.now();
      for (var item in data) {
        WeatherForecast forecast = WeatherForecast.fromJson(item);
        // Check if the forecast date is different from the current date
        if (forecast.date.day != currentDate.day) {
          forecasts.add(forecast);
          currentDate = forecast.date;
        }
      }
      return forecasts;
    } else {
      // If the server did not return a 200 OK response, throw an exception.
      throw Exception('Failed to load forecast data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cityName),
      ),
      body: Center(
        child: FutureBuilder<List<WeatherForecast>>(
          future: futureForecast,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<WeatherForecast> forecasts = snapshot.data!;
              return ListView.builder(
                itemCount: forecasts.length,
                itemBuilder: (context, index) {
                  WeatherForecast forecast = forecasts[index];
                  return ListTile(
                    title: Text('${forecast.date.toLocal()}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Temperature: ${forecast.temperature.toStringAsFixed(1)}°F'),
                        Text('Weather: ${forecast.weatherDescription}'),
                      ],
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}


