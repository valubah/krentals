# Car Booking Feature Module

This module implements the car listing, details, and booking flow for the K Rentals application.

## 1. State Management Approach
For this module, I utilized **Bloc (flutter_bloc)**.
- **Why Bloc?** Bloc enforces a strict separation of concerns, clearly delineating events (user actions) from state (UI representations). For a booking flow with multiple discrete states (date selection, date validation, payment loading, success/failure), Bloc makes it straightforward to model these distinct stages and gracefully handle failures (e.g. `BookingPaymentFailed` state preserving the booking object).
- It also scales exceptionally well for complex business logic, allowing us to write exhaustive tests for the `BookingBloc` (which was also done) easily by tracking event-to-state transitions.

## 2. Integrating a Real Payment Gateway
In a production app, integrating a payment gateway like Paystack or Stripe would involve:
- **Backend:** The app should not process payments directly natively. Instead, when the user taps "Pay", the app would request a `client_secret` or an `access_code` from the backend, passing the booking details (amount, car id).
- **Client SDK:** Using the official Flutter SDK provided by the gateway (e.g., `flutter_stripe`), the app would initialize the payment sheet using the retrieved token/secret.
- **Webhooks:** Upon successful local SDK completion, the app would wait for our backend to confirm via a webhook from the payment provider that funds were successfully captured before transitioning the UI to the "Payment Successful" screen.

## 3. Handling Booking Conflicts (Backend)
To prevent double bookings (conflicts), the backend should implement robust concurrency control:
- **Database Locks / Transactions:** When a user initiates a booking and payment, the backend should use row-level locking or optimistic concurrency control (e.g., a version column or checking overlap during insertion via a serialized transaction) on the car's calendar. 
- **Temporary Holds:** When the user proceeds to the payment screen, the backend can place a short-lived "hold" (e.g., 10 minutes) on the selected dates. If the payment succeeds, the hold becomes a confirmed booking. If the hold expires or the payment fails, the dates are released for others.

## 4. Scaling heavily (100k+ Users)
If scaling to 100k+ users, I would refactor:
- **Pagination & Caching:** Implement infinite scrolling/pagination for the car list module rather than loading all cars at once. Use a robust caching strategy (e.g., Redis on the backend, and local DB like Hive/Isar on the frontend) to reduce latency and database load.
- **CQRS / Specialized Search Services:** Use a dedicated indexing engine (like Elasticsearch or Algolia) to power the "Search & Filter" APIs instead of querying the primary relational database, as reading available cars filtered by dates can be very computationally expensive.
- **WebSockets / Server-Sent Events:** For the payment states, replace polling or client-side delays with real-time push notifications or WebSockets so the client is notified precisely when the backend registers payment success.
