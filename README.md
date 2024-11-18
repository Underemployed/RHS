# Fort Police Database App

## Data Structure Guide

### 1. Wanderer Database (wanderer.xlsx)
Required Headers (case-insensitive):r
- `name` / `person name` / `full name`
- `photo` / `image` / `picture` / `img`
- `address` / `location`
- `area` / `zone` / `region`

Example:
| name | photo | address | area |
|------|--------|---------|------|
| John Doe | https://drive.google.com/file/d/... | 123 Main St | North Zone |

### 2. RHS Database (rhs.xlsx)
Required Headers:
- `id` / `number`
- `name` / `person name` / `full name`

Example:
| id | name | additional_info |
|----|------|----------------|
| 1 | John Doe | Any extra details |

### 3. Contact Database (contacts.xlsx)
Required Headers:
- `name` / `full name` / `fullname` 
- `phone` / `mobile` / `contact` / `number` / `mobile number` / `phone number`
- `rank` / `designation` / `position`

Example:
| name | phone | rank |
|------|-------|------|
| John Doe | 1234567890 | Inspector |

## Data Guidelines
- Place Excel files in `assets/data/` directory
- First row must contain headers
- Headers are case-insensitive
- Multiple header variations supported
- Numbers automatically convert to integers
- Google Drive photo links supported in wanderer.xlsx
- Empty cells allowed
- Unicode text supported
- Additional columns allowed

## File Setup
1. Create Excel files with appropriate headers
2. Save in .xlsx format
3. Place in assets/data/ folder
4. Update pubspec.yaml to include:c
```yaml
flutter:
  assets:
    - assets/data/
```
## Build and Deploy

To update and build the app, run the following commands in the terminal within the `rhs` directory:

```sh
flutter clean
flutter pub get
dart run flutter_launcher_icons
flutter build appbundle
flutter build apk --release
cp build/app/outputs/flutter-apk/app-release.apk "Fort Police Database.apk"
cd ./
```