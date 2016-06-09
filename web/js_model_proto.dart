library js_model_proto;

import 'package:js_utils/js_wrapper_generator.dart';

class Address {
  String cityName;
  String streetName;
}
class User {
  String firstName;
  String lastName;
  Address mainAddress;
  List<Address> addresses;
}

main() {
  var libraryHeader = """
@JS()
library js_model;
import 'package:js/js.dart';
""";
  new WrapperGenerator(#js_model_proto,
      fileHeader: libraryHeader)
      .generateTo('js_model.dart');
}
