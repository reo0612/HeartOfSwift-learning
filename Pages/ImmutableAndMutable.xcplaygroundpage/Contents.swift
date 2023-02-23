
// TODO: もっと良い例を考えたい

// イミュータブル(不変)なクラスを継承したミュータブル(可変)なサブクラスを生成すると
// イミュータビリティ(不変性)が破壊されてしまう例

// イミュータブルなクラス
class Person {
    let name: String
    let age: Int
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
}

let person = Person(name: "reo", age: 25)
// イミュータブルなクラスだからもちろん、コンパイルエラーになっちゃう
//person.name = "imanishi"

// ミュータブルなクラス
class Men: Person {
    var mutableGrades: [Int] = []
}

let girl = Person(name: "Alice", age: 18)
let men = Men(name: "Bob", age: 20)
let people: [Person] = [girl, men]

for person in people {
    // 以下の条件だと問題が起きてしまう
    // もちろん、people[0]はPersonクラスのインスタンスなので
    // Menクラスのインスタンスにキャストできないから必ず失敗する
    if let _men = person as? Men {
        // ただif文の中では、girl(Personインスタンス)がMenのインスタンスに
        // キャストできた場合を前提としているので、mutableGradesにアクセスできてしまう
        _men.mutableGrades.append(90)
        
        // コンパイルエラーにならず、
        // 実行中にエラーになるのでかなり注意が必要
    }
}
print(men.mutableGrades)
