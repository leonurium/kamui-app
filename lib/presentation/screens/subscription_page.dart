import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kamui_app/presentation/blocs/subscription/subscription_bloc.dart';
import 'package:kamui_app/presentation/blocs/subscription/subscription_event.dart';
import 'package:kamui_app/presentation/blocs/subscription/subscription_state.dart';

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SubscriptionBloc()..add(LoadProductsEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Premium Subscription'),
          centerTitle: true,
        ),
        body: BlocBuilder<SubscriptionBloc, SubscriptionState>(
          builder: (context, state) {
            if (state is SubscriptionLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SubscriptionLoaded) {
              return _buildSubscriptionList(context, state);
            } else if (state is SubscriptionError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text('No subscription plans available'));
          },
        ),
      ),
    );
  }

  Widget _buildSubscriptionList(BuildContext context, SubscriptionLoaded state) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.products.length,
      itemBuilder: (context, index) {
        final product = state.products[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            title: Text(product.title),
            subtitle: Text(product.description),
            trailing: Text(
              product.rawPrice.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            onTap: () {
              context.read<SubscriptionBloc>().add(
                    PurchaseProductEvent(product.id),
                  );
            },
          ),
        );
      },
    );
  }
} 