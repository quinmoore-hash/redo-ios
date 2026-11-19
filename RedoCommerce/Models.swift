import SwiftUI

enum Channel: String, CaseIterable, Identifiable {
    case redoChat = "Redo Chat"
    case email = "Email"
    case sms = "SMS"
    case instagram = "Instagram DM"
    case facebook = "Facebook Messenger"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .redoChat: "bubble.left.fill"
        case .email: "envelope"
        case .sms: "message"
        case .instagram: "camera"
        case .facebook: "bubble.left.and.bubble.right"
        }
    }
}

enum TicketStatus: String, CaseIterable, Identifiable {
    case open = "Open", snoozed = "Snoozed", closed = "Closed"
    var id: String { rawValue }
}

enum InboxView_: String, CaseIterable, Identifiable {
    case mine = "Assigned to me", all = "All tickets", unassigned = "Unassigned"
    var id: String { rawValue }
}

enum MessageKind { case customer, agent, note, event }

struct Message: Identifiable {
    let id = UUID()
    var author: String
    var kind: MessageKind
    var text: String
    var time: String
}

struct Product: Identifiable {
    let id = UUID()
    var name: String
    var variant: String
    var quantity: Int
    var price: Double
    var symbol: String
}

struct Order: Identifiable {
    let id = UUID()
    var number: String
    var date: String
    var status: String
    var products: [Product]
    var total: Double { products.reduce(0) { $0 + $1.price * Double($1.quantity) } }
}

struct ReturnRecord: Identifiable {
    let id = UUID()
    var kind: String
    var orderNumber: String
    var status: String
    var reason: String
    var resolution: String
    var products: [Product]
}

struct Customer: Identifiable {
    let id = UUID()
    var name: String
    var email: String
    var totalSpent: Double
    var orders: [Order]
    var returns: [ReturnRecord]

    var initials: String? {
        guard name != "Unknown Customer" else { return nil }
        return name.split(separator: " ").compactMap(\.first).prefix(2).map(String.init).joined()
    }
    var firstName: String { String(name.split(separator: " ").first ?? "") }
}

struct Ticket: Identifiable {
    let id = UUID()
    var customer: Customer
    var subject: String?
    var channel: Channel
    var status: TicketStatus
    var assignee: String?
    var updated: String
    var tags: [String]
    var messages: [Message]

    var preview: String { messages.last(where: { $0.kind == .customer })?.text ?? messages.last?.text ?? "" }
}

struct Template: Identifiable {
    let id = UUID()
    var name: String
    var body: String
}

func money(_ v: Double) -> String { v.formatted(.currency(code: "USD")) }

final class AppStore: ObservableObject {
    @Published var signedIn = false
    @Published var inTicket = false
    @Published var storeHandle = "court-and-field"
    @Published var tickets: [Ticket] = MockData.tickets
    let agent = "Harrison Burgess"
    let agentEmail = "harrison@courtandfield.com"
    let teammates = ["Harrison Burgess", "Ricardo Gambini", "Ava Thompson", "Noah Kim"]
    let allTags = ["VIP", "Exchange", "Shipping delay", "Damaged", "Wrong size", "Refund", "Wholesale"]
    let templates = MockData.templates
    var customers: [Customer] { MockData.customers }

    func ticket(_ id: UUID) -> Ticket? { tickets.first { $0.id == id } }

    func update(_ id: UUID, _ change: (inout Ticket) -> Void) {
        guard let i = tickets.firstIndex(where: { $0.id == id }) else { return }
        change(&tickets[i])
    }
}

enum MockData {
    static let runner = Product(name: "Court Runner", variant: "White / 9", quantity: 1, price: 128, symbol: "shoe.fill")
    static let jacket = Product(name: "Transit Jacket", variant: "Olive / M", quantity: 1, price: 148, symbol: "tshirt.fill")
    static let cap = Product(name: "Field Cap", variant: "Black", quantity: 1, price: 38, symbol: "graduationcap.fill")
    static let tee = Product(name: "Everyday Tee", variant: "Heather / L", quantity: 2, price: 34, symbol: "tshirt")
    static let bag = Product(name: "Weekender Duffel", variant: "Sand", quantity: 1, price: 189, symbol: "bag.fill")

    static let everette = Customer(
        name: "Everette Lane", email: "everette.lane@gmail.com", totalSpent: 1_284.50,
        orders: [
            Order(number: "#10428", date: "Nov 12", status: "Delivered", products: [runner]),
            Order(number: "#10211", date: "Oct 3", status: "Delivered", products: [jacket, cap]),
        ],
        returns: [
            ReturnRecord(kind: "Exchange", orderNumber: "#10428", status: "In transit", reason: "Too small", resolution: "Exchange", products: [runner]),
        ])

    static let maya = Customer(
        name: "Maya Chen", email: "maya.chen@outlook.com", totalSpent: 3_544.74,
        orders: [
            Order(number: "#11902", date: "Nov 14", status: "In transit", products: [jacket]),
            Order(number: "#11083", date: "Sep 22", status: "Delivered", products: [bag, tee]),
            Order(number: "#10544", date: "Jul 8", status: "Delivered", products: [cap]),
        ],
        returns: [
            ReturnRecord(kind: "Claim", orderNumber: "#11083", status: "Complete", reason: "Item(s) were damaged", resolution: "Store credit", products: [bag]),
            ReturnRecord(kind: "Return", orderNumber: "#10544", status: "Complete", reason: "Changed mind", resolution: "Refund", products: [cap]),
        ])

    static let jordan = Customer(
        name: "Jordan Price", email: "jprice@icloud.com", totalSpent: 412.00,
        orders: [Order(number: "#11877", date: "Nov 10", status: "Delivered", products: [tee, cap])],
        returns: [])

    static let sofia = Customer(
        name: "Sofia Ramirez", email: "sofia.r@gmail.com", totalSpent: 928.20,
        orders: [Order(number: "#11650", date: "Nov 2", status: "Delivered", products: [runner, tee])],
        returns: [ReturnRecord(kind: "Return", orderNumber: "#11650", status: "Label sent", reason: "Wrong size", resolution: "Refund", products: [tee])])

    static let liam = Customer(
        name: "Liam Patel", email: "liam@patelsupply.co", totalSpent: 6_120.00,
        orders: [Order(number: "#11911", date: "Nov 15", status: "Processing", products: [bag, jacket, cap])],
        returns: [])

    static let unknown = Customer(name: "Unknown Customer", email: "No email on file", totalSpent: 0, orders: [], returns: [])

    static let customers = [everette, maya, jordan, sofia, liam]

    static let tickets: [Ticket] = [
        Ticket(customer: everette, subject: nil, channel: .redoChat, status: .open, assignee: "Harrison Burgess", updated: "2 min ago", tags: ["Exchange"], messages: [
            Message(author: "Everette Lane", kind: .customer, text: "Hi! I need to return my Court Runners, they're too tight", time: "Today 9:38am"),
            Message(author: "Commerce Agent", kind: .agent, text: "Sorry about that! They run a little small. Want a size 10 instead? No refund wait.", time: "Today 9:39am"),
            Message(author: "Everette Lane", kind: .customer, text: "yes please", time: "Today 9:40am"),
            Message(author: "Redo", kind: .event, text: "Exchange created · #10428", time: "Today 9:40am"),
            Message(author: "Everette Lane", kind: .customer, text: "Also can I keep the old pair until the new one shows up? I have a race this weekend", time: "Today 9:41am"),
        ]),
        Ticket(customer: maya, subject: "Where is my order #11902?", channel: .email, status: .open, assignee: "Harrison Burgess", updated: "18 min ago", tags: ["Shipping delay", "VIP"], messages: [
            Message(author: "Maya Chen", kind: .customer, text: "Hi there, it's been 6 days and my tracking for the Transit Jacket hasn't moved. Can you check on it?", time: "Today 9:12am"),
            Message(author: "Ricardo Gambini", kind: .note, text: "Checked live tracking: scanned into Memphis Tuesday, due Thursday.", time: "Today 9:20am"),
        ]),
        Ticket(customer: unknown, subject: nil, channel: .redoChat, status: .open, assignee: "Harrison Burgess", updated: "1 hr ago", tags: [], messages: [
            Message(author: "Unknown Customer", kind: .customer, text: "Does the Weekender Duffel fit in an overhead bin? https://court-and-field.myshopify.com/products/weekender-duffel", time: "Today 8:50am"),
        ]),
        Ticket(customer: sofia, subject: "Return label not working", channel: .email, status: .open, assignee: "Harrison Burgess", updated: "3 hr ago", tags: ["Wrong size"], messages: [
            Message(author: "Sofia Ramirez", kind: .customer, text: "The return label you sent says invalid when I try to drop it off at UPS. Can you resend it?", time: "Today 6:41am"),
        ]),
        Ticket(customer: jordan, subject: nil, channel: .instagram, status: .open, assignee: "Harrison Burgess", updated: "Yesterday", tags: [], messages: [
            Message(author: "Jordan Price", kind: .customer, text: "do you guys restock the field cap in navy?? been waiting forever", time: "Yesterday 4:02pm"),
            Message(author: "You", kind: .agent, text: "Great question! Navy is coming back the first week of December.", time: "Yesterday 4:10pm"),
            Message(author: "Jordan Price", kind: .customer, text: "can you let me know when it drops", time: "Yesterday 4:12pm"),
        ]),
        Ticket(customer: liam, subject: "Wholesale order for 40 units", channel: .email, status: .open, assignee: "Harrison Burgess", updated: "2 days ago", tags: ["Wholesale"], messages: [
            Message(author: "Liam Patel", kind: .customer, text: "We'd like to place a wholesale order of 40 Transit Jackets for our team. Do you offer volume pricing?", time: "Mon 2:30pm"),
        ]),
        Ticket(customer: maya, subject: nil, channel: .sms, status: .open, assignee: nil, updated: "35 min ago", tags: [], messages: [
            Message(author: "Maya Chen", kind: .customer, text: "can I add the matching cap to my order?", time: "Today 9:05am"),
        ]),
        Ticket(customer: jordan, subject: nil, channel: .facebook, status: .open, assignee: "Ava Thompson", updated: "4 hr ago", tags: [], messages: [
            Message(author: "Jordan Price", kind: .customer, text: "What's your return window for sale items?", time: "Today 5:40am"),
        ]),
        Ticket(customer: everette, subject: "Package protection claim", channel: .email, status: .snoozed, assignee: "Harrison Burgess", updated: "3 days ago", tags: ["Damaged"], messages: [
            Message(author: "Everette Lane", kind: .customer, text: "My box arrived crushed and the cap is bent. I bought package protection.", time: "Sat 11:16am"),
            Message(author: "You", kind: .agent, text: "So sorry! I've filed the claim; a replacement ships Monday.", time: "Sat 11:30am"),
        ]),
        Ticket(customer: sofia, subject: "Thanks!", channel: .email, status: .closed, assignee: "Harrison Burgess", updated: "1 week ago", tags: [], messages: [
            Message(author: "Sofia Ramirez", kind: .customer, text: "Got my refund, thank you so much!", time: "Nov 11 3:02pm"),
        ]),
    ]

    static let templates: [Template] = [
        Template(name: "Where's my order?", body: "Hi {first_name}! I just checked your tracking and your package is on the way. You'll get a text the moment it's out for delivery."),
        Template(name: "Resend return label", body: "Hi {first_name}, sorry about that! I've sent a fresh return label to your email. It's good at any UPS location."),
        Template(name: "Exchange for a new size", body: "Hi {first_name}! I've set up an exchange for a new size. We'll ship it as soon as your return is scanned, no refund wait."),
        Template(name: "Package protection claim", body: "Hi {first_name}, so sorry your order arrived damaged. Your package protection covers it, so I've filed a claim and a replacement is on the way."),
        Template(name: "Restock alert", body: "Hi {first_name}! I've added you to the restock list, so you'll get a text as soon as it's back."),
        Template(name: "Thanks for reaching out", body: "Thanks for reaching out, {first_name}! Let me know if there's anything else I can help with."),
    ]

    static func aiDraft(for t: Ticket) -> String {
        let c = t.customer
        let name = c.name == "Unknown Customer" ? "" : c.firstName
        let hi = name.isEmpty ? "Hi there!" : "Hi \(name)!"
        let text = (t.messages.last(where: { $0.kind == .customer })?.text ?? "").lowercased()
        let has = { (words: [String]) in words.contains { text.contains($0) } }
        let tagged = { (tag: String) in t.tags.contains(tag) }
        let order = c.orders.first
        let items = { (o: Order) in o.products.map(\.name).joined(separator: " and ") }

        if tagged("Exchange") || has(["exchange", "too tight", "too small", "keep the old"]),
           let r = c.returns.first(where: { $0.kind == "Exchange" }) {
            let keep = has(["keep"]) ? " And yes, keep your current pair until the new one arrives, just send them back within 14 days." : ""
            return "\(hi) Your exchange for order \(r.orderNumber) is all set. We'll ship your new \(r.products.map(\.name).joined(separator: " and ")) as soon as your return is scanned, no refund wait.\(keep)"
        }
        if has(["damaged", "crushed", "bent", "broken"]) || tagged("Damaged") {
            return "\(hi) So sorry your order arrived damaged. Your package protection covers it, so I've filed a claim and a replacement is on the way."
        }
        if has(["tracking", "where is", "hasn't moved"]) || tagged("Shipping delay"),
           let o = c.orders.first(where: { $0.status == "In transit" }) ?? order {
            return "\(hi) I just checked tracking for order \(o.number) (\(items(o))) and it's on the way. It's due in the next couple of days, and you'll get a text the moment it's out for delivery."
        }
        if has(["return", "label", "refund"]) || tagged("Wrong size") {
            if let r = c.returns.first(where: { $0.status != "Complete" }) {
                return "\(hi) Sorry about that! I've sent a fresh return label for order \(r.orderNumber) to your email. It's good at any UPS location, and your \(r.resolution.lowercased()) starts as soon as it's scanned."
            }
            return "\(hi) You can return anything within 30 days of delivery, sale items included. Just start a return on our returns page and we'll email you a free label."
        }
        if has(["restock", "back in stock", "drops", "navy"]) {
            return "\(hi) I've added you to the restock list, so you'll get a text as soon as it's back."
        }
        if has(["wholesale", "volume", "bulk"]) || tagged("Wholesale") {
            return "\(hi) Thanks for thinking of us for your team. We offer volume pricing on orders of 25+ units, so I'll send a wholesale quote for your order to \(c.email) today."
        }
        if let o = order {
            return "Thanks for reaching out\(name.isEmpty ? "" : ", \(name)")! I'm looking at order \(o.number) now and will follow up shortly. Let me know if there's anything else I can help with."
        }
        return "Thanks for reaching out\(name.isEmpty ? "" : ", \(name)")! I'm looking into this now and will follow up shortly. Let me know if there's anything else I can help with."
    }
}
