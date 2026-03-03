# Authentication API Endpoints

This document describes the authentication endpoints that should be implemented on your backend at `http://mohammedsaead00-001-site1.rtempurl.com`.

## Base URL
```
http://mohammedsaead00-001-site1.rtempurl.com
```

## Authentication Endpoints

### 1. User Registration
**POST** `/api/auth/register`

Registers a new user account.

**Request Body:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "securepassword123"
}
```

**Response:**
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4...",
  "user": {
    "id": "user-uuid-string",
    "name": "John Doe",
    "email": "john@example.com",
    "avatar": null,
    "createdAt": "2026-03-02T23:00:00.000Z",
    "lastLoginAt": "2026-03-02T23:00:00.000Z"
  }
}
```

### 2. User Login
**POST** `/api/auth/login`

Authenticates a user and returns access tokens.

**Request Body:**
```json
{
  "email": "john@example.com",
  "password": "securepassword123"
}
```

**Response:**
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4...",
  "user": {
    "id": "user-uuid-string",
    "name": "John Doe",
    "email": "john@example.com",
    "avatar": null,
    "createdAt": "2026-03-02T23:00:00.000Z",
    "lastLoginAt": "2026-03-02T23:00:00.000Z"
  }
}
```

### 3. Refresh Token
**POST** `/api/auth/refresh`

Refreshes an expired access token.

**Request Body:**
```json
{
  "refreshToken": "dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4..."
}
```

**Response:**
```json
{
  "accessToken": "new-access-token-here"
}
```

### 4. Get User Profile
**GET** `/api/auth/profile`

Retrieves the authenticated user's profile information.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response:**
```json
{
  "id": "user-uuid-string",
  "name": "John Doe",
  "email": "john@example.com",
  "avatar": null,
  "createdAt": "2026-03-02T23:00:00.000Z",
  "lastLoginAt": "2026-03-02T23:00:00.000Z"
}
```

### 5. User Logout
**POST** `/api/auth/logout`

Invalidates user tokens and logs out the user.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response:**
```
204 No Content
```

## Error Handling

The API uses standard HTTP status codes:

- `200` - Success
- `201` - Created
- `204` - No Content (successful logout)
- `400` - Bad Request (validation errors)
- `401` - Unauthorized (invalid credentials/token)
- `409` - Conflict (email already exists)
- `500` - Internal Server Error

Error responses follow this format:
```json
{
  "message": "Error description",
  "statusCode": 400
}
```

## Security Requirements

### Password Requirements
- Minimum 6 characters
- Should include complexity requirements (your choice)
- Stored as hashed values (bcrypt recommended)

### Token Management
- **Access Token**: JWT token with short expiry (15-30 minutes)
- **Refresh Token**: Longer-lived token for refreshing access tokens
- Tokens should be invalidated on logout
- Implement proper token refresh logic

### Authentication Headers
All authenticated endpoints require:
```
Authorization: Bearer <access_token>
```

## Implementation Notes

1. **Token Storage**: The Flutter app uses secure storage for tokens
2. **Session Management**: App automatically handles token refresh
3. **Error Handling**: App provides user-friendly error messages
4. **Network Resilience**: App gracefully handles network failures
5. **Local Fallback**: Session persistence works offline

## User Flow

1. **Registration**: User signs up → Backend creates account → Returns tokens + user data
2. **Login**: User logs in → Backend validates credentials → Returns tokens + user data  
3. **Session**: App stores tokens securely → Uses access token for authenticated requests
4. **Refresh**: When access token expires → App automatically refreshes using refresh token
5. **Logout**: User logs out → App invalidates tokens on both client and server

## Testing Endpoints

You can test these endpoints using tools like:
- Postman
- curl
- Swagger/OpenAPI documentation
- Your backend's testing framework

The Flutter app is now ready to communicate with your backend authentication system!