// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:cloud_functions/cloud_functions.dart' as _i809;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:firebase_storage/firebase_storage.dart' as _i457;
import 'package:get_it/get_it.dart' as _i174;
import 'package:google_sign_in/google_sign_in.dart' as _i116;
import 'package:injectable/injectable.dart' as _i526;
import 'package:ravecards/core/di/injection_container.dart' as _i23;
import 'package:ravecards/features/auth/data/repositories/auth_repository_impl.dart'
    as _i838;
import 'package:ravecards/features/auth/domain/repositories/auth_repository.dart'
    as _i969;
import 'package:ravecards/features/auth/domain/usecases/get_auth_state.dart'
    as _i578;
import 'package:ravecards/features/auth/domain/usecases/send_otp.dart' as _i86;
import 'package:ravecards/features/auth/domain/usecases/sign_in_with_google.dart'
    as _i958;
import 'package:ravecards/features/auth/domain/usecases/sign_out.dart' as _i798;
import 'package:ravecards/features/auth/domain/usecases/verify_otp.dart'
    as _i661;
import 'package:ravecards/features/auth/presentation/cubit/auth_cubit.dart'
    as _i511;
import 'package:ravecards/features/card/data/repositories/card_repository_impl.dart'
    as _i386;
import 'package:ravecards/features/card/domain/repositories/card_repository.dart'
    as _i816;
import 'package:ravecards/features/card/domain/usecases/create_card.dart'
    as _i933;
import 'package:ravecards/features/card/domain/usecases/get_card.dart' as _i642;
import 'package:ravecards/features/card/domain/usecases/refresh_qr_token.dart'
    as _i132;
import 'package:ravecards/features/card/presentation/cubit/card_cubit.dart'
    as _i759;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final firebaseModule = _$FirebaseModule();
    gh.lazySingleton<_i59.FirebaseAuth>(() => firebaseModule.firebaseAuth);
    gh.lazySingleton<_i974.FirebaseFirestore>(() => firebaseModule.firestore);
    gh.lazySingleton<_i457.FirebaseStorage>(() => firebaseModule.storage);
    gh.lazySingleton<_i809.FirebaseFunctions>(() => firebaseModule.functions);
    gh.lazySingleton<_i116.GoogleSignIn>(() => firebaseModule.googleSignIn);
    gh.lazySingleton<_i969.AuthRepository>(() => _i838.AuthRepositoryImpl(
          firebaseAuth: gh<_i59.FirebaseAuth>(),
          firestore: gh<_i974.FirebaseFirestore>(),
          googleSignIn: gh<_i116.GoogleSignIn>(),
        ));
    gh.lazySingleton<_i816.CardRepository>(() => _i386.CardRepositoryImpl(
          firestore: gh<_i974.FirebaseFirestore>(),
          storage: gh<_i457.FirebaseStorage>(),
          functions: gh<_i809.FirebaseFunctions>(),
        ));
    gh.factory<_i578.GetAuthState>(
        () => _i578.GetAuthState(gh<_i969.AuthRepository>()));
    gh.factory<_i86.SendOtp>(() => _i86.SendOtp(gh<_i969.AuthRepository>()));
    gh.factory<_i958.SignInWithGoogle>(
        () => _i958.SignInWithGoogle(gh<_i969.AuthRepository>()));
    gh.factory<_i798.SignOut>(() => _i798.SignOut(gh<_i969.AuthRepository>()));
    gh.factory<_i661.VerifyOtp>(
        () => _i661.VerifyOtp(gh<_i969.AuthRepository>()));
    gh.factory<_i933.CreateCard>(
        () => _i933.CreateCard(gh<_i816.CardRepository>()));
    gh.factory<_i642.GetCard>(() => _i642.GetCard(gh<_i816.CardRepository>()));
    gh.factory<_i132.RefreshQrToken>(
        () => _i132.RefreshQrToken(gh<_i816.CardRepository>()));
    gh.factory<_i511.AuthCubit>(() => _i511.AuthCubit(
          sendOtp: gh<_i86.SendOtp>(),
          verifyOtp: gh<_i661.VerifyOtp>(),
          signInWithGoogle: gh<_i958.SignInWithGoogle>(),
          signOut: gh<_i798.SignOut>(),
        ));
    gh.factory<_i759.CardCubit>(() => _i759.CardCubit(
          getCard: gh<_i642.GetCard>(),
          createCard: gh<_i933.CreateCard>(),
          refreshQrToken: gh<_i132.RefreshQrToken>(),
        ));
    return this;
  }
}

class _$FirebaseModule extends _i23.FirebaseModule {}
