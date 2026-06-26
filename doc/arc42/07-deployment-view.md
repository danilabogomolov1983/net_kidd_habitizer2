# 7. Deployment View

## 7.1 Deployment Targets

| Platform | Artifact | Build command |
|----------|----------|---------------|
| Android | APK / AAB | `flutter build apk --release` |
| iOS | IPA | `flutter build ios --release` |
| Web | Static files | `flutter build web --release` |
| Linux | Snap / binary | `flutter build linux --release` |
| macOS | App bundle | `flutter build macos --release` |
| Windows | MSIX | `flutter build windows --release` |

## 7.2 Docker Deployment (Web)

```
┌──────────────────────────────────────────┐
│              Docker Host                  │
│                                           │
│  ┌────────────────────────────────────┐  │
│  │  nginx:alpine (port 80)            │  │
│  │  ┌──────────────────────────────┐  │  │
│  │  │  /usr/share/nginx/html       │  │  │
│  │  │  (Flutter web build output)  │  │  │
│  │  └──────────────────────────────┘  │  │
│  └────────────────────────────────────┘  │
│                                           │
│  User accesses http://host:80             │
└──────────────────────────────────────────┘
```

### Steps

```bash
# Build and run locally
cd operations
./deploy.sh web
docker run -p 8080:80 habitizer:latest

# Or build manually
flutter build web --release
docker build -t habitizer:latest -f operations/Dockerfile .
docker run -p 8080:80 habitizer:latest
```

## 7.3 Infrastructure Requirements

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| Storage | 50 MB (app + DB) | 200 MB |
| Memory | 64 MB | 256 MB |
| OS | Android 5+ / iOS 12+ / any Docker host | Latest |
