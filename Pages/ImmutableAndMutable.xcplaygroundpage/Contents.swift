
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

// ミュータブルなクラス
class Men: Person {
    var mutableGrades: [Int] = []
}

let girl = Person(name: "Alice", age: 18)
let men = Men(name: "Bob", age: 20)
let people: [Person] = [girl, men]

for person in people {
    // 以下の条件だと問題が起きてしまう
    // もちろん、personはPersonクラスのインスタンスなので
    // Menクラスのインスタンスにキャストできないから必ず失敗する
    if let _men = person as? Men {
        // ただif文の中では、girl(Personインスタンス)がMenのインスタンスに
        // キャストできた場合を前提としているので、mutableGradesにアクセスできてしまう
        
        // なので、コンパイルエラーにならないため、
        // 実行中にエラーになるのでかなり注意が必要
        
        // この例だと、ここの条件に入ることは絶対ないが
        // 下記のような危険性があるということ
        _men.mutableGrades.append(90)
    }
}
print(men.mutableGrades)
