# Android-Specific Features for Valdi

## Overview

This guide covers Android-specific features and considerations when developing with Valdi.

## Android Platform Architecture

### Native Bridge

Valdi compiles TypeScript directly to native Android views using:

- **Kotlin/Java**: Platform implementation layer
- **Android NDK**: C++ integration for performance-critical code
- **JNI**: Java Native Interface for cross-language communication

### View Hierarchy

```bash
Valdi TSX Component
    ↓ (compiled to)
Android View/ViewGroup
    ↓ (rendered as)
Native Android UI
```

## Android-Specific Styling

### Platform-Specific Attributes

```tsx
new Style<View>({
  // Android-specific properties
  filterTouchesWhenObscured: false,  // Prevents touches when view is obscured
  accessibilityLiveRegion: 'polite', // Screen reader announcements
  importantForAccessibility: 'yes',  // Accessibility importance
});
```

### Elevation and Shadows

```tsx
new Style<View>({
  elevation: 4,                    // Shadow elevation in dp
  backgroundColor: 'white',
  borderRadius: 8,
  shadowColor: 'black',
  shadowOpacity: 0.2,
  shadowRadius: 4,
});
```

### Android Theme Integration

```tsx
// Access Android theme colors
const themeColors = {
  primary: '#007AFF',
  surface: '#FFFFFF',
  onSurface: '#000000',
};

new Style<View>({
  backgroundColor: themeColors.surface,
  color: themeColors.onSurface,
});
```

## Device-Specific Features

### Back Button Handling

```tsx
import { AndroidBackHandler } from 'valdi_android/src/AndroidBackHandler';

export class AppComponent extends Component {
  private backHandler = new AndroidBackHandler();

  onCreate() {
    this.backHandler.setOnBackPressed(() => {
      if (this.canGoBack()) {
        this.goBack();
        return true; // Handled
      }
      return false; // Let system handle (exit app)
    });
  }

  onDestroy() {
    this.backHandler.removeOnBackPressed();
  }
}
```

### Status Bar Customization

```tsx
import { AndroidStatusBar } from 'valdi_android/src/AndroidStatusBar';

export class AppComponent extends Component {
  onCreate() {
    AndroidStatusBar.setColor('#007AFF');  // Primary color
    AndroidStatusBar.setLightIcons(true);  // Light status bar icons
  }
}
```

### Navigation Bar

```tsx
import { AndroidNavigationBar } from 'valdi_android/src/AndroidNavigationBar';

AndroidNavigationBar.setColor('#FFFFFF');
AndroidNavigationBar.setLightIcons(false);
```

## Permissions

### Runtime Permissions

```tsx
import { AndroidPermissions } from 'valdi_android/src/AndroidPermissions';

export class CameraComponent extends Component {
  private async requestCameraPermission() {
    const granted = await AndroidPermissions.request('CAMERA');
    if (granted) {
      this.openCamera();
    } else {
      this.showPermissionDenied();
    }
  }

  private async checkPermissions() {
    const cameraGranted = await AndroidPermissions.check('CAMERA');
    const storageGranted = await AndroidPermissions.check('WRITE_EXTERNAL_STORAGE');

    return cameraGranted && storageGranted;
  }
}
```

### Permission Groups

Common Android permissions:

- `CAMERA`: Camera access
- `READ_EXTERNAL_STORAGE`: Read files
- `WRITE_EXTERNAL_STORAGE`: Write files
- `ACCESS_FINE_LOCATION`: GPS location
- `ACCESS_COARSE_LOCATION`: Network location
- `RECORD_AUDIO`: Microphone access
- `READ_CONTACTS`: Contacts access

## File System Access

### Android Storage

```tsx
import { AndroidFileSystem } from 'valdi_android/src/AndroidFileSystem';

export class FileManager extends Component {
  private async saveFile(filename: string, data: Uint8Array) {
    try {
      const filePath = await AndroidFileSystem.getExternalFilesDir();
      await AndroidFileSystem.writeFile(`${filePath}/${filename}`, data);
    } catch (error) {
      console.error('Failed to save file:', error);
    }
  }

  private async readFile(filename: string): Promise<Uint8Array> {
    const filePath = await AndroidFileSystem.getExternalFilesDir();
    return await AndroidFileSystem.readFile(`${filePath}/${filename}`);
  }
}
```

### Scoped Storage (Android 10+)

```tsx
// Use MediaStore for shared media files
const imageUri = await AndroidFileSystem.saveToMediaStore(data, 'image/jpeg', 'photo.jpg');

// Use SAF (Storage Access Framework) for user-selected files
const fileUri = await AndroidFileSystem.openDocument('image/*');
```

## Notifications

### Local Notifications

```tsx
import { AndroidNotifications } from 'valdi_android/src/AndroidNotifications';

export class NotificationManager extends Component {
  private async scheduleNotification() {
    const notificationId = await AndroidNotifications.schedule({
      title: 'Mercedes Analytics Update',
      body: 'New conversation data available',
      delayMs: 60 * 1000, // 1 minute
      channelId: 'analytics_updates',
      icon: 'ic_notification'
    });

    // Store ID for cancellation
    this.setState({ notificationId });
  }

  private async cancelNotification() {
    if (this.state.notificationId) {
      await AndroidNotifications.cancel(this.state.notificationId);
    }
  }
}
```

### Notification Channels (Android 8.0+)

```tsx
await AndroidNotifications.createChannel({
  id: 'analytics_updates',
  name: 'Analytics Updates',
  description: 'Notifications for new analytics data',
  importance: 'default',
  sound: true,
  vibration: true
});
```

## Biometric Authentication

### Fingerprint/Face Unlock

```tsx
import { AndroidBiometric } from 'valdi_android/src/AndroidBiometric';

export class BiometricAuth extends Component {
  private async authenticate() {
    try {
      const result = await AndroidBiometric.authenticate({
        title: 'Authenticate',
        subtitle: 'Use your fingerprint to continue',
        description: 'Place your finger on the sensor',
        negativeButtonText: 'Cancel'
      });

      if (result.success) {
        this.onAuthenticationSuccess();
      }
    } catch (error) {
      this.onAuthenticationError(error);
    }
  }
}
```

## Camera Integration

### Camera Access

```tsx
import { AndroidCamera } from 'valdi_android/src/AndroidCamera';

export class CameraComponent extends Component {
  private async takePhoto() {
    try {
      const photoData = await AndroidCamera.takePhoto({
        quality: 0.8,
        width: 1920,
        height: 1080
      });

      this.processPhoto(photoData);
    } catch (error) {
      console.error('Camera error:', error);
    }
  }

  private async recordVideo() {
    const videoUri = await AndroidCamera.recordVideo({
      quality: 'high',
      maxDuration: 30 // seconds
    });
  }
}
```

## Sensors

### Device Sensors

```tsx
import { AndroidSensors } from 'valdi_android/src/AndroidSensors';

export class SensorComponent extends Component {
  private accelerometer?: SensorSubscription;

  onCreate() {
    this.accelerometer = AndroidSensors.subscribe('accelerometer', (data) => {
      console.log('Acceleration:', data.x, data.y, data.z);
    });
  }

  onDestroy() {
    if (this.accelerometer) {
      this.accelerometer.unsubscribe();
    }
  }
}
```

Available sensors:

- `accelerometer`: Device acceleration
- `gyroscope`: Rotation rate
- `magnetometer`: Magnetic field
- `barometer`: Atmospheric pressure
- `light`: Ambient light level
- `proximity`: Proximity to device

## Background Tasks

### WorkManager Integration

```tsx
import { AndroidWorkManager } from 'valdi_android/src/AndroidWorkManager';

export class BackgroundSync extends Component {
  private async scheduleSync() {
    await AndroidWorkManager.schedule({
      type: 'periodic',
      intervalMs: 15 * 60 * 1000, // 15 minutes
      constraints: {
        networkType: 'connected',
        batteryNotLow: true
      },
      task: 'sync_analytics_data'
    });
  }
}
```

## App Lifecycle

### Activity Lifecycle Events

```tsx
import { AndroidLifecycle } from 'valdi_android/src/AndroidLifecycle';

export class AppComponent extends Component {
  onCreate() {
    AndroidLifecycle.addListener({
      onResume: () => {
        console.log('App resumed');
        this.refreshData();
      },
      onPause: () => {
        console.log('App paused');
        this.saveState();
      },
      onDestroy: () => {
        console.log('App destroyed');
        this.cleanup();
      }
    });
  }
}
```

## Performance Considerations

### Memory Management

```tsx
// Use Android's memory info
import { AndroidMemory } from 'valdi_android/src/AndroidMemory';

const memoryInfo = AndroidMemory.getInfo();
if (memoryInfo.lowMemory) {
  // Free up memory
  this.clearCache();
}
```

### Battery Optimization

```tsx
import { AndroidPowerManager } from 'valdi_android/src/AndroidPowerManager';

// Check if device is in power save mode
if (AndroidPowerManager.isPowerSaveMode()) {
  // Reduce background tasks
  this.disableBackgroundSync();
}
```

## Testing on Android

### Android-Specific Tests

```tsx
describe('Android Features', () => {
  valdiIt('handles back button', async (driver) => {
    // Test back button handling
    const component = createComponent(AppComponent);

    // Simulate back button press
    AndroidTestUtils.pressBackButton();

    // Verify navigation
    expect(component.getCurrentScreen()).toBe('previous_screen');
  });

  valdiIt('requests permissions', async (driver) => {
    // Mock permission request
    AndroidTestUtils.mockPermission('CAMERA', true);

    const component = createComponent(CameraComponent);
    await component.requestPermissions();

    expect(component.hasCameraPermission()).toBe(true);
  });
});
```

## Build Configuration

### Android Manifest

Valdi generates the Android manifest automatically, but you can customize:

```xml
<!-- Custom permissions -->
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />

<!-- Custom application attributes -->
<application
    android:name=".MercedesApplication"
    android:theme="@style/AppTheme">
</application>
```

### Gradle Configuration

For custom native dependencies or advanced Android features:

```gradle
android {
    defaultConfig {
        minSdkVersion 19
        targetSdkVersion 34
    }

    buildTypes {
        release {
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android.txt')
        }
    }
}

dependencies {
    implementation 'com.google.android.material:material:1.9.0'
    implementation 'androidx.biometric:biometric:1.1.0'
}
```

## Distribution

### APK Generation

```bash
# Debug APK
bazel build //apps/mercedes_app:mercedes_app_android

# Release APK
bazel build //apps/mercedes_app:mercedes_app_android_release
```

### Play Store Deployment

1. Generate signed APK/AAB
2. Upload to Google Play Console
3. Configure store listing
4. Set up beta/alpha channels
5. Publish to production

## Troubleshooting

### Common Android Issues

#### ANR (Application Not Responding)

- Move long-running tasks to background threads
- Use `Worker` threads for heavy computations
- Implement proper loading states

#### Memory Leaks

- Unsubscribe from sensors/listeners in `onDestroy`
- Use weak references for callbacks
- Monitor memory usage with Android Profiler

#### Permission Denied

- Check manifest permissions
- Request runtime permissions
- Handle permission denials gracefully

#### Battery Drain

- Reduce location update frequency
- Use `JobScheduler` for background tasks
- Respect Doze mode restrictions

## Next Steps

- [Deployment Guide](./DEPLOYMENT.md)
