import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'crypto_model.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto Prices',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: CryptoListScreen(),
    );
  }
}

class CryptoListScreen extends StatefulWidget {
  @override
  _CryptoListScreenState createState() => _CryptoListScreenState();
}

class _CryptoListScreenState extends State<CryptoListScreen> {
  List<Crypto> _cryptos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCryptoPrices();
  }

  Future<void> _fetchCryptoPrices() async {
    final response =
        await http.get(Uri.parse('https://api.coinlore.net/api/tickers/'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> cryptoList = data['data'];

      setState(() {
        _cryptos = cryptoList.map((json) => Crypto.fromJson(json)).toList();
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load crypto prices');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List Crypto - UAS - M IDRIS EPENDI'),
      ),
      body: _isLoading
          ? Center(
              child: SpinKitFadingCircle(
                color: Colors.blue,
                size: 50.0,
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchCryptoPrices,
              child: ListView.builder(
                itemCount: _cryptos.length,
                itemBuilder: (context, index) {
                  final crypto = _cryptos[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text(
                            crypto.symbol,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          crypto.name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Symbol: ${crypto.symbol}'),
                        trailing: Text(
                          '\$${crypto.priceUsd.toStringAsFixed(2)}',
                          style: TextStyle(
                              color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
