import SwiftUI

struct SmartQuestionCard: View {
    let question: String
    let onAnswer: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Image(systemName: "sparkles")
                    .font(.title2)
                    .foregroundColor(.purple)
                    .padding(8)
                    .background(Color.purple.opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Quick Question")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    
                    Text(question)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .foregroundColor(.secondary)
                        .padding(8)
                }
            }
            
            Button(action: onAnswer) {
                HStack {
                    Image(systemName: "mic.fill")
                    Text("Tap to Answer")
                }
                .font(.subheadline.bold())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    LinearGradient(
                        colors: [Color.purple, Color.blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct SmartQuestionCard_Previews: PreviewProvider {
    static var previews: some View {
        SmartQuestionCard(
            question: "Does he have a preferred soap brand for bath time?",
            onAnswer: {},
            onDismiss: {}
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
