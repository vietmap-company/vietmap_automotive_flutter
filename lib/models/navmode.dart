// ignore_for_file: public_member_api_docs

///Option to specify the mode of transportation.
@Deprecated('Use MapNavigationMode instead')
enum NavigationMode { walking, cycling, driving, drivingWithTraffic }

///Option to specify the mode of transportation.
enum MapNavigationMode { walking, cycling, driving, drivingWithTraffic }

///Option to specify the mode of transportation.
enum DrivingProfile {
  drivingTraffic("driving-traffic"),
  cycling("cycling"),
  walking("walking"),
  motorcycle("motorcycle");

  final String stringValue;

  const DrivingProfile(this.stringValue);
}
