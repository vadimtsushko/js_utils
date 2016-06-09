library wrapper_generator;

import 'dart:mirrors';
import 'dart:io';
import 'package:path/path.dart' as path;

///<-- Metadata
const stub = const Stub();

class Stub {
  const Stub();
}

const skipFactory = const SkipFactory();

class SkipFactory {
  const SkipFactory();
}

class WrapperGenerator {
  static const WARNING_HEADER = '''
/// Warning! That file is generated. Do not edit it manually

''';
  Symbol libraryName;
  List<ClassGenerator> classGenerators = new List<ClassGenerator>();
  Map<Type, ClassMirror> classMirrors = new Map<Type, ClassMirror>();
  List<Type> _classesOrdered = [];
  String fileHeader;
  bool printWarning = true;
  WrapperGenerator(this.libraryName,
      {this.fileHeader, this.printWarning: true});
  StringBuffer output = new StringBuffer();
  init() {
    var lib = currentMirrorSystem().findLibrary(libraryName);
    lib.declarations.forEach((sym, dm) {
      if (dm is ClassMirror) {
        _classesOrdered.add(dm.reflectedType);
        classMirrors[dm.reflectedType] = dm;
      }
    });
  }

  void generateOutput() {
    if (printWarning) {
      output.write(WARNING_HEADER);
    }
    if (fileHeader != null) {
      output.writeln(fileHeader);
    }
    classGenerators.forEach((cls) {
      generateOuputForClass(cls);
    });
  }

  generateTo(String outFileName) {
    init();
    processAll();
    generateOutput();
    saveOuput(outFileName);
  }

  void saveOuput(String fileName) {
    if (path.isRelative(fileName)) {
      var targetDir = path.dirname(path.fromUri(Platform.script));
      fileName = path.join(targetDir, path.basename(fileName));
    }
    new File(fileName).writeAsStringSync(output.toString());
    print('Created file: $fileName');
  }

  void generateOuputForClass(ClassGenerator classGenerator) {
    if (classGenerator.isStub) {
      return;
    }
    output.write('@JS()\n');
    output.write('@anonymous\n');
    output.write('class ${classGenerator.type}');
    if (classGenerator.superClass != Object) {
      output.write(' extends ${classGenerator.superClass}');
    }
    output.write('{\n');
    classGenerator.properties.forEach(generateOuputForProperty);
    output.write('  external factory ${classGenerator.type} (');
    if (!classGenerator.skipFactory) {
      output.write('{\n');
      output.write(classGenerator.properties
          .map((e) => '    ${e.type} ${e.name}')
          .join(',\n'));
      output.write('}');
    }
    output.write(');\n');
    output.write('}\n\n');
  }

  void generateOuputForProperty(PropertyGenerator propertyGenerator) {
    output.write(
        '  external ${propertyGenerator.type} get ${propertyGenerator.name};\n');
    output.write(
        '  external set ${propertyGenerator.name}(${propertyGenerator.type} value);\n');
  }

  processAll() {
    _classesOrdered.forEach(processClass);
  }

  processClass(Type classType) {
    var classMirror = classMirrors[classType];
    var generatorClass = new ClassGenerator();
    classGenerators.add(generatorClass);
    generatorClass.type = classMirror.reflectedType;
    generatorClass.superClass = classMirror.superclass.reflectedType;
    if (!classMirror.metadata.isEmpty) {
      generatorClass.isStub =
          classMirror.metadata.any((m) => m.type.reflectedType == Stub);
      generatorClass.skipFactory =
          classMirror.metadata.any((m) => m.type.reflectedType == SkipFactory);
    }
    classMirror.declarations.forEach((Symbol name, DeclarationMirror vm) =>
        processProperty(generatorClass, name, vm));
  }

  processProperty(ClassGenerator classGenerator, name, DeclarationMirror vm) {
    if (vm is VariableMirror) {
      PropertyGenerator property = new PropertyGenerator();
      classGenerator.properties.add(property);
      property.name = MirrorSystem.getName(name);
      property.processVariableMirror(vm);
    }
  }
}

class PropertyGenerator {
  String name;
  Type type;
  String get typeName => type == dynamic ? '' : type.toString();
  String toString() => 'PropertyGenerator($name,$type)';
  String get commentLine => '  // $type $name\n';
  processVariableMirror(VariableMirror vm) {
    type = vm.type.reflectedType;
  }
}

class ClassGenerator {
  Type type;
  Type superClass;
  bool isStub = false;
  bool skipFactory = false;
  List<PropertyGenerator> properties = new List<PropertyGenerator>();
  String toString() => 'ClassGenerator($properties)';
}
