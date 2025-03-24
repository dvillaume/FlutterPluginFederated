import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:siprix_voip_sdk/subscriptions_model.dart';
import 'subscr_add.dart';
import 'subscr_model_app.dart';

class SubscrListPage extends StatefulWidget {
  const SubscrListPage({super.key});

  @override
  State<SubscrListPage> createState() => _SubscrListPageState();
}

enum SubscrAction { delete, add }

class _SubscrListPageState extends State<SubscrListPage> {
  // Couleurs principales de l'application
  static const Color primaryColor = Color(0xFF2A3990);
  static const Color accentColor = Color(0xFF4481EB);
  static const Color backgroundColor = Color(0xFFF5F7FA);
  static const Color cardColor = Colors.white;
  static const Color textColor = Color(0xFF333333);
  static const Color subtitleColor = Color(0xFF677294);

  @override
  Widget build(BuildContext context) {
    final subscriptions = context.watch<SubscriptionsModel>();

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.grid_view,
                    color: primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Supervision BLF",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 24),
              subscriptions.length > 0
                  ? Expanded(
                      child: ListView.separated(
                        scrollDirection: Axis.vertical,
                        itemCount: subscriptions.length,
                        itemBuilder: (context, index) =>
                            _buildSubscriptionCard(subscriptions, index),
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                      ),
                    )
                  : _buildEmptySubscriptionsList(),
            ],
          ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: const LinearGradient(
                colors: [primaryColor, accentColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _addSubscription,
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
        ),
      ],
    );
  }

  Widget _buildEmptySubscriptionsList() {
    return Expanded(
      child: Center(
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
                    color: primaryColor.withOpacity(0.15),
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
                        color: primaryColor.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Icon(
                      Icons.grid_view,
                      size: 48,
                      color: primaryColor.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              "Aucune supervision BLF",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Ajoutez des supervisions BLF pour surveiller\nl'état des postes",
              style: TextStyle(
                fontSize: 14,
                color: subtitleColor,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard(SubscriptionsModel subscriptions, int index) {
    if (subscriptions[index] is! AppBlfSubscrModel) {
      SubscriptionModel subscr = subscriptions[index];
      return Text(subscr.label, style: Theme.of(context).textTheme.titleSmall);
    }

    AppBlfSubscrModel blfSubscr = subscriptions[index] as AppBlfSubscrModel;
    return ListenableBuilder(
      listenable: blfSubscr,
      builder: (BuildContext context, Widget? child) {
        return Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _getSubscrIcon(blfSubscr.state, blfSubscr.blfState),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${blfSubscr.label} (${blfSubscr.toExt})',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${blfSubscr.blfState}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: subtitleColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      _subscrListTileMenu(index),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _getSubscrIcon(SubscriptionState s, BLFState blfState) {
    Color color = (s == SubscriptionState.destroyed)
        ? Colors.grey
        : (blfState == BLFState.terminated) || (blfState == BLFState.unknown)
            ? Colors.green
            : Colors.red;
    bool blinking = (blfState == BLFState.early);

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: blinking
          ? const AnimatedContactIcon()
          : Icon(
              Icons.account_circle,
              color: color,
              size: 24,
            ),
    );
  }

  PopupMenuButton<SubscrAction> _subscrListTileMenu(int index) {
    return PopupMenuButton<SubscrAction>(
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.more_vert,
          color: primaryColor,
        ),
      ),
      onSelected: (SubscrAction action) {
        _doSubscriptionAction(action, index);
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<SubscrAction>(
          value: SubscrAction.delete,
          height: 48,
          child: Row(
            children: [
              Icon(
                Icons.delete_outline,
                size: 20,
                color: Colors.red,
              ),
              const SizedBox(width: 12),
              Text(
                'Supprimer',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _addSubscription() {
    Navigator.of(context).pushNamed(SubscrAddPage.routeName);
  }

  void _doSubscriptionAction(SubscrAction action, int index) {
    context
        .read<SubscriptionsModel>()
        .deleteSubscription(index)
        .catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.red.shade800,
          margin: const EdgeInsets.all(16),
        ),
      );
    });
  }
}

class AnimatedContactIcon extends StatefulWidget {
  const AnimatedContactIcon({super.key});

  @override
  State<AnimatedContactIcon> createState() => _AnimatedContactIconState();
}

class _AnimatedContactIconState extends State<AnimatedContactIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: const Icon(
        Icons.account_circle,
        color: Colors.orange,
        size: 24,
      ),
    );
  }
}
