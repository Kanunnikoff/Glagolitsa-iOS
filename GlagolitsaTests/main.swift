import Foundation

private func assertEqual(_ actual: String, _ expected: String, _ message: String) {
    guard actual == expected else {
        fatalError("\(message): ожидалось '\(expected)', получено '\(actual)'")
    }
}

let converter = Converter.create()

assertEqual(
    converter.convert(fromCyrillic: "мир", glagoliticILetter: .i),
    "ⰿⰻⱃ",
    "Обычная буква i должна сохранять прежний перевод кириллической и"
)

assertEqual(
    converter.convert(fromGlagolitic: "ⰿⰻⱃ", glagoliticILetter: .i),
    "мир",
    "Обычная буква i должна сохранять прежний обратный перевод"
)

assertEqual(
    converter.convert(fromCyrillic: "мир", glagoliticILetter: .izhe),
    "ⰿⰹⱃ",
    "Izhe должна использоваться как глаголическая и"
)

assertEqual(
    converter.convert(fromGlagolitic: "ⰿⰹⱃ", glagoliticILetter: .izhe),
    "мир",
    "Izhe должна переводиться обратно как кириллическая и"
)

assertEqual(
    converter.convert(fromCyrillic: "мир", glagoliticILetter: .initialIzhe),
    "ⰿⰺⱃ",
    "Initial Izhe должна использоваться как глаголическая и"
)

assertEqual(
    converter.convert(fromGlagolitic: "ⰿⰺⱃ", glagoliticILetter: .initialIzhe),
    "мир",
    "Initial Izhe должна переводиться обратно как кириллическая и"
)

assertEqual(
    converter.convert(fromGlagolitic: "ⱏⰺ", glagoliticILetter: .initialIzhe),
    "ы",
    "Составная ы должна иметь приоритет над отдельной выбранной буквой и"
)

print("Проверки переводчика пройдены")
