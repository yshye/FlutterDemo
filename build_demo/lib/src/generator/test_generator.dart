import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:build_demo/src/class/test_void.dart';
import 'package:source_gen/source_gen.dart';

class TestGenerator extends GeneratorForAnnotation<TestVoid> {
  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    return "// ${element.name}";
  }
}
