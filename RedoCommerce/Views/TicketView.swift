import SwiftUI

enum TicketSheet: String, Identifiable {
    case details, templates, snooze, tags, forward
    var id: String { rawValue }
}

struct TicketView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss
    let ticketID: UUID
    @State private var draft = ""
    @State private var isNote = false
    @State private var sheet: TicketSheet?

    var body: some View {
        if let ticket = store.ticket(ticketID) {
            VStack(spacing: 0) {
                header(ticket)
                Divider()
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(ticket.messages) { MessageBubble(message: $0).id($0.id) }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                    .onAppear { proxy.scrollTo(ticket.messages.last?.id, anchor: .bottom) }
                    .onChange(of: ticket.messages.count) {
                        withAnimation { proxy.scrollTo(ticket.messages.last?.id, anchor: .bottom) }
                    }
                }
                Divider()
                composer(ticket)
            }
            .toolbar(.hidden, for: .navigationBar)
            .toolbar(.hidden, for: .tabBar)
            .sheet(item: $sheet) { s in
                switch s {
                case .details: DetailsView(ticketID: ticketID)
                case .templates: TemplatesView { draft = $0.body.replacingOccurrences(of: "{first_name}", with: ticket.customer.firstName) }
                case .snooze: SnoozeView { snooze() }.presentationDetents([.medium])
                case .tags: TagsView(ticketID: ticketID).presentationDetents([.medium])
                case .forward: ForwardView(subject: ticket.subject ?? "Conversation with \(ticket.customer.name)")
                }
            }
        }
    }

    func header(_ t: Ticket) -> some View {
        HStack(alignment: .top) {
            Button { dismiss() } label: {
                Image(systemName: "arrow.left").font(.system(size: 18, weight: .medium)).foregroundStyle(.black).frame(width: 32, height: 32)
            }
            VStack(alignment: .leading, spacing: 6) {
                Button { sheet = .details } label: {
                    HStack(spacing: 8) {
                        Avatar(initials: t.customer.initials, size: 28)
                        Text(t.customer.name).font(.system(size: 18, weight: .medium)).foregroundStyle(.black).lineLimit(1)
                    }
                }
                HStack(spacing: 6) {
                    ChannelChip(channel: t.channel)
                    StatusChip(status: t.status)
                }
            }
            Spacer()
            if t.status == .closed {
                Button("Reopen") { store.update(ticketID) { $0.status = .open } }.buttonStyle(OutlineButton())
            } else {
                Button {
                    store.update(ticketID) { $0.status = .closed }
                    dismiss()
                } label: { Label("Close", systemImage: "checkmark") }
                    .buttonStyle(SolidButton())
            }
            Menu {
                Button { sheet = .details } label: { Label("Details", systemImage: "person.text.rectangle") }
                Button { sheet = .snooze } label: { Label("Snooze", systemImage: "moon") }
                Button { sheet = .tags } label: { Label("Edit tags", systemImage: "tag") }
                if t.channel == .email {
                    Button { sheet = .forward } label: { Label("Forward email", systemImage: "arrowshape.turn.up.right") }
                }
                Button { store.update(ticketID) { $0.assignee = nil }; dismiss() } label: { Label("Unassign", systemImage: "person.badge.minus") }
            } label: {
                Image(systemName: "ellipsis").font(.system(size: 18, weight: .semibold)).foregroundStyle(.black).frame(width: 36, height: 44)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    func composer(_ t: Ticket) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Menu {
                Button { isNote = false } label: { Label("Reply", systemImage: "text.bubble") }
                Button { isNote = true } label: { Label("Internal note", systemImage: "note.text") }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: isNote ? "note.text" : "text.bubble")
                    Text(isNote ? "Internal note" : "Reply").font(.system(size: 16, weight: .medium))
                    Image(systemName: "chevron.down").font(.system(size: 12, weight: .semibold))
                }
                .foregroundStyle(Color(white: 0.25))
            }
            .padding(.leading, 12)

            ZStack(alignment: .topLeading) {
                TextEditor(text: $draft)
                    .scrollContentBackground(.hidden)
                    .padding(6)
                if draft.isEmpty {
                    Text(isNote ? "Add a note for your team..." : "Start typing...").foregroundStyle(Color(white: 0.6)).padding(.horizontal, 11).padding(.vertical, 14)
                        .allowsHitTesting(false)
                }
            }
            .frame(height: 84)
            .background(isNote ? Color.redoCream : Color.white, in: RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.redoBorder))

            HStack(spacing: 22) {
                Image(systemName: "paperclip")
                Button { sheet = .templates } label: { Image(systemName: "bolt") }
                Spacer()
                let ready = !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                Button(action: send) {
                    HStack(spacing: 10) {
                        Image(systemName: "paperplane")
                        Text("Send")
                        Rectangle().frame(width: 1, height: 20).opacity(0.4)
                        Image(systemName: "chevron.down").font(.system(size: 12, weight: .semibold))
                    }
                }
                .buttonStyle(SolidButton(enabled: ready))
                .disabled(!ready)
            }
            .font(.system(size: 18))
            .foregroundStyle(Color(white: 0.25))
            .padding(.horizontal, 8)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    func send() {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        store.update(ticketID) {
            $0.messages.append(Message(author: "You", kind: isNote ? .note : .agent, text: text, time: "Just now"))
            $0.updated = "Just now"
        }
        draft = ""
    }

    func snooze() {
        sheet = nil
        store.update(ticketID) { $0.status = .snoozed }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { dismiss() }
    }
}

struct MessageBubble: View {
    let message: Message

    var body: some View {
        switch message.kind {
        case .event:
            HStack(spacing: 6) {
                Image(systemName: "arrow.triangle.2.circlepath")
                Text(message.text)
            }
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(Color.redoPurple)
            .padding(.horizontal, 10).padding(.vertical, 5)
            .background(Color.redoLavender, in: Capsule())
            .frame(maxWidth: .infinity)
        case .customer:
            VStack(alignment: .leading, spacing: 6) {
                meta
                Text(message.text)
                    .padding(12)
                    .background(Color.redoField, in: RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.redoBorder))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.trailing, 50)
        case .agent, .note:
            VStack(alignment: .trailing, spacing: 6) {
                meta
                Text(message.text)
                    .foregroundStyle(message.kind == .note ? Color.black : Color.white)
                    .padding(12)
                    .background(message.kind == .note ? Color.redoCream : Color.black, in: RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(message.kind == .note ? Color.orange.opacity(0.35) : Color.clear))
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.leading, 50)
        }
    }

    var meta: some View {
        HStack(spacing: 8) {
            if message.kind == .note { Image(systemName: "lock.fill").font(.system(size: 11)) }
            Text(message.author).font(.system(size: 14, weight: .medium))
            Text(message.time).font(.system(size: 13)).foregroundStyle(Color.redoMuted)
        }
    }
}
