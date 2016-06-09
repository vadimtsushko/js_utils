/// Warning! That file is generated. Do not edit it manually

@JS()
library js_model;
import 'package:js/js.dart';

@JS()
@anonymous
class Address{
  external String get cityName;
  external set cityName(String value);
  external String get streetName;
  external set streetName(String value);
  external factory Address ({
    String cityName,
    String streetName});
}

@JS()
@anonymous
class User{
  external String get firstName;
  external set firstName(String value);
  external String get lastName;
  external set lastName(String value);
  external Address get mainAddress;
  external set mainAddress(Address value);
  external List<Address> get addresses;
  external set addresses(List<Address> value);
  external factory User ({
    String firstName,
    String lastName,
    Address mainAddress,
    List<Address> addresses});
}

