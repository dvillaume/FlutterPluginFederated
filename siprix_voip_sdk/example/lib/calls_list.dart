// ignore_for_file: unused_element

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:siprix_voip_sdk/siprix_voip_sdk.dart';
import 'package:siprix_voip_sdk/calls_model.dart';
import 'package:siprix_voip_sdk/devices_model.dart';
import 'package:siprix_voip_sdk/logs_model.dart';
import 'package:siprix_voip_sdk/video.dart';
import 'package:siprix_voip_sdk/cdrs_model.dart';

import 'calls_model_app.dart';
import 'accouns_model_app.dart';
import 'main.dart';
import 'dialer_widget.dart';

////////////////////////////////////////////////////////////////////////////////////////
//CallsListPage - represents list of calls

enum CallAction { accept, reject, switchTo, hangup, hold, redirect }

class CallsListPage extends StatefulWidget {
  const CallsListPage({super.key});

  @override
  State<CallsListPage> createState() => _CallsListPageState();
}

class _CallsListPageState extends State<CallsListPage>
    with SingleTickerProviderStateMixin {
  Timer? _callDurationTimer;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleDurationTimer(CallsModel calls) {
    if (calls.isEmpty) {
      _callDurationTimer?.cancel();
      _callDurationTimer = null;
    } else {
      if (_callDurationTimer != null) return;
      _callDurationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        calls.calcDuration();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final calls = context.watch<AppCallsModel>();
    final cdrs = context.watch<CdrsModel>();
    CallModel? switchedCall = calls.switchedCall();
    _toggleDurationTimer(calls);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF2A3990),
            unselectedLabelColor: const Color(0xFF677294),
            indicatorColor: const Color(0xFF2A3990),
            tabs: const [
              Tab(text: 'Appels en cours'),
              Tab(text: 'Historique'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCurrentCallsTab(calls, switchedCall),
          _buildCallHistoryTab(cdrs),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [Color(0xFF2A3990), Color(0xFF4481EB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4481EB).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _showAddCallPage,
            borderRadius: BorderRadius.circular(30),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentCallsTab(AppCallsModel calls, CallModel? switchedCall) {
    if (calls.isEmpty) {
      return _buildEmptyCallsView();
    }

    return Column(
      children: [
        Expanded(
          child: Column(
            children: [
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(0.0),
                  itemCount: calls.length,
                  scrollDirection: Axis.vertical,
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(height: 1),
                  itemBuilder: (BuildContext context, int index) {
                    return ListenableBuilder(
                        listenable: calls[index],
                        builder: (BuildContext context, Widget? child) {
                          return _callModelRowTile(calls, index);
                        });
                  },
                ),
              ),
              const Divider(height: 1),
              if (switchedCall != null)
                Expanded(
                    child: SwitchedCallWidget(switchedCall,
                        key: ValueKey(switchedCall.myCallId))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCallHistoryTab(CdrsModel cdrs) {
    if (cdrs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2A3990).withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A3990).withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A3990).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Icon(
                      Icons.history,
                      size: 48,
                      color: const Color(0xFF2A3990).withOpacity(0.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              "Aucun appel dans l'historique",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: cdrs.length,
      itemBuilder: (context, index) {
        final cdr = cdrs[index];
        return ListTile(
          leading: Icon(
            cdr.incoming ? Icons.call_received : Icons.call_made,
            color: cdr.connected ? Colors.green : Colors.red,
          ),
          title: Text(
            cdr.displName.isEmpty ? cdr.remoteExt : cdr.displName,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(cdr.madeAtDate),
              if (cdr.connected) Text('Durée: ${cdr.duration}'),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (cdr.hasVideo) const Icon(Icons.videocam),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.call),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF2A3990),
                  foregroundColor: Colors.white,
                ),
                onPressed: () => _makeCallFromHistory(cdr),
              ),
            ],
          ),
        );
      },
    );
  }

  void _makeCallFromHistory(CdrModel cdr) {
    final accounts = context.read<AppAccountsModel>();
    if (accounts.selAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucun compte sélectionné'),
          backgroundColor: Color(0xFF2A3990),
        ),
      );
      return;
    }

    CallDestination dest =
        CallDestination(cdr.remoteExt, accounts.selAccountId!, cdr.hasVideo);
    context.read<AppCallsModel>().invite(dest).then((_) {
      // Basculer vers l'onglet des appels en cours
      _tabController.animateTo(0);
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$err'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  Widget _buildEmptyCallsView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2A3990).withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A3990).withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A3990).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Icon(
                    Icons.phone_outlined,
                    size: 48,
                    color: const Color(0xFF2A3990).withOpacity(0.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            "Aucun appel en cours",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Appuyez sur le bouton + pour\npasser un appel",
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF677294),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  ListTile _callModelRowTile(CallsModel calls, int index) {
    final call = calls[index];
    final bool isSwitched = (calls.switchedCallId == call.myCallId);

    return ListTile(
      selected: isSwitched,
      selectedColor: Colors.black,
      selectedTileColor: Theme.of(context).secondaryHeaderColor,
      leading: Icon(
        call.isIncoming ? Icons.call_received_rounded : Icons.call_made_rounded,
        size: 20,
      ),
      title: Text(call.nameAndExt,
          style: TextStyle(
            fontWeight: (isSwitched ? FontWeight.bold : FontWeight.normal),
            fontSize: 14,
          ),
          overflow: TextOverflow.ellipsis),
      subtitle: Text(
        call.state.name,
        style: const TextStyle(fontSize: 12),
      ),
      trailing: isSwitched
          ? null
          : IconButton(
              icon: const Icon(Icons.swap_calls_rounded, size: 20),
              onPressed: () {
                calls.switchToCall(call.myCallId);
              },
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
            ),
      dense: true,
      visualDensity: const VisualDensity(vertical: -4),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _noAccountsNotification() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A3990).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_circle_outlined,
              color: Color(0xFF2A3990),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Impossible de passer des appels",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Vous devez d'abord configurer un compte pour utiliser Octovia",
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF677294),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _navToAccountPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2A3990),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text("Ajouter un compte"),
          ),
        ],
      ),
    );
  }

  void _navToAccountPage() {
    // Naviguer vers l'onglet des comptes (index 0)
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
      // Accéder à HomePageState pour changer de tab
      final ScaffoldMessengerState scaffold = ScaffoldMessenger.of(context);
      scaffold.showSnackBar(
        SnackBar(
          content: const Text('Veuillez configurer un compte pour continuer'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: const Color(0xFF2A3990),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showAddCallPage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DialerWidget(
                  onCallPressed: (String number, bool isVideo) {
                    final accounts = context.read<AppAccountsModel>();
                    if (accounts.selAccountId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No account selected')),
                      );
                      return;
                    }
                    CallDestination dest = CallDestination(
                        number, accounts.selAccountId!, isVideo);
                    context
                        .read<AppCallsModel>()
                        .invite(dest)
                        .catchError((err) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text('$err')));
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} //CallsPage

////////////////////////////////////////////////////////////////////////////////////////
//SwitchedCallWidget - provides controls for manipulating current/switched call

class SwitchedCallWidget extends StatefulWidget {
  const SwitchedCallWidget(this.myCall, {super.key});
  final CallModel myCall;

  @override
  State<SwitchedCallWidget> createState() => _SwitchedCallWidgetState();
}

class _SwitchedCallWidgetState extends State<SwitchedCallWidget> {
  final SiprixVideoRenderer _localRenderer = SiprixVideoRenderer();
  final SiprixVideoRenderer _remoteRenderer = SiprixVideoRenderer();
  static const double eIconSize = 30;

  bool _sendDtmfMode = false;

  @override
  void initState() {
    super.initState();
    _localRenderer.init(
        SiprixVoipSdk.kLocalVideoCallId, context.read<LogsModel>());
    _remoteRenderer.init(widget.myCall.myCallId, context.read<LogsModel>());
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: widget.myCall,
        builder: (BuildContext context, Widget? child) {
          return Stack(children: [
            ..._buildVideoControls(),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildCallStateText(),
                    const SizedBox(height: 8),
                    _buildFromToText(),
                    const SizedBox(height: 8),
                    _buildCallDuration(),
                    const SizedBox(height: 16),
                    ..._buildCallControls(),
                    const SizedBox(height: 16),
                    if (widget.myCall.state == CallState.ringing)
                      _buildIncomingCallAcceptReject()
                    else
                      _buildHangupButton(),
                  ],
                ),
              ),
            ),
          ]);
        });
  }

  Text _buildCallStateText() {
    return Text(widget.myCall.nameAndExt,
        style: Theme.of(context).textTheme.titleLarge);
  }

  Widget _buildFromToText() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('State: ${widget.myCall.state.name}',
          style: Theme.of(context).textTheme.titleMedium),
      Text('Acc: ${widget.myCall.accUri}'),
      Text('CallId: ${widget.myCall.myCallId}'),
      if (widget.myCall.receivedDtmf.isNotEmpty)
        Text('DTMF: ${widget.myCall.receivedDtmf}'),
    ]);
  }

  List<Widget> _buildVideoControls() {
    List<Widget> children = [];
    if (widget.myCall.hasVideo) {
      //Received video
      children.add(Center(child: SiprixVideoView(_remoteRenderer)));

      //Camera preview
      children.add(SizedBox(
          width: 130, height: 100, child: SiprixVideoView(_localRenderer)));

      //Button 'Mute camera'
      children.add(IconButton(
          onPressed: _muteCam,
          iconSize: eIconSize,
          icon: Icon(widget.myCall.isCamMuted
              ? Icons.videocam_off_outlined
              : Icons.videocam_outlined)));
    }
    return children;
  }

  List<Widget> _buildCallControls() {
    List<Widget> children = [];

    if ((widget.myCall.state != CallState.connected) &&
        (widget.myCall.state != CallState.holding) &&
        (widget.myCall.state != CallState.held)) {
      return children;
    }

    if (_sendDtmfMode) {
      children.add(_buildSendDtmf());
      return children;
    }

    final bool isCallConnected = (widget.myCall.state == CallState.connected);

    children.add(Wrap(
        spacing: 25,
        runSpacing: 15,
        crossAxisAlignment: WrapCrossAlignment.start,
        children: [
          IconButton.filledTonal(
            iconSize: eIconSize,
            onPressed: _muteMic,
            icon: widget.myCall.isMicMuted
                ? const Icon(Icons.mic_off_rounded)
                : const Icon(Icons.mic_rounded),
          ),
          IconButton.filledTonal(
            iconSize: eIconSize,
            onPressed: isCallConnected ? _toggleSendDtmfMode : null,
            icon: const Icon(Icons.dialpad_rounded),
          ),
          MenuAnchor(
              builder: (BuildContext context, MenuController controller,
                  Widget? child) {
                return IconButton.filledTonal(
                    icon: const Icon(Icons.volume_up),
                    iconSize: eIconSize,
                    onPressed: () {
                      if (controller.isOpen) {
                        controller.close();
                      } else {
                        controller.open();
                      }
                    });
              },
              menuChildren: _buildPlayoutDevicesMenu())
        ]));

    children.add(const SizedBox(height: 10));

    children.add(Wrap(
        spacing: 25,
        runSpacing: 15,
        crossAxisAlignment: WrapCrossAlignment.start,
        children: [
          IconButton.filledTonal(
            iconSize: eIconSize,
            onPressed: _showAddCallPage,
            icon: const Icon(Icons.add),
          ),
          IconButton.filledTonal(
              iconSize: eIconSize,
              onPressed:
                  (widget.myCall.state == CallState.holding) ? null : _holdCall,
              icon: Icon(
                  widget.myCall.isLocalHold ? Icons.play_arrow : Icons.pause)),
          MenuAnchor(
              builder: (BuildContext context, MenuController controller,
                  Widget? child) {
                return IconButton.filledTonal(
                  icon: const Icon(Icons.more_horiz),
                  iconSize: eIconSize,
                  onPressed: () {
                    if (controller.isOpen) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                  },
                );
              },
              menuChildren: [
                MenuItemButton(
                    leadingIcon: const Icon(Icons.play_arrow),
                    onPressed: isCallConnected ? _playFile : null,
                    child: const Text('Play file')),
              ]),
        ]));

    return children;
  }

  Text _buildCallDuration() {
    String label;
    switch (widget.myCall.state) {
      case CallState.connected:
        label = widget.myCall.durationStr;
      case CallState.held:
        label = "On Hold (${widget.myCall.holdState.name})";
      default:
        label = "-:-";
    }
    return Text(label,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w600, color: Colors.green));
  }

  Widget _buildIncomingCallAcceptReject() {
    return Wrap(spacing: 50, runSpacing: 10, children: [
      IconButton.filledTonal(
        onPressed: _rejectCall,
        icon: const Icon(Icons.call_end),
        style: OutlinedButton.styleFrom(
            backgroundColor: Colors.red, foregroundColor: Colors.white),
      ),
      IconButton.filledTonal(
        onPressed: _acceptCall,
        icon: const Icon(Icons.call),
        style: OutlinedButton.styleFrom(
            backgroundColor: Colors.green, foregroundColor: Colors.white),
      )
    ]);
  }

  Widget _buildHangupButton() {
    final bool enabled = (widget.myCall.state != CallState.disconnecting);
    return IconButton.filledTonal(
        iconSize: eIconSize,
        icon: const Icon(Icons.call_end),
        style: OutlinedButton.styleFrom(
            backgroundColor: Colors.red, foregroundColor: Colors.white),
        onPressed: enabled ? _hangUpCall : null,
        color: Colors.red);
  }

  void showSnackBar(dynamic err) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
  }

  List<MenuItemButton> _buildPlayoutDevicesMenu() {
    final devices = context.watch<DevicesModel>();
    return [
      for (var dvc in devices.playout)
        MenuItemButton(
            onPressed: () {
              _setPlayoutDevice(dvc.index);
            },
            child: Text(dvc.name)),
    ];
  }

  void _setPlayoutDevice(int index) {
    final devices = context.read<DevicesModel>();
    devices.setPlayoutDevice(index).catchError(showSnackBar);
  }

  void _hangUpCall() {
    widget.myCall.bye().catchError(showSnackBar);
  }

  void _acceptCall() {
    widget.myCall.accept(widget.myCall.hasVideo).catchError(showSnackBar);
  }

  void _rejectCall() {
    widget.myCall.reject().catchError(showSnackBar);
  }

  void _sendDtmf(String tone) {
    widget.myCall.sendDtmf(tone).catchError(showSnackBar);
  }

  void _holdCall() {
    widget.myCall.hold().catchError(showSnackBar);
  }

  void _muteMic() {
    widget.myCall.muteMic(!widget.myCall.isMicMuted).catchError(showSnackBar);
  }

  void _muteCam() {
    widget.myCall.muteCam(!widget.myCall.isCamMuted).catchError(showSnackBar);
  }

  void _recordFile() async {
    if (widget.myCall.isRecStarted) {
      widget.myCall.stopRecordFile().catchError(showSnackBar);
    } else {
      String pathToFile =
          await MyApp.getRecFilePath("rec.wav"); //record to temp folder
      widget.myCall.recordFile(pathToFile).catchError(showSnackBar);
    }
  }

  void _playFile() async {
    String pathToFile = await MyApp.writeAssetAndGetFilePath(
        "music.mp3"); //write 'asset/music.mp3' to temp folder
    widget.myCall.playFile(pathToFile).catchError(showSnackBar);
  }

  void _makeConference() {
    final calls = context.read<AppCallsModel>();
    calls.makeConference().catchError(showSnackBar);
  }

  void _transferBlind(String ext) async {
    widget.myCall.transferBlind(ext).catchError(showSnackBar);
  }

  void _transferAttended(int? toCallId) async {
    if (toCallId == null) return;

    widget.myCall.transferAttended(toCallId).catchError(showSnackBar);
  }

  void _showAddCallPage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DialerWidget(
                  onCallPressed: (String number, bool isVideo) {
                    final accounts = context.read<AppAccountsModel>();
                    if (accounts.selAccountId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No account selected')),
                      );
                      return;
                    }
                    CallDestination dest = CallDestination(
                        number, accounts.selAccountId!, isVideo);
                    context
                        .read<AppCallsModel>()
                        .invite(dest)
                        .catchError((err) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text('$err')));
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _toggleSendDtmfMode() {
    setState(() => _sendDtmfMode = !_sendDtmfMode);
  }

  Widget _buildSendDtmf() {
    const double spacing = 8;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const SizedBox(
          height: spacing,
        ),
        Wrap(spacing: spacing, children: <Widget>[
          OutlinedButton(
              child: const Text('1'),
              onPressed: () {
                _sendDtmf("1");
              }),
          OutlinedButton(
              child: const Text('2'),
              onPressed: () {
                _sendDtmf("2");
              }),
          OutlinedButton(
              child: const Text('3'),
              onPressed: () {
                _sendDtmf("3");
              }),
        ]),
        const SizedBox(height: spacing),
        Wrap(spacing: spacing, children: <Widget>[
          OutlinedButton(
              child: const Text('4'),
              onPressed: () {
                _sendDtmf("4");
              }),
          OutlinedButton(
              child: const Text('5'),
              onPressed: () {
                _sendDtmf("5");
              }),
          OutlinedButton(
              child: const Text('6'),
              onPressed: () {
                _sendDtmf("6");
              }),
        ]),
        const SizedBox(height: spacing),
        Wrap(spacing: spacing, children: <Widget>[
          OutlinedButton(
              child: const Text('7'),
              onPressed: () {
                _sendDtmf("7");
              }),
          OutlinedButton(
              child: const Text('8'),
              onPressed: () {
                _sendDtmf("8");
              }),
          OutlinedButton(
              child: const Text('9'),
              onPressed: () {
                _sendDtmf("9");
              }),
        ]),
        const SizedBox(height: spacing),
        Wrap(spacing: spacing, children: <Widget>[
          OutlinedButton(
              child: const Text('*'),
              onPressed: () {
                _sendDtmf("*");
              }),
          OutlinedButton(
              child: const Text('0'),
              onPressed: () {
                _sendDtmf("0");
              }),
          OutlinedButton(
              child: const Text('#'),
              onPressed: () {
                _sendDtmf("#");
              }),
        ]),
        const SizedBox(height: spacing),
        IconButton.filledTonal(
            onPressed: _toggleSendDtmfMode, icon: const Icon(Icons.close)),
      ],
    );
  }
}//_CallsPageState