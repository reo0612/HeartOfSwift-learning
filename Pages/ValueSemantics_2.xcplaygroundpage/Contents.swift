// ○ Value Semanticsを持たない型の問題と対処法

// Value Semanticsを持たない型は以下のような問題を引き起こす
// ・意図しない変更
// ・整合性の破壊

// ○ 意図しない変更の例

// 意図しない変更の例として、あるサービスのアイテムを考える(TODOアプリなら個々のTODOであったり、写真アプリだと写真..etc)

class Item {
    var name: String
    var settings: Settings
    
    init(name: String, settings: Settings) {
        self.name = name
        self.settings = settings
    }
}

// 設定を表すクラス
// このクラスはReference Semanticsを持っている
class Settings {
    // アイテムが公開されているかどうか
    var isPublic: Bool

    init(isPublic: Bool) {
        self.isPublic = isPublic
    }
}

// 例えば、アイテム複製の処理をしたとする

let item = Item(name: "今日やったこと", settings: Settings(isPublic: false))
let _item = Item(name: item.name, settings: item.settings)

// この時、公開するためにSettingsのisPublicプロパティをtrueに変更すると...?

_item.settings.isPublic = true

// SettingsクラスはReference Semanticsを持っているので
// 上記の変更は、オリジナルのitem変数の方にも影響を及ぼしてしまう

print(item.settings.isPublic) // true
print(_item.settings.isPublic) // true

// このように複製されたアイテムだけを公開したかったのに
// オリジナルのアイテムも公開されているので意図していない変更になっている

// Itemインスタンスを複製するときに、
// Settingsインスタンスも複製しないといけなかった(ディープコピーしなければいけなかった)

// ○ 整合性の破壊の例

// 以下のクラスは姓と名を持ったPersonクラスで
// 姓と名を連結してフルネームを返してくれる
// そして、内部でキャッシュを持つ

class Person {
    init(firstName: String, familyName: String) {
        self.firstName = firstName
        self.familyName = familyName
    }
    
    // キャッシュとの整合性が崩れるので
    // firstName及びfamilyNameに
    // アクセス後、キャッシュをクリアする
    
    // firstNameに変更があった場合にキャッシュをクリアする
    var firstName: String {
        didSet {
            _fullName = nil
        }
    }
    var familyName: String {
        // familyNameに変更があった場合にキャッシュをクリアする
        didSet {
            _fullName = nil
        }
    }
    
    private var _fullName: String? // キャッシュを持つために生成
    var fullName: String {
        // 2度目以降のアクセスはキャッシュされたものを返す
        if let fullName = _fullName {
            return fullName
        }
        // 初回アクセス時はキャッシュする
        _fullName = firstName + familyName
        return _fullName!
    }
}

// 整合性の破壊は上記で起こるのか？

// 例えば、以下のような処理があったとする

let person: Person = Person(firstName: "Taylor", familyName: "Swift")
var familyName: String = person.familyName
familyName.append("y")

/*
 String自体はValue Semanticsを持っているから
`familyName.append`による変更はperson.familyNameに影響を及ばさない

つまり、Value Semanticsを持っている
 */

print(person.familyName) // Swift
print(familyName) // Swifty

/*
 
 だが、もし仮にStringがReference Semanticsを持つ場合どうなるか？
 
 StringがReference Semanticsを持っていたら、
 `person.familyName`も`familyName`も同じインスタンスを共有する事になる
 
 なので、`familyName.append("y")`によって
 `person.familyName`、`familyName`は"Swifty"になる
 
 ただ、これ自体は悪いことではない
 問題になるのは、`fullName`のキャッシュの存在である
 
 
 例えば、以下のような処理があったとする
 */

print(person.fullName) // Taylor Swift

var firstName = person.firstName
firstName.append("z")

// 整合性が保ていない🥺

print(person.firstName) // Taylorz
print(person.fullName) // Taylor Swift

/*
 
 状態が変更された時は、キャッシュをクリアするように設計したのに
 なんで整合性が保てていないのかというと「想定していないパスで値を変更した」から
 
 例えば、以下のように直接、変更していれば整合性が破壊されることはなかった
 
 */

firstName = "Taylorz"
print(person.firstName) // Taylorz
print(person.fullName) // Taylorz Swift

/*
 
 原因としては、`append`で間接的に状態が変更されるということを想定していなかったこと
 
 このように、Reference Semanticsではこのような事態に陥りやすく、
 設計時に見落とせば簡単に整合性の破壊が起きてしまう
 
 */

// MARK: - 問題への対処法

/*
 
 参照型中心の言語では先ほどのセクションのような問題が起こるので
 いくつか対処法が存在する
 
 ・防御的コピー
 ・Read-only View
 ・イミュータブルクラス
 
 ただ、Swiftでは値型を用いることで問題を対処する事が可能
 
 以下でイミュータブルクラスと値型を比較してみる
 */

// MARK: - イミュータブルクラスによる解決方法

class A {
    var str: String
    var b: B
    
    init(str: String, b: B) {
        self.str = str
        self.b = b
    }
}

class B {
    let flg: Bool
    
    init(flg: Bool) {
        self.flg = flg
    }
}

var a = A(str: "hoge", b: B(flg: false))
var _a = A(str: a.str, b: a.b)

/*
 
 _a変数(aの複製)が間違って、flgプロパティを変更しようとしても、
 イミュータブルなので変更できない
 
 つまり、「意図しない変更」が防げている
 
 */

_a.b.flg = true // コンパイルエラー❌

/*
 変更するためには、新しく`B`インスタンスを生成して
 `_a.b.flg`に代入する必要がある
 
 この場合、`_a.b.flg`に代入されるのは全く新しい`B`インスタンスなので
 `a.b.flg`に影響を与える事はない
 
 */

_a.b = B(flg: true)

/*

 整合性の破壊もイミュータブルクラスによって解決する(ここでは例は割愛)
 
 java, kotlinなどの参照型中心の言語ではStringはイミュータブルクラスとして実装されており、
 それは「意図しない変更」、「整合性の破壊」を防止するため
 
 だったら、全てイミュータブルクラスで定義すれば良いのかというとそうでもない
 
 */

// MARK: - イミュータブルクラスの問題

/*
 例えば、何らかのサービスのUserクラスを実装し、
 ユーザーはそれぞれそのサービスで使う事ができるポイントを持っているとする
 
 そして、そのポイントを付与する処理を行うとする
 */

class MutableUser {
    let name: String
    var point: Int
    
    init(name: String, point: Int) {
        self.name = name
        self.point = point
    }
}



// ミュータブルクラスの場合

var mutableUser = MutableUser(name: "takashi", point: 0)
mutableUser.point = 100

// イミュータブルクラスの場合

final class ImutableUser {
    let name: String
    let point: Int
    
    init(name: String, point: Int) {
        self.name = name
        self.point = point
    }
}

var imutableUser = ImutableUser(name: "takashi", point: 0)
// ImutableUserインスタンスのpointプロパティに100ポイントを付与できない
imutableUser.point = 100 // ❌

/*
 なので100ポイントを付与する場合、以下のようにpoint以外は全く同じで、
 100ポイント増えたインスタンスを新しく生成しないといけない
 
 そして、imutableUser変数に対して新しいインスタンスを代入しないといけない
 
 今は、nameとpointだけなのであまり複雑ではないが色々な状態を持つようになると
 複雑になって、何らかのバグを生みかねない
 
 pointプロパティを更新するだけで、インスタンスを丸ごと作り直すのは
 面倒だし、パフォーマンス的にも宜しくない(無駄なインスタンスをヒープ領域に格納する事になる)
 
 */

imutableUser = ImutableUser(name: imutableUser.name, point: imutableUser.point + 100)

// MARK: - 値型

/*
 
 例えば、先ほどの例で出てきたような「意図しない変更」を解決する
 
 */

class C {
    var str: String
    var d: D
    
    init(str: String, d: D) {
        self.str = str
        self.d = d
    }
}

struct D {
    var flg: Bool
    
    init(flg: Bool) {
        self.flg = flg
    }
}

var c = C(str: "hoge", d: D(flg: false))
var _c = c // 複製を生成
_c.d.flg = true // c.d.flgは値型だから変更されない😁

