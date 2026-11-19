import SwiftUI

struct InboxView: View {
    @EnvironmentObject var store: AppStore
    @State private var view: InboxView_ = .mine
    @State private var status: TicketStatus = .open
    @State private var search = ""
    @State private var channels = Set(Channel.allCases)
    @State private var showFilter = false
    @State private var showNew = false

    var visible: [Ticket] {
        store.tickets.filter { t in
            let viewOK: Bool = switch view {
            case .mine: t.assignee == store.agent
            case .all: true
            case .unassigned: t.assignee == nil
            }
            let q = search.lowercased()
            let searchOK = q.isEmpty || t.customer.name.lowercased().contains(q) || t.preview.lowercased().contains(q) || (t.subject?.lowercased().contains(q) ?? false)
            return viewOK && searchOK && t.status == status && channels.contains(t.channel)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header
                Divider()
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(visible) { t in
                            NavigationLink(value: t.id) { TicketRow(ticket: t) }
                                .buttonStyle(.plain)
                            Divider()
                        }
                        if visible.isEmpty {
                            VStack(spacing: 8) {
                                Image(systemName: "tray").font(.system(size: 34)).foregroundStyle(Color.redoMuted)
                                Text("No tickets here").foregroundStyle(Color.redoMuted)
                            }
                            .padding(.top, 80)
                        }
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: UUID.self) { id in TicketView(ticketID: id) }
            .sheet(isPresented: $showFilter) { FilterView(channels: $channels) }
            .sheet(isPresented: $showNew) { NewTicketView() }
        }
    }

    var header: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Menu {
                    ForEach(InboxView_.allCases) { v in Button(v.rawValue) { view = v } }
                } label: {
                    HStack(spacing: 8) {
                        Text(view.rawValue).font(.system(size: 22, weight: .semibold))
                        Image(systemName: "chevron.down").font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundStyle(.black)
                }
                Spacer()
                Button("+ New Ticket") { showNew = true }.buttonStyle(SolidButton())
            }
            HStack(spacing: 12) {
                HStack {
                    Image(systemName: "magnifyingglass").foregroundStyle(Color.redoMuted)
                    TextField("Search", text: $search)
                }
                .padding(.horizontal, 12)
                .frame(height: 40)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.redoBorder))
                Button { showFilter = true } label: {
                    Image(systemName: channels.count < Channel.allCases.count ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease")
                        .font(.system(size: 18))
                        .foregroundStyle(.black)
                        .frame(width: 40, height: 40)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.redoBorder))
                }
            }
            Menu {
                ForEach(TicketStatus.allCases) { s in Button(s.rawValue) { status = s } }
            } label: {
                HStack(spacing: 6) {
                    Text("\(status.rawValue) (\(visible.count))")
                    Image(systemName: "chevron.down").font(.system(size: 12, weight: .semibold))
                }
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color(white: 0.3))
            }
            .padding(.leading, 12)
        }
        .padding(.horizontal, 22)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }
}

struct TicketRow: View {
    let ticket: Ticket

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Avatar(initials: ticket.customer.initials)
            VStack(alignment: .leading, spacing: 4) {
                Text(ticket.customer.name).font(.system(size: 16, weight: .medium))
                Text(ticket.updated).font(.system(size: 14)).foregroundStyle(Color.redoMuted)
                if let s = ticket.subject {
                    Text(s).font(.system(size: 16, weight: .semibold)).padding(.top, 2)
                }
                Text(ticket.preview).font(.system(size: 15)).foregroundStyle(Color(white: 0.25)).lineLimit(2)
                HStack(spacing: 6) {
                    ChannelChip(channel: ticket.channel)
                    StatusChip(status: ticket.status)
                }
                .padding(.top, 6)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 16)
        .contentShape(Rectangle())
    }
}

struct FilterView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @Binding var channels: Set<Channel>
    @State private var draft: Set<Channel> = []
    @State private var assignee = ""

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button { dismiss() } label: { Label("Back", systemImage: "arrow.left") }
                Spacer()
                Button("Clear all") { draft = Set(Channel.allCases); assignee = "" }
            }
            .font(.system(size: 17, weight: .medium))
            .foregroundStyle(Color(white: 0.25))
            .padding(.horizontal, 24)
            .padding(.top, 22)

            VStack(alignment: .leading, spacing: 6) {
                Text("Filter tickets").font(.system(size: 26, weight: .bold))
                Text("Apply filters to tickets and save filter as a new view.").foregroundStyle(Color.redoMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    FieldLabel("Channels")
                    ForEach(Channel.allCases) { c in
                        let on = draft.contains(c)
                        Button {
                            if on { draft.remove(c) } else { draft.insert(c) }
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: on ? "checkmark.square.fill" : "square")
                                    .font(.system(size: 20))
                                    .foregroundStyle(on ? Color.redoPurple : Color.redoBorder)
                                Text(c.rawValue).foregroundStyle(.black)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 50)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(on ? Color.redoPurple : Color.redoBorder, lineWidth: on ? 2 : 1))
                        }
                    }
                    FieldLabel("Assignees").padding(.top, 8)
                    PickerField(placeholder: "Any assignee", selection: $assignee, options: store.teammates)
                }
                .padding(24)
            }

            HStack(spacing: 16) {
                Button("+ Save as view") { channels = draft; dismiss() }
                    .buttonStyle(OutlineButton()).frame(maxWidth: .infinity)
                Button { channels = draft; dismiss() } label: { Text("Apply").frame(maxWidth: .infinity) }
                    .buttonStyle(SolidButton())
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .overlay(alignment: .top) { Divider() }
        }
        .onAppear { draft = channels }
    }
}

struct NewTicketView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var channel = "Email"
    @State private var customerName = ""
    @State private var subject = ""
    @State private var message = ""

    var body: some View {
        VStack(spacing: 0) {
            SheetHeader(title: "Create ticket")
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    FieldLabel("Channel")
                    PickerField(placeholder: "Channel", selection: $channel, options: [Channel.email.rawValue, Channel.sms.rawValue])
                    FieldLabel("Email to send as").padding(.top, 6)
                    PickerField(placeholder: "Select which email to send as", selection: .constant("support@courtandfield.com"), options: ["support@courtandfield.com"])
                    FieldLabel("Customer").padding(.top, 6)
                    PickerField(placeholder: "Tap to search customers", selection: $customerName, options: store.customers.map(\.name))
                    FieldLabel("Email Subject").padding(.top, 6)
                    TextField("", text: $subject).boxed()
                    FieldLabel("Message").padding(.top, 6)
                    TextEditor(text: $message)
                        .scrollContentBackground(.hidden)
                        .frame(height: 120)
                        .padding(6)
                        .background(Color.redoField, in: RoundedRectangle(cornerRadius: 8))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.redoBorder))
                    let ready = !customerName.isEmpty && !message.isEmpty
                    Button {
                        guard let c = store.customers.first(where: { $0.name == customerName }) else { return }
                        let t = Ticket(customer: c, subject: subject.isEmpty ? nil : subject, channel: Channel(rawValue: channel) ?? .email,
                                       status: .open, assignee: store.agent, updated: "Just now", tags: [],
                                       messages: [Message(author: "You", kind: .agent, text: message, time: "Just now")])
                        store.tickets.insert(t, at: 0)
                        dismiss()
                    } label: { Text("Create ticket").frame(maxWidth: .infinity) }
                        .buttonStyle(SolidButton(enabled: ready))
                        .disabled(!ready)
                        .padding(.top, 12)
                }
                .padding(24)
            }
        }
    }
}
