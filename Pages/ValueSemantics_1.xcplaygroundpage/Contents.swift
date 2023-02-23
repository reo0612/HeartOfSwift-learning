import UIKit

// Heart of Swift
// 参照先: https://heart-of-swift.github.io/

// Swiftの中心的な考え方は大きく2つ
// ・Value Semantics(値の意味論)
// ・Protocol-oriented Programing(プロトコル指向プログラミング)

// ○ Value Semanticsの定義

// ある型がValue Semanticsを持っている状態
// ・その型の変数を初期化、値を代入したり、引数に渡したりしたときに元の値のコピーが作られる
// ・元の値と元の値のコピーは"独立に変更すること"ができる(どちらかを変更してももう片方には影響を与えない)

// ・Value Semanticsを持つ例

struct HogeStruct {
    // 元の値
    var value: Int = 0
}

// 変数hogeに代入する
//var hoge = HogeStruct()
// 変数hogeを変数fugaに代入する
//var fuga = hoge
// 変数hogeのvalueに対して2を代入する
//hoge.value = 2

// この時、変数fugaのvalueも2になるのかというと...ならない
//print(hoge.value) // 2
//print(fuga.value) // 0

// structは値型で"HogeStructのインスタンスは、
// 変数hoge自身が格納されているスタック領域に対して直接格納される(値型のインスタンスがコピーされる)

// なのでhoge変数からfuga変数を代入(fuga変数のスタック領域にHogeStructインスタンスがコピーされる)しても
// それは複製なので、変数hogeのvalueプロパティの値を変更したとしても変数fugaには影響が及ばない

// この事から"変更に対する独立性を持っている"ため、HogeStructはValue Semanticsを持っていると言える


// ・Value Semanticsを持たない例

class HogeClass {
    // 元の値
    var value: Int = 0
}

// 変数hogeに代入する
var hoge = HogeClass()
// 変数hogeを変数fugaに代入する
var fuga = hoge
// 変数hogeのvalueに対して2を代入する
hoge.value = 2

// この時、変数fugaのvalueも2になるのかというと...なる
print(hoge.value)
print(fuga.value)

// classは参照型でHogeClassのインスタンス生成時に、メモリ上のヒープ領域のどこかに格納され、
// "その領域を表すメモリアドレス"が変数に格納される(hoge変数およびfuga変数は同一のメモリアドレスを参照している)

// なので、hoge変数のvalueプロパティを変更すれば
// fuga変数のvalueプロパティも変更されてしまう

// "変更に対する独立性を持っていない"ことになる
// Value Semanticsと対比して、Reference Semanticsと呼ばれる

// ○ Value SemanticsとReference Semantics
// Value Semanticsは値型、Reference Semanticsは参照型と深い関係があるが混同してしてはいけない

// 値型だけど、Reference Semanticsになっている場合も存在するし、
// 参照型だけど、Value Semanticsになっている場合も存在する

// ・値型だけどValue Semanticsを持たない例

//class Bar {
//    var value: Int = 0
//}

struct Foo {
    var value: Int = 0
    var bar: Bar = Bar()
}

//var a = Foo()
//var b = a
//a.value = 2
//a.bar.value = 3

// Fooは値型のため、変数a及び変数bに別々のFooインスタンスのコピーが格納されているので
// a.valueとb.valueはお互いの変更に影響を及ばさない

// ただ、Barは参照型なのでaとbのbarプロパティにはBarのメモリアドレスが格納されている
// つまり、そのアドレスを介して同じインスタンスを参照しているということ

// なので下記のように値を代入すれば
// a.bar.value = 3

// b.bar.valueも変更されてしまう
//print(a.bar.value)
//print(b.bar.value)

// そのため、Fooは値型だけど"変更に対する独立性を持っていない"
// なので、Value Semanticsを持っていないことになる

// だけど、a.valueとb.valueは"変更に対する独立性を持っている"
// なので、Reference Semanticsも持たないことになる

// このように、Value Semanticsおよび
// Reference Semanticsを持たない型になる

// このような型は非常に扱いづらいとされている

// ・参照型プロパティを持っているけどValue Semanticsを持つ例

// 先ほどのBarクラスをイミュータブルなクラスに変更する
final class Bar {
    let value: Int = 0
}

// Barクラスをイミュータブルなクラスにするために
// valueプロパティをletに変更し、final classにしている

// final classにする理由としては継承したサブクラスが作られてしまうと
// イミュータビリティが破壊されてしまうから
// ※ 『ImmutableAndMutable』を参照

var a = Foo()
var b = a
a.value = 2
//a.bar.value = 3 // コンパイルエラーになる

// a.bar, b.barはどちらも同一のBarクラスのインスタンスを参照している
// ただ、同じインスタンスを参照しているがBarクラスはイミュータブルなクラスなので
// そのインスタンスを介してプロパティを変更することができない

// この事から値型に参照型のプロパティが定義されていたとしても
// "独立性を破壊される"ということにはならない

// つまり、Fooは参照型のプロパティBarを定義されているが
// Value Semanticsを持っているということになる

// イミュータブルクラス自体はどうだろうか

var c = Bar()
var d = c
//c.value = 2

// 上記のようにイミュータブルクラスのインスタンスはそもそも変更することができないので
// 片方を変更すれば、片方が変更されるということは起こらない

// なのでイミュータブルクラス自体は、
// Value Semanticsを持っている

// MARK: - ミュータブルな参照型をプロパティを持つけどValue Semanticsを持つ例



/*
 
 先ほどの例では、ミュータブルな参照型プロパティを持つ場合、Value Semanticsを持っていなかった
 
 struct Foo {
    var value: Int = 0
    // ミュータブルな参照型プロパティ
    var bar: Bar = Bar()
 }
 
 class Bar {
    var value: Int = 0
 }
 
 しかし、「ミュータブルな参照型プロパティを持つ場合、Value Semanticsを持たない」というパターンで判断するのは危険⚠️
 
 例えば、標準ライブラリの`Array`は内部にミュータブルな参照型を保持しているのにも関わらず、
 Copy-on-Writeという仕組みでValue Semanticsを実現している
 
 なので大切なのは、そのようなパターンで判断しないで、定義をしっかり確認して判断することが大切である
 
 */

// MARK: - まとめ

/*
 
 ・ある型がValue Semanticsを持つ状態というのは、「その型の値が変更に対して独立している」ということ
 ・値型とValue Semantics、参照型とReference Semanticsと混同して考えず、区別して考える
 ・値型でもReference Semanticsを持っている事があるし、その逆もあり得るのでパターンで考えず、定義に基づいて判断する
 
 */
