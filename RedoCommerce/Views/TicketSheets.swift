import SwiftUI

struct DetailsView: View {
    @EnvironmentObject var store: AppStore
    let ticketID: UUID

    var body: some View {
        VStack(spacing: 0) {
            SheetHeader(title: "Details")
            if let t = store.ticket(ticketID) {
                let c = t.customer
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        section("Assignee") {
                            HStack {
                                Avatar(initials: t.assignee.map { $0.split(separator: " ").compactMap(\.first).map(String.init).joined() }, size: 26)
                                Menu {
                                    ForEach(store.teammates, id: \.self) { m in Button(m) { store.update(ticketID) { $0.assignee = m } } }
                                } label: {
                                    Text(t.assignee ?? "Unassigned").foregroundStyle(.black)
                                    Spacer()
                                    Image(systemName: "square.and.pencil").foregroundStyle(Color.redoMuted)
                                }
                            }
                        }
                        Divider()
                        section("Customer information") {
                            HStack {
                                Avatar(initials: c.initials, size: 36)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(c.name).font(.system(size: 16, weight: .medium))
                                    Text(c.email).font(.system(size: 14)).foregroundStyle(Color.redoMuted)
                                }
                                Spacer()
                                Image(systemName: "square.and.pencil").foregroundStyle(Color.redoMuted)
                            }
                            Button {} label: { Label("Create order", systemImage: "plus") }.buttonStyle(OutlineButton()).padding(.top, 4)
                            Divider().padding(.vertical, 8)
                            stat("Total spent", money(c.totalSpent))
                            stat("Total orders", "\(c.orders.count)")
                            stat("Total returns", "\(c.returns.count)")
                            if !t.tags.isEmpty {
                                HStack { ForEach(t.tags, id: \.self) { Chip(text: $0, icon: "tag") } }.padding(.top, 6)
                            }
                        }
                        if !c.orders.isEmpty {
                            Divider()
                            section("Order History") {
                                ForEach(c.orders) { o in
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text("Order \(o.number)").font(.system(size: 16, weight: .semibold))
                                            Spacer()
                                            Chip(text: o.status, fg: o.status == "Delivered" ? .redoGreen : .redoOrange,
                                                 bg: o.status == "Delivered" ? .redoMint : .redoCream)
                                        }
                                        Text("\(o.date) · \(money(o.total))").font(.system(size: 14)).foregroundStyle(Color.redoMuted)
                                        ForEach(o.products) { ProductRow(product: $0) }
                                    }
                                    .padding(.bottom, 12)
                                }
                            }
                        }
                        if !c.returns.isEmpty {
                            Divider()
                            section("Return History") {
                                ForEach(c.returns) { r in
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack(spacing: 8) {
                                            Text("\(r.kind) for Order \(r.orderNumber)").font(.system(size: 16, weight: .semibold))
                                            Image(systemName: "doc.on.doc").font(.system(size: 14))
                                        }
                                        Chip(text: r.status)
                                        Text("Products").font(.system(size: 15, weight: .semibold)).padding(.top, 4)
                                        ForEach(r.products) { ProductRow(product: $0) }
                                        HStack(spacing: 6) {
                                            Chip(text: r.reason, fg: Color(white: 0.3), bg: .redoField)
                                            Chip(text: r.resolution, fg: .redoPurple, bg: .redoLavender, border: .redoPurple.opacity(0.3))
                                        }
                                    }
                                    .padding(.bottom, 14)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    func section<C: View>(_ title: String, @ViewBuilder content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.system(size: 18)).foregroundStyle(Color(white: 0.3))
            content()
        }
        .padding(24)
    }

    func stat(_ label: String, _ value: String) -> some View {
        HStack { Text(label); Spacer(); Text(value) }.font(.system(size: 15))
    }
}

struct ProductRow: View {
    let product: Product

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: product.symbol)
                .font(.system(size: 18))
                .foregroundStyle(Color(white: 0.35))
                .frame(width: 40, height: 40)
                .background(Color.redoField, in: RoundedRectangle(cornerRadius: 6))
            VStack(alignment: .leading, spacing: 2) {
                Text(product.name).font(.system(size: 15, weight: .medium))
                Text("\(product.variant) · Qty \(product.quantity)").font(.system(size: 13)).foregroundStyle(Color.redoMuted)
            }
            Spacer()
            Text(money(product.price)).font(.system(size: 15))
        }
    }
}

struct TemplatesView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss
    let onPick: (Template) -> Void
    @State private var search = ""

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                Button { dismiss() } label: { Image(systemName: "arrow.left").foregroundStyle(.black) }
                Text("Use a template").font(.system(size: 20, weight: .medium))
                Spacer()
            }
            .padding(.horizontal, 24).padding(.vertical, 18)
            Divider()
            ScrollView {
                VStack(spacing: 10) {
                    HStack {
                        Image(systemName: "magnifyingglass").foregroundStyle(Color.redoMuted)
                        TextField("Search", text: $search)
                    }
                    .padding(.horizontal, 12).frame(height: 40)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.redoBorder))
                    .padding(.bottom, 6)
                    ForEach(store.templates.filter { search.isEmpty || $0.name.localizedCaseInsensitiveContains(search) }) { t in
                        Button { onPick(t); dismiss() } label: {
                            HStack {
                                Text(t.name).foregroundStyle(.black)
                                Spacer()
                                Image(systemName: "ellipsis").foregroundStyle(Color.redoMuted)
                            }
                            .padding(.horizontal, 18).frame(height: 54)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.redoBorder))
                        }
                    }
                }
                .padding(24)
            }
        }
    }
}

struct SnoozeView: View {
    let onSnooze: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            SheetHeader(title: "Snooze until")
            VStack(spacing: 14) {
                ForEach(["Tomorrow: Fri 8:00 AM", "This weekend: Sat 8:00 PM", "Next week: Mon 8:00 AM", "Choose custom date"], id: \.self) { label in
                    Button { onSnooze() } label: { Text(label).frame(maxWidth: .infinity) }.buttonStyle(OutlineButton())
                }
            }
            .padding(24)
            Spacer()
        }
    }
}

struct TagsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss
    let ticketID: UUID
    @State private var selected: [String] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SheetHeader(title: "Edit tags")
            VStack(alignment: .leading, spacing: 12) {
                FieldLabel("Active tags")
                FlowTags(tags: store.allTags, selected: $selected)
                HStack(spacing: 12) {
                    Button { selected = store.ticket(ticketID)?.tags ?? [] } label: { Text("Reset").frame(maxWidth: .infinity) }
                        .buttonStyle(OutlineButton())
                    Button {
                        store.update(ticketID) { $0.tags = selected }
                        dismiss()
                    } label: { Text("Save").frame(maxWidth: .infinity) }
                        .buttonStyle(SolidButton())
                }
                .padding(.top, 8)
            }
            .padding(24)
            Spacer()
        }
        .onAppear { selected = store.ticket(ticketID)?.tags ?? [] }
    }
}

struct FlowTags: View {
    let tags: [String]
    @Binding var selected: [String]

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), alignment: .leading)], alignment: .leading, spacing: 8) {
            ForEach(tags, id: \.self) { tag in
                let on = selected.contains(tag)
                Button {
                    if on { selected.removeAll { $0 == tag } } else { selected.append(tag) }
                } label: {
                    Chip(text: tag, icon: on ? "checkmark" : "plus",
                         fg: on ? .redoPurple : Color(white: 0.3), bg: on ? .redoLavender : .white,
                         border: on ? .redoPurple.opacity(0.4) : .redoBorder)
                }
            }
        }
    }
}

struct ForwardView: View {
    @Environment(\.dismiss) private var dismiss
    @State var subject: String
    @State private var recipients = ""
    @State private var message = ""

    init(subject: String) { _subject = State(initialValue: "Fwd: \(subject)") }

    var body: some View {
        VStack(spacing: 0) {
            SheetHeader(title: "Forward email")
            VStack(alignment: .leading, spacing: 10) {
                FieldLabel("Email to send as")
                PickerField(placeholder: "Select which email to send as", selection: .constant("support@courtandfield.com"), options: ["support@courtandfield.com"])
                FieldLabel("Recipients").padding(.top, 6)
                TextField("Enter email addresses", text: $recipients).textInputAutocapitalization(.never).boxed()
                FieldLabel("Email subject").padding(.top, 6)
                TextField("", text: $subject).boxed()
                FieldLabel("Message").padding(.top, 6)
                TextField("Start typing to add message above the email thread", text: $message, axis: .vertical)
                    .lineLimit(4...6).padding(.vertical, 10).boxed()
                Button { dismiss() } label: { Text("Forward & close").frame(maxWidth: .infinity) }
                    .buttonStyle(SolidButton(enabled: !recipients.isEmpty))
                    .disabled(recipients.isEmpty)
                    .padding(.top, 10)
            }
            .padding(24)
            Spacer()
        }
    }
}
