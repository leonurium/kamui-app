import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kamui_app/presentation/blocs/subscription/subscription_bloc.dart';
import 'package:kamui_app/presentation/blocs/subscription/subscription_event.dart';
import 'package:kamui_app/presentation/blocs/subscription/subscription_state.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:kamui_app/domain/usecases/purchase_package_usecase.dart';
import 'package:get_it/get_it.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kamui_app/core/config/constants.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> with SingleTickerProviderStateMixin {
  late AnimationController _restoreButtonController;
  late Animation<double> _restoreButtonAnimation;

  @override
  void initState() {
    super.initState();
    _restoreButtonController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _restoreButtonAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _restoreButtonController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _restoreButtonController.dispose();
    super.dispose();
  }

  Future<void> _showRestoreConfirmationDialog(SubscriptionBloc subscriptionBloc) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.restore, color: Theme.of(context).colorScheme.primary),
              SizedBox(width: 8),
              Text('Restore Purchases'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This will restore your previous subscription if you have one.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'If you\'ve purchased on another device, make sure you\'re signed in with the same account.',
                        style: TextStyle(fontSize: 14, color: Colors.blue[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                subscriptionBloc.add(RestorePurchasesEvent());
              },
              icon: Icon(Icons.restore),
              label: Text('Restore Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF1A3055);
    final Color accentColor = const Color(0xFF7C4DFF);
    return BlocProvider(
      create: (context) => SubscriptionBloc(
        purchasePackageUseCase: GetIt.I<PurchasePackageUseCase>(),
      )..add(LoadProductsEvent()),
      child: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          final appName = snapshot.data?.appName ?? '';
          return BlocListener<SubscriptionBloc, SubscriptionState>(
            listener: (context, state) async {
              if (state is PurchaseSuccess) {
                // Show dialog first
                await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => AlertDialog(
                    title: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Success!'),
                      ],
                    ),
                    content: Text('Your purchase was successful! You are now a premium user.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog
                          Navigator.of(context).pop(true); // Return to home page with success
                        },
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
              } else if (state is PurchaseError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
                // Reload products after error
                context.read<SubscriptionBloc>().add(LoadProductsEvent());
              } else if (state is RestoreSuccess) {
                await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Restore Successful!'),
                      ],
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Your previous subscription has been restored successfully.'),
                        SizedBox(height: 16),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.verified_user, color: Colors.green),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'You now have access to all premium features.',
                                  style: TextStyle(color: Colors.green[700]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop(true);
                        },
                        child: Text('Continue'),
                      ),
                    ],
                  ),
                );
              } else if (state is RestoreError) {
                await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Restore Failed'),
                      ],
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(state.message),
                        SizedBox(height: 16),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.red),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Make sure you\'re signed in with the same account you used for the original purchase.',
                                  style: TextStyle(color: Colors.red[700]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Try Again'),
                      ),
                    ],
                  ),
                );
              }
            },
            child: Scaffold(
              backgroundColor: primaryColor,
              appBar: AppBar(
                centerTitle: true,
                backgroundColor: primaryColor,
                elevation: 0,
                title: Text(
                  'Premium',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  ScaleTransition(
                    scale: _restoreButtonAnimation,
                    child: TextButton.icon(
                      onPressed: () {
                        final subscriptionBloc = context.read<SubscriptionBloc>();
                        _showRestoreConfirmationDialog(subscriptionBloc);
                      },
                      icon: Icon(Icons.restore, color: Colors.white),
                      label: Text('Restore', style: TextStyle(color: Colors.white)),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              body: BlocBuilder<SubscriptionBloc, SubscriptionState>(
                builder: (context, state) {
                  if (state is SubscriptionLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    );
                  } else if (state is SubscriptionError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: Colors.red),
                          SizedBox(height: 16),
                          Text(
                            state.message,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => context.read<SubscriptionBloc>().add(LoadProductsEvent()),
                            child: Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  } else if (state is SubscriptionLoaded) {
                    return Stack(
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              // Header Section
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.verified_user, color: accentColor, size: 28),
                                        SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            'Unlock True Privacy',
                                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                            softWrap: true,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "Enjoy secure, private, and unrestricted internet access.",
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Colors.white70,
                                          ),
                                    ),
                                    SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Icon(Icons.history, color: accentColor, size: 20),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            "Already purchased?",
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Container(
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.restore, color: accentColor, size: 20),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              "Tap the Restore button above to recover your previous subscription",
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    color: Colors.white70,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Subscription Cards
                              _buildSubscriptionList(context, state, accentColor, appName),
                              // Feature Comparison
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                child: _FeatureComparison(),
                              ),
                              // Payment Methods
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.credit_card, color: Colors.white70),
                                  SizedBox(width: 8),
                                  Icon(Icons.account_balance_wallet, color: Colors.white70),
                                ],
                              ),
                              // FAQ Link
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                child: Center(
                                  child: TextButton(
                                    onPressed: () async {
                                      final Uri url = Uri.parse(Constants.faqUrl);
                                      if (await canLaunchUrl(url)) {
                                        await launchUrl(url);
                                      }
                                    },
                                    child: Text('FAQ', style: TextStyle(color: accentColor, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (state is PurchaseInProgress)
                          Container(
                            color: Colors.black54,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Processing purchase...',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Please wait while we process your payment',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubscriptionList(BuildContext context, SubscriptionLoaded state, Color accentColor, String appName) {
    return Column(
      children: [
        SizedBox(height: 16),
        SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.products.length,
            itemBuilder: (context, index) {
              final product = state.products[index];
              final cleanedTitle = state.cleanedTitles[index];
              return Container(
                width: 300,
                margin: EdgeInsets.only(right: 16),
                child: _SubscriptionCard(
                  product: product,
                  accentColor: accentColor,
                  isBestValue: index == state.products.length - 1, // Emphasize last (yearly) plan
                  cleanedTitle: cleanedTitle,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  final dynamic product; // Replace with your actual product type
  final Color accentColor;
  final bool isBestValue;
  final String cleanedTitle;

  const _SubscriptionCard({Key? key, required this.product, required this.accentColor, this.isBestValue = false, required this.cleanedTitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: isBestValue ? 8 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: isBestValue ? BorderSide(color: accentColor, width: 2) : BorderSide.none,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isBestValue)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Best Value',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            SizedBox(height: 8),
            Text(
              cleanedTitle,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8),
            Text(
              product.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 12),
            Text(
              product.price,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).textTheme.titleLarge!.color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: BlocBuilder<SubscriptionBloc, SubscriptionState>(
                builder: (context, state) {
                  final bool isPurchasing = state is PurchaseInProgress;
                  return ElevatedButton(
                    onPressed: isPurchasing ? null : () {
                      context.read<SubscriptionBloc>().add(
                        PurchaseProductEvent(product.id),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: isPurchasing
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Subscribe',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureComparison extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final features = [
      {'icon': Icons.block, 'text': 'No Ads'},
      {'icon': Icons.public, 'text': 'Global high-speed servers'},
      {'icon': Icons.lock_outline, 'text': 'No logs & full privacy'},
      {'icon': Icons.speed, 'text': 'Unlimited bandwidth'},
      {'icon': Icons.support_agent, 'text': '24/7 customer support'},
    ];
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('All plans include:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...features.map((f) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Icon(f['icon'] as IconData, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Text(f['text'] as String, style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
} 