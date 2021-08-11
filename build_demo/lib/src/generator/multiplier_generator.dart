import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import '../class/test_multiplier.dart';

class MultiplierGenerator extends GeneratorForAnnotation<TestMultiplier> {
  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    StringBuffer buffer = StringBuffer("===== element =====\n")
      ..write("element.toString:${element.toString()}")
      ..write('\n')
      ..write("element.name:${element.name}")
      ..write('\n')
      ..write("element.metadata:${element.metadata}")
      ..write('\n')
      ..write("element.kind:${element.kind}")
      ..write('\n')
      ..write("element.displayName:${element.displayName}")
      ..write('\n')
      ..write("element.documentationComment:${element.documentationComment}")
      ..write('\n')
      ..write("element.enclosingElement:${element.enclosingElement}")
      ..write('\n')
      ..write("element.hasAlwaysThrows:${element.hasAlwaysThrows}")
      ..write('\n')
      ..write("element.hasDeprecated:${element.hasDeprecated}")
      ..write('\n')
      ..write("element.hasFactory:${element.hasFactory}")
      ..write('\n')
      ..write("element.hasIsTest:${element.hasIsTest}")
      ..write('\n')
      ..write("element.hasLiteral:${element.hasLiteral}")
      ..write('\n')
      ..write("element.hasOverride:${element.hasOverride}")
      ..write('\n')
      ..write("element.hasProtected:${element.hasProtected}")
      ..write('\n')
      ..write("element.hasRequired:${element.hasRequired}")
      ..write('\n')
      ..write("element.isPrivate:${element.isPrivate}")
      ..write('\n')
      ..write("element.isPublic:${element.isPublic}")
      ..write('\n')
      ..write("element.isSynthetic:${element.isSynthetic}")
      ..write('\n')
      ..write("element.nameLength:${element.nameLength}")
      ..write('\n')
      ..write("element.runtimeType:${element.runtimeType}")
      ..write('\n');

    if (element.kind == ElementKind.CLASS) {
      buffer..write("\n====  element.fields ====\n");
      for (var e in ((element as ClassElement).fields)) {
        buffer..write(e)..write('\n');
      }
      buffer..write("\n====  element.methods ====\n");
      for (var e in element.methods) {
        buffer..write(e)..write('\n');
      }
    }

    buffer..write("\n=====  annotation =====\n");

    final strValue = annotation.read('str').literalValue as String;
    final ageValue = annotation.read('age').literalValue as int;
    final otherValue = annotation.peek('other');
    buffer
      ..write("str:$strValue")
      ..write('\n')
      ..write("age:$ageValue")
      ..write('\n')
      ..write("other:$otherValue")
      ..write('\n');

    buffer..write("\n=====  buildStep =====\n");
    AssetId item = buildStep.inputId;
    buffer
      ..write("buildStep.runtimeType: ${buildStep.runtimeType}")
      ..write('\n')
      ..write("buildStep.inputId.path: ${item.path}")
      ..write('\n')
      ..write("buildStep.inputId.extension: ${item.extension}")
      ..write('\n')
      ..write("buildStep.inputId.package: ${item.package}")
      ..write('\n')
      ..write("buildStep.inputId.uri: ${item.uri}")
      ..write('\n')
      ..write("buildStep.inputId.pathSegments: ${item.pathSegments}")
      ..write('\n');
    for (var item in buildStep.allowedOutputs) {
      buffer
        ..write("buildStep.allowedOutputs.path: ${item.path}")
        ..write('\n')
        ..write("buildStep.allowedOutputs.extension: ${item.extension}")
        ..write('\n')
        ..write("buildStep.allowedOutputs.package: ${item.package}")
        ..write('\n')
        ..write("buildStep.allowedOutputs.uri: ${item.uri}")
        ..write('\n')
        ..write("buildStep.allowedOutputs.pathSegments: ${item.pathSegments}")
        ..write('\n');
    }

    return """
void print$strValue(){
  print(\"\"\"
${buffer.toString()}
  \"\"\");
}
    """;
  }
}
