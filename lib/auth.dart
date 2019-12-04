import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hasura_connect/hasura_connect.dart';

const String URL = "https://hasura-firebase.herokuapp.com/v1/graphql";

final GoogleSignIn _googleSignIn = GoogleSignIn();
final FirebaseAuth _auth = FirebaseAuth.instance;

Future<FirebaseUser> handleSignIn() async {
  final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

  final FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
  print("Logado como ${user.displayName}");
  IdTokenResult token = await user.getIdToken();
  print(user.uid);
  final HasuraConnect connection = HasuraConnect(URL, token: (isError) async {
    return "Bearer ${token.token}";
  });

  String query = """
    query {
      loved_language {
        name
      }
    }
  """;

  var data = await connection.query(query);
  print(data);
}
