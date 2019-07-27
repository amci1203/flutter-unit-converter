// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';
import 'dart:async';
import 'dart:convert' show json, utf8;

import 'unit.dart';

/// Retrieves a list of currencies and their current
/// exchange rate (mock data).
///   GET /currency : get a list of currencies
///   GET /currency/convert : get conversion from one currency amount to another
class Api {
  static final HttpClient http = HttpClient();
  static final String baseUrl = 'flutter.udacity.com';

  /// Gets all the units and conversion rates for a given category.
  ///
  /// The `category` parameter is the name of the [Category] from which to
  /// retrieve units. We pass this into the query parameter in the API call.
  ///
  /// Returns a list. Returns null on error.
  static Future<List<Unit>> getUnits() async {
    final uri = Uri.https(baseUrl, '/currency');
    try {
      final req = await http.getUrl(uri);
      final res = await req.close();

      if (res.statusCode != HttpStatus.OK) return null;

      final body = await res.transform(utf8.decoder).join();
      final list = json.decode(body)['units'];

      return List<Unit>.generate(list.length, (i) => Unit(
        name: list[i]['name'],
        conversion: list[i]['conversion'].toDouble(),
      ));
    } on Exception catch (e) {
      print('Error Fetching Currency Units: $e');
      return null;
    }
  }

  /// Given two units, converts from one to another.
  ///
  /// Returns a double, which is the converted amount. Returns null on error.
  static Future<String> convert(
    String amount,
    String from,
    String to,
  ) async {
    final uri = Uri.https(baseUrl, '/currency/convert', {
      'amount': amount,
      'from': from,
      'to': to,
    });

    try {
      final req = await http.getUrl(uri);
      final res = await req.close();

      if (res.statusCode != HttpStatus.OK) return null;

      final txt = await res.transform(utf8.decoder).join();
      final map = json.decode(txt);

      return map['conversion'].toString();
    } on Exception catch (e) {
      print('Error During Currency Conversion: $e');
      return null;
    }
  }
}
