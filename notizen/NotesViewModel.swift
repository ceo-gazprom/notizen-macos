import Foundation

class NotesViewModel: ObservableObject {
    @Published var notes: [Note] = []
    
    private let saveKey = "SavedNotes"

    init() {
        loadNotes()
    }

    func saveNotes() {
        if let data = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }

    func loadNotes() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let savedNotes = try? JSONDecoder().decode([Note].self, from: data) {
            notes = savedNotes
        }
    }

    // Добавление новой заметки
    func addNote(title: String, content: String) {
        let newNote = Note(
            id: UUID(),
            title: title,
            content: content,
            createdAt: Date()
        )
        notes.append(newNote)
    }

    // Удаление заметки
    func deleteNote(at offsets: IndexSet) {
        notes.remove(atOffsets: offsets)
    }

    // Обновление существующей заметки
    func updateNote(id: UUID, title: String, content: String) {
        if let index = notes.firstIndex(where: { $0.id == id }) {
            notes[index].title = title
            notes[index].content = content
        }
    }
    
    func removeNote(note: Note) {
        notes.removeAll { $0.id == note.id }
    }
    
    // Загрузка заметок из JSON
    func importNotes(from url: URL) {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let importedNotes = try decoder.decode([Note].self, from: data)
            notes.append(contentsOf: importedNotes)
        } catch {
            print("Error loading notes from JSON: \(error.localizedDescription)")
        }
    }

    // Экспорт заметок в JSON
    func exportToJSON() -> URL? {
        do {
            let data = try JSONEncoder().encode(notes)
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("Notes.json")
            try data.write(to: url)
            return url
        } catch {
            print("Ошибка экспорта: \(error)")
            return nil
        }
    }
}
