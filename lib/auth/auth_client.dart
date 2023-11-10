import "package:oauth2_client/oauth2_client.dart";
import "package:smolaton/settings.dart";

class AuthClient extends OAuth2Client {
  AuthClient()
      : super(
            customUriScheme: kCustomUriScheme,
            redirectUri: "$kCustomUriScheme:/oauth2",
            tokenUrl:
                "https://auth.umom.pro/realms/umom-realm/protocol/openid-connect/token",
            authorizeUrl:
                "https://auth.umom.pro/realms/umom-realm/protocol/openid-connect/auth");
}
