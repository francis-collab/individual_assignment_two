import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../services/listing_service.dart';
import '../../models/listing_model.dart';

part 'listing_event.dart';
part 'listing_state.dart';

class ListingBloc extends Bloc<ListingEvent, ListingState> {
  final ListingService _service;

  ListingBloc(this._service) : super(ListingInitial()) {
    on<LoadListings>(_onLoadListings);
    on<CreateListingEvent>(_onCreateListing);
    on<UpdateListingEvent>(_onUpdateListing);
    on<DeleteListingEvent>(_onDeleteListing);
    on<SearchListingsEvent>(_onSearchListings);
  }

  Future<void> _onLoadListings(
    LoadListings event,
    Emitter<ListingState> emit,
  ) async {
    emit(ListingLoading());

    try {
      Stream<List<Listing>> stream;
      if (event.isMyListings && event.uid != null) {
        stream = _service.getMyListings(event.uid!);
      } else {
        stream = _service.getAllListings();
      }
      emit(ListingLoaded(stream));
    } catch (e) {
      emit(ListingError('Failed to load listings: $e'));
    }
  }

  Future<void> _onCreateListing(
    CreateListingEvent event,
    Emitter<ListingState> emit,
  ) async {
    try {
      await _service.createListing(event.listing);
      // Reload after create (use creator's UID)
      add(LoadListings(isMyListings: true, uid: event.listing.createdBy));
    } catch (e) {
      emit(ListingError('Create failed: $e'));
    }
  }

  Future<void> _onUpdateListing(
    UpdateListingEvent event,
    Emitter<ListingState> emit,
  ) async {
    try {
      await _service.updateListing(event.id, event.listing);
      add(LoadListings(isMyListings: true, uid: event.listing.createdBy));
    } catch (e) {
      emit(ListingError('Update failed: $e'));
    }
  }

  Future<void> _onDeleteListing(
    DeleteListingEvent event,
    Emitter<ListingState> emit,
  ) async {
    try {
      await _service.deleteListing(event.id);
      // Reload using the uid from the event
      if (event.uid != null) {
        add(LoadListings(isMyListings: true, uid: event.uid!));
      } else {
        add(LoadListings());
      }
    } catch (e) {
      emit(ListingError('Delete failed: $e'));
    }
  }

  Future<void> _onSearchListings(
    SearchListingsEvent event,
    Emitter<ListingState> emit,
  ) async {
    emit(ListingLoading());

    try {
      // Get base stream (all listings)
      Stream<List<Listing>> baseStream = _service.getAllListings();

      // Apply category filter if selected
      if (event.category != null && event.category!.isNotEmpty) {
        baseStream = baseStream.map(
          (listings) => listings.where((l) => l.category == event.category).toList(),
        );
      }

      // Apply name search filter (client-side)
      if (event.query.isNotEmpty) {
        final lowerQuery = event.query.toLowerCase();
        baseStream = baseStream.map(
          (listings) => listings.where((l) => l.name.toLowerCase().contains(lowerQuery)).toList(),
        );
      }

      emit(ListingLoaded(baseStream));
    } catch (e) {
      emit(ListingError('Search failed: $e'));
    }
  }
}