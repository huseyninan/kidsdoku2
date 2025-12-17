# Environment Object Usage Guide

## Overview
The `AppEnvironment` class is a centralized environment object that manages app-wide state and provides access to global managers.

## What's Available

### Properties
- `isPremium: Bool` - Whether the user has an active premium subscription
- `isLoadingSubscription: Bool` - Whether the subscription status is being checked
- `soundManager: SoundManager` - Singleton instance for managing sound effects
- `hapticManager: HapticManager` - Singleton instance for managing haptic feedback

### Methods
- `checkSubscriptionStatus()` - Manually checks the subscription status with RevenueCat
- `refreshSubscriptionStatus()` - Refreshes the subscription status after a purchase

## How to Use

### 1. Access in any View
Add the `@EnvironmentObject` property wrapper to access the environment:

```swift
struct MyView: View {
    @EnvironmentObject var appEnvironment: AppEnvironment
    
    var body: some View {
        VStack {
            if appEnvironment.isPremium {
                Text("Premium User")
            } else {
                Text("Free User")
            }
        }
    }
}
```

### 2. Check Premium Status
Use the `isPremium` property to conditionally show features:

```swift
if appEnvironment.isPremium {
    // Show premium features
    PremiumFeatureView()
} else {
    // Show upgrade prompt
    UpgradeButton()
}
```

### 3. Refresh After Purchase
After a successful purchase, call `refreshSubscriptionStatus()`:

```swift
PaywallView()
    .onPurchaseCompleted { customerInfo in
        appEnvironment.refreshSubscriptionStatus()
    }
```

### 4. Access Sound and Haptic Managers
Instead of calling `SoundManager.shared` directly, you can use:

```swift
// Play sound
appEnvironment.soundManager.playSound(.correctPlacement)

// Trigger haptic
appEnvironment.hapticManager.trigger(.success)

// Toggle sound
appEnvironment.soundManager.toggleSound()
```

## Current Implementation

The environment object is already:
- ✅ Created in `AppEnvironment.swift`
- ✅ Injected at the app level in `kidsdoku2App.swift`
- ✅ Used in `MainMenuView.swift` to refresh subscription after purchase
- ✅ Automatically available to all child views in the navigation stack

## Adding to New Views

When creating new views, remember to:
1. Add `@EnvironmentObject var appEnvironment: AppEnvironment` if you need access to app state
2. Update previews to include the environment object:
   ```swift
   #Preview {
       MyNewView()
           .environmentObject(AppEnvironment())
   }
   ```

## Benefits

- **Centralized State**: All app-wide state in one place
- **Automatic Updates**: SwiftUI automatically updates views when published properties change
- **Easy Access**: Available throughout the app without manual passing
- **Type Safety**: Compiler checks ensure proper usage

