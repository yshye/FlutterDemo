import 'package:build/build.dart';
import 'package:build_demo/src/generator/multiplier_generator.dart';
import 'package:build_demo/src/generator/test_generator.dart';
import 'package:source_gen/source_gen.dart';

Builder multiplierLibraryBuilder(BuilderOptions options) =>
    LibraryBuilder(MultiplierGenerator());

Builder voidLibraryBuilder(BuilderOptions options) =>
    LibraryBuilder(TestGenerator());
