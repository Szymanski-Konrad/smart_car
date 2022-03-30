import 'package:bloc/bloc.dart';
import 'package:smart_car/pages/trip_summary/bloc/trip_summary_state.dart';
import 'package:smart_car/services/firestore_handler.dart';

class TripSummaryCubit extends Cubit<TripSummaryState> {
  TripSummaryCubit() : super(const TripSummaryState()) {
    init();
  }

  Future<void> init() async {
    final trips = await FirestoreHandler.fetchTripSummaries();
    if (isClosed) return;
    trips.sort((a, b) => b.startTripTime.compareTo(a.startTripTime));
    emit(state.copyWith(trips: trips));
  }
}
