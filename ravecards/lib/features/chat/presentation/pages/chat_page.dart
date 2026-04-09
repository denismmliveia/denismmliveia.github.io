import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_windowmanager_plus/flutter_windowmanager_plus.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../link/domain/entities/link_entity.dart';
import '../../../link/presentation/widgets/countdown_widget.dart';
import '../../../moderation/domain/usecases/revoke_link.dart';
import '../../../moderation/domain/usecases/block_user.dart';
import '../../../moderation/domain/usecases/report_user.dart';
import '../../domain/entities/message_entity.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_state.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/photo_bubble_widget.dart';
import '../widgets/text_bubble_widget.dart';

class ChatPage extends StatefulWidget {
  final String linkId;
  final LinkEntity link;

  const ChatPage({super.key, required this.linkId, required this.link});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _scrollController = ScrollController();

  String get _otherUid =>
      widget.link.userA == context.read<ChatCubit>().currentUid
          ? widget.link.userB
          : widget.link.userA;

  @override
  void initState() {
    super.initState();
    FlutterWindowManagerPlus.addFlags(FlutterWindowManagerPlus.FLAG_SECURE);
    context.read<ChatCubit>().init(widget.linkId, otherUid: _otherUid);
  }

  @override
  void dispose() {
    FlutterWindowManagerPlus.clearFlags(FlutterWindowManagerPlus.FLAG_SECURE);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _confirmRevoke(BuildContext context) async {
    final nav = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0D0020),
        title: const Text('Revocar vínculo',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          '¿Seguro? El chat y el vínculo desaparecerán para ambos.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => nav.pop(false),
            child: const Text('Cancelar',
                style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => nav.pop(true),
            child: const Text('Revocar',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final result = await sl<RevokeLink>().call(widget.linkId);
      if (mounted) {
        result.fold(
          (f) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(f.message),
                backgroundColor: AppColors.error),
          ),
          (_) => nav.pop(),
        );
      }
    }
  }

  Future<void> _confirmBlock(BuildContext context, String targetUid) async {
    final nav = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0D0020),
        title: const Text('Bloquear usuario',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'Esta persona no podrá verte ni escanearte. El vínculo actual también se revocará.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => nav.pop(false),
            child: const Text('Cancelar',
                style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => nav.pop(true),
            child: const Text('Bloquear',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final result = await sl<BlockUser>()
          .call(targetUid: targetUid, linkId: widget.linkId);
      if (mounted) {
        result.fold(
          (f) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(f.message),
                backgroundColor: AppColors.error),
          ),
          (_) => nav.pop(),
        );
      }
    }
  }

  Future<void> _showReportDialog(
      BuildContext context, String targetUid) async {
    final nav = Navigator.of(context);
    String? selectedReason;
    final reasons = ['Acoso', 'Contenido inapropiado', 'Spam', 'Otro'];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: const Color(0xFF0D0020),
          title: const Text('Reportar usuario',
              style: TextStyle(color: Colors.white)),
          content: RadioGroup<String>(
            groupValue: selectedReason,
            onChanged: (v) => setState(() => selectedReason = v),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: reasons
                  .map((r) => InkWell(
                        onTap: () => setState(() => selectedReason = r),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          child: Row(
                            children: [
                              Radio<String>(
                                value: r,
                                activeColor: AppColors.purple,
                              ),
                              Text(r,
                                  style: const TextStyle(
                                      color: Colors.white70)),
                            ],
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar',
                  style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: selectedReason == null
                  ? null
                  : () => Navigator.of(ctx).pop(true),
              child: const Text('Reportar',
                  style: TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      ),
    );
    if (confirmed == true && selectedReason != null && mounted) {
      final result = await sl<ReportUser>().call(
          targetUid: targetUid,
          reason: selectedReason!,
          linkId: widget.linkId);
      if (mounted) {
        result.fold(
          (f) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(f.message),
                backgroundColor: AppColors.error),
          ),
          (_) => nav.pop(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06000F),
      body: BlocConsumer<ChatCubit, ChatState>(
        listenWhen: (prev, curr) => prev.messages.length != curr.messages.length,
        listener: (_, __) => _scrollToBottom(),
        builder: (context, state) {
          final cubit = context.read<ChatCubit>();
          return Stack(
            children: [
              Column(
                children: [
                  _buildHeader(context, state),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      itemCount: state.messages.length,
                      itemBuilder: (_, index) {
                        final msg = state.messages[index];
                        final isOwn = msg.senderId == cubit.currentUid;
                        if (msg.type == MessageType.text) {
                          return TextBubbleWidget(
                              message: msg, isOwn: isOwn);
                        }
                        return PhotoBubbleWidget(
                          message: msg,
                          isOwn: isOwn,
                          currentUid: cubit.currentUid,
                          onHoldStart: () => cubit.requestPhotoView(
                              widget.linkId, msg.id),
                          onHoldEnd: cubit.dismissPhoto,
                        );
                      },
                    ),
                  ),
                  ChatInputBar(
                    enabled: !state.isLinkExpired,
                    onSendText: (text) => cubit.sendText(widget.linkId, text),
                    onSendPhoto: (bytes) =>
                        cubit.sendPhoto(widget.linkId, bytes),
                  ),
                ],
              ),
              if (state.actionStatus == ChatActionStatus.viewingPhoto &&
                  state.viewingPhotoUrl != null)
                _buildPhotoViewer(context, state.viewingPhotoUrl!),
              if (state.isLinkExpired) _buildExpiryOverlay(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ChatState state) {
    final expiresAt = widget.link.expiresAt;
    final otherUid = _otherUid;
    return SafeArea(
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0D0020),
          border: Border(
            bottom: BorderSide(
              color: const Color(0xFFB300FF).withValues(alpha: 0.3),
            ),
          ),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white70),
              onPressed: () => Navigator.of(context).pop(),
            ),
            if (state.otherUserPhotoUrl != null)
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(state.otherUserPhotoUrl!),
              )
            else
              const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFF6600CC),
                child: Icon(Icons.person, color: Colors.white, size: 18),
              ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                state.otherUserName ?? '…',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (expiresAt != null) CountdownWidget(expiresAt: expiresAt),
            if (!state.isLinkExpired)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white38),
                color: const Color(0xFF0D0020),
                onSelected: (value) {
                  if (value == 'revoke') _confirmRevoke(context);
                  if (value == 'block') _confirmBlock(context, otherUid);
                  if (value == 'report') _showReportDialog(context, otherUid);
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'revoke',
                    child: Text('Revocar vínculo',
                        style: TextStyle(color: Colors.white70)),
                  ),
                  PopupMenuItem(
                    value: 'block',
                    child: Text('Bloquear',
                        style: TextStyle(color: Colors.white70)),
                  ),
                  PopupMenuItem(
                    value: 'report',
                    child: Text('Reportar',
                        style: TextStyle(color: AppColors.error)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpiryOverlay(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.88),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Este vínculo ha expirado',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB300FF),
                ),
                onPressed: () =>
                    Navigator.of(context).popUntil((r) => r.isFirst),
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoViewer(BuildContext context, String photoUrl) {
    return GestureDetector(
      onTap: context.read<ChatCubit>().dismissPhoto,
      child: Container(
        color: Colors.black.withValues(alpha: 0.95),
        child: Center(
          child: Image.network(
            photoUrl,
            fit: BoxFit.contain,
            loadingBuilder: (_, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const CircularProgressIndicator(
                color: Color(0xFF39FF14),
              );
            },
          ),
        ),
      ),
    );
  }
}
