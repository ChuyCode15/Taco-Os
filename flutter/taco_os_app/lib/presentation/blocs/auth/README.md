# AuthBloc - Authentication BLoC

## Overview

The `AuthBloc` manages the complete authentication lifecycle for the Taco'Os application, including Google Sign-In, session validation, background timeout, and lockout after failed attempts.

## Requirements

**Validates: Requirements 1.3, 1.5, 1.6, 1.7, 1.9**

## Files

- `auth_event.dart` - Authentication events
- `auth_state.dart` - Authentication states
- `auth_bloc.dart` - Main BLoC implementation
- `auth_bloc_exports.dart` - Barrel file for clean imports

## Events

### SignInRequested
Triggers Google Sign-In flow. Implements:
- Counter for failed attempts (max 3)
- 30-second lockout after 3 failures
- JWT storage on success

### SignOutRequested
Removes JWT from secure storage and clears user data from memory.

### SessionChecked
Validates active session by checking:
- JWT validity (not expired)
- Background time (< 12 hours)

### BackgroundTimeoutExceeded
Triggered when app has been in background for > 12 hours. Automatically signs out user.

## States

### AuthInitial
Initial state before session verification.

### AuthLoading
Loading state during authentication operations.

### Authenticated
User successfully authenticated. Contains `User` entity with profile and role.

### Unauthenticated
No active session or session invalidated.

### AuthError
Authentication failed. Contains:
- `message`: Descriptive error message
- `isBlocked`: Whether sign-in is blocked
- `blockedSecondsRemaining`: Countdown timer (if blocked)

## Lockout Logic

**Validates: Requirements 1.3, 1.5**

The BLoC implements a 30-second lockout after 3 consecutive failed sign-in attempts:

1. **Failed Attempt Counter**: Increments on each failure (AC 1.3)
2. **Lockout Trigger**: After 3 failures, activates 30-second block (AC 1.5)
3. **Block Timer**: Disables sign-in button for 30 seconds
4. **Countdown Timer**: Updates UI every second with remaining time
5. **Auto-Reset**: Clears counter and unlocks after 30 seconds
6. **Success Reset**: Clears counter on successful sign-in

## Session Validation

**Validates: Requirements 1.6, 1.7, 1.8**

The BLoC validates sessions using two criteria:

1. **JWT Validity**: Token must not be expired (AC 1.8)
2. **Background Time**: Must be < 12 hours (AC 1.7)

If either condition fails, the session is invalidated and the user is signed out.

## Background Timeout

**Validates: Requirements 1.7**

When the app is in background for > 12 hours:
1. `BackgroundTimeoutExceeded` event is dispatched
2. `SignOutUseCase` executes to remove JWT
3. `Unauthenticated` state is emitted
4. User must re-authenticate

## Usage Example

```dart
// In a widget
BlocProvider(
  create: (context) => sl<AuthBloc>()
    ..add(const SessionChecked(backgroundTimeMs: 0)),
  child: BlocConsumer<AuthBloc, AuthState>(
    listener: (context, state) {
      if (state is Authenticated) {
        // Navigate to role selection or home
      } else if (state is Unauthenticated) {
        // Navigate to login
      } else if (state is AuthError) {
        if (state.isBlocked) {
          // Show lockout message with countdown
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      }
    },
    builder: (context, state) {
      if (state is AuthLoading) {
        return const CircularProgressIndicator();
      }
      
      if (state is AuthError && state.isBlocked) {
        return ElevatedButton(
          onPressed: null, // Disabled
          child: Text('Bloqueado (${state.blockedSecondsRemaining}s)'),
        );
      }
      
      return ElevatedButton(
        onPressed: () {
          context.read<AuthBloc>().add(const SignInRequested());
        },
        child: const Text('Iniciar sesión con Google'),
      );
    },
  ),
)
```

## Testing

Tests are located in `test/presentation/blocs/auth/auth_bloc_test.dart` and cover:

- Initial state verification
- Successful sign-in flow
- Failed sign-in with counter
- Lockout after 3 attempts
- Successful sign-out
- Session validation (valid/invalid)
- Background timeout

Run tests:
```bash
flutter test test/presentation/blocs/auth/auth_bloc_test.dart
```

## Dependencies

The AuthBloc depends on three use cases from the domain layer:

- `SignInUseCase` - Handles Google Sign-In flow
- `SignOutUseCase` - Removes JWT and clears data
- `CheckSessionUseCase` - Validates JWT and background time

All dependencies are injected via the DI container (`get_it`).

## Clean Architecture Compliance

✅ **Presentation Layer Only** - BLoC lives in `lib/presentation/blocs/`
✅ **Domain Use Cases** - Only calls domain layer use cases
✅ **No Direct Repository Access** - Follows dependency inversion
✅ **Pure Domain Entities** - Uses `User` entity from domain layer
✅ **Error Handling** - Maps `Failure` types to user-friendly messages

## Notes

- The BLoC automatically cancels all timers on `close()` to prevent memory leaks
- The failed attempts counter resets on successful sign-in OR after lockout expires
- The lockout countdown updates the state every second for UI feedback
- Background timeout requires external lifecycle monitoring to dispatch the event
