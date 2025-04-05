import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:web3dart/web3dart.dart';
import 'package:wallet/wallet.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'dart:typed_data';

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
  bool _isWalletConnected = false;
  late String chainId;

  @override
  void initState() {
    super.initState();
    final rpcUrl = dotenv.env['RPC_URL'] ?? 'https://eth-sepolia.public.blastapi.io';
    _client = Web3Client(rpcUrl, http.Client());
    _credentials = EthPrivateKey.fromHex(widget.privateKey);
    chainId = dotenv.env['CHAIN_ID'] ?? '11155111';
  }

  String signPersonalMessage(EthPrivateKey credentials, String message) {
    final prefix = '\x19Ethereum Signed Message:\n${message.length}';
    final prefixedMessage = utf8.encode(prefix + message);
    final messageHash = keccak256(prefixedMessage);
    final signature = credentials.signToEcSignature(Uint8List.fromList(messageHash));
    final r = signature.r.toRadixString(16).padLeft(64, '0');
    final s = signature.s.toRadixString(16).padLeft(64, '0');
    final v = (signature.v + 27).toRadixString(16).padLeft(2, '0');
    final sigHex = '0x$r$s$v';
    print('Signature: $sigHex');
    return sigHex;
  }

  Future<bool> _showConnectDialog() async {
    if (!mounted) return false;
    print('Showing connect dialog');
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Connect Wallet'),
        content: const Text('Do you want to connect your wallet to this website?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Connect'),
          ),
        ],
      ),
    );
    print('Dialog result: $result');
    return result ?? false;
  }

  String getEthereumProviderScript() {
    final address = '0x' + _credentials.address.toString(); // Should be 0x...
    final chainId = dotenv.env['CHAIN_ID'] ?? '11155111';
    final chainIdHex = '0x${int.parse(chainId).toRadixString(16)}';
    return '''
      (function() {
        if (window.ethereum) return;
        
        const provider = {
          isMetaMask: true,
          selectedAddress: $_isWalletConnected ? '$address' : null,
          chainId: '$chainIdHex',
          networkVersion: '$chainId',
          isConnected: () => $_isWalletConnected,
          enable: async () => {
            console.log('enable called');
            return provider.request({ method: 'eth_requestAccounts' });
          },
          request: async (args) => {
            console.log('Provider request:', JSON.stringify(args));
            const method = args.method;
            if (method === 'eth_requestAccounts') {
              const accounts = await window.flutter_inappwebview.callHandler('requestAccounts');
              console.log('Accounts received:', accounts);
              if (accounts && accounts.length > 0) {
                provider.selectedAddress = accounts[0];
                return accounts;
              }
              throw new Error('User rejected the request');
            } else if (method === 'eth_accounts') {
              console.log('eth_accounts called, returning:', provider.selectedAddress ? [provider.selectedAddress] : []);
              return provider.selectedAddress ? [provider.selectedAddress] : [];
            } else if (method === 'eth_chainId') {
              console.log('eth_chainId called, returning:', provider.chainId);
              return provider.chainId;
            } else if (method === 'personal_sign') {
              if (!provider.selectedAddress) throw new Error('Wallet not connected');
              const message = args.params[0].startsWith('0x') ? 
                new TextDecoder().decode(Uint8Array.from(args.params[0].slice(2).match(/.{1,2}/g).map(byte => parseInt(byte, 16)))) 
                : args.params[0];
              const signature = await window.flutter_inappwebview.callHandler('signPersonalMessage', message);
              return signature;
            } else {
              return await window.flutter_inappwebview.callHandler('rpcCall', method, args.params || []);
            }
          },
          on: (eventName, callback) => {
            if (eventName === 'accountsChanged') {
              window.accountsChangedCallback = callback;
            } else if (eventName === 'chainChanged') {
              window.chainChangedCallback = callback;
            }
            console.log('Event listener registered:', eventName);
          },
          emit: (eventName, ...args) => {
            if (eventName === 'accountsChanged' && window.accountsChangedCallback) {
              window.accountsChangedCallback(args[0]);
            } else if (eventName === 'chainChanged' && window.chainChangedCallback) {
              window.chainChangedCallback(args[0]);
            }
            console.log('Event emitted:', eventName, args);
          }
        };
        window.ethereum = provider;
        window.dispatchEvent(new Event('ethereum#initialized'));
        console.log('Ethereum provider injected:', JSON.stringify(provider));
      })();
    ''';
  }

  @override
  Widget build(BuildContext context) {
    final ensUrl = dotenv.env['ENS_URL'] ?? 'https://sepolia.app.ens.domains';

    return Scaffold(
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(ensUrl)),
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            javaScriptEnabled: true,
            useShouldOverrideUrlLoading: true,
            javaScriptCanOpenWindowsAutomatically: true,
          ),
        ),
        onWebViewCreated: (controller) async {
          _webViewController = controller;
          print('Webview created, injecting provider');
          await controller.evaluateJavascript(source: getEthereumProviderScript());

          controller.addJavaScriptHandler(
            handlerName: 'requestAccounts',
            callback: (args) async {
              print('requestAccounts called with args: $args');
              if (_isWalletConnected) {
                final address = '0x' + _credentials.address.toString();
                print('Returning connected address: $address');
                return [address];
              }
              final shouldConnect = await _showConnectDialog();
              if (shouldConnect) {
                setState(() => _isWalletConnected = true);
                final address = '0x' + _credentials.address.toString();
                print('Connected address: $address');
                await controller.evaluateJavascript(
                  source: "if (window.accountsChangedCallback) window.accountsChangedCallback(['$address']); window.ethereum.emit('accountsChanged', ['$address']);",
                );
                return [address];
              }
              return [];
            },
          );

          controller.addJavaScriptHandler(
            handlerName: 'signPersonalMessage',
            callback: (args) async {
              if (!_isWalletConnected) throw Exception('Wallet not connected');
              final message = args[0] as String;
              final signature = signPersonalMessage(_credentials, message);
              return signature;
            },
          );

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
                }else if (method == 'eth_getTransactionByHash') { // Added block starts here
                  final txHash = params[0] as String;
                  final transaction = await _client.getTransactionByHash(txHash);
                  if (transaction == null) {
                    return null; // Ethereum RPC returns null for non-existent transactions
                  }
                  return {
                    'hash': transaction.hash,
                    'from': transaction.from?.toString(),
                    'to': transaction.to?.toString(),
                    'value': '0x${transaction.value.getInWei.toRadixString(16)}',
                    'gas': '0x${transaction.gas?.toRadixString(16)}',
                    'gasPrice': '0x${transaction.gasPrice.getInWei.toRadixString(16)}',
                    'nonce': '0x${transaction.nonce.toRadixString(16)}',
                    'blockHash': transaction.blockHash,
                    'blockNumber': transaction.blockNumber != null ? '0x${(transaction.blockNumber as dynamic).toInt().toRadixString(16)}' : null,
                    'transactionIndex': transaction.transactionIndex != null ? '0x${transaction.transactionIndex!.toRadixString(16)}' : null,
                    'input': transaction.input != null ? '0x${bytesToHex(transaction.input!, include0x: false)}' : '0x',
                  }; // Added block ends here
                }else if (method == 'eth_sendTransaction') {
                  final tx = params[0] as Map<String, dynamic>;
                  final transaction = Transaction(
                    to: EthereumAddress.fromHex(tx['to']),
                    from: EthereumAddress.fromHex(tx['from']),
                    data: tx['data'] != null ? hexToBytes(tx['data']) : null,
                    gasPrice: tx['gasPrice'] != null ? EtherAmount.fromBigInt(EtherUnit.wei, BigInt.parse(tx['gasPrice'].substring(2), radix: 16)) : null,
                    maxGas: tx['gas'] != null ? int.parse(tx['gas'].substring(2), radix: 16) : null,
                    maxFeePerGas: tx['maxFeePerGas'] != null ? EtherAmount.fromBigInt(EtherUnit.wei, BigInt.parse(tx['maxFeePerGas'].substring(2), radix: 16)) : null,
                    maxPriorityFeePerGas: tx['maxPriorityFeePerGas'] != null ? EtherAmount.fromBigInt(EtherUnit.wei, BigInt.parse(tx['maxPriorityFeePerGas'].substring(2), radix: 16)) : null,
                    nonce: tx['nonce'] != null ? int.parse(tx['nonce'].substring(2), radix: 16) : null,
                    value: tx['value'] != null ? EtherAmount.fromBigInt(EtherUnit.wei, BigInt.parse(tx['value'].substring(2), radix: 16)) : null,
                  );
                  final txHash = await _client.sendTransaction(_credentials, transaction, chainId: int.parse(chainId));
                  print('Transaction sent: $txHash');
                  return txHash;
                }
                return 'Method not implemented';
              } catch (e) {
                return 'Error: $e';
              }
            },
          );
        },
        onLoadStart: (controller, url) {
          print('Loading: $url');
        },
        onLoadStop: (controller, url) async {
          print('Loaded: $url');
          await controller.evaluateJavascript(source: getEthereumProviderScript());
        },
        onConsoleMessage: (controller, consoleMessage) {
          print('Web console: ${consoleMessage.message}');
        },
      ),
    );
  }
}