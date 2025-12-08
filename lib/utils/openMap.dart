import 'package:url_launcher/url_launcher.dart';

Future<void> openMap(double lat, double lng) async {
  final appUrl = Uri.parse("geo:$lat,$lng?q=$lat,$lng");
  final webUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");

  if (await canLaunchUrl(appUrl)) {
    await launchUrl(appUrl, mode: LaunchMode.externalApplication);
  } else if (await canLaunchUrl(webUrl)) {
    await launchUrl(webUrl, mode: LaunchMode.externalApplication);
  } else {
    throw Exception("No map applications available.");
  }
}