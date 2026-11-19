import SwiftUI

extension Color {
    static let redoPurple = Color(red: 0.33, green: 0.24, blue: 0.80)
    static let redoLavender = Color(red: 0.94, green: 0.92, blue: 1.0)
    static let redoGreen = Color(red: 0.04, green: 0.52, blue: 0.29)
    static let redoMint = Color(red: 0.91, green: 0.98, blue: 0.93)
    static let redoOrange = Color(red: 0.75, green: 0.42, blue: 0.0)
    static let redoCream = Color(red: 1.0, green: 0.96, blue: 0.86)
    static let redoBorder = Color(white: 0.85)
    static let redoField = Color(white: 0.965)
    static let redoMuted = Color(white: 0.45)
}

struct RedoMark: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        let top = r.width * 0.40
        let bottom = r.width * 0.5
        p.addEllipse(in: CGRect(x: r.midX - top, y: r.minY, width: top * 2, height: top * 2))
        p.addEllipse(in: CGRect(x: r.midX - bottom, y: r.maxY - bottom * 2, width: bottom * 2, height: bottom * 2))
        let neckTop = r.minY + top
        let neckBottom = r.maxY - bottom
        let waist = r.width * 0.12
        p.move(to: CGPoint(x: r.midX - top * 0.7, y: neckTop))
        p.addQuadCurve(to: CGPoint(x: r.midX - bottom * 0.7, y: neckBottom), control: CGPoint(x: r.midX - waist, y: (neckTop + neckBottom) / 2))
        p.addLine(to: CGPoint(x: r.midX + bottom * 0.7, y: neckBottom))
        p.addQuadCurve(to: CGPoint(x: r.midX + top * 0.7, y: neckTop), control: CGPoint(x: r.midX + waist, y: (neckTop + neckBottom) / 2))
        p.closeSubpath()
        return p
    }
}

struct RedoLogo: View {
    var size: CGFloat = 36

    var body: some View {
        HStack(spacing: size * 0.4) {
            RedoMark().frame(width: size * 0.42, height: size)
            Text("redo").font(.system(size: size * 0.8, weight: .regular))
        }
        .foregroundStyle(.black)
    }
}

struct Chip: View {
    let text: String
    var icon: String? = nil
    var fg: Color = .black
    var bg: Color = .white
    var border: Color = .redoBorder

    var body: some View {
        HStack(spacing: 4) {
            if let icon { Image(systemName: icon).font(.system(size: 10, weight: .semibold)) }
            Text(text).font(.system(size: 13, weight: .medium))
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .foregroundStyle(fg)
        .background(bg, in: RoundedRectangle(cornerRadius: 5))
        .overlay(RoundedRectangle(cornerRadius: 5).stroke(border))
    }
}

struct ChannelChip: View {
    let channel: Channel

    var body: some View {
        if channel == .redoChat {
            Chip(text: channel.rawValue, icon: channel.icon, fg: .redoPurple, bg: .redoLavender, border: .redoPurple.opacity(0.35))
        } else {
            Chip(text: channel.rawValue, icon: channel.icon, fg: Color(white: 0.25))
        }
    }
}

struct StatusChip: View {
    let status: TicketStatus

    var body: some View {
        switch status {
        case .open: Chip(text: "Open", fg: .redoGreen, bg: .redoMint, border: .redoGreen.opacity(0.3))
        case .snoozed: Chip(text: "Snoozed", icon: "moon.fill", fg: .redoOrange, bg: .redoCream, border: .redoOrange.opacity(0.3))
        case .closed: Chip(text: "Closed", fg: .redoMuted, bg: .redoField)
        }
    }
}

struct Avatar: View {
    let initials: String?
    var size: CGFloat = 32

    var body: some View {
        ZStack {
            Circle().fill(Color.redoField)
            Circle().stroke(Color.redoBorder)
            if let initials {
                Text(initials).font(.system(size: size * 0.36, weight: .semibold)).foregroundStyle(Color.redoMuted)
            } else {
                Image(systemName: "person").font(.system(size: size * 0.45)).foregroundStyle(Color.redoMuted)
            }
        }
        .frame(width: size, height: size)
    }
}

struct SolidButton: ButtonStyle {
    var enabled = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(enabled ? Color.white : Color(white: 0.62))
            .padding(.horizontal, 16)
            .frame(minHeight: 44)
            .background(enabled ? Color.black : Color.redoField, in: RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(enabled ? Color.clear : Color.redoBorder))
            .opacity(configuration.isPressed ? 0.75 : 1)
    }
}

struct OutlineButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(Color(white: 0.2))
            .padding(.horizontal, 16)
            .frame(minHeight: 44)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.redoBorder))
            .opacity(configuration.isPressed ? 0.6 : 1)
    }
}

struct BoxedField: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 12)
            .frame(minHeight: 44)
            .background(Color.redoField, in: RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.redoBorder))
    }
}

extension View {
    func boxed() -> some View { modifier(BoxedField()) }
}

struct FieldLabel: View {
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text).font(.system(size: 15, weight: .medium)).frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct SheetHeader: View {
    let title: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(title).font(.system(size: 22, weight: .medium))
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark").font(.system(size: 18)).foregroundStyle(.black)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 18)
            Divider()
        }
    }
}

struct PickerField: View {
    let placeholder: String
    @Binding var selection: String
    let options: [String]

    var body: some View {
        Menu {
            ForEach(options, id: \.self) { o in Button(o) { selection = o } }
        } label: {
            HStack {
                Text(selection.isEmpty ? placeholder : selection)
                    .foregroundStyle(selection.isEmpty ? Color(white: 0.55) : .black)
                Spacer()
                Image(systemName: "chevron.down").foregroundStyle(Color.redoMuted)
            }
            .boxed()
        }
    }
}
