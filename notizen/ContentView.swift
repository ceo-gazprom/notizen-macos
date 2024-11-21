import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var viewModel = NotesViewModel()
    @State private var selectedNote: Note? // Хранит выбранную заметку
    @State private var isShowingEditor = false
    
    var body: some View {
        NavigationSplitView {
            VStack {
                if viewModel.notes.isEmpty {
                    // Показать сообщение, если список пуст
                    Text("No notes available")
                        .font(.title2)
                        .foregroundColor(.gray)
                        .padding()
                } else {
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
                }
            }
            .navigationTitle("Notes")
            .toolbar {
                // В правом верхнем углу выпадающее меню с действиями
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(action: {
                            importNotesFromJSON()
                        }) {
                            Label("Import Notes", systemImage: "square.and.arrow.down")
                        }
                        Button(action: {
                            if let url = viewModel.exportToJSON() {
                                NSWorkspace.shared.open(url)
                            }
                        }) {
                            Label("Export Notes", systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title)
                    }
                }
                
                // Кнопка создания новой заметки
                ToolbarItem(placement: .principal) {
                    Button(action: {
                        selectedNote = nil // Сбрасываем выбор для новой заметки
                        isShowingEditor = true
                    }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("New Note")
                                .font(.headline)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .padding(.horizontal)
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
