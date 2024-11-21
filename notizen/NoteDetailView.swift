import SwiftUI

struct NoteDetailView: View {
    let note: Note
    var onEdit: () -> Void // Колбэк для вызова редактора

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(note.title)
                .font(.largeTitle)
                .bold()

            Text(note.createdAt, style: .date)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Divider()

            ScrollView {
                Text(note.content)
                    .font(.body)
                    .padding(.top, 8)
            }

            Spacer()
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    onEdit()
                } label: {
                    Image(systemName: "pencil")
                }
            }
        }
        .navigationTitle("Note Details")
    }
}
