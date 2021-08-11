import '../class/test_multiplier.dart';

@TestMultiplier('JsonYe', 100)
class JsonYe {
  String? name;
  int? age;
  bool? sex;

  void eat(dynamic anything) {}

  String talk() {
    return "$name talk";
  }

  void fun1() {}

  void fun2(int a) {}
}

@TestMultiplier("Liuli", 80)
void LiuLi() {}

@TestMultiplier("Alibaba", 101)
const String Alibaba = 'AlibabaStr';

@TestMultiplier("Huba", 100)
enum Huba { get, post }

@TestMultiplier("Litda", 88)
mixin Litda {}
