part of 'listing_bloc.dart';

@immutable
abstract class ListingEvent {}

class LoadListings extends ListingEvent {
  final bool isMyListings;
  final String? uid;

  LoadListings({this.isMyListings = false, this.uid});
}

class CreateListingEvent extends ListingEvent {
  final Listing listing;

  CreateListingEvent(this.listing);
}

class UpdateListingEvent extends ListingEvent {
  final String id;
  final Listing listing;

  UpdateListingEvent(this.id, this.listing);
}

class DeleteListingEvent extends ListingEvent {
  final String id;
  final String? uid; // Added to reload My Listings correctly

  DeleteListingEvent(this.id, {this.uid});
}

class SearchListingsEvent extends ListingEvent {
  final String query;
  final String? category;

  SearchListingsEvent(this.query, this.category);
}