# Mercedes Analytics API Integration

## Overview

This guide covers integrating the Valdi Android app with the Mercedes analytics Rust backend API.

## API Architecture

### Backend Details

- **Framework**: Axum (Rust web framework)
- **Database**: PostgreSQL with SeaORM
- **Authentication**: JWT tokens via HttpOnly cookies
- **Pagination**: Cursor-based pagination
- **Isolation**: Business-level data isolation

### API Endpoints

#### Authentication

```bash
POST /admin/login
POST /admin/logout
GET  /admin/me
```

#### Admin Endpoints (Business Management)

```bash
GET    /admin/businesses
POST   /admin/businesses
GET    /admin/businesses/{id}
PUT    /admin/businesses/{id}
DELETE /admin/businesses/{id}

GET    /admin/users
POST   /admin/users
GET    /admin/users/{id}
PUT    /admin/users/{id}
DELETE /admin/users/{id}
```

#### Public Endpoints (Analytics Data)

```bash
GET /conversations?cursor={cursor}&limit={limit}
GET /conversations/{id}
GET /payments?cursor={cursor}&limit={limit}
GET /payments/{id}
GET /metabase/embed/{dashboard_id}
```

## Valdi HTTP Client Setup

### HTTP Client Configuration

```tsx
import { HTTPClient } from 'valdi_http/src/HTTPClient';
import { Storage } from 'valdi_persistence/src/Storage';

export class ApiService {
  private client: HTTPClient;
  private storage: Storage;

  constructor(baseUrl: string = 'https://api.mercedes-analytics.com') {
    this.client = new HTTPClient(baseUrl);
    this.storage = new Storage();
  }

  // Helper method to get auth token
  private async getAuthToken(): Promise<string | null> {
    return await this.storage.get('auth_token');
  }

  // Helper method to set auth headers
  private async getAuthHeaders(): Promise<Record<string, string>> {
    const token = await this.getAuthToken();
    return token ? { 'Authorization': `Bearer ${token}` } : {};
  }
}
```

## Authentication Integration

### Login Implementation

```tsx
export class AuthService extends ApiService {
  async login(email: string, password: string): Promise<LoginResponse> {
    const loginData = new TextEncoder().encode(JSON.stringify({
      email,
      password
    }));

    const response = await this.client.post('/admin/login', loginData, {
      'Content-Type': 'application/json'
    });

    if (response.statusCode === 200) {
      const responseText = new TextDecoder().decode(response.body);
      const loginResponse: LoginResponse = JSON.parse(responseText);

      // Store token securely
      await this.storage.set('auth_token', loginResponse.token);
      await this.storage.set('user_info', JSON.stringify(loginResponse.user));

      return loginResponse;
    } else {
      throw new Error('Login failed');
    }
  }

  async logout(): Promise<void> {
    await this.client.post('/admin/logout', new Uint8Array(), {
      ...(await this.getAuthHeaders())
    });

    // Clear stored data
    await this.storage.remove('auth_token');
    await this.storage.remove('user_info');
  }

  async getCurrentUser(): Promise<User | null> {
    try {
      const response = await this.client.get('/admin/me', {
        ...(await this.getAuthHeaders())
      });

      if (response.statusCode === 200) {
        const responseText = new TextDecoder().decode(response.body);
        return JSON.parse(responseText);
      }
    } catch (error) {
      console.error('Failed to get current user:', error);
    }
    return null;
  }
}
```

### Login Component Integration

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

export class LoginScreen extends StatefulComponent<LoginViewModel, LoginState> {
  state = { isLoading: false };

  private authService = new AuthService();

  private async handleLogin() {
    this.setState({ isLoading: true, error: undefined });

    try {
      await this.authService.login(
        this.viewModel.email,
        this.viewModel.password
      );

      // Navigate to dashboard
      this.navigateToDashboard();
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
        onChangeText={(text) =>
          this.setViewModel({ ...this.viewModel, email: text })
        }
      />
      <textField
        placeholder='Password'
        secureTextEntry={true}
        value={this.viewModel.password}
        onChangeText={(text) =>
          this.setViewModel({ ...this.viewModel, password: text })
        }
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

## Data Fetching Components

### Conversations List

```tsx
import { StatefulComponent } from 'valdi_core/src/Component';

interface ConversationsViewModel {
  businessId: string;
}

interface ConversationsState {
  conversations: Conversation[];
  isLoading: boolean;
  cursor?: string;
  hasMore: boolean;
}

export class ConversationsList extends StatefulComponent<ConversationsViewModel, ConversationsState> {
  state = {
    conversations: [],
    isLoading: false,
    hasMore: true
  };

  private apiService = new ApiService();

  async onCreate() {
    await this.loadConversations();
  }

  private async loadConversations(loadMore: boolean = false) {
    this.setState({ isLoading: true });

    try {
      const params = new URLSearchParams();
      if (loadMore && this.state.cursor) {
        params.set('cursor', this.state.cursor);
      }
      params.set('business_id', this.viewModel.businessId);
      params.set('limit', '20');

      const response = await this.apiService.get(`/conversations?${params}`, {
        ...(await this.apiService.getAuthHeaders())
      });

      if (response.statusCode === 200) {
        const responseText = new TextDecoder().decode(response.body);
        const data: ConversationsResponse = JSON.parse(responseText);

        this.setState({
          conversations: loadMore
            ? [...this.state.conversations, ...data.conversations]
            : data.conversations,
          cursor: data.next_cursor,
          hasMore: !!data.next_cursor
        });
      }
    } catch (error) {
      console.error('Failed to load conversations:', error);
    } finally {
      this.setState({ isLoading: false });
    }
  }

  onRender() {
    <scroll>
      <layout padding={16}>
        {this.state.conversations.map(conversation => (
          <ConversationItem
            key={conversation.id}
            conversation={conversation}
          />
        ))}

        {this.state.isLoading && (
          <label value='Loading...' textAlignment='center' />
        )}

        {this.state.hasMore && !this.state.isLoading && (
          <view
            backgroundColor='blue'
            padding={12}
            onTap={() => this.loadConversations(true)}
          >
            <label value='Load More' color='white' textAlignment='center' />
          </view>
        )}
      </layout>
    </scroll>;
  }
}
```

### Individual Conversation Item

```tsx
interface ConversationItemViewModel {
  conversation: Conversation;
}

export class ConversationItem extends Component<ConversationItemViewModel> {
  onRender() {
    <view
      backgroundColor='white'
      padding={12}
      marginBottom={8}
      borderRadius={8}
      style={{ shadowColor: 'black', shadowOpacity: 0.1, shadowRadius: 4 }}
    >
      <label
        value={this.viewModel.conversation.title}
        font='system-bold 16'
      />
      <label
        value={`Created: ${new Date(this.viewModel.conversation.created_at).toLocaleDateString()}`}
        font='system 12'
        color='gray'
      />
      <label
        value={this.viewModel.conversation.preview}
        font='system 14'
        numberOfLines={2}
      />
    </view>;
  }
}
```

## Metabase Integration

### Embedded Dashboard

```tsx
import { WebView } from 'valdi_core/src/NativeTemplateElements';

interface MetabaseViewModel {
  dashboardId: string;
}

export class MetabaseDashboard extends Component<MetabaseViewModel> {
  private apiService = new ApiService();

  onRender() {
    <view style={{ flex: 1 }}>
      <WebView
        src={`https://metabase.mercedes-analytics.com/embed/dashboard/${this.viewModel.dashboardId}`}
        style={{ flex: 1 }}
      />
    </view>;
  }
}
```

## Error Handling

### Global Error Boundary

```tsx
export class ErrorBoundary extends StatefulComponent<{}, { hasError: boolean; error?: Error }> {
  state = { hasError: false };

  static getDerivedStateFromError(error: Error) {
    return { hasError: true, error };
  }

  onRender() {
    if (this.state.hasError) {
      return (
        <view style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
          <label value='Something went wrong' font='system-bold 18' />
          <label value={this.state.error?.message || 'Unknown error'} color='red' />
          <view
            backgroundColor='blue'
            padding={12}
            onTap={() => this.setState({ hasError: false, error: undefined })}
          >
            <label value='Retry' color='white' />
          </view>
        </view>
      );
    }

    return this.props.children;
  }
}
```

## Caching Strategy

### Response Caching

```tsx
export class CachedApiService extends ApiService {
  private cache = new LRUCache<string>(100); // Cache up to 100 responses

  async getCached(url: string, headers: Record<string, string> = {}): Promise<HTTPResponse> {
    const cacheKey = `${url}:${JSON.stringify(headers)}`;
    const cached = this.cache.get(cacheKey);

    if (cached && Date.now() - cached.timestamp < 5 * 60 * 1000) { // 5 minutes
      return cached.response;
    }

    const response = await this.get(url, headers);
    this.cache.insert(cacheKey, { response, timestamp: Date.now() });

    return response;
  }
}
```

## Testing API Integration

### Mock API Service

```tsx
export class MockApiService extends ApiService {
  async get(url: string, headers?: Record<string, string>): Promise<HTTPResponse> {
    // Return mock data based on URL
    if (url.includes('/conversations')) {
      const mockData = {
        conversations: [
          { id: '1', title: 'Mock Conversation', preview: 'Mock content...' }
        ]
      };
      return {
        statusCode: 200,
        body: new TextEncoder().encode(JSON.stringify(mockData)),
        headers: { 'content-type': 'application/json' }
      };
    }

    throw new Error('Mock not implemented for this endpoint');
  }
}
```

## Security Considerations

### Token Storage

- Use encrypted storage for auth tokens
- Implement token refresh logic
- Clear tokens on logout

### HTTPS Only

- Ensure all API calls use HTTPS
- Validate SSL certificates

### Input Validation

- Validate all user inputs before API calls
- Sanitize data to prevent injection attacks

## Performance Optimization

### Request Batching

```tsx
export class BatchedApiService extends ApiService {
  private requestQueue: Array<{ url: string; resolve: Function; reject: Function }> = [];
  private isProcessing = false;

  async getBatched(urls: string[]): Promise<HTTPResponse[]> {
    const promises = urls.map(url => new Promise<HTTPResponse>((resolve, reject) => {
      this.requestQueue.push({ url, resolve, reject });
    }));

    this.processQueue();
    return Promise.all(promises);
  }

  private async processQueue() {
    if (this.isProcessing || this.requestQueue.length === 0) return;

    this.isProcessing = true;

    while (this.requestQueue.length > 0) {
      const batch = this.requestQueue.splice(0, 5); // Process 5 at a time

      const responses = await Promise.all(
        batch.map(({ url }) => this.get(url))
      );

      batch.forEach(({ resolve }, index) => resolve(responses[index]));
    }

    this.isProcessing = false;
  }
}
```

## Next Steps

- [Android Specific Features](./ANDROID_SPECIFIC.md)
- [Deployment Guide](./DEPLOYMENT.md)
