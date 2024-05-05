import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'weather_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      List<dynamic> data = jsonDecode(response.body)['list'];
      List<WeatherForecast> forecasts = [];
      DateTime currentDate = DateTime.now();
      for (var item in data) {
        WeatherForecast forecast = WeatherForecast.fromJson(item);
        if (forecast.date.day != currentDate.day) {
          forecasts.add(forecast);
          currentDate = forecast.date;
        }
      }
      return forecasts;
    } else {
      throw Exception('Failed to load forecast data');
    }
  }

  void addToFavorites() async {
    try {
      await FirebaseFirestore.instance.collection('favorites').add({
        'user': FirebaseAuth.instance.currentUser?.uid,
        'cityName': widget.cityName,
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Added to favorites'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to add to favorites'),
      ));
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
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
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
                    ),
                  ),
                  ElevatedButton(
                    onPressed: addToFavorites,
                    child: const Text('Add to Favorites'),
                  ),
                ],
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
