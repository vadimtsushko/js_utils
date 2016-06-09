// Copyright (c) 2016, Vadim Tsushko. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:js_utils/js_utils.dart';
import 'js_model.dart';
import 'dart:html';

main() {
  var user = new User(
      firstName: 'Vadim',
      lastName: 'Tsushko',
      mainAddress: new Address(cityName: 'Tyumen', streetName: 'Aguage'),
      addresses: [
        new Address(cityName: 'Tyumen', streetName: 'Aguage'),
        new Address(cityName: 'Tyumen', streetName: 'Aguage')
      ]);

  Map jsonUser = toJson(user);
  querySelector('#output').text = 'User: $user $jsonUser';
}
