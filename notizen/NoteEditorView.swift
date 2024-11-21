import SwiftUI

struct NoteEditorView: View {
    @ObservedObject var viewModel: NotesViewModel
    @Binding var note: Note?

    @State private var title = ""
    @State private var content = ""

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            TextField("Title", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            TextEditor(text: $content)
                .frame(height: 300)
                .border(Color.gray, width: 1)
                .padding()

            Button("Save") {
                if let note = note {
                    viewModel.updateNote(id: note.id, title: title, content: content)
                } else {
                    viewModel.addNote(title: title, content: content)
                }
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
        }
        .onAppear {
            if let note = note {
                title = note.title
                content = note.content
            }
        }
        .padding()
    }
}
