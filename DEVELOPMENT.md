# Valdi Android Development Guide

## Overview

This guide covers developing Android apps with Valdi, focusing on the Mercedes analytics use case.

## Valdi Architecture

### Component-Based Development

Valdi uses TypeScript TSX for declarative UI rendering:

```tsx
import { Component } from 'valdi_core/src/Component';

export class MercedesDashboard extends Component {
  onRender() {
    <view backgroundColor='white' padding={16}>
      <label value='Mercedes Analytics' font='system-bold 24' />
    </view>;
  }
}
```

### Key Concepts

#### Components

- Extend `Component` or `StatefulComponent`
- Lifecycle: `onCreate()`, `onRender()`, `onDestroy()`
- Props via `ViewModel` interface
- State via `State` interface

#### TSX Rendering

- React-like syntax
- Direct compilation to native views
- No JavaScript bridges or web views

#### Styling

```tsx
import { Style } from 'valdi_core/src/Style';

const buttonStyle = new Style<View>({
  backgroundColor: '#007AFF',
  padding: 12,
  borderRadius: 8,
  color: 'white'
});

<view style={buttonStyle}>
  <label value='Tap me' />
</view>
```

## Project Structure

### Module Organization

```bash
apps/mercedes_app/src/valdi/mercedes_app/
├── src/           # TypeScript source files
│   ├── App.tsx
│   ├── components/
│   │   ├── Dashboard.tsx
│   │   ├── LoginForm.tsx
│   │   └── DataList.tsx
│ └── services/
│     └── ApiService.ts
├── res/           # Images and assets
├── strings/       # Localization files
├── BUILD.bazel    # Build configuration
├── module.yaml    # Module dependencies
└── tsconfig.json  # TypeScript config
```

## Component Development

### Basic Component

```tsx
import { Component } from 'valdi_core/src/Component';
import { systemFont } from 'valdi_core/src/SystemFont';

export class WelcomeScreen extends Component {
  onRender() {
    <layout padding={24}>
      <label
        value='Welcome to Mercedes Analytics'
        font={systemFont(18)}
        textAlignment='center'
      />
    </layout>;
  }
}
```

### Stateful Component

```tsx
import { StatefulComponent } from 'valdi_core/src/Component';

interface LoginViewModel {
  email: string;
  password: string;
}

interface LoginState {
  isLoading: boolean;
  error?: string;
}

export class LoginForm extends StatefulComponent<LoginViewModel, LoginState> {
  state = {
    isLoading: false
  };

  private async handleLogin() {
    this.setState({ isLoading: true, error: undefined });
    try {
      // Login logic here
      await this.login(this.viewModel.email, this.viewModel.password);
    } catch (error) {
      this.setState({ error: error.message });
    } finally {
      this.setState({ isLoading: false });
    }
  }

  onRender() {
    <layout padding={24}>
      <textField
        placeholder='Email'
        value={this.viewModel.email}
        onChangeText={(text) => this.setViewModel({ ...this.viewModel, email: text })}
      />
      <textField
        placeholder='Password'
        secureTextEntry={true}
        value={this.viewModel.password}
        onChangeText={(text) => this.setViewModel({ ...this.viewModel, password: text })}
      />

      {this.state.error && (
        <label value={this.state.error} color='red' />
      )}

      <view
        backgroundColor={this.state.isLoading ? 'gray' : 'blue'}
        padding={12}
        onTap={() => this.handleLogin()}
      >
        <label
          value={this.state.isLoading ? 'Logging in...' : 'Login'}
          color='white'
          textAlignment='center'
        />
      </view>
    </layout>;
  }
}
```

## Layout and Views

### Flexbox Layout

```tsx
<view style={{ flexDirection: 'column', padding: 16 }}>
  <view style={{ flex: 1, backgroundColor: 'red' }} />
  <view style={{ flex: 2, backgroundColor: 'blue' }} />
</view>
```

### Scroll Views

```tsx
<scroll horizontal={false}>
  <view style={{ padding: 16 }}>
    {/* Content that may exceed screen height */}
  </view>
</scroll>
```

## Event Handling

### Touch Events

```tsx
<view
  onTap={() => console.log('Tapped!')}
  onLongPress={() => console.log('Long pressed!')}
  onDoubleTap={() => console.log('Double tapped!')}
>
  <label value='Tap me' />
</view>
```

### Gesture Configuration

```tsx
new Style<View>({
  onTapDisabled: false,
  onLongPressDisabled: false,
  longPressDuration: 0.5,
  touchAreaExtension: 10  // Extends touch area
})
```

## Data Management

### HTTP Client

```tsx
import { HTTPClient } from 'valdi_http/src/HTTPClient';

const client = new HTTPClient('https://api.mercedes-analytics.com');

// GET request
const response = await client.get('/conversations', {
  'Authorization': `Bearer ${token}`
});

// POST request
const postData = new TextEncoder().encode(JSON.stringify({
  name: 'New Conversation'
}));
const response = await client.post('/conversations', postData, {
  'Content-Type': 'application/json'
});
```

### Persistent Storage

```tsx
import { Storage } from 'valdi_persistence/src/Storage';

const storage = new Storage();

// Store data
await storage.set('user_token', token);

// Retrieve data
const token = await storage.get('user_token');

// Remove data
await storage.remove('user_token');
```

## Navigation

### Basic Navigation

```tsx
import { Navigation } from 'valdi_navigation/src/Navigation';

const navigation = new Navigation();

// Push new page
navigation.push({
  component: DashboardComponent,
  props: { userId: 123 }
});

// Pop current page
navigation.pop();

// Replace current page
navigation.replace({
  component: LoginComponent
});
```

## Testing

### Unit Tests

```tsx
import { valdiIt, createComponent } from 'valdi_test/test/JSXTestUtils';
import { elementTypeFind } from 'foundation/test/util/elementTypeFind';

describe('LoginForm', () => {
  valdiIt('renders login form', async (driver) => {
    const component = createComponent(LoginForm, {
      email: 'test@example.com',
      password: 'password'
    });

    const labels = elementTypeFind(
      componentGetElements(component),
      IRenderedElementViewClass.Label
    );

    expect(labels.length).toBeGreaterThan(0);
  });
});
```

### Running Tests

```bash
bazel test //apps/mercedes_app/src/valdi/mercedes_app:test
```

## Performance Optimization

### View Recycling

```tsx
<collection
  data={this.items}
  renderItem={(item) => <ListItem data={item} />}
  itemHeight={60}
/>
```

### Lazy Loading

```tsx
<view lazy={true}>
  {/* Content loaded only when visible */}
</view>
```

### Image Optimization

```tsx
<image
  src='https://example.com/image.jpg'
  objectFit='cover'
  lazy={true}
/>
```

## Debugging

### Hot Reloading

```bash
valdi hotreload --module mercedes_app
```

### VS Code Debugger

- Set breakpoints in TypeScript code
- Inspect component state and props
- Debug network requests

### Logging

```tsx
console.log('Debug message');
console.warn('Warning message');
console.error('Error message');
```

## Best Practices

### Code Organization

- Keep components small and focused
- Use TypeScript interfaces for props and state
- Separate business logic from UI components
- Use consistent naming conventions

### Performance

- Create styles at component level, not in render
- Use keys for dynamic lists
- Implement proper error handling
- Optimize image loading

### Accessibility

```tsx
<label
  value='Login Button'
  accessibilityLabel='Tap to log in to your account'
  accessibilityHint='Opens the main dashboard'
/>
```

## Next Steps

- [API Integration Guide](./API_INTEGRATION.md)
- [Android Specific Features](./ANDROID_SPECIFIC.md)
- [Deployment Guide](./DEPLOYMENT.md)
