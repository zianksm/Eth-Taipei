import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:web3dart/web3dart.dart';
import 'package:wallet/wallet.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:typed_data';
import 'dart:convert'; // For utf8 encoding

class WebviewPage extends StatefulWidget {
  final String privateKey;

  const WebviewPage({super.key, required this.privateKey});

  @override
  State<WebviewPage> createState() => _WebviewPageState();
}

class _WebviewPageState extends State<WebviewPage> {
  InAppWebViewController? _webViewController;
  late Web3Client _client;
  late EthPrivateKey _credentials;

  @override
  void initState() {
    super.initState();
    final rpcUrl = dotenv.env['RPC_URL']!;
    _client = Web3Client(rpcUrl, http.Client());
    _credentials = EthPrivateKey.fromHex(widget.privateKey);
  }

  // Custom method to sign a personal message for web3dart 3.0.0
  String signPersonalMessage(EthPrivateKey credentials, String message) {
    // Ethereum personal message prefix
    final prefix = '\x19Ethereum Signed Message:\n${message.length}';
    final prefixedMessage = utf8.encode(prefix + message);
    final messageHash = keccak256(prefixedMessage);

    // Use signToEcSignature instead of sign (web3dart 3.0.0)
    final signature = credentials.signToEcSignature(Uint8List.fromList(messageHash));
    // Concatenate r, s, and v into a 65-byte signature
    final r = signature.r.toRadixString(16).padLeft(64, '0');
    final s = signature.s.toRadixString(16).padLeft(64, '0');
    final v = signature.v.toRadixString(16).padLeft(2, '0');
    final sigHex = '0x$r$s$v';
    print('Signature: $sigHex');
    return sigHex;
  }

  // JavaScript to inject a basic window.ethereum provider
  String getEthereumProviderScript() {
    final address = _credentials.address.toString();
    return '''
      (function() {
        const provider = {
          isMetaMask: true,
          selectedAddress: '$address',
          request: async (args) => {
            const method = args.method;
            if (method === 'eth_requestAccounts' || method === 'eth_accounts') {
              return ['$address'];
            } else if (method === 'eth_chainId') {
              return '0x${int.parse(dotenv.env['ChainID']!).toRadixString(16)}';
            } else if (method === 'personal_sign') {
              const message = args.params[0].startsWith('0x') ? 
                new TextDecoder().decode(Uint8Array.from(args.params[0].slice(2).match(/.{1,2}/g).map(byte => parseInt(byte, 16)))) 
                : args.params[0];
              const signature = await window.flutter_inappwebview.callHandler('signPersonalMessage', message);
              return signature;
            } else {
              return await window.flutter_inappwebview.callHandler('rpcCall', method, args.params || []);
            }
          },
          on: (event, callback) => {
            console.log('Event listener registered:', event);
          }
        };
        window.ethereum = provider;
        window.dispatchEvent(new Event('ethereum#initialized'));
      })();
    ''';
  }

  @override
  Widget build(BuildContext context) {
    final ensUrl = dotenv.env['ENS_URL'] ?? 'https://app.ens.domains';

    return Scaffold(
      appBar: AppBar(title: const Text('ENS Webview')),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(ensUrl)),
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            javaScriptEnabled: true,
            useShouldOverrideUrlLoading: true,
          ),
        ),
        onWebViewCreated: (controller) {
          _webViewController = controller;

          // Handler for personal_sign
          controller.addJavaScriptHandler(
            handlerName: 'signPersonalMessage',
            callback: (args) async {
              final message = args[0] as String;
              final signature = signPersonalMessage(_credentials, message);
              return signature;
            },
          );

          // Handler for generic RPC calls
          controller.addJavaScriptHandler(
            handlerName: 'rpcCall',
            callback: (args) async {
              final method = args[0] as String;
              final params = args[1] as List<dynamic>;
              try {
                if (method == 'eth_getBalance') {
                  final address = EthereumAddress.fromHex(params[0]);
                  final balance = await _client.getBalance(address);
                  return '0x${balance.getInWei.toRadixString(16)}';
                }
                return 'Method not implemented';
              } catch (e) {
                return 'Error: $e';
              }
            },
          );
        },
        onLoadStop: (controller, url) async {
          await controller.evaluateJavascript(source: getEthereumProviderScript());
        },
      ),
    );
  }
}