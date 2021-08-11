# Flutter 注解
Flutter，其实也就是Dart的注解处理依赖于 [source_gen](https://github.com/dart-lang/source_gen)。它的详细资料可以在它的 Github 主页查看，这里我们不做过多展开，你只需要知道[ Dart-APT  Powered by  source_gen]
在Flutter中应用注解以及生成代码仅需一下几个步骤：

1.依赖 source_gen
2.创建注解
3.创建生成器
4.创建Builder
5.编写配置文件

## 示例
### 1. 依赖 source_gen
```shell
 flutter pub add source_gen
```
### 2. 创建和使用
#### 2.1 无参数
**创建**
```dart
class TestVoid {
  const TestVoid();
}
```
**使用**
```dart
@TestVoid()
class TestVoidModel {}
```
#### 2.2 有参
**创建**
```dart
class TestMultiplier {
  final String str;
  final int age;

  const TestMultiplier(this.str, this.age);
}
```
**使用**
```dart
@TestMultiplier('JsonYe', 100)
class DemoMultiplier {}
```

### 3. 创建生成器
需要创建一个类，继承于`GeneratorForAnnotation`，并实现`generateForAnnotatedElement`方法：
```dart
class MultiplierGenerator extends GeneratorForAnnotation<TestMultiplier> {
  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    final strValue = annotation.read('str').literalValue as String;
    final ageValue = annotation.read('age').literalValue as int;

    return """
void testMultiplierGenerator(){
  print("Model:${element.name},str:$strValue,age:$ageValue");
}
    """;
  }
}
```

### 4. 创建Builder
```dart
import 'package:source_gen/source_gen.dart';

Builder multiplierLibraryBuilder(BuilderOptions options) =>
    LibraryBuilder(MultiplierGenerator());
```

### 5. 创建配置文件
在项目根目录下创建build.yaml文件，并配置各项参数：
```ymal
builders:
  multiplierBuilder:
    import: "package:build_demo/src/builder.dart"
    builder_factories: ["multiplierLibraryBuilder"]
    build_extensions: {".dart":[".g.dart"]}
    auto_apply: root_package
    build_to: source
```

### 6. 安装 `build_runner`
```shell
flutter pub add build_runner
```

### 7. 运行Builder
```shell
flutter packages pub run build_runner build
```

## Dart-APT 详解
### 1.注解创建与使用
Dart的注解创建和普通的class创建没有任何区别，可以 extends, 可以 implements ，甚至可以 with。
唯一必须的要求是：构造方法需要用 const 来修饰。
不同于java注解的创建需要指明@Target（定义可以修饰对象范围）
Dart 的注解没有修饰范围，定义好的注解可以修饰类、属性、方法、参数。
但值得注意的是，如果你的 Generator 直接继承自 GeneratorForAnnotation， 那你的 Generator 只能拦截到 top-level 级别的元素，对于类内部属性、方法等无法拦截，类内部属性、方法修饰注解暂时没有意义。（不过这个事情扩展一下肯定可以实现的啦~）

### 2.创建生成器 Generator
Generator 为创建代码而生。通常情况下，我们将继承 GeneratorForAnnotation，并在其泛型参数中添加目标 annotation。然后复写 generateForAnnotatedElement 方法，最终 return 一个字符串，便是我们要生成的代码。

#### 2.1 GeneratorForAnnotation与annotation的对应关系
GeneratorForAnnotation是单注解处理器，每一个 GeneratorForAnnotation 必须有且只有一个 annotation 作为其泛型参数。也就是说每一个继承自GeneratorForAnnotation的生成器只能处理一种注解。

#### 2.2 GenerateForAnnotatedElement 参数含义
最值得关注的是 generateForAnnotatedElement 方法的三个参数：Element element, ConstantReader annotation, BuildStep buildStep。我们生成代码所依赖的信息均来自这三个参数。

- `Element element`：被 annotation 所修饰的元素，通过它可以获取到元素的name、可见性等等。
- `ConstantReader annotation`：表示注解对象，通过它可以获取到注解相关信息以及参数值。
- `BuildStep buildStep`：这一次构建的信息，通过它可以获取到一些输入输出信息，例如输入文件名等

generateForAnnotatedElement 的返回值是一个 String，你需要用字符串拼接出你想要生成的代码，return null 意味着不需要生成文件。

#### 2.3 代码与文件生成规则
不同于java apt，文件生成完全由开发者自定义。GeneratorForAnnotation 的文件生成有一套自己的规则。

在不做其他深度定制的情况下，如果 generateForAnnotatedElement 的返回值 永不为空，则：

- 若一个源文件仅含有一个被目标注解修饰的类，则每一个包含目标注解的文件，都对应一个生成文件；

- 若一个源文件含有多个被目标注解修饰的类，则生成一个文件，generateForAnnotatedElement方法被执行多次，生成的代码通过两个换行符拼接后，输出到该文件中。

### 3.generateForAnnotatedElement 参数: Element
例如我们有这样一段代码，使用了 @TestMetadata 这个注解：
```dart
@ParamMetadata("ParamMetadata", 2)
@TestMetadata("papapa")
class TestModel {
  int age;
  int bookNum;

  void fun1() {}

  void fun2(int a) {}
}

```
在 generateForAnnotatedElement 方法中，我们可以通过 Element 参数获取 TestModel 的一些简单信息：
```dart
element.toString: class TestModel
element.name: TestModel
element.metadata: [@ParamMetadata("ParamMetadata",2),@TestMetadata("papapa")] 
element.kind: CLASS
element.displayName: TestModel
element.documentationComment: null
element.enclosingElement: flutter_annotation|lib/demo_class.dart
element.hasAlwaysThrows: false
element.hasDeprecated: false
element.hasFactory: false
element.hasIsTest: false
element.hasLiteral: false
element.hasOverride: false
element.hasProtected: false
element.hasRequired: false
element.isPrivate: false
element.isPublic: true
element.isSynthetic: false
element.nameLength: 9
element.runtimeType: ClassElementImpl
```

由前文我们知道，GeneratorForAnnotation的域仅限于class, 通过 element 只能拿到 TestModel 的类信息，那类内部的 Field 和 method 信息如何获取呢？
关注 kind 属性值： element.kind: CLASS，kind 标识 Element 的类型，可以是 CLASS、FIELD、FUNCTION 等等。
对应这些类型，还有相应的 Element 子类：ClassElement、FieldElement、FunctionElement等等，所以你可以这样：
```dart
if(element.kind == ElementKind.CLASS){
  for (var e in ((element as ClassElement).fields)) {
    print("$e \n");
  }
  for (var e in ((element as ClassElement).methods)) {
	print("$e \n");
  }
}

输出：
int age 
int bookNum 
void fun1() 
void fun2(int a) 
```

### 4.generateForAnnotatedElement 参数: annotation
注解除了标记以外，携带参数也是注解很重要的能力之一。注解携带的参数，可以通过 annotation 获取：
```dart
annotation.runtimeType: _DartObjectConstant
annotation.read("name"): ParamMetadata
annotation.read("id"): 2
annotation.objectValue: ParamMetadata (id = int (2); name = String('ParamMetadata'))
```
annotation 的类型是 ConstantReader，除了提供 read 方法来获取具体参数以外，还提供了peek方法，它们两个的能力相同，不同之处在于，如果read方法读取了不存在的参数名，会抛出异常，peek则不会，而是返回null。

### 5.generateForAnnotatedElement 参数: buildStep
buildStep 提供的是该次构建的输入输出信息:
```dart
buildStep.runtimeType: BuildStepImpl
buildStep.inputId.path: lib/demo_class.dart
buildStep.inputId.extension: .dart
buildStep.inputId.package: flutter_annotation
buildStep.inputId.uri: package:flutter_annotation/demo_class.dart
buildStep.inputId.pathSegments: [lib, demo_class.dart]
buildStep.expectedOutputs.path: lib/demo_class.g.dart
buildStep.expectedOutputs.extension: .dart
buildStep.expectedOutputs.package: flutter_annotation
```

### 6.模板代码生成技巧
现在，你已经获取了所能获取的三个信息输入来源，下一步则是根据这些信息来生成代码。

如何生成代码呢？你有以下两个选择：

#### 6.1 简单模板代码，字符串拼接：
如果需要生成的代码不是很复杂，则可以直接用字符串进行拼接，比如这样：
```dart
generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    ...
    StringBuffer codeBuffer = StringBuffer("\n");
    codeBuffer..write("class ")
      ..write(element.name)
      ..write("_APT{")
      ..writeln("\n")
      ..writeln("}");
    
    return codeBuffer.toString();
  }
```
不过一般情况下我们并不建议这样做，因为这样写起来太容易出错了，且不具备可读性。

#### 6.2 复杂模板代码，dart 多行字符串+占位符
dart提供了一种三引号的语法，用于多行字符串：
```dart
var str3 = """大王叫我来巡山
  路口遇见了如来
  """;
```
结合占位符后，可以实现比较清晰的模板代码：
```dart
tempCode(String className) {
    return """
      class ${className}APT {
 
      }
      """;
  }
  
generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    ...
    return tempCode(element.name);
  } 
```
如果参数过多的话，tempCode方法的参数可以替换为一个Map。

(在模板代码中不要忘记import package哦~ 建议先在编译器里写好模板代码，编译器静态检查没有问题了，再放到三引号中修改占位符)

如果你熟悉java-apt的话，看到这里应该会想问，dart里有没有类似 javapoet 这样的代码库来辅助生成代码啊？从个人角度来说，更推荐第二种方式去生成代码，因为它表现的足够清晰，具有足够高的可读性，比起javapoet这种模式，可以更容易的理解模板代码意义，编写也更加简单。

### 7.配置文件字段含义
在工程根目录下创建build.yaml 文件，用来配置Builder相关信息。
以下面配置为例：
```ymal
builders:
  test_builder:
    import: 'package:flutter_annotation/test_builder.dart'
    builder_factories: ['testBuilder']
    build_extensions: { '.dart': ['.g1.dart'] }
    required_inputs:['.dart']
    auto_apply: root_package
    build_to: source

  test_builder2:
    import: 'package:flutter_annotation/test_builder2.dart'
    builder_factories: ['testBuilder2']
    build_extensions: { '.dart': ['.g.dart'] }
    auto_apply: root_package
    runs_before: ['flutter_annotation|test_builder']
    build_to: source
```

在builders 下配置你所有的builder。test_builder与 test_builder2 均是你的builder命名。

- import 关键字用于导入 return Builder 的方法所在包 （必须）
- builder_factories 填写的是我们 return Builder 的方法名（必须）
- build_extensions  指定输入扩展名到输出扩展名的映射，比如我们接受.dart文件的输入，最终输出.g.dart 文件（必须）
- auto_apply 指定builder作用于，可选值：  （可选，默认为 none）
    - "none"：除非手动配置，否则不要应用此Builder
    - "dependents"：将此Builder应用于包，直接依赖于公开构建器的包。
    - "all_packages"：将此Builder应用于传递依赖关系图中的所有包。
    - "root_package"：仅将此Builder应用于顶级包。
- build_to 指定输出位置,可选值： （可选，默认为 cache）
    - "source": 输出到其主要输入的源码树上
    - "cache": 输出到隐藏的构建缓存上
- required_inputs:  指定一个或一系列文件扩展名，表示在任何可能产生该类型输出的Builder之后运行（可选）
- runs_before: 保证在指定的Builder之前运行

配置字段的解释较为拗口，这里我只列出了常用的一些配置字段，还有一些不常用的字段可以在 [source_gen的github主页](https://pub.dev/packages/build_config) 查阅。

> 转载：https://juejin.cn/post/6844903878392053774
