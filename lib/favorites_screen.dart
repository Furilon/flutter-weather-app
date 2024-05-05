import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'weather_data.dart';
import 'individual_city_screen.dart';
import 'main.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late User _currentUser;
  late List<dynamic> _favoriteCities;
  late List<WeatherData> _weatherDataList;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser!;
    _favoriteCities = [];
    _weatherDataList = [];
    _loadFavoriteCities();
  }

  Future<void> _loadFavoriteCities() async {
    try {
      QuerySnapshot favoritesSnapshot = await FirebaseFirestore.instance
          .collection('favorites')
          .where('user', isEqualTo: _currentUser.uid)
          .get();
      setState(() {
        _favoriteCities =
            favoritesSnapshot.docs.map((doc) => doc['cityName']).toList();
      });
      await _fetchWeatherData();
    } catch (error) {
      print('Failed to load favorite cities: $error');
    }
  }

  Future<void> _fetchWeatherData() async {
    try {
      List<WeatherData> weatherDataList = [];
      for (String cityName in _favoriteCities) {
        String apiKey = 'fd80244eb438a5e523f948e21723406f';
        Uri url = Uri.parse(
            'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey'
        );
        final response = await http.get(url);
        if (response.statusCode == 200) {
          dynamic data = jsonDecode(response.body);
          WeatherData weatherData = WeatherData.fromJson(data);
          weatherDataList.add(weatherData);
        }
      }
      setState(() {
        _weatherDataList = weatherDataList;
      });
    } catch (error) {
      print('Failed to fetch weather data: $error');
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Main()));
    } catch (error) {
      print('Failed to sign out: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: _weatherDataList.isNotEmpty
          ? ListView.builder(
              itemCount: _weatherDataList.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CityForecastScreen(cityName: _weatherDataList[index].cityName),
                        ),
                      );
                    },
                    child: WeatherCard(weatherData: _weatherDataList[index]),
                );
              },
            )
          : const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}