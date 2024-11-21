import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var viewModel = NotesViewModel()
    @State private var selectedNote: Note? // Хранит выбранную заметку
    @State private var isShowingEditor = false
    
    var body: some View {
        NavigationSplitView {
            // Список заметок
            List(viewModel.notes, id: \.id) { note in
                HStack {
                    VStack(alignment: .leading) {
                        Text(note.title)
                            .font(.headline)
                        Text(note.createdAt, style: .date)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    
                    // Кнопка удаления заметки
                    Button {
                        viewModel.removeNote(note: note)
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(BorderlessButtonStyle()) // Позволяет кнопке работать в списке
                    
                    // Кнопка редактирования заметки
                    Button {
                        selectedNote = note // Устанавливаем выбранную заметку для редактирования
                        isShowingEditor = true // Открываем редактор
                    } label: {
                        Image(systemName: "pencil")
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(BorderlessButtonStyle()) // Позволяет кнопке работать в списке
                }
                .onTapGesture {
                    selectedNote = note // Обновляем выбранную заметку
                }
            }
            .navigationTitle("Notes")
            .toolbar {
                // Кнопка добавления новой заметки
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        selectedNote = nil // Сбрасываем выбор для новой заметки
                        isShowingEditor = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                
                // Кнопка экспорта в JSON
                ToolbarItem(placement: .secondaryAction) {
                    Button {
                        if let url = viewModel.exportToJSON() {
                            NSWorkspace.shared.open(url)
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
                
                // Кнопка импорта из JSON
                ToolbarItem(placement: .secondaryAction) {
                    Button {
                        importNotesFromJSON()
                    } label: {
                        Image(systemName: "square.and.arrow.down")
                    }
                }
            }
        } detail: {
            if let selectedNote = selectedNote {
                VStack {
                    Text(selectedNote.title)
                        .font(.title)
                    
                    // Добавляем ScrollView для прокрутки
                    ScrollView {
                        Text(selectedNote.content) // Контент заметки
                            .font(.body)
                            .padding() // Добавляем отступы
                    }
                    .padding() // Добавляем отступы для ScrollView
                }
                .padding()
            } else {
                Text("Select a note to view details")
                    .foregroundColor(.gray)
                    .font(.title2)
            }
        }
        .sheet(isPresented: $isShowingEditor) {
            NoteEditorView(
                viewModel: viewModel,
                note: $selectedNote
            )
        }
    }
    
    private func importNotesFromJSON() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.json]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        
        if panel.runModal() == .OK, let url = panel.url {
            viewModel.importNotes(from: url)
        }
    }
}
