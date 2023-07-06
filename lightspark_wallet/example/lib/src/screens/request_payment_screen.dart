import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lightspark_wallet/lightspark_wallet.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../model/lightspark_client_notifier.dart';
import '../utils/lce.dart';

sealed class RequestPaymentEvent {}

class RequestPaymentStart implements RequestPaymentEvent {}

class AddAmountTapped implements RequestPaymentEvent {}

class AmountSubmitted implements RequestPaymentEvent {
  final int amountSats;

  AmountSubmitted(this.amountSats);
}

class CopyTapped implements RequestPaymentEvent {}

class ShareTapped implements RequestPaymentEvent {}

class RequestPaymentState extends Equatable {
  final String encodedInvoice;
  final int amountSats;
  final bool onAmountEntryScreen;

  const RequestPaymentState(
    this.encodedInvoice,
    this.amountSats, {
    this.onAmountEntryScreen = false,
  });

  @override
  List<Object?> get props => [encodedInvoice, amountSats, onAmountEntryScreen];
}

class RequestPaymentBloc
    extends Bloc<RequestPaymentEvent, Lce<RequestPaymentState>> {
  final LightsparkWalletClient client;
  RequestPaymentBloc(this.client) : super(Lce.loading()) {
    on<RequestPaymentStart>((event, emit) async {
      final invoice = await client.createInvoice(0);
      emit(Lce.content(RequestPaymentState(invoice.encodedPaymentRequest, 0)));
    });

    on<AddAmountTapped>((event, emit) {
      state.maybeMap(content: (state) {
        emit(Lce.content(RequestPaymentState(
          state.encodedInvoice,
          state.amountSats,
          onAmountEntryScreen: true,
        )));
      });
    });

    on<AmountSubmitted>((event, emit) async {
      emit(Lce.loading());
      final invoice = await client.createInvoice(event.amountSats);
      emit(Lce.content(RequestPaymentState(
        invoice.encodedPaymentRequest,
        event.amountSats,
        onAmountEntryScreen: false,
      )));
    });

    on<CopyTapped>((event, emit) {
      state.maybeMap(content: (state) {
        Clipboard.setData(ClipboardData(text: state.encodedInvoice));
      });
    });

    on<ShareTapped>((event, emit) {
      state.withData((state) => Share.share(state.encodedInvoice));
    });
  }
}

class RequestPaymentScreen extends StatelessWidget {
  static const routeName = '/request_payment';

  const RequestPaymentScreen({super.key});

  static Route route() {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Request Payment')),
        body: Center(
          child: BlocProvider(
            create: (context) => RequestPaymentBloc(
              Provider.of<LightsparkClientNotifier>(
                context,
                listen: false,
              ).value,
            )..add(RequestPaymentStart()),
            child: const RequestPaymentScreen(),
          ),
        ),
      ),
      settings: const RouteSettings(name: routeName),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RequestPaymentBloc, Lce<RequestPaymentState>>(
        builder: (context, lce) {
      return lce.maybeMap(content: (state) {
        return state.onAmountEntryScreen
            ? AmountEntryScreen(
                onAmountSubmitted: (amountSats) {
                  context
                      .read<RequestPaymentBloc>()
                      .add(AmountSubmitted(amountSats));
                },
              )
            : InvoiceScreen(
                state.encodedInvoice,
                state.amountSats,
              );
      }, loading: () {
        return const CircularProgressIndicator();
      }, error: (error) {
        return Text(error.toString());
      })!;
    });
  }
}

class InvoiceScreen extends StatelessWidget {
  final String encodedInvoice;
  final int amountSats;

  const InvoiceScreen(this.encodedInvoice, this.amountSats, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              QrImageView(data: encodedInvoice, size: 200),
              Text(encodedInvoice.truncateMiddle(14)),
              const SizedBox(height: 8),
              if (amountSats > 0) ...[
                Text(
                  '$amountSats sats',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
              ],
              OutlinedButton(
                onPressed: () {
                  context.read<RequestPaymentBloc>().add(AddAmountTapped());
                },
                child: Text(amountSats == 0 ? 'Add Amount' : 'Change Amount'),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton.icon(
              onPressed: () {
                context.read<RequestPaymentBloc>().add(ShareTapped());
              },
              style: FilledButton.styleFrom().copyWith(
                minimumSize: MaterialStateProperty.all(const Size(150, 48)),
              ),
              icon: const Icon(Icons.share_outlined, size: 12),
              label: const Text('Share'),
            ),
            const SizedBox(width: 24),
            FilledButton.icon(
              style: FilledButton.styleFrom().copyWith(
                minimumSize: MaterialStateProperty.all(const Size(150, 48)),
              ),
              onPressed: () {
                context.read<RequestPaymentBloc>().add(CopyTapped());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copied to clipboard')),
                );
              },
              icon: const Icon(Icons.copy, size: 12),
              label: const Text('Copy'),
            ),
          ],
        )
      ],
    );
  }
}

extension on String {
  String truncateMiddle(int length) {
    if (length >= this.length) {
      return this;
    }
    final left = substring(0, length ~/ 2);
    final right = substring(this.length - length ~/ 2);
    return '$left...$right';
  }
}

class AmountEntryScreen extends StatefulWidget {
  final void Function(int amountSats) onAmountSubmitted;

  const AmountEntryScreen({Key? key, required this.onAmountSubmitted})
      : super(key: key);

  @override
  AmountEntryScreenState createState() => AmountEntryScreenState();
}

class AmountEntryScreenState extends State<AmountEntryScreen> {
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _amountController,
            decoration: const InputDecoration(
              labelText: 'Amount',
              hintText: 'Enter amount in sats',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              final amount = int.tryParse(_amountController.text.trim()) ?? 0;
              widget.onAmountSubmitted(amount);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
