import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'google_auth_event.dart';
part 'google_auth_state.dart';

class GoogleAuthBloc extends Bloc<GoogleAuthEvent, GoogleAuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  GoogleAuthBloc() : super(AuthInitial()) {
    on<GoogleSignInRequested>((event, emit) async {
      log("GoogleSignInRequested");
      emit(GoogleAuthLoading());
      try {
        log("GoogleSignInAccount");
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        log("logedin");
        if (googleUser == null) {
          log("Unauthenticated");
          emit(Unauthenticated());
          return;
        }

        final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );


        final UserCredential userCredential =
        await _auth.signInWithCredential(credential);

        log("email: ${userCredential.user!.email}");
        log("uid: ${userCredential.user!.uid}");
        emit(Authenticated(userCredential.user!));
      } catch (e) {
        log("Failed to sign in with Google: $e");
        emit(AuthError("Failed to sign in with Google: $e"));
      }
    });

    on<SignOutRequested>((event, emit) async {
      await _googleSignIn.signOut();
      await _auth.signOut();
      emit(Unauthenticated());
    });
  }
}



