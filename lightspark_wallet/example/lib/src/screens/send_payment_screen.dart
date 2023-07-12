import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lightspark_wallet/lightspark_wallet.dart';
import 'package:lightspark_wallet_example/src/utils/currency.dart';
import 'package:lightspark_wallet_example/src/utils/lce.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../model/lightspark_client_notifier.dart';

class SendPaymentScreen extends StatelessWidget {
  const SendPaymentScreen({super.key});

  static Route route() {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Send Payment')),
        body: Center(
          child: BlocProvider(
            create: (context) => SendPaymentBloc(
              Provider.of<LightsparkClientNotifier>(
                context,
                listen: false,
              ).value,
            ),
            child: const SendPaymentScreen(),
          ),
        ),
      ),
      settings: const RouteSettings(name: 'send_payment'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SendPaymentBloc, Lce<SendPaymentState>>(
        builder: (context, lce) {
      return lce.maybeMap(content: (state) {
        return state.paymentStatus == PaymentStatus.NOT_STARTED
            ? (state.decodedInvoice == null
                ? const _InvoiceEntryScreen()
                : _ConfirmInvoiceScreen())
            : state.paymentStatus == PaymentStatus.SUCCESS
                ? _PaymentSuccessScreen()
                : state.paymentStatus == PaymentStatus.FAILURE
                    ? _PaymentFailedScreen()
                    : _ConfirmInvoiceScreen();
      }, loading: () {
        return const CircularProgressIndicator();
      }, error: (error) {
        return Text(error.toString());
      })!;
    });
  }
}

enum PaymentStatus {
  NOT_STARTED,
  SUCCESS,
  FAILURE,
  PENDING,
}

sealed class SendPaymentScreenEvent {}

class DecodeInvoiceEvent extends SendPaymentScreenEvent {
  final String invoice;

  DecodeInvoiceEvent(this.invoice);
}

class SendPaymentEvent extends SendPaymentScreenEvent {}

class ResetEvent extends SendPaymentScreenEvent {}

class SendPaymentState extends Equatable {
  final InvoiceData? decodedInvoice;
  final String? errorMessage;
  final PaymentStatus paymentStatus;

  const SendPaymentState({
    this.decodedInvoice,
    this.errorMessage,
    this.paymentStatus = PaymentStatus.NOT_STARTED,
  });

  factory SendPaymentState.initial() => const SendPaymentState();

  @override
  List<Object?> get props => [
        decodedInvoice,
        errorMessage,
        paymentStatus,
      ];
}

class SendPaymentBloc
    extends Bloc<SendPaymentScreenEvent, Lce<SendPaymentState>> {
  final LightsparkWalletClient client;

  SendPaymentBloc(this.client)
      : super(Lce.content(SendPaymentState.initial())) {
    on<DecodeInvoiceEvent>((event, emit) async {
      emit(Lce.loading());
      try {
        final decodedInvoice = await client.decodeInvoice(event.invoice);
        emit(Lce.content(SendPaymentState(decodedInvoice: decodedInvoice)));
      } catch (e) {
        emit(Lce.content(const SendPaymentState(
          errorMessage: 'Failed to decode the invoice. Try again.',
        )));
      }
    });

    on<SendPaymentEvent>((event, emit) async {
      await state.maybeMap(content: (state) async {
        try {
          emit(Lce.loading());
          final payment = await client.payInvoiceAndAwaitResult(
            state.decodedInvoice!.encodedPaymentRequest,
            100000,
          );
          emit(Lce.content(SendPaymentState(
            decodedInvoice: state.decodedInvoice,
            paymentStatus: payment.status == TransactionStatus.SUCCESS
                ? PaymentStatus.SUCCESS
                : PaymentStatus.FAILURE,
            errorMessage: payment.status == TransactionStatus.FAILED
                ? 'Failed to send the payment. Try again.'
                : null,
          )));
        } catch (e) {
          emit(Lce.content(SendPaymentState(
            decodedInvoice: state.decodedInvoice,
            paymentStatus: PaymentStatus.FAILURE,
            errorMessage: 'Failed to send the payment. Try again.',
          )));
        }
      });
    });

    on<ResetEvent>((event, emit) {
      emit(Lce.content(SendPaymentState.initial()));
    });
  }
}

class _InvoiceEntryScreen extends StatefulWidget {
  const _InvoiceEntryScreen();

  @override
  _InvoiceEntryScreenState createState() => _InvoiceEntryScreenState();
}

class _InvoiceEntryScreenState extends State<_InvoiceEntryScreen> {
  final _invoiceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Scan a QR code or enter an encoded invoice below',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          SizedBox(
            height: 200,
            width: 200,
            child: MobileScanner(onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              final encodedInvoice = barcodes.first.rawValue ?? '';
              _invoiceController.text = encodedInvoice;
              _onDecodeRequested();
            }),
          ),
          TextField(
            controller: _invoiceController,
            decoration: const InputDecoration(labelText: 'Encoded invoice'),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _onDecodeRequested,
            child: const Text('Decode invoice'),
          ),
        ],
      ),
    );
  }

  void _onDecodeRequested() {
    context
        .read<SendPaymentBloc>()
        .add(DecodeInvoiceEvent(_invoiceController.text.trim()));
  }
}

class _PaymentSuccessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 48,
          ),
          const SizedBox(height: 24),
          const Text('Payment sent successfully!'),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              context.read<SendPaymentBloc>().add(ResetEvent());
            },
            child: const Text('Send another payment'),
          ),
        ],
      ),
    );
  }
}

class _PaymentFailedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 24),
          const Text('Failed to send the payment. Try again.'),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              context.read<SendPaymentBloc>().add(ResetEvent());
            },
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}

class _ConfirmInvoiceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state =
        context.watch<SendPaymentBloc>().state.withData((data) => data);
    if (state == null || state.decodedInvoice == null) {
      return const CircularProgressIndicator();
    }
    final decodedInvoice = state.decodedInvoice!;
    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LabeledText(
            label: 'Amount',
            text: decodedInvoice.amount.originalUnit
                .toAbbreviatedValue(decodedInvoice.amount.originalValue),
          ),
          const SizedBox(height: 8),
          LabeledText(
            label: 'Created at',
            text: DateFormat('MMM dd, hh:mma').format(
              DateTime.parse(decodedInvoice.createdAt).toLocal(),
            ),
          ),
          LabeledText(
            label: 'Expires at',
            text: DateFormat('MMM dd, hh:mma').format(
              DateTime.parse(decodedInvoice.expiresAt).toLocal(),
            ),
          ),
          const SizedBox(height: 8),
          if (decodedInvoice.memo?.isNotEmpty == true)
            LabeledText(
              label: 'Memo',
              text: decodedInvoice.memo!,
            ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () async {
              context.read<SendPaymentBloc>().add(SendPaymentEvent());
            },
            child: const Text('Pay invoice'),
          ),
        ],
      ),
    );
  }
}

class LabeledText extends StatelessWidget {
  const LabeledText({
    required this.label,
    required this.text,
    super.key,
  });

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
