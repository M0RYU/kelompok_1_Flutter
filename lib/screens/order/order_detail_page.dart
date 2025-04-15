import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../../models/order_model.dart';
import '../../models/user_model.dart';
import '../../services/order_service.dart';
import '../../services/auth_service.dart';
import '../../services/chat_service.dart';
import '../../services/azure_storage_service.dart';
import '../chat/chat_detail_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class OrderDetailPage extends StatefulWidget {
  final String orderId;

  const OrderDetailPage({Key? key, required this.orderId}) : super(key: key);

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  bool _isLoading = true;
  OrderModel? _order;
  final OrderService _orderService = OrderService();
  final ChatService _chatService = ChatService();
  final AzureStorageService _azureStorage = AzureStorageService();
  String? _userId;
  String? _userType;
  Map<String, dynamic>? _designBriefMap;
  
  // User data for client/designer
  UserModel? _clientData;
  UserModel? _designerData;
  
  // For file uploads
  List<PlatformFile> _selectedFiles = [];
  bool _isUploading = false;
  String? _revisionFeedback;
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userData = await authService.getCurrentUserData();
      
      if (!mounted) return;
      
      _userId = userData?.uid;
      _userType = userData?.userType;

      // Fetch order details
      _order = await _orderService.getOrderById(widget.orderId);
      
      if (_order != null) {
        // Fetch client and designer data
        if (_order!.clientId.isNotEmpty) {
          final clientDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(_order!.clientId)
              .get();
          
          if (clientDoc.exists) {
            _clientData = UserModel.fromJson(clientDoc.data()!, clientDoc.id);
          }
        }
        
        if (_order!.designerId != null && _order!.designerId!.isNotEmpty) {
          final designerDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(_order!.designerId)
              .get();
          
          if (designerDoc.exists) {
            _designerData = UserModel.fromJson(designerDoc.data()!, designerDoc.id);
          }
        }
        
        // Parse design brief if available
        if (_order!.designBrief != null && _order!.designBrief!.isNotEmpty) {
          try {
            // Remove curly braces and split by commas
            final briefString = _order!.designBrief!
                .replaceAll('{', '')
                .replaceAll('}', '')
                .trim();
                
            final pairs = briefString.split(', ');
            
            _designBriefMap = {};
            for (final pair in pairs) {
              final keyValue = pair.split(': ');
              if (keyValue.length == 2) {
                _designBriefMap![keyValue[0].trim()] = keyValue[1].trim().replaceAll("'", "");
              }
            }
          } catch (e) {
            debugPrint('Error parsing design brief: $e');
          }
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading order details: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Text(
          'Detail Pesanan',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _order == null
              ? const Center(child: Text('Pesanan tidak ditemukan'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOrderHeader(),
                      const Divider(height: 32),
                      _buildOrderStatus(),
                      const Divider(height: 32),
                      _buildUserDetails(),
                      const Divider(height: 32),
                      _buildDesignDetails(),
                      const Divider(height: 32),
                      _buildPaymentDetails(),
                      if (_order!.attachmentUrls != null && _order!.attachmentUrls!.isNotEmpty)
                        ...[
                          const Divider(height: 32),
                          _buildAttachments(),
                        ],
                      if (_shouldShowActionButtons())
                        ...[
                          const SizedBox(height: 24),
                          _buildActionButtons(),
                        ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildOrderHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ID Pesanan:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            Text(
              _order!.id,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _order!.packageType,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.date_range, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              'Tanggal Pesanan: ${DateFormat('dd MMM yyyy, HH:mm').format(_order!.createdAt)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserDetails() {
    // Determine which user info to show based on current user type
    final UserModel? userToShow = _userType == 'client' ? _designerData : _clientData;
    final String userTypeLabel = _userType == 'client' ? 'Designer' : 'Client';
    
    if (userToShow == null) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$userTypeLabel Information',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              backgroundImage: userToShow.photoURL != null 
                  ? NetworkImage(userToShow.photoURL!) 
                  : null,
              child: userToShow.photoURL == null
                  ? Text(
                      userToShow.name.isNotEmpty ? userToShow.name[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userToShow.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    userToShow.email,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _startChat(userToShow),
              icon: const Icon(Icons.chat, size: 16),
              label: const Text('Chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _startChat(UserModel otherUser) async {
    if (_userId == null) return;
    
    try {
      // Create or get existing chat
      final chatId = await _chatService.createChat(
        user1Id: _userId!, 
        user2Id: otherUser.uid,
      );
      
      if (!mounted) return;
      
      // Navigate to chat page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatDetailPage(
            chatId: chatId,
            otherUserId: otherUser.uid,
            otherUserName: otherUser.name,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start chat: $e')),
      );
    }
  }

  Widget _buildOrderStatus() {
    final statusColors = {
      'completed': Colors.green,
      'in_progress': Colors.blue,
      'pending': Colors.amber,
      'cancelled': Colors.red,
      'waiting': Colors.purple,
      'review': Colors.orange,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status Pesanan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColors[_order!.status] ?? Colors.grey,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _getStatusDisplay(_order!.status),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),
            Text(
              _order!.formattedPrice,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getStatusDisplay(String status) {
    switch (status) {
      case 'pending': return 'Menunggu';
      case 'in_progress': return 'Dalam Proses';
      case 'completed': return 'Selesai';
      case 'cancelled': return 'Dibatalkan';
      case 'waiting': return 'Menunggu Proses';
      case 'review': return 'Review Desain';
      default: return 'Unknown';
    }
  }

  Widget _buildDesignDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detail Desain',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (_designBriefMap != null) ...[
          _buildDesignBriefField('Nama Usaha', 'businessName'),
          _buildDesignBriefField('Jenis Usaha', 'businessType'),
          _buildDesignBriefField('Alamat Usaha', 'businessAddress'),
          _buildDesignBriefField('Telepon Usaha', 'businessPhone'),
          _buildDesignBriefField('Deskripsi Usaha', 'businessDescription'),
          _buildDesignBriefField('Tema Desain', 'designTheme'),
          _buildDesignBriefField('Warna Desain', 'designColor'),
          _buildDesignBriefField('Ukuran Desain', 'designSize'),
          _buildDesignBriefField('Teks Desain', 'designText'),
          _buildDesignBriefField('Catatan Tambahan', 'designNotes'),
        ] else ...[
          Text(
            _order!.designBrief ?? 'Tidak ada detail desain',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ],
    );
  }

  Widget _buildDesignBriefField(String label, String key) {
    final value = _designBriefMap?[key];
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detail Pembayaran',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text('Metode Pembayaran:'),
            const SizedBox(width: 8),
            Text(
              _order!.paymentMethod ?? 'Belum dipilih',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('Status Pembayaran:'),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _order!.paymentStatus == 'completed' ? Colors.green : Colors.amber,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _order!.paymentStatus == 'completed' ? 'Lunas' : 'Pending',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAttachments() {
    // Kita perlu memisahkan attachment berdasarkan pemiliknya
    // Asumsikan bahwa URL attachment menyimpan informasi tentang siapa yang menguploadnya
    // Contoh: URL mungkin mengandung userId atau userType
    
    // Kita akan membagi attachment berdasarkan informasi di URL
    // Biasanya URL akan berisi informasi folder yang bisa kita gunakan
    List<String> designerAttachments = [];
    List<String> clientAttachments = [];
    
    // Jika tidak ada attachment, tidak perlu menampilkan apapun
    if (_order!.attachmentUrls == null || _order!.attachmentUrls!.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // Pisahkan attachment berdasarkan path URL
    for (var url in _order!.attachmentUrls!) {
      // Jika URL mengandung designer ID, maka itu adalah attachment dari designer
      if (_order!.designerId != null && url.contains(_order!.designerId!)) {
        designerAttachments.add(url);
      } 
      // Jika URL mengandung client ID, maka itu adalah attachment dari client
      else if (url.contains(_order!.clientId)) {
        clientAttachments.add(url);
      } 
      // Jika tidak bisa ditentukan, tambahkan ke attachment designer (default)
      else {
        designerAttachments.add(url);
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lampiran',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Lampiran dari Designer
        if (designerAttachments.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.design_services, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Text(
                      'Lampiran dari Designer',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: designerAttachments.map((url) {
                    bool isImage = _isImageUrl(url);
                    
                    return InkWell(
                      onTap: () => _openAttachment(url),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: isImage 
                            ? FutureBuilder<FileInfo>(
                                future: DefaultCacheManager().getSingleFile(url).then((file) => 
                                  FileInfo(file, FileSource.Cache, DateTime.now(), url)),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.done && 
                                      snapshot.hasData) {
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(7),
                                      child: Image.file(
                                        snapshot.data!.file,
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  }
                                  return const Center(
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  );
                                },
                              )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _getFileIcon(url), 
                                      color: Colors.grey[700],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _getFileExtension(url).toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
        
        // Lampiran dari Client (jika ada)
        if (clientAttachments.isNotEmpty) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.person, color: Colors.orange[700]),
                    const SizedBox(width: 8),
                    Text(
                      'Lampiran dari Client',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: clientAttachments.map((url) {
                    bool isImage = _isImageUrl(url);
                    
                    return InkWell(
                      onTap: () => _openAttachment(url),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: isImage 
                            ? FutureBuilder<FileInfo>(
                                future: DefaultCacheManager().getSingleFile(url).then((file) => 
                                  FileInfo(file, FileSource.Cache, DateTime.now(), url)),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.done && 
                                      snapshot.hasData) {
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(7),
                                      child: Image.file(
                                        snapshot.data!.file,
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  }
                                  return const Center(
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  );
                                },
                              )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _getFileIcon(url), 
                                      color: Colors.grey[700],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _getFileExtension(url).toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  bool _isImageUrl(String url) {
    final ext = _getFileExtension(url).toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(ext);
  }
  
  String _getFileExtension(String url) {
    Uri uri = Uri.parse(url);
    String path = uri.path;
    String fileName = path.split('/').last;
    if (fileName.contains('.')) {
      return fileName.split('.').last;
    }
    return '';
  }
  
  IconData _getFileIcon(String url) {
    final ext = _getFileExtension(url).toLowerCase();
    
    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(ext)) {
      return Icons.image;
    } else if (['pdf'].contains(ext)) {
      return Icons.picture_as_pdf;
    } else if (['doc', 'docx'].contains(ext)) {
      return Icons.description;
    } else if (['xls', 'xlsx'].contains(ext)) {
      return Icons.table_chart;
    } else if (['ppt', 'pptx'].contains(ext)) {
      return Icons.slideshow;
    } else if (['zip', 'rar', '7z'].contains(ext)) {
      return Icons.archive;
    } else if (['mp4', 'avi', 'mov', 'wmv'].contains(ext)) {
      return Icons.videocam;
    } else {
      return Icons.insert_drive_file;
    }
  }
  
  Future<void> _openAttachment(String url) async {
    try {
      // Check if we can directly open the URL (like web URLs)
      final uri = Uri.parse(url);
      if (uri.scheme == 'http' || uri.scheme == 'https') {
        if (await canLaunchUrl(uri)) {
          await launchUrl(
            uri,
            mode: LaunchMode.platformDefault,
          );
          return;
        }
      }
      
      // For file scheme or if we can't launch the URL directly, download and use Share.shareXFiles
      final tempDir = await getTemporaryDirectory();
      final file = await DefaultCacheManager().getSingleFile(url);
      
      // Get the file extension to determine the MIME type
      final ext = _getFileExtension(url).toLowerCase();
      String mimeType;
      
      switch (ext) {
        case 'pdf':
          mimeType = 'application/pdf';
          break;
        case 'jpg':
        case 'jpeg':
          mimeType = 'image/jpeg';
          break;
        case 'png':
          mimeType = 'image/png';
          break;
        default:
          mimeType = 'application/octet-stream';
      }
      
      // Using Share.shareXFiles with XFile which properly handles file URIs on Android
      final xFile = XFile(file.path, mimeType: mimeType);
      final fileName = url.split('/').last;
      
      await Share.shareXFiles(
        [xFile],
        text: 'Open attachment: $fileName',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening attachment: $e')),
        );
      }
    }
  }

  bool _shouldShowActionButtons() {
    if (_userId == null) return false;
    
    // Designer action buttons
    if (_userType == 'designer' && _order!.designerId == _userId) {
      // Designer can submit files when order is in_progress, waiting, or pending
      if (['in_progress', 'waiting', 'pending'].contains(_order!.status)) {
        return true;
      }
    }
    
    // Client action buttons
    if (_userType == 'client' && _order!.clientId == _userId) {
      // Client can request revision or complete order when in review
      if (_order!.status == 'review') {
        return true;
      }
    }
    
    return false;
  }

  Widget _buildActionButtons() {
    if (_userType == 'designer' && ['in_progress', 'waiting', 'pending'].contains(_order!.status)) {
      return Column(
        children: [
          // File upload options
          if (!_isUploading) ...[
            ElevatedButton.icon(
              onPressed: _pickFiles,
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload Files'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32),
              ),
            ),
            if (_selectedFiles.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('${_selectedFiles.length} file(s) selected', 
                style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedFiles.map((file) => Chip(
                  label: Text(
                    file.name.length > 15 
                        ? '${file.name.substring(0, 12)}...' 
                        : file.name,
                    style: const TextStyle(fontSize: 12),
                  ),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () {
                    setState(() {
                      _selectedFiles.remove(file);
                    });
                  },
                )).toList(),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _uploadFilesAndUpdateStatus(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                ),
                child: const Text(
                  'Submit for Review',
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ] else ...[
            const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Uploading files...'),
                ],
              ),
            ),
          ],
        ],
      );
    } else if (_userType == 'client' && _order!.status == 'review') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showRevisionDialog(),
                  icon: const Icon(Icons.loop, color: Colors.white),
                  label: const Text(
                    'Request Revision',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _completeOrder(),
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                  label: const Text(
                    'Approve & Complete',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }
    
    return const SizedBox.shrink();
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
        withData: true,
      );
      
      if (result != null) {
        setState(() {
          _selectedFiles = result.files;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking files: $e')),
      );
    }
  }

  Future<void> _uploadFilesAndUpdateStatus() async {
    if (_selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one file')),
      );
      return;
    }
    
    setState(() {
      _isUploading = true;
    });
    
    try {
      final List<String> uploadedUrls = [];
      
      // Upload each file to storage
      for (final file in _selectedFiles) {
        if (file.path != null) {
          // Make sure to pass the correct folder path for the uploads
          final url = await _azureStorage.uploadFile(
            File(file.path!), 
            _userId ?? 'unknown',  // Use current user ID
            widget.orderId         // Use order ID for folder structure
          );
          
          uploadedUrls.add(url);
        }
      }
      
      // Add attachments to the order
      if (uploadedUrls.isNotEmpty) {
        await _orderService.addAttachments(widget.orderId, uploadedUrls);
      }
      
      // Update status to review
      await _orderService.updateOrderStatus(widget.orderId, 'review');
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Files uploaded and sent for review'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Refresh order data
      _loadData();
      
      // Reset selected files after successful upload
      setState(() {
        _selectedFiles = [];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading files: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _showRevisionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Revision'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Please provide details on what needs to be revised:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _feedbackController,
              decoration: const InputDecoration(
                hintText: 'Enter your feedback here...',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submitRevisionRequest();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _submitRevisionRequest() async {
    if (_feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide revision feedback')),
      );
      return;
    }
    
    try {
      // Update order status back to in_progress
      await _orderService.updateOrderStatus(widget.orderId, 'in_progress');
      
      // Save the revision feedback
      await _orderService.addClientFeedback(widget.orderId, _feedbackController.text.trim(), 0);
      
      _feedbackController.clear();
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Revision request submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Refresh order data
      _loadData();
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit revision request: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _completeOrder() async {
    try {
      // Update order status to completed
      await _orderService.updateOrderStatus(widget.orderId, 'completed');
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order completed successfully'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Refresh order data
      _loadData();
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to complete order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateOrderStatus(String status) async {
    try {
      await _orderService.updateOrderStatus(widget.orderId, status);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Status pesanan berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Refresh order data
      _loadData();
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengubah status pesanan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}