import 'package:flutter/foundation.dart';

class ConfigService extends ChangeNotifier {
  // Azure Blob Storage configuration
  final String _azureStorageAccount = "moryustorage";
  final String _azureProfileContainer = "flutteruts";
  
  // SAS token (should be retrieved securely, not hardcoded in production)
  String _azureStorageSasToken = "sp=racwdlmeop&st=2025-04-09T12:49:11Z&se=2025-04-19T20:49:11Z&sv=2024-11-04&sr=c&sig=FQ%2F66sk%2BB3pNcKtjzFS5wHN80Ln7x1ZQz7s%2B8ovHxQM%3D";

  // Getters
  String get azureStorageAccount => _azureStorageAccount;
  String get azureProfileContainer => _azureProfileContainer;
  String get azureStorageSasToken => _azureStorageSasToken;

  // Method to set SAS token - call this when you obtain the token
  Future<void> setAzureSasToken(String sasToken) async {
    _azureStorageSasToken = sasToken;
    notifyListeners();
  }
}