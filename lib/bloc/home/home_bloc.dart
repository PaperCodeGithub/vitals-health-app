import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/apis.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final List<String> _medicalFacts = [
    "Your heart pumps 2,000 gallons of blood daily.",
    "Your blood vessels could circle the globe 4 times.",
    "The cornea gets oxygen directly from the air.",
    "Your brain operates on 15 watts of power.",
  ];

  HomeBloc() : super(HomeLoading()) {
    on<FetchProfileEvent>(_onFetchProfile);
    on<ToggleEmergencyEvent>(_onToggleEmergency);
  }

  Future<void> _onFetchProfile(FetchProfileEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      final DocumentSnapshot snapshot = await DatabaseService.instance.getProfile();
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data() as Map<String, dynamic>;

        final randomFact = _medicalFacts[Random().nextInt(_medicalFacts.length)];

        emit(HomeLoaded(
          userName: data['name']?.split(' ')[0] ?? "User",
          bloodGroup: data['bloodGroup']?.isNotEmpty == true ? data['bloodGroup'] : "-",
          weight: data['weight']?.isNotEmpty == true ? data['weight'] : "-",
          height: data['height']?.isNotEmpty == true ? data['height'] : "-",
          gender: data['gender'] ?? "-",
          isEmergency: data['emergency'] ?? false,
          dailyFact: randomFact,
        ));
      } else {
        emit(HomeError("Profile data not found."));
      }
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> _onToggleEmergency(ToggleEmergencyEvent event, Emitter<HomeState> emit) async {
    if (state is! HomeLoaded) return;

    final currentState = state as HomeLoaded;
    final newStatus = !event.currentStatus;

    emit(HomeLoaded(
      userName: currentState.userName,
      bloodGroup: currentState.bloodGroup,
      weight: currentState.weight,
      height: currentState.height,
      gender: currentState.gender,
      isEmergency: newStatus,
      dailyFact: currentState.dailyFact,
    ));

    try {


    } catch (e) {
      emit(HomeLoaded(
        userName: currentState.userName,
        bloodGroup: currentState.bloodGroup,
        weight: currentState.weight,
        height: currentState.height,
        gender: currentState.gender,
        isEmergency: event.currentStatus,
        dailyFact: currentState.dailyFact,
      ));

    }
  }
}