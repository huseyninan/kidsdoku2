# Kidsdoku2 UI Design System

## Design Philosophy

Kidsdoku2 follows a **"Storybook Adventure"** design language that creates a warm, inviting, and playful experience for children. The visual style combines:

- 🎨 **Soft, rounded shapes** - No sharp corners, everything feels friendly
- 🌈 **Warm color palette** - Earth tones, pastels, and vibrant accents
- 📚 **Storybook aesthetic** - Illustrated backgrounds, themed cards
- ✨ **Gentle animations** - Spring-based transitions, subtle feedback
- 🦊 **Character elements** - Fox mascot, animal symbols

---

## Color System

### Primary Palette

#### Premium Gold
```swift
premiumGold:        Color(red: 0.95, green: 0.77, blue: 0.06)
premiumGoldDark:    Color(red: 0.85, green: 0.55, blue: 0.0)
premiumBorderLight: Color(red: 1.0, green: 0.95, blue: 0.7)
premiumBorder:      Color(red: 0.95, green: 0.85, blue: 0.5)
```
**Usage**: Premium buttons, crown icons, locked content indicators

#### Quest Brown
```swift
questButtonDark:  Color(red: 0.35, green: 0.22, blue: 0.12)
questButtonLight: Color(red: 0.45, green: 0.28, blue: 0.15)
questSubtitle:    Color(red: 0.9, green: 0.85, blue: 0.75)
```
**Usage**: Main menu quest buttons, primary CTAs

#### Footer Beige
```swift
footerText:       Color(red: 0.4, green: 0.25, blue: 0.15)
footerBackground: Color(red: 0.85, green: 0.75, blue: 0.6)
```
**Usage**: Bottom banner, decorative elements

### Difficulty Colors

#### Easy (Green)
```swift
difficultyEasy: Color(red: 0.45, green: 0.55, blue: 0.45)
```
**Themes**: 
- 3×3: "Wakey Wakey" 🌅
- 4×4: "Sunny Meadow" 🌻
- 6×6: "Echo Cave" 🦇

#### Normal (Blue)
```swift
difficultyNormal: Color(red: 0.35, green: 0.45, blue: 0.60)
```
**Themes**:
- 3×3: "Breakfast Time" 🥐
- 4×4: "Twisty Trails" 🌲
- 6×6: "Snowy Slopes" ⛷️

#### Hard (Dark Blue)
```swift
difficultyHard: Color(red: 0.30, green: 0.35, blue: 0.50)
```
**Themes**:
- 3×3: "Garden Path" 🌺
- 4×4: "Mushroom Grove" 🍄
- 6×6: "Starry Summit" ⭐

### Game Action Gradients

#### Undo (Peach)
```swift
undoGradientStart: Color(red: 0.98, green: 0.89, blue: 0.75)
undoGradientEnd:   Color(red: 0.97, green: 0.78, blue: 0.58)
```

#### Erase (Lavender)
```swift
eraseGradientStart: Color(red: 0.95, green: 0.85, blue: 0.95)
eraseGradientEnd:   Color(red: 0.88, green: 0.7, blue: 0.92)
```

#### Hint (Yellow)
```swift
hintGradientStart: Color(red: 1.0, green: 0.93, blue: 0.76)
hintGradientEnd:   Color(red: 0.99, green: 0.82, blue: 0.64)
```

#### Settings (Purple)
```swift
gameSettingsGradientStart: Color(red: 0.7, green: 0.5, blue: 0.9)
gameSettingsGradientEnd:   Color(red: 0.6, green: 0.4, blue: 0.8)
```

### Puzzle Selection Colors

```swift
puzzleSelectionBackground: Color(red: 0.85, green: 0.88, blue: 0.92)  // Light blue-gray
puzzleHeaderText:          Color(red: 0.3, green: 0.3, blue: 0.35)    // Dark gray
puzzleButtonBackground:    Color.white                                 // Pure white
puzzleButtonBadge:         Color(red: 0.93, green: 0.90, blue: 0.78)  // Cream
puzzleCompletedBorder:     Color(red: 0.24, green: 0.65, blue: 0.33)  // Green
```

### Game View Colors

```swift
gamePaletteTitle:    Color(red: 0.44, green: 0.3, blue: 0.23)   // Brown
gamePaletteSubtitle: Color(red: 0.62, green: 0.47, blue: 0.34)  // Light brown
```

---

## Typography

### Font System
All text uses **SF Rounded** (`.rounded` design) for a friendly, approachable feel.

### Type Scale

#### Display (Main Menu)
```swift
.font(.system(size: 30, weight: .heavy, design: .rounded))
```
**Usage**: "Let's Play!" footer

#### Title Large
```swift
.font(.system(size: 28, weight: .bold, design: .rounded))
```
**Usage**: Quest button titles, puzzle selection header

#### Title Medium
```swift
.font(.system(size: 24, weight: .bold, design: .rounded))
```
**Usage**: Difficulty section headers

#### Title Small
```swift
.font(.system(size: 22, weight: .semibold, design: .rounded))
```
**Usage**: Settings toggles

#### Body Large
```swift
.font(.system(size: 18, weight: .medium, design: .rounded))
```
**Usage**: Quest subtitles, puzzle numbers

#### Body Medium
```swift
.font(.system(size: 16, weight: .semibold, design: .rounded))
```
**Usage**: Palette title, message banners, tutorial text

#### Body Small
```swift
.font(.system(size: 15, weight: .bold, design: .rounded))
```
**Usage**: Premium button text

#### Caption
```swift
.font(.system(size: 12, weight: .semibold, design: .rounded))
```
**Usage**: Palette subtitle, hints

---

## Layout System

### Spacing Scale

```swift
// Vertical Spacing
regularTopSpacing:      70pt
regularButtonSpacing:   50pt
compactButtonSpacing:   24pt
questButtonSpacing:     24pt

// Horizontal Padding
headerHorizontalPadding:  10pt
regularHorizontalPadding: 80pt
compactHorizontalPadding: 32pt
footerHorizontalPadding:  40pt

// Footer
footerVerticalPadding: 12pt
```

### Corner Radii

```swift
smallCornerRadius:          20pt  // Buttons, badges
largeCornerRadius:          30pt  // Quest buttons
puzzleCardCornerRadius:     24pt  // Difficulty cards
puzzleButtonCornerRadius:   20pt  // Individual puzzles
puzzleSettingsCornerRadius: 16pt  // Settings toggles
```

### Responsive Breakpoints

```swift
maxContentWidth: 680pt  // Maximum width for regular size class
```

**Behavior**:
- **Compact Width** (iPhone Portrait): Full width, reduced padding
- **Regular Width** (iPad, iPhone Landscape): Centered content, max 680pt

---

## Component Library

### 1. StorybookBadge

**Purpose**: Display text in a decorative badge

**Visual Style**:
- Rounded rectangle with gradient
- Drop shadow
- White text

**Usage**:
```swift
StorybookBadge(text: "Puzzle 1")
```

### 2. StorybookProgressBar

**Purpose**: Show puzzle completion progress

**Visual Style**:
- Capsule shape
- Gradient fill based on progress
- Smooth animations

**Usage**:
```swift
StorybookProgressBar(progress: 0.65)
```

### 3. StorybookInfoChip

**Purpose**: Display icon + text in a compact chip

**Visual Style**:
- Rounded background
- SF Symbol icon
- Small text

**Usage**:
```swift
StorybookInfoChip(icon: "clock", text: "05:32")
```

### 4. StorybookIconCircle

**Purpose**: Circular icon button

**Visual Style**:
- Circle with gradient fill
- SF Symbol icon
- Drop shadow

**Usage**:
```swift
StorybookIconCircle(
    systemName: "slider.horizontal.3",
    gradient: [Color.purple, Color.blue]
)
```

### 5. StorybookActionButton

**Purpose**: Game action buttons (Undo, Erase, Hint)

**Visual Style**:
- Rounded rectangle
- Gradient background
- Icon + text label
- Disabled state support

**Usage**:
```swift
StorybookActionButton(
    title: "Undo",
    icon: "arrow.uturn.backward",
    isEnabled: true,
    gradient: [Color.orange, Color.red],
    action: { /* undo logic */ }
)
```

### 6. StorybookHeaderCard

**Purpose**: Header background container

**Visual Style**:
- Rounded bottom corners
- White background
- Subtle shadow

### 7. StorybookBoardMat

**Purpose**: Decorative board background

**Visual Style**:
- Rounded rectangle
- Cream/beige color
- Layered shadows for depth

### 8. StorybookPaletteMat

**Purpose**: Symbol palette background

**Visual Style**:
- Rounded rectangle
- Light background
- Subtle border

---

## Symbol System

### Symbol Groups

#### Animals (11 groups)
- **animals**: animal1, animal2, animal4, animal8, animal10, animal15
- **animals2**: animal3, animal6, animal12, animal14, animal15, animal10
- **animals3**: animal_2_6, animal_2_7, animal_2_8, animal_2_9, animal_2_10, animal_2_11
- **animals4**: animal_2_1, animal_2_3, animal_2_5, animal_2_4, animal_2_12, animal_2_13
- **animalItems**: animal_with_item_1 through animal_with_item_6

#### Birds (4 groups)
- **birds**: bird1, bird4, bird6, bird7, bird9, bird13
- **birds2**: bird_2_11, bird_2_12, bird_2_13, bird_2_14, bird_2_15, bird_2_10
- **birds3**: bird_2_1 through bird_2_6
- **birds4**: bird2, bird3, bird5, bird14, bird15, bird11

#### Sea & Weather (2 groups)
- **sea**: sea7, sea11, sea3, sea5, sea9, sea13
- **weather**: sea6, sea8, sea10, sea12, sea14, sea1

#### Numbers
- **numbers**: number1 through number6

### Symbol Display

#### SymbolTokenView

**Purpose**: Render individual symbol or number

**Contexts**:
- **Board**: Larger size, fixed/editable styling
- **Palette**: Medium size, selection highlight

**Visual States**:
- **Fixed**: Darker background, bold appearance
- **Editable**: Lighter background, can be changed
- **Selected**: Glowing border, scale effect
- **Highlighted**: Matching values glow

**Usage**:
```swift
SymbolTokenView(
    symbolIndex: 2,
    symbolName: "animal4",
    showNumbers: false,
    size: 60,
    context: .board,
    isSelected: true
)
```

---

## Animation System

### Spring Animations

#### Default Spring
```swift
.spring(response: 0.35, dampingFraction: 0.6)
```
**Usage**: Symbol selection, palette interactions

#### Fast Spring
```swift
.spring(response: 0.3, dampingFraction: 0.7)
```
**Usage**: Message banners

#### Gentle Spring
```swift
.spring(response: 0.5, dampingFraction: 0.8)
```
**Usage**: Celebration overlay

### Easing Animations

#### Quick Ease
```swift
.easeInOut(duration: 0.15)
```
**Usage**: Cell taps, quick feedback

#### Standard Ease
```swift
.easeInOut(duration: 0.2)
```
**Usage**: Undo, erase, hint actions

#### Button Press
```swift
.easeInOut(duration: 0.1)
```
**Usage**: Button scale effects

### Transitions

#### Message Banner
```swift
.transition(.move(edge: .top).combined(with: .opacity))
```

#### Celebration
```swift
.transition(.scale.combined(with: .opacity))
```

---

## Visual Feedback System

### Haptic Feedback

#### Selection
```swift
HapticManager.shared.trigger(.selection)
```
**When**: Cell tap, palette selection, button press

#### Light
```swift
HapticManager.shared.trigger(.light)
```
**When**: Undo, erase actions

#### Medium
```swift
HapticManager.shared.trigger(.medium)
```
**When**: Hint usage

#### Success
```swift
HapticManager.shared.trigger(.success)
```
**When**: Puzzle completion

### Sound Effects

#### Correct Placement
```swift
SoundManager.shared.play(.correctPlacement, volume: 0.6)
```
**When**: Valid symbol placement

#### Incorrect Placement
```swift
SoundManager.shared.play(.incorrectPlacement, volume: 0.5)
```
**When**: Invalid placement attempt

#### Hint
```swift
SoundManager.shared.play(.hint, volume: 0.6)
```
**When**: Hint button pressed

#### Victory
```swift
SoundManager.shared.play(.victory, volume: 0.7)
```
**When**: Puzzle completed

### Visual Feedback

#### Glowing Highlight
- **Color**: Yellow with opacity
- **Blur**: Gaussian blur effect
- **Animation**: Pulsing scale

#### Scale Effects
- **Button Press**: 0.97x scale
- **Selected Symbol**: 1.08x scale
- **Hover State**: 1.02x scale

#### Message Banners
- **Info**: Blue background
- **Success**: Green background
- **Warning**: Orange background

---

## Background System

### Main Menu
- **Image**: `fox_bg`
- **Style**: Scaledtofill, ignores safe area
- **Alignment**: Bottom

### Game View
- **Image**: `gridbg`
- **Style**: Resizable stretch
- **Overlay**: Running fox animation at bottom

### Puzzle Selection
- **Color**: Light blue-gray solid
- **Style**: Ignores safe area

---

## Icon System

### SF Symbols Used

#### Navigation & Actions
- `questionmark.circle.fill` - Tutorial
- `gearshape.fill` - Settings
- `crown.fill` - Premium
- `arrow.uturn.backward` - Undo
- `xmark.circle` - Erase
- `lightbulb` - Hint
- `slider.horizontal.3` - Game settings

#### Status Indicators
- `checkmark` - Completed puzzle
- `lock.fill` - Locked puzzle
- `clock` - Timer
- `star.fill` - Full star rating
- `star.leadinghalf.filled` - Half star rating
- `star` - Empty star rating

---

## Responsive Design

### Device Sizing Strategy

#### Board Size Calculation
```swift
func computeBoardSize(
    availableWidth: CGFloat,
    availableHeight: CGFloat,
    bottomSafeArea: CGFloat
) -> CGFloat
```

**Logic**:
1. Calculate available space after header/palette/buttons
2. Take minimum of width and height
3. Apply padding and safe area insets
4. Clamp to reasonable min/max values

#### Adaptive Scaling

**iPad / Landscape**:
- Larger badge scale (1.1x)
- More horizontal padding
- Centered content with max width

**iPhone Portrait**:
- Smaller badge scale (0.9x)
- Reduced padding
- Full-width content

### Grid Layouts

#### Puzzle Selection
```swift
LazyVGrid(columns: [
    GridItem(.adaptive(minimum: 80, maximum: 150), spacing: 12)
])
```

**Behavior**:
- iPhone: 2-3 columns
- iPad: 4-6 columns
- Adapts to available width

---

## Accessibility Considerations

### Color Contrast
- All text meets WCAG AA standards
- Premium gold has sufficient contrast on white
- Difficulty colors distinguishable

### Touch Targets
- Minimum 44×44pt for all interactive elements
- Puzzle buttons: 100pt height
- Palette symbols: Adaptive sizing

### Dynamic Type Support
- Uses system font scaling
- `.rounded` design maintains readability
- Layouts adapt to larger text

### VoiceOver (Future Enhancement)
- Add `.accessibilityLabel()` to all buttons
- Provide context for symbols
- Announce game state changes

---

## Dark Mode (Future Enhancement)

### Proposed Dark Palette

#### Backgrounds
- Main: `Color(red: 0.1, green: 0.1, blue: 0.12)`
- Cards: `Color(red: 0.15, green: 0.15, blue: 0.17)`

#### Text
- Primary: `.white`
- Secondary: `Color(red: 0.8, green: 0.8, blue: 0.82)`

#### Accents
- Keep vibrant colors for difficulty/actions
- Reduce saturation slightly for comfort

---

## Animation Performance

### Optimization Techniques

#### Drawing Group
```swift
.drawingGroup()
```
**Usage**: Puzzle grid in selection view
**Benefit**: Rasterizes complex views for smoother scrolling

#### Isolated Updates
```swift
private struct GameTimerView: View {
    @ObservedObject var viewModel: GameViewModel
    // Only re-renders when time changes
}
```

#### Conditional Rendering
```swift
if viewModel.showCelebration {
    CelebrationOverlay(...)
}
```
**Benefit**: Only renders overlay when needed

---

## Design Tokens (Summary)

### Colors
- 40+ named colors
- Organized by feature area
- Consistent gradient patterns

### Typography
- 8 type scales
- Single font family (SF Rounded)
- Semantic naming

### Spacing
- 8pt base unit
- Consistent padding system
- Responsive breakpoints

### Corner Radii
- 3 sizes: 16pt, 20pt, 24pt, 30pt
- Consistent across components

### Shadows
- Subtle depth (radius 3-4pt)
- Stronger emphasis (radius 8-12pt)
- Consistent opacity (0.08-0.3)

---

## Component Composition Examples

### Quest Button
```swift
Button {
    // Action
} label: {
    VStack(spacing: 8) {
        Text("Start Journey: 4x4")
            .font(.system(size: 28, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
        Text("Fable Adventures")
            .font(.system(size: 18, weight: .medium, design: .rounded))
            .foregroundStyle(Theme.Colors.questSubtitle)
    }
}
.buttonStyle(QuestButtonStyle())
```

### Puzzle Button
```swift
ZStack {
    RoundedRectangle(cornerRadius: 20)
        .fill(Color.white)
    
    VStack {
        HStack {
            numberBadge
            Spacer()
            statusBadge
        }
        emojiImage
    }
    
    if isLocked {
        lockOverlay
    }
}
```

### Game Header
```swift
HStack {
    StorybookBadge(text: "Puzzle 1")
    Spacer()
    StorybookProgressBar(progress: 0.65)
    GameTimerView(viewModel: viewModel)
    StorybookIconCircle(systemName: "slider.horizontal.3")
}
.padding()
.background(StorybookHeaderCard())
```

---

## Design Principles

### 1. **Consistency**
- Reusable components across all screens
- Unified color palette
- Predictable interaction patterns

### 2. **Clarity**
- Clear visual hierarchy
- Obvious interactive elements
- Immediate feedback

### 3. **Delight**
- Playful animations
- Charming illustrations
- Rewarding celebrations

### 4. **Accessibility**
- High contrast ratios
- Large touch targets
- Clear iconography

### 5. **Performance**
- Optimized rendering
- Smooth animations
- Fast load times

---

## Conclusion

The Kidsdoku2 design system creates a cohesive, delightful experience through:

- ✅ **Warm, inviting color palette** with thematic consistency
- ✅ **Rounded, friendly typography** using SF Rounded
- ✅ **Smooth, spring-based animations** for natural feel
- ✅ **Reusable component library** for maintainability
- ✅ **Responsive layouts** adapting to all devices
- ✅ **Multi-sensory feedback** (visual, audio, haptic)
- ✅ **Storybook aesthetic** that appeals to children

The system is scalable, maintainable, and ready for future enhancements like dark mode and accessibility improvements.
