import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kamui_app/presentation/blocs/premium/premium_bloc.dart';
import 'package:kamui_app/domain/entities/package.dart';
import 'package:kamui_app/injection.dart' as di;
import 'package:in_app_purchase/in_app_purchase.dart';

class PremiumPage extends StatefulWidget {
  const PremiumPage({Key? key}) : super(key: key);

  @override
  _PremiumPageState createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  late PremiumBloc _premiumBloc;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  @override
  void initState() {
    super.initState();
    _premiumBloc = di.sl<PremiumBloc>()..add(LoadPackages());
  }

  @override
  void dispose() {
    _premiumBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _premiumBloc,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Premium Packages',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocConsumer<PremiumBloc, PremiumState>(
          listener: (context, state) {
            if (state is PremiumError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            } else if (state is PremiumPurchaseSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Purchase successful!'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            }
          },
          builder: (context, state) {
            if (state is PremiumLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is PremiumError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      state.message,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _premiumBloc.add(LoadPackages()),
                      child: Text('Retry'),
                    ),
                  ],
                ),
              );
            } else if (state is PremiumLoaded) {
              return _buildPackageList(context, state.packages);
            }
            return SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildPackageList(BuildContext context, List<Package> packages) {
    return Column(
      children: [
        SizedBox(height: 16),
        SizedBox(
          height: 500,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: packages.length,
            itemBuilder: (context, index) {
              final package = packages[index];
              return Container(
                width: 300,
                margin: EdgeInsets.only(right: 16),
                child: _PackageCard(
                  package: package,
                  onPurchase: () => _handlePurchase(package),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _handlePurchase(Package package) {
    _premiumBloc.add(PurchasePackage(
      packageId: package.id,
      purchaseToken: '', // This will be set by the repository
      platform: defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
    ));
  }
}

class _PackageCard extends StatelessWidget {
  final Package package;
  final VoidCallback onPurchase;

  const _PackageCard({
    Key? key,
    required this.package,
    required this.onPurchase,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: package.isPopular
            ? BorderSide(color: Color.fromRGBO(37, 112, 252, 1), width: 2)
            : BorderSide.none,
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (package.isPopular)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(37, 112, 252, 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Color.fromRGBO(37, 112, 252, 1), size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Most Popular',
                      style: TextStyle(
                        color: Color.fromRGBO(37, 112, 252, 1),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 16),
            Text(
              package.name,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              package.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 16),
            ...package.features.map((feature) => Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feature,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )),
            SizedBox(height: 16),
            if (package.discount > 0)
              Text(
                '${package.price.toStringAsFixed(2)} ${package.currency}',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                ),
              ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${package.priceAfterDiscount.toStringAsFixed(2)} ${package.currency}',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Color.fromRGBO(37, 112, 252, 1),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (package.discount > 0)
                      Text(
                        '${package.discount}% OFF',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                ElevatedButton(
                  onPressed: onPurchase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(37, 112, 252, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(
                    'Get Started',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 