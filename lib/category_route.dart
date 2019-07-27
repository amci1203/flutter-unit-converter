// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'api.dart';
import 'backdrop.dart';
import 'category.dart';
import 'category_tile.dart';
import 'unit.dart';
import 'unit_converter.dart';

/// Loads in unit conversion data, and displays the data.

class CategoryRoute extends StatefulWidget {
  const CategoryRoute();

  @override
  _CategoryRouteState createState() => _CategoryRouteState();
}

class _CategoryRouteState extends State<CategoryRoute> {
  static const _baseColors = <ColorSwatch>[
    ColorSwatch(0xFF6AB7A8, {
      'highlight': Color(0xFF6AB7A8),
      'splash': Color(0xFF0ABC9B),
    }),
    ColorSwatch(0xFFFFD28E, {
      'highlight': Color(0xFFFFD28E),
      'splash': Color(0xFFFFA41C),
    }),
    ColorSwatch(0xFFFFB7DE, {
      'highlight': Color(0xFFFFB7DE),
      'splash': Color(0xFFF94CBF),
    }),
    ColorSwatch(0xFF8899A8, {
      'highlight': Color(0xFF8899A8),
      'splash': Color(0xFFA9CAE8),
    }),
    ColorSwatch(0xFFEAD37E, {
      'highlight': Color(0xFFEAD37E),
      'splash': Color(0xFFFFE070),
    }),
    ColorSwatch(0xFF81A56F, {
      'highlight': Color(0xFF81A56F),
      'splash': Color(0xFF7CC159),
    }),
    ColorSwatch(0xFFD7C0E2, {
      'highlight': Color(0xFFD7C0E2),
      'splash': Color(0xFFCA90E5),
    }),
    ColorSwatch(0xFFCE9A9A, {
      'highlight': Color(0xFFCE9A9A),
      'splash': Color(0xFFF94D56),
      'error': Color(0xFF912D2D),
    }),
  ];

  static const _icons = <String>[
    'assets/icons/length.png',
    'assets/icons/area.png',
    'assets/icons/volume.png',
    'assets/icons/mass.png',
    'assets/icons/time.png',
    'assets/icons/digital_storage.png',
    'assets/icons/power.png',
    'assets/icons/currency.png',
  ];

  Category _defaultCategory;
  Category _currentCategory;

  final _categories = <Category>[];

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    if (_categories.isEmpty) {
      await _retrieveCurrencyCategories();
      await _retrieveLocalCategories();
      setState(() {
        _defaultCategory = _categories[0];
        _currentCategory = _defaultCategory;
      });
    }
  }

  /// Retrieves a list of [Categories] and their [Unit]s
  Future<void> _retrieveLocalCategories() async {
    var path = 'assets/data/regular_units.json';
    final json = DefaultAssetBundle.of(context).loadString(path);
    final data = JsonDecoder().convert(await json);
    if (data is! Map) throw ('Data retrieved from API is not a Map');

    int i = 0;
    data.forEach((name, unitList) {
      List<Unit> units = <Unit>[];

      for (var j = 0, len = unitList.length; j < len; j++) {
        var unit = unitList[j];
        units.add(
          Unit(
            name: unit['name'],
            conversion: unit['conversion'],
          )
        );
      }

      _categories.add(
        Category(
          name: name,
          units: units,
          color: _baseColors[i],
          iconLocation: _icons[i],
        )
      );

      i++;
    });
  }

  Future<void> _retrieveCurrencyCategories() async {
    _categories.add(Category(
      name: 'Currency',
      units: [],
      color: _baseColors.last,
      iconLocation: _icons.last,
    ));

    final units = await Api.getUnits();

    if (units != null) {
      _categories.removeLast();
      _categories.add(Category(
        name: 'Currency',
        units: units,
        color: _baseColors.last,
        iconLocation: _icons.last,
      ));
    }
  }

  void _onCategoryTap(Category category) {
    setState(() {
      _currentCategory = category;
    });
  }

  void _noopTap(Category category) {
    return;
  }

  Widget _buildCategoryWidgets(Orientation deviceOrientation) {
    if (deviceOrientation == Orientation.portrait) {
      return ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          var c = _categories[index];
          return CategoryTile(
            category: c,
            onTap: c.units.length > 0 ? _onCategoryTap : _noopTap,
          );
        },
        itemCount: _categories.length,
      );
    } else {
      return GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 3.0,
        children: _categories.map((Category c) {
          return CategoryTile(
            category: c,
            onTap: c.units.length > 0 ? _onCategoryTap : _noopTap,
          );
        }).toList(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_categories.isEmpty) {
      return Center(
        child: Container(
          height: 180.0,
          width: 180.0,
          child: CircularProgressIndicator(),
        ),
      );
    }

    final listView = Container(
      padding: EdgeInsets.only(
        right: 8.0,
        left: 8.0,
        bottom: 48.0,
      ),
      child: _buildCategoryWidgets(MediaQuery.of(context).orientation),
    );

    return Scaffold(
      // appBar: appBar,
      body: Backdrop(
        currentCategory: _currentCategory,
        frontPanel: UnitConverter(
          category: _currentCategory
        ),
        backPanel: listView,
        backTitle: Text('Select A Category'),
        frontTitle: Text('Unit Converter'),
      )
    );
  }
}
