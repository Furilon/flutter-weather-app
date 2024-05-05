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