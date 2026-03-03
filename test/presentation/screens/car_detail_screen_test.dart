import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:krentals/presentation/screens/car_detail_screen.dart';
import 'package:krentals/data/models/car_model.dart';
import 'package:krentals/presentation/blocs/booking/booking_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockBookingBloc extends Mock implements BookingBloc {}

void main() {
  late MockBookingBloc mockBookingBloc;

  setUp(() {
    mockBookingBloc = MockBookingBloc();
    when(() => mockBookingBloc.state).thenReturn(const BookingInitial());
  });

  final testCar = Car(
    id: 'test_car',
    name: 'Test Car',
    brand: 'Test Brand',
    pricePerDay: 100.0,
    location: 'Test Location',
    isAvailable: true,
    imageUrls: ['assets/images/cars/car_001_1.png'],
    description: 'Test Description',
    category: 'Test Category',
    seats: 5,
    transmission: 'Automatic',
    rating: 5.0,
    reviewCount: 10,
    features: ['Feature 1'],
    blockedDates: const [],
  );

  testWidgets('CarDetailScreen displays Hero and Image', (
    WidgetTester tester,
  ) async {
    // Set a large enough window size to ensure SliverAppBar is expanded
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<BookingBloc>.value(
          value: mockBookingBloc,
          child: CarDetailScreen(car: testCar),
        ),
      ),
    );

    // Pump multiple times to allow complex sliver layouts to settle
    for (int i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Verify CarDetailScreen is present
    expect(find.byType(CarDetailScreen), findsOneWidget);

    debugDumpApp();

    // Verify car name is present
    expect(find.text(testCar.name), findsOneWidget);

    // Verify Hero widget is present
    expect(find.byType(Hero), findsWidgets);

    // Check for any Image widget that uses our asset
    final assetImageFinder = find.byWidgetPredicate(
      (widget) =>
          widget is Image &&
          widget.image is AssetImage &&
          (widget.image as AssetImage).assetName == testCar.imageUrls.first,
    );
    expect(assetImageFinder, findsWidgets);
  });
}
