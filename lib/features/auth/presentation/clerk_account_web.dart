import 'package:web/web.dart' as web;

const clerkAccountEnabled = bool.fromEnvironment('HADGALY_CLERK_ENABLED');

void openClerkAccount() => web.window.location.assign('/auth/index.html');
