# Redo Commerce (demo replica)

Offline SwiftUI copy of the **Redo Commerce** iOS app, the support inbox Shopify merchants use to answer customers on the go. It uses mock data and has no backend.

## Screens
- **Sign in**: Shopify store address, then "Sign in with Shopify".
- **Inbox**: views (Assigned to me, All, Unassigned), search, filters, status (Open / Snoozed / Closed), and `+ New Ticket`.
- **Ticket**: conversation, reply or internal note, templates (lightning icon), Close, plus a `...` menu for Details, Snooze, Edit tags and Forward email.
- **Details**: assignee, customer stats, order history and return/claim history.
- **Profile**: agent info, notifications, sign out.

## Run
```
brew install xcodegen   # only needed after adding files
xcodegen generate
open RedoCommerce.xcodeproj   # run on any iPhone simulator
```

## Layout
- `RedoCommerce/Models.swift`: models, mock data, `AppStore` state
- `RedoCommerce/Theme.swift`: colors, logo, chips, buttons
- `RedoCommerce/Views/`: one file per area
