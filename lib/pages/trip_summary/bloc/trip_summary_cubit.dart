import 'package:bloc/bloc.dart';
import 'package:smart_car/app/blocs/global_bloc.dart';
import 'package:smart_car/pages/trip_summary/bloc/trip_summary_state.dart';
import 'package:smart_car/services/firestore_handler.dart';

class TripSummaryCubit extends Cubit<TripSummaryState> {
  TripSummaryCubit()
      : super(TripSummaryState(
          tankSize: GlobalBlocs.settings.state.settings.tankSize,
        )) {
    init();
  }

  Future<void> init() async {
    emit(state.copyWith(isLoading: true));
    final trips = await FirestoreHandler.fetchTripSummaries();
    if (isClosed) return;
    trips.sort((a, b) => a.startTripTime.compareTo(b.startTripTime));
    emit(state.copyWith(
      trips: trips,
      isLoading: false,
    ));
  }
}
