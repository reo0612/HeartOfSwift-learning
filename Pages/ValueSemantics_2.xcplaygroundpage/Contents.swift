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

// 例えば、アイテムの複製の処理をしたとする

// オリジナル
let item = Item(name: "今日やったこと", settings: Settings(isPublic: false))
// オリジナルから複製を作成する
let copy = Item(name: item.name, settings: item.settings)

// 複製されたアイテムはcopyに格納されている
// この時、公開するためにSettingsのisPublicプロパティをtrueに変更すると...?

copy.settings.isPublic = true

// SettingsクラスはReference Semanticsを持っているので
// 上記の変更は、オリジナルのitem変数の方にも影響を及ぼしてしまう

print(item.settings.isPublic) // true
print(copy.settings.isPublic) // true

// このように複製されたアイテムだけを公開したかったのに
// オリジナルのアイテムも公開されているので意図していない変更になっている

// Itemインスタンスを複製するときに、
// Settingsインスタンスも複製しないといけなかった(ディープコピーしなければいけなかった)


// ○ 整合性の破壊の例


