part of 'listing_bloc.dart';

@immutable
abstract class ListingState {}

class ListingInitial extends ListingState {}

class ListingLoading extends ListingState {}

class ListingLoaded extends ListingState {
  final Stream<List<Listing>> listingsStream;
  ListingLoaded(this.listingsStream);
}

class ListingError extends ListingState {
  final String message;
  ListingError(this.message);
}