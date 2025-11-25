import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:watch_it/watch_it.dart';

import '../../../app/routes/params/room_view_param.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_sizes.dart';
import '../../../core/themes/app_text_style.dart';
import '../../../data/models/user/user_model.dart';
import '../../view_model/room_view_model.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/app_progress_indicator.dart';
import '../../widgets/app_text_field.dart';
import '../home/widgets/profile_photo.dart';

class RoomView extends StatefulWidget with WatchItStatefulWidgetMixin {
  final RoomViewParam param;

  const RoomView({super.key, required this.param});

  @override
  RoomViewState createState() => RoomViewState();
}

class RoomViewState extends State<RoomView> {
  final model = di<RoomViewModel>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppDialog.showProgress(() async {
        await model.init(widget.param);
      });
    });
  }

  @override
  void dispose() {
    model.resetStates();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSizes.padding),
        child: Column(
          children: [
            const AppLogo(),
            const SizedBox(height: AppSizes.padding),
            AppSizes.screenWidth(context) > 1080 ? _DesktopView() : _MobileView(),
          ],
        ),
      ),
    );
  }
}

class _DesktopView extends StatelessWidget {
  const _DesktopView();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.screenHeight(context) - 100,
      constraints: BoxConstraints(maxHeight: 1200),
      child: Row(
        children: [
          Expanded(flex: 4, child: const _LocalVideoWidget()),
          const SizedBox(width: AppSizes.padding),
          Expanded(flex: 4, child: const _RemoteVideoWidget()),
          const SizedBox(width: AppSizes.padding),
          Expanded(flex: 2, child: _ChatWidget()),
        ],
      ),
    );
  }
}

class _MobileView extends StatelessWidget {
  const _MobileView();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.screenWidth(context),
      height: AppSizes.screenHeight(context),
      constraints: BoxConstraints(minHeight: 1200),
      child: const Column(
        children: [
          Expanded(child: _LocalVideoWidget()),
          SizedBox(height: AppSizes.padding),
          Expanded(child: _RemoteVideoWidget()),
          SizedBox(height: AppSizes.padding),
          Expanded(child: _ChatWidget()),
        ],
      ),
    );
  }
}

class _LocalVideoWidget extends StatelessWidget with WatchItMixin {
  const _LocalVideoWidget();

  @override
  Widget build(BuildContext context) {
    final model = watch(di<RoomViewModel>());

    final user = model.user;
    final localVideoEnabled = model.localVideoEnabled;
    final localAudioEnabled = model.localAudioEnabled;
    final localStream = model.localStream;
    final renderVideo = model.localStream.renderVideo;
    final localObjectFit = model.localObjectFit;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: AppColors.blackLv3),
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radius),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 56,
              padding: const EdgeInsets.fromLTRB(
                AppSizes.padding / 1.5,
                AppSizes.padding / 1.5,
                AppSizes.padding,
                AppSizes.padding / 1.5,
              ),
              decoration: const BoxDecoration(
                color: AppColors.blackLv5,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ProfilePhoto(
                        size: 36,
                        imgUrl: user?.imageUrl,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${user?.name ?? 'Loading...'} (You)',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.bold(size: 16),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          child: Container(
                            color: Colors.transparent,
                            child: Icon(
                              localVideoEnabled ? Icons.videocam_outlined : Icons.videocam_off_outlined,
                              color: localVideoEnabled ? AppColors.blackLv1 : AppColors.redLv1,
                              size: 24,
                            ),
                          ),
                          onTap: () {
                            model.localAudioVideoController('video', !localVideoEnabled);
                          },
                        ),
                      ),
                      const SizedBox(width: 18),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          child: Container(
                            color: Colors.transparent,
                            child: Icon(
                              localAudioEnabled ? Icons.mic_none_outlined : Icons.mic_off_outlined,
                              color: localAudioEnabled ? AppColors.blackLv1 : AppColors.redLv1,
                              size: 24,
                            ),
                          ),
                          onTap: () {
                            model.localAudioVideoController('audio', !localAudioEnabled);
                          },
                        ),
                      ),
                      const SizedBox(width: 18),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          child: Container(
                            color: Colors.transparent,
                            child: Icon(
                              localObjectFit == RTCVideoViewObjectFit.RTCVideoViewObjectFitContain
                                  ? Icons.fit_screen_outlined
                                  : Icons.fit_screen_rounded,
                              color: AppColors.blackLv1,
                              size: 24,
                            ),
                          ),
                          onTap: () {
                            model.onTapLocalVideoFit();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.black,
                child: renderVideo
                    ? localVideoEnabled
                          ? RTCVideoView(
                              localStream,
                              objectFit: localObjectFit,
                              placeholderBuilder: (context) => _WaitingPlaceholder(),
                            )
                          : Center(
                              child: Icon(
                                Icons.videocam_off_outlined,
                                color: AppColors.redLv2,
                                size: 100,
                              ),
                            )
                    : AppProgressIndicator(
                        color: AppColors.white,
                        textColor: AppColors.white,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RemoteVideoWidget extends StatelessWidget with WatchItMixin {
  const _RemoteVideoWidget();

  @override
  Widget build(BuildContext context) {
    final model = watch(di<RoomViewModel>());

    final user = model.user;
    final opponentUser = model.opponentUser;
    final remoteVideoEnabled = model.remoteVideoEnabled;
    final remoteAudioEnabled = model.remoteAudioEnabled;
    final remoteStream = model.remoteStream;
    final renderVideo = model.localStream.renderVideo;
    final remoteObjectFit = model.remoteObjectFit;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: AppColors.blackLv3),
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radius),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 56,
              padding: EdgeInsets.fromLTRB(
                !remoteStream.renderVideo ? AppSizes.padding : AppSizes.padding / 1.5,
                AppSizes.padding / 1.5,
                AppSizes.padding,
                AppSizes.padding / 1.5,
              ),
              decoration: const BoxDecoration(
                color: AppColors.blackLv5,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: !remoteStream.renderVideo
                    ? [
                        Text(
                          'Waiting ${user?.role == UserRole.client ? 'Counselor' : 'Client'} to join the room...',
                          style: AppTextStyle.bold(
                            size: 14,
                            color: AppColors.blackLv1,
                          ),
                        ),
                      ]
                    : [
                        Row(
                          children: [
                            ProfilePhoto(
                              size: 36,
                              imgUrl: opponentUser?.imageUrl,
                            ),
                            const SizedBox(width: 12),
                            Row(
                              children: [
                                Text(
                                  opponentUser?.name ?? '(No name)',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyle.bold(size: 16),
                                ),
                                const SizedBox(width: 8),
                                if (!remoteAudioEnabled)
                                  Icon(
                                    Icons.mic_off,
                                    color: AppColors.redLv2,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ],
                        ),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            child: Container(
                              color: Colors.transparent,
                              child: Icon(
                                remoteObjectFit == RTCVideoViewObjectFit.RTCVideoViewObjectFitContain
                                    ? Icons.fit_screen_outlined
                                    : Icons.fit_screen_rounded,
                                color: AppColors.blackLv1,
                                size: 24,
                              ),
                            ),
                            onTap: () {
                              model.onTapRemoteVideoFit();
                            },
                          ),
                        ),
                      ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.black,
                child: renderVideo
                    ? remoteVideoEnabled
                          ? RTCVideoView(
                              remoteStream,
                              objectFit: remoteObjectFit,
                              placeholderBuilder: (context) => _WaitingPlaceholder(),
                            )
                          : Center(
                              child: Icon(
                                Icons.videocam_off_outlined,
                                color: AppColors.redLv2,
                                size: 100,
                              ),
                            )
                    : AppProgressIndicator(
                        color: AppColors.white,
                        textColor: AppColors.white,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaitingPlaceholder extends StatelessWidget {
  const _WaitingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Waiting...',
        style: AppTextStyle.bold(
          size: 14,
          color: AppColors.white,
        ),
      ),
    );
  }
}

class _ChatWidget extends StatefulWidget with WatchItStatefulWidgetMixin {
  const _ChatWidget();

  @override
  State<_ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<_ChatWidget> {
  final scrollController = ScrollController();
  final chatController = TextEditingController();

  @override
  void dispose() {
    scrollController.dispose();
    chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = watch(di<RoomViewModel>());

    final user = model.user;
    final chats = model.chats;

    callAfterEveryBuild(
      (context, cancel) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.decelerate,
        );
      },
    );

    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: AppColors.blackLv3),
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radius),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 56,
              padding: const EdgeInsets.all(AppSizes.padding),
              decoration: const BoxDecoration(
                color: AppColors.blackLv5,
                border: Border(
                  bottom: BorderSide(width: 1, color: AppColors.blackLv4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.message_outlined,
                    color: AppColors.blackLv1,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Chats',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.bold(
                      size: 16,
                      color: AppColors.blackLv1,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: AppColors.white,
                child: Column(
                  children: [
                    Expanded(
                      child: SizedBox(
                        width: double.infinity,
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: const EdgeInsets.all(AppSizes.padding / 1.5),
                          child: Column(
                            children: [
                              ...List.generate(
                                chats.length,
                                (i) => _ChatBubble(
                                  isMe: chats[i].userId == user?.id,
                                  message: chats[i].message ?? '',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppColors.blackLv6,
                        border: Border(
                          top: BorderSide(width: 1, color: AppColors.blackLv4),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: chatController,
                              hintText: 'Write message...',
                              showBorder: false,
                              minLines: 1,
                              maxLines: 3,
                              fillColor: AppColors.blackLv6,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (val) {
                                model.onSubmitChat(chatController.text);
                                chatController.clear();
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              child: Container(
                                color: Colors.transparent,
                                child: const Icon(
                                  Icons.send,
                                  color: AppColors.blackLv1,
                                  size: 26,
                                ),
                              ),
                              onTap: () async {
                                if (chatController.text.isEmpty) return;
                                chatController.clear();
                                await model.onSubmitChat(chatController.text);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.isMe,
    required this.message,
  });

  final bool isMe;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: isMe ? const EdgeInsets.only(left: 40) : const EdgeInsets.only(right: 40),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          decoration: BoxDecoration(
            color: isMe ? AppColors.blackLv4 : AppColors.blackLv5,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(message, style: AppTextStyle.semibold(size: 14)),
        ),
      ),
    );
  }
}
