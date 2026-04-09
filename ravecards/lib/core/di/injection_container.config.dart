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
import 'package:http/http.dart' as _i519;
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
import 'package:ravecards/features/chat/data/repositories/chat_repository_impl.dart'
    as _i698;
import 'package:ravecards/features/chat/domain/repositories/chat_repository.dart'
    as _i190;
import 'package:ravecards/features/chat/domain/usecases/get_other_user_profile.dart'
    as _i966;
import 'package:ravecards/features/chat/domain/usecases/request_photo_view.dart'
    as _i611;
import 'package:ravecards/features/chat/domain/usecases/send_photo_message.dart'
    as _i1004;
import 'package:ravecards/features/chat/domain/usecases/send_text_message.dart'
    as _i90;
import 'package:ravecards/features/chat/domain/usecases/watch_messages.dart'
    as _i28;
import 'package:ravecards/features/chat/presentation/cubit/chat_cubit.dart'
    as _i58;
import 'package:ravecards/features/link/data/repositories/link_repository_impl.dart'
    as _i951;
import 'package:ravecards/features/link/domain/repositories/link_repository.dart'
    as _i184;
import 'package:ravecards/features/link/domain/usecases/watch_link.dart'
    as _i502;
import 'package:ravecards/features/link/domain/usecases/watch_my_links.dart'
    as _i843;
import 'package:ravecards/features/link/presentation/cubit/links_cubit.dart'
    as _i391;
import 'package:ravecards/features/memories/data/repositories/memory_repository_impl.dart'
    as _i1;
import 'package:ravecards/features/memories/domain/repositories/memory_repository.dart'
    as _i61;
import 'package:ravecards/features/memories/domain/usecases/watch_memories.dart'
    as _i297;
import 'package:ravecards/features/memories/presentation/cubit/memories_cubit.dart'
    as _i740;
import 'package:ravecards/features/moderation/data/repositories/moderation_repository_impl.dart'
    as _i501;
import 'package:ravecards/features/moderation/domain/repositories/moderation_repository.dart'
    as _i138;
import 'package:ravecards/features/moderation/domain/usecases/block_user.dart'
    as _i721;
import 'package:ravecards/features/moderation/domain/usecases/report_user.dart'
    as _i873;
import 'package:ravecards/features/moderation/domain/usecases/revoke_link.dart'
    as _i121;
import 'package:ravecards/features/scan/data/repositories/scan_repository_impl.dart'
    as _i679;
import 'package:ravecards/features/scan/domain/repositories/scan_repository.dart'
    as _i476;
import 'package:ravecards/features/scan/domain/usecases/confirm_link.dart'
    as _i397;
import 'package:ravecards/features/scan/domain/usecases/initiate_link.dart'
    as _i1030;
import 'package:ravecards/features/scan/domain/usecases/preview_card.dart'
    as _i718;
import 'package:ravecards/features/scan/domain/usecases/validate_qr_token.dart'
    as _i248;
import 'package:ravecards/features/scan/presentation/cubit/scan_cubit.dart'
    as _i707;

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
    gh.lazySingleton<_i519.Client>(() => firebaseModule.httpClient);
    gh.lazySingleton<_i138.ModerationRepository>(() =>
        _i501.ModerationRepositoryImpl(
            functions: gh<_i809.FirebaseFunctions>()));
    gh.lazySingleton<_i61.MemoryRepository>(() => _i1.MemoryRepositoryImpl(
          firestore: gh<_i974.FirebaseFirestore>(),
          auth: gh<_i59.FirebaseAuth>(),
        ));
    gh.lazySingleton<_i190.ChatRepository>(() => _i698.ChatRepositoryImpl(
          firestore: gh<_i974.FirebaseFirestore>(),
          auth: gh<_i59.FirebaseAuth>(),
          functions: gh<_i809.FirebaseFunctions>(),
          httpClient: gh<_i519.Client>(),
        ));
    gh.lazySingleton<_i184.LinkRepository>(
        () => _i951.LinkRepositoryImpl(gh<_i974.FirebaseFirestore>()));
    gh.lazySingleton<_i476.ScanRepository>(() => _i679.ScanRepositoryImpl(
          functions: gh<_i809.FirebaseFunctions>(),
          firestore: gh<_i974.FirebaseFirestore>(),
        ));
    gh.factory<_i502.WatchLink>(
        () => _i502.WatchLink(gh<_i184.LinkRepository>()));
    gh.factory<_i843.WatchMyLinks>(
        () => _i843.WatchMyLinks(gh<_i184.LinkRepository>()));
    gh.lazySingleton<_i969.AuthRepository>(() => _i838.AuthRepositoryImpl(
          firebaseAuth: gh<_i59.FirebaseAuth>(),
          firestore: gh<_i974.FirebaseFirestore>(),
          googleSignIn: gh<_i116.GoogleSignIn>(),
        ));
    gh.factory<_i721.BlockUser>(
        () => _i721.BlockUser(gh<_i138.ModerationRepository>()));
    gh.factory<_i873.ReportUser>(
        () => _i873.ReportUser(gh<_i138.ModerationRepository>()));
    gh.factory<_i121.RevokeLink>(
        () => _i121.RevokeLink(gh<_i138.ModerationRepository>()));
    gh.lazySingleton<_i816.CardRepository>(() => _i386.CardRepositoryImpl(
          firestore: gh<_i974.FirebaseFirestore>(),
          storage: gh<_i457.FirebaseStorage>(),
          functions: gh<_i809.FirebaseFunctions>(),
        ));
    gh.factory<_i966.GetOtherUserProfile>(
        () => _i966.GetOtherUserProfile(gh<_i190.ChatRepository>()));
    gh.factory<_i611.RequestPhotoView>(
        () => _i611.RequestPhotoView(gh<_i190.ChatRepository>()));
    gh.factory<_i1004.SendPhotoMessage>(
        () => _i1004.SendPhotoMessage(gh<_i190.ChatRepository>()));
    gh.factory<_i90.SendTextMessage>(
        () => _i90.SendTextMessage(gh<_i190.ChatRepository>()));
    gh.factory<_i28.WatchMessages>(
        () => _i28.WatchMessages(gh<_i190.ChatRepository>()));
    gh.factory<_i578.GetAuthState>(
        () => _i578.GetAuthState(gh<_i969.AuthRepository>()));
    gh.factory<_i86.SendOtp>(() => _i86.SendOtp(gh<_i969.AuthRepository>()));
    gh.factory<_i958.SignInWithGoogle>(
        () => _i958.SignInWithGoogle(gh<_i969.AuthRepository>()));
    gh.factory<_i798.SignOut>(() => _i798.SignOut(gh<_i969.AuthRepository>()));
    gh.factory<_i661.VerifyOtp>(
        () => _i661.VerifyOtp(gh<_i969.AuthRepository>()));
    gh.factory<_i58.ChatCubit>(() => _i58.ChatCubit(
          watchMessages: gh<_i28.WatchMessages>(),
          sendText: gh<_i90.SendTextMessage>(),
          sendPhoto: gh<_i1004.SendPhotoMessage>(),
          requestView: gh<_i611.RequestPhotoView>(),
          getOtherUserProfile: gh<_i966.GetOtherUserProfile>(),
          watchLink: gh<_i502.WatchLink>(),
          auth: gh<_i59.FirebaseAuth>(),
        ));
    gh.factory<_i297.WatchMemories>(
        () => _i297.WatchMemories(gh<_i61.MemoryRepository>()));
    gh.factory<_i397.ConfirmLink>(
        () => _i397.ConfirmLink(gh<_i476.ScanRepository>()));
    gh.factory<_i1030.InitiateLink>(
        () => _i1030.InitiateLink(gh<_i476.ScanRepository>()));
    gh.factory<_i718.PreviewCard>(
        () => _i718.PreviewCard(gh<_i476.ScanRepository>()));
    gh.factory<_i248.ValidateQrToken>(
        () => _i248.ValidateQrToken(gh<_i476.ScanRepository>()));
    gh.factory<_i391.LinksCubit>(
        () => _i391.LinksCubit(watchMyLinks: gh<_i843.WatchMyLinks>()));
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
    gh.factory<_i740.MemoriesCubit>(
        () => _i740.MemoriesCubit(watchMemories: gh<_i297.WatchMemories>()));
    gh.factory<_i707.ScanCubit>(() => _i707.ScanCubit(
          validateQrToken: gh<_i248.ValidateQrToken>(),
          previewCard: gh<_i718.PreviewCard>(),
          initiateLink: gh<_i1030.InitiateLink>(),
          confirmLink: gh<_i397.ConfirmLink>(),
          watchLink: gh<_i502.WatchLink>(),
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
