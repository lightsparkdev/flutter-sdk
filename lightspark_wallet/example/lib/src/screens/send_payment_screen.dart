import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lightspark_wallet/lightspark_wallet.dart';
import 'package:lightspark_wallet_example/src/utils/currency.dart';
import 'package:provider/provider.dart';

import '../model/lightspark_client_notifier.dart';

class SendPaymentScreen extends StatefulWidget {
  const SendPaymentScreen({super.key});

  static Route route() {
    return MaterialPageRoute(
      builder: (context) => const SendPaymentScreen(),
      settings: const RouteSettings(name: 'send_payment'),
    );
  }

  @override
  SendPaymentScreenState createState() => SendPaymentScreenState();
}

enum _PAYMENT_STATUS {
  NOT_STARTED,
  SUCCESS,
  FAILURE,
  PENDING,
}

class SendPaymentScreenState extends State<SendPaymentScreen> {
  final _invoiceController = TextEditingController();
  InvoiceData? _decodedInvoice;
  String? _errorMessage;
  bool _isLoading = false;
  _PAYMENT_STATUS _paymentStatus = _PAYMENT_STATUS.NOT_STARTED;

  void _resetState() {
    setState(() {
      _decodedInvoice = null;
      _errorMessage = null;
      _isLoading = false;
      _paymentStatus = _PAYMENT_STATUS.NOT_STARTED;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send payment'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _decodedInvoice == null
              ? _buildEncodedInvoiceInput()
              : _buildDecodedInvoice(),
    );
  }

  Widget _buildEncodedInvoiceInput() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _invoiceController,
            decoration: const InputDecoration(labelText: 'Encoded invoice'),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () async {
              final client = context.read<LightsparkClientNotifier>().value;
              try {
                setState(() {
                  _decodedInvoice = null;
                  _errorMessage = null;
                  _isLoading = true;
                });
                final decodedInvoice =
                    await client.decodeInvoice(_invoiceController.text.trim());
                setState(() {
                  _decodedInvoice = decodedInvoice;
                  _errorMessage = null;
                  _isLoading = false;
                });
              } catch (e) {
                setState(() {
                  _errorMessage = 'Failed to decode the invoice. Try again.';
                  _isLoading = false;
                });
              }
            },
            child: const Text('Decode invoice'),
          ),
        ],
      ),
    );
  }

  Widget _buildDecodedInvoice() {
    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LabeledText(
            label: 'Amount',
            text: _decodedInvoice!.amount.originalUnit
                .toAbbreviatedValue(_decodedInvoice!.amount.originalValue),
          ),
          const SizedBox(height: 8),
          LabeledText(
            label: 'Created at',
            text: DateFormat('MMM dd, hh:mma').format(
              DateTime.parse(_decodedInvoice!.createdAt).toLocal(),
            ),
          ),
          LabeledText(
            label: 'Expires at',
            text: DateFormat('MMM dd, hh:mma').format(
              DateTime.parse(_decodedInvoice!.expiresAt).toLocal(),
            ),
          ),
          const SizedBox(height: 8),
          if (_decodedInvoice!.memo?.isNotEmpty == true)
            LabeledText(
              label: 'Memo',
              text: _decodedInvoice!.memo!,
            ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () async {
              final client = context.read<LightsparkClientNotifier>().value;
              try {
                setState(() {
                  _errorMessage = null;
                  _isLoading = true;
                  _paymentStatus = _PAYMENT_STATUS.PENDING;
                });
                final amount =
                    _decodedInvoice!.amount; // TODO: add manual amount input.
                final maxFeesMsats =
                    amount.originalUnit.toSats(amount.originalValue) *
                        0.0017 *
                        1000;
                final payment = await client.payInvoiceAndAwaitResult(
                  _decodedInvoice!.encodedPaymentRequest,
                  maxFeesMsats.ceil(),
                );
                setState(() {
                  _decodedInvoice = null;
                  _errorMessage = null;
                  _isLoading = false;
                  _paymentStatus = payment.status == TransactionStatus.SUCCESS
                      ? _PAYMENT_STATUS.SUCCESS
                      : _PAYMENT_STATUS.FAILURE;
                });
              } catch (e) {
                print(e);
                setState(() {
                  _errorMessage = 'Failed to pay the invoice. Try again.';
                  _isLoading = false;
                  _paymentStatus = _PAYMENT_STATUS.FAILURE;
                });
              }
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
