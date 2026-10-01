/// Public developer contact from the store listing.
const String developerContactEmail = 'mike.busam@plate-pal.de';

/// A `mailto:` link to the developer; spaces stay `%20` for mail apps.
Uri feedbackMailUri(String subject) => Uri(
  scheme: 'mailto',
  path: developerContactEmail,
  query: 'subject=${Uri.encodeComponent(subject)}',
);
