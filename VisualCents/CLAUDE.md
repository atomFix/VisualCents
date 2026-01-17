# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**VisualCents** is a personal finance iOS application built with SwiftUI, emphasizing "frictionless transaction logging" through multiple input methods including manual entry and OCR-based receipt scanning. The app features a sophisticated theming system with smooth, physics-based animations and CloudKit synchronization.

## Build and Run Commands

```bash
# Navigate to project directory
cd /Users/code/project/xcode/bright/VisualCents

# Build the project
xcodebuild -project VisualCents.xcodeproj -scheme VisualCents -configuration Debug build

# Run on iOS Simulator
xcodebuild -project VisualCents.xcodeproj -scheme VisualCents -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build

# Clean build
xcodebuild -project VisualCents.xcodeproj -scheme VisualCents clean

# Run tests
xcodebuild test -project VisualCents.xcodeproj -scheme VisualCents -destination 'platform=iOS Simulator,name=iPhone 17 Pro'

# Clean build folder (when Xcode previews crash with SIGBUS)
rm -rf ~/Library/Developer/Xcode/DerivedData/VisualCents-*
rm -rf ~/Library/Caches/com.apple.dt.Xcode
# Then in Xcode: Cmd+Shift+K (Clean Build Folder)
```

**Common Issues:**
- If SwiftUI Previews crash with SIGBUS(10) error, it's a cache issue. Clean derived data and rebuild.
- Working directory is `VisualCents/` (contains app source), but project file is at parent level.

## Architecture

### Core Patterns

1. **MVVM with SwiftUI**: Standard SwiftUI architecture using `@State`, `@Observable`, and `@Environment` for state management
2. **SwiftData + CloudKit**: Modern persistence layer with automatic cloud synchronization
3. **Protocol-Based Theming**: Type-safe theme system with runtime switching
4. **Service Layer Pattern**: Isolated services for OCR, calendar, and external integrations
5. **Custom Navigation**: Side drawer navigation with smooth physics-based animations

### Data Flow

```
VisualCentsApp (Entry Point)
    ↓
ThemedRootView (Injects theme via environment)
    ↓
ContentView → MainContainerView
    ↓
Navigation Stack with Drawer
    ↓
Feature Views (Dashboard, Budget, Assets, etc.)
```

**Key Points:**
- Theme is injected via `@Environment(\.appTheme)` - all views should use this, never hardcode colors
- SwiftData context is provided via `.modelContainer()` at app level
- Theme changes trigger view rebuild via `.id(themeManager.currentThemeId)` to ensure proper propagation

### Directory Structure

```
VisualCents/
├── Models/                    # SwiftData models (@Model)
│   ├── Transaction.swift      # Core: amount, merchant, date, category, asset
│   ├── Category.swift         # Transaction categories with default presets
│   ├── Budget.swift          # Category budgets with monthly tracking
│   ├── Asset.swift           # Financial assets/accounts
│   └── SavingsGoal.swift     # Savings goals with progress tracking
│
├── Views/                     # SwiftUI views organized by feature
│   ├── Navigation/           # Custom drawer navigation system
│   │   ├── MainContainerView.swift    # Main container with drag gestures
│   │   ├── SideMenuView.swift         # Drawer menu
│   │   └── MenuItem.swift             # Menu enum
│   ├── Dashboard/           # Home screen with overview cards
│   ├── Entry/               # Transaction input (manual + OCR)
│   ├── Transactions/        # Transaction list and details
│   ├── Budget/             # Budget planning and tracking
│   ├── Assets/             # Asset management
│   ├── Savings/            # Savings goals
│   ├── Statistics/         # Analytics and charts
│   └── Settings/           # App configuration including theme picker
│
├── Theme/                  # Theming system
│   ├── AppTheme.swift      # Protocol defining all visual properties
│   ├── ThemeManager.swift  # @Observable manager for theme switching
│   ├── SoftPopTheme.swift  # Default vibrant dark theme
│   ├── CharcoalTheme.swift # Dark sketch-like theme
│   ├── MinimalistTheme.swift # Clean minimal theme
│   └── OilPaintTheme.swift # Artistic painterly theme
│
├── DesignSystem/           # Design tokens and legacy constants
│   ├── DesignSystem.swift  # Colors, typography, spacing (VC* enums)
│   └── BounceButtonStyle.swift # Custom button animations
│
└── Services/               # External integrations
    ├── AliyunOCRService.swift  # Receipt OCR (Aliyun API)
    └── CalendarService.swift   # Calendar integration
```

## Theming System

The app uses a **protocol-based theming system** that decouples UI styling from implementation.

### How It Works

1. **`AppTheme` Protocol** (`Theme/AppTheme.swift`): Defines all visual properties (colors, fonts, metrics, haptics)
2. **Theme Implementations**: Concrete types (SoftPopTheme, CharcoalTheme, etc.) conform to AppTheme
3. **`ThemeManager`**: `@Observable` class that manages current theme selection via UserDefaults
4. **Environment Injection**: Theme provided to all views via `@Environment(\.appTheme)`

### Usage in Views

```swift
struct SomeView: View {
    @Environment(\.appTheme) private var theme

    var body: some View {
        VStack {
            Text("Hello")
                .font(theme.customFont(size: 17, weight: .semibold))
                .foregroundStyle(theme.textPrimary)
                .padding(theme.padding)
                .background(theme.cardBackground)
        }
        .background(theme.background)
    }
}
```

**Critical Rules:**
- ALWAYS use `theme.*` properties, never hardcode colors or values
- Use `theme.styleCard()` or `theme.styleButton()` for consistent styling
- Theme is type-erased (`any AppTheme`), so you can't access theme-specific properties directly
- All themes must implement the full `AppTheme` protocol

### Available Themes

- `softPop`: Default vibrant dark theme (purple/blue accents)
- `minimalist` ("极简"): Clean, minimal design
- `oilPaint` ("油画风格"): Artistic, painterly style
- `charcoal` ("素描风格"): Dark, sketch-like theme (currently default)

### Adding a New Theme

1. Create a new struct conforming to `AppTheme`
2. Implement all required properties and methods
3. Add case to `AvailableTheme` enum in `ThemeManager.swift`
4. Add display name in `AvailableTheme.displayName`

## SwiftData Models

### Core Relationships

```
Transaction (many-to-one)→ Category
Transaction (many-to-one)→ Asset
Category (one-to-one)→ Budget
```

### Model Important Notes

- **All models use UUID for CloudKit sync**: `@Attribute(.unique) var id: UUID`
- **Delete rules**: Models have cascade delete rules for data integrity
- **Default categories**: Auto-created on app launch via `setupDefaultCategories()` in `VisualCentsApp.swift`
- **Timestamps**: Models include `createdAt` for sorting

### SwiftData Schema

Defined in `VisualCentsApp.swift`:
```swift
let schema = Schema([
    Transaction.self,
    Category.self,
    Budget.self,
    Asset.self,
    SavingsGoal.self
])
```

CloudKit is enabled with `.cloudKitDatabase = .automatic`

### Querying in Views

```swift
struct SomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var transactions: [Transaction]

    // With sorting and filtering
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
}
```

## Navigation Architecture

The app uses a **custom side drawer navigation** instead of the traditional tab bar.

### How It Works

1. **`MainContainerView`**: Manages drawer state with drag gestures
2. **Edge Swipe**: Swipe from left edge (30pt) to open menu
3. **Physics Animation**: Uses `interactiveSpring` for smooth, natural feel
4. **Menu Items**: Defined in `MenuItem` enum (dashboard, statistics, budget, etc.)

### Drawer Configuration

```swift
private let menuWidth: CGFloat = 280
private let edgeDragWidth: CGFloat = 30
private let minDragToOpen: CGFloat = 60
```

### Adding a New Menu Item

1. Add case to `MenuItem` enum in `Views/Navigation/MenuItem.swift`
2. Add view case in `MainContainerView.contentView` switch statement
3. Add menu item in `SideMenuView` with icon and label

## Services

### AliyunOCRService

Receipt scanning using Aliyun OCR API. Uses CryptoKit for request signing.

**Important:**
- API credentials stored in UserDefaults (should be moved to secure storage)
- Async/await pattern for network operations
- Proper error handling with `OCRServiceError`

### CalendarService

Calendar integration for transaction reminders and recurring events.

## Design System

### Legacy vs New Theming

The codebase has both:
- **Legacy**: `DesignSystem/DesignSystem.swift` with `VCColors`, `VCFont`, `VCMetrics` enums
- **New**: Theme protocol system

**Prefer the new theme system** (`@Environment(\.appTheme)`) for all new code. Legacy constants may still exist in older views.

### Design Tokens

- **Colors**: Semantic naming (background, cardBackground, textPrimary, incomeGreen, expenseRed, etc.)
- **Typography**: Helper methods for hero, title, body, caption, amount fonts
- **Metrics**: Consistent padding (16/24/8), corner radii (24/16/12)

## Common Patterns

### Creating a New Feature View

1. Create view in appropriate `Views/` subdirectory
2. Use `@Environment(\.appTheme) private var theme` for styling
3. Use `@Environment(\.modelContext) private var modelContext` for data access
4. Use `@Query` for fetching SwiftData models
5. Apply theme styling via `theme.*` properties
6. Add to `MainContainerView.contentView` switch statement
7. Add menu item in `SideMenuView`

### Adding Haptic Feedback

```swift
Button("Tap me") {
    theme.lightHaptic()    // or mediumHaptic(), heavyHaptic()
    theme.successHaptic()  // or errorHaptic()
}
```

### Using the Theme's Style Modifiers

```swift
VStack {
    // Content
}
.styleCard(EmptyView())  // Applies card background, shadow, corner radius
```

## Project Configuration

- **Scheme**: VisualCents
- **Target**: VisualCents (app), VisualCentsTests, VisualCentsUITests
- **Platform**: iOS (iphonesimulator)
- **Language**: Swift
- **UI Framework**: SwiftUI
- **Persistence**: SwiftData with CloudKit
- **Minimum iOS**: Not specified (check project settings)

## Key Technical Decisions

1. **SwiftData over Core Data**: Chosen for modern Swift-first API with CloudKit sync
2. **Protocol-based Theming**: Type-safe, compile-time checked, easy to extend
3. **Custom Drawer Navigation**: More distinctive than standard tab bar, better for large screens
4. **Physics-based Animations**: Uses `interactiveSpring` for natural, responsive feel
5. **Environment-based Theme Injection**: SwiftUI-native approach with automatic propagation

## Known Issues and Limitations

- No unit tests in codebase yet (test targets exist but empty)
- API credentials stored in UserDefaults (security concern)
- Limited error handling in some views
- Preview crashes when build cache becomes corrupted (clean build fixes)
