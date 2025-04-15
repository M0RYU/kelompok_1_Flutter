import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class AzureStorageService {
  // Azure Storage settings
  static const String storageAccount = 'moryustorage';
  static const String sasToken = '?sp=racwdlmeop&st=2025-04-09T22:57:53Z&se=2025-04-20T06:57:53Z&sv=2024-11-04&sr=c&sig=13Yq%2F6CcmP8EKkUjELsVnMkKMir0xMSdRG%2BvXvNQ1uA%3D';
  static const String containerName = 'flutteruts';
  static const String profileContainerName = 'flutteruts';
  
  // Base URLs for Azure Blob Storage
  final String _baseUrl = 'https://$storageAccount.blob.core.windows.net/$containerName';
  final String _profileBaseUrl = 'https://$storageAccount.blob.core.windows.net/$profileContainerName';
  
  // Upload a file to Azure Blob Storage and return the URL
  Future<String> uploadFile(File file, String userId, String orderId) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';
      final blobPath = 'design_references/$userId/$orderId/$fileName';
      
      // Full URL with SAS token for the upload
      final uploadUrl = '$_baseUrl/$blobPath$sasToken';
      
      // Read file as bytes
      final fileBytes = await file.readAsBytes();
      
      // Create HTTP PUT request
      final response = await http.put(
        Uri.parse(uploadUrl),
        headers: {
          'Content-Type': _getContentType(fileName),
          'x-ms-blob-type': 'BlockBlob'
        },
        body: fileBytes,
      );
      
      // Check response status
      if (response.statusCode == 201) {
        // Return the public URL without SAS token for retrieving the file
        return '$_baseUrl/$blobPath';
      } else {
        throw Exception('Failed to upload file. Status code: ${response.statusCode}, response: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error uploading file to Azure: ${e.toString()}');
      throw Exception('Failed to upload file to Azure: ${e.toString()}');
    }
  }
  
  // Upload multiple files and return the URLs
  Future<List<String>> uploadFiles(List<File> files, String userId, String orderId) async {
    List<String> uploadedUrls = [];
    
    try {
      for (var file in files) {
        final url = await uploadFile(file, userId, orderId);
        uploadedUrls.add(url);
      }
      return uploadedUrls;
    } catch (e) {
      debugPrint('Error uploading files to Azure: ${e.toString()}');
      throw e;
    }
  }
  
  // Upload a profile image and return the URL
  Future<String?> uploadProfileImage(File image, String userId) async {
    try {
      final fileName = 'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';
      final blobPath = 'profiles/$userId/$fileName';
      
      // Full URL with SAS token for the upload
      final uploadUrl = '$_profileBaseUrl/$blobPath$sasToken';
      
      // Read file as bytes
      final fileBytes = await image.readAsBytes();
      
      // Create HTTP PUT request
      final response = await http.put(
        Uri.parse(uploadUrl),
        headers: {
          'Content-Type': _getContentType(fileName),
          'x-ms-blob-type': 'BlockBlob'
        },
        body: fileBytes,
      );
      
      // Check response status
      if (response.statusCode == 201) {
        // Return the public URL without SAS token for retrieving the file
        return '$_profileBaseUrl/$blobPath';
      } else {
        debugPrint('Failed to upload profile image. Status: ${response.statusCode}, Response: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error uploading profile image to Azure: ${e.toString()}');
      return null;
    }
  }
  
  // Delete a profile image from Azure Blob Storage
  Future<bool> deleteProfileImage(String imageUrl) async {
    try {
      // Extract the blob path from the URL
      if (!imageUrl.contains('blob.core.windows.net')) {
        debugPrint('Not an Azure Blob Storage URL: $imageUrl');
        return false;
      }
      
      // Parse the URL to get the blob path
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      
      // The first segment is the container name, the rest are the blob path
      if (pathSegments.length < 2) {
        debugPrint('Invalid blob URL format: $imageUrl');
        return false;
      }
      
      // Construct the blob path without the container name
      final blobPath = pathSegments.sublist(1).join('/');
      
      // Full URL with SAS token for deletion
      final deleteUrl = '$_profileBaseUrl/$blobPath$sasToken';
      
      // Send DELETE request
      final response = await http.delete(Uri.parse(deleteUrl));
      
      // Check response status
      if (response.statusCode == 202) {
        debugPrint('Successfully deleted profile image from Azure');
        return true;
      } else {
        debugPrint('Failed to delete profile image. Status: ${response.statusCode}, Response: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error deleting profile image from Azure: ${e.toString()}');
      return false;
    }
  }
  
  // Helper method to determine content type based on file extension
  String _getContentType(String fileName) {
    final ext = path.extension(fileName).toLowerCase();
    
    switch (ext) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }
}