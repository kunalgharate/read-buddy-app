import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

import 'Contribution.dart'; // Import the contributions screen

class PickupDetailsScreen extends StatefulWidget {
  const PickupDetailsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PickupDetailsScreenState createState() => _PickupDetailsScreenState();
}

class _PickupDetailsScreenState extends State<PickupDetailsScreen> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  
  bool _isLoadingLocation = false;
  final bool _receiptUploaded = false;

  @override
  void dispose() {
    _addressController.dispose();
    _pinCodeController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<bool> _handleLocationPermission() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar('Location services are disabled. Please enable location services.', Colors.red);
        // Try to open location settings
        await Geolocator.openLocationSettings();
        return false;
      }

      // Check location permission using permission_handler
      var status = await Permission.location.status;
      
      if (status.isDenied) {
        // Request permission
        status = await Permission.location.request();
        if (status.isDenied) {
          _showSnackBar('Location permission denied. Please grant location access.', Colors.red);
          return false;
        }
      }

      if (status.isPermanentlyDenied) {
        // Show dialog to open app settings
        _showPermissionDialog();
        return false;
      }

      if (status.isGranted) {
        return true;
      }

      return false;
    } catch (e) {
      _showSnackBar('Error requesting location permission', Colors.red);
      return false;
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission Required'),
          content: const Text(
            'This app needs location permission to get your current address. Please grant location permission from app settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Handle permissions first
      bool hasPermission = await _handleLocationPermission();
      if (!hasPermission) {
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      // Get current position with timeout and fallback
      Position position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 15),
        );
      } catch (e) {
        // Fallback to last known position
        Position? lastPosition = await Geolocator.getLastKnownPosition();
        if (lastPosition != null) {
          position = lastPosition;
          _showSnackBar('Using last known location', Colors.orange);
        } else {
          // Try with medium accuracy
          try {
            position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.medium,
              timeLimit: const Duration(seconds: 20),
            );
          } catch (e2) {
            throw Exception('Unable to get location');
          }
        }
      }

      // Get address from coordinates
      await _getAddressFromCoordinates(position.latitude, position.longitude);
      
      _showSnackBar('Location and address updated successfully!', Colors.green);

    } catch (e) {
      String errorMessage = 'Failed to get current location';
      
      // Handle specific error types
      if (e.toString().contains('PERMISSION_DENIED')) {
        errorMessage = 'Location permission denied. Please enable location access.';
      } else if (e.toString().contains('LOCATION_SERVICE_DISABLED')) {
        errorMessage = 'Location services disabled. Please turn on location services.';
      } else if (e.toString().contains('TIMEOUT')) {
        errorMessage = 'Location request timed out. Please try again.';
      } else if (e.toString().contains('NETWORK')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (e.toString().contains('Unable to get location')) {
        errorMessage = 'Unable to get your location. Please check GPS and try again.';
      }
      
      _showSnackBar(errorMessage, Colors.red);
      
      // Show manual location option
      _showManualLocationDialog();
      
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude, 
        longitude,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Geocoding timeout');
        },
      );
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = '';
        
        if (place.name != null && place.name!.isNotEmpty) {
          address += '${place.name!}, ';
        }
        if (place.street != null && place.street!.isNotEmpty) {
          address += '${place.street!}, ';
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          address += '${place.subLocality!}, ';
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          address += '${place.locality!}, ';
        }
        if (place.subAdministrativeArea != null && place.subAdministrativeArea!.isNotEmpty) {
          address += '${place.subAdministrativeArea!}, ';
        }
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          address += '${place.administrativeArea!}, ';
        }
        if (place.country != null && place.country!.isNotEmpty) {
          address += place.country!;
        }
        
        // Remove trailing comma and space
        if (address.endsWith(', ')) {
          address = address.substring(0, address.length - 2);
        }
        
        setState(() {
          _addressController.text = address.isNotEmpty ? address : 'Address not found';
          
          // Enhanced pin code handling - ensure exactly 6 digits
          String pinCode = place.postalCode ?? '';
          if (pinCode.isNotEmpty) {
            // Clean pin code - remove any non-numeric characters
            pinCode = pinCode.replaceAll(RegExp(r'[^0-9]'), '');
            
            // Ensure it's exactly 6 digits
            if (pinCode.length >= 6) {
              // Take first 6 digits if longer
              pinCode = pinCode.substring(0, 6);
            } else if (pinCode.isNotEmpty && pinCode.length < 6) {
              // If it's shorter than 6 digits, pad with zeros at the end
              // This is a fallback, ideally we should get proper 6-digit codes
              pinCode = pinCode.padRight(6, '0');
              _showSnackBar('Pin code might be incomplete. Please verify.', Colors.orange);
            } else {
              // If no valid pin code found, clear the field
              pinCode = '';
              _showSnackBar('Pin code not found. Please enter manually.', Colors.orange);
            }
          }
          
          _pinCodeController.text = pinCode;
        });
        
        // Validate pin code and show appropriate message
        if (place.postalCode != null && place.postalCode!.isNotEmpty) {
          String originalPinCode = place.postalCode!.replaceAll(RegExp(r'[^0-9]'), '');
          if (originalPinCode.length == 6) {
            _showSnackBar('Address and pin code updated successfully!', Colors.green);
          } else if (originalPinCode.length < 6) {
            _showSnackBar('Pin code seems incomplete. Please verify and update if needed.', Colors.orange);
          } else {
            _showSnackBar('Address updated. Pin code trimmed to 6 digits.', Colors.blue);
          }
        } else {
          _showSnackBar('Address updated but pin code not found. Please enter manually.', Colors.orange);
        }
        
      } else {
        setState(() {
          _addressController.text = 'Address not found for this location';
          _pinCodeController.text = '';
        });
        _showSnackBar('Address not found for this location', Colors.orange);
      }
    } catch (e) {
     ('Error getting address: $e');
      setState(() {
        _addressController.text = 'Lat: ${latitude.toStringAsFixed(6)}, Lng: ${longitude.toStringAsFixed(6)}';
        _pinCodeController.text = '';
      });
      _showSnackBar('Could not get address. Please enter manually.', Colors.orange);
    }
  }

  void _showManualLocationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Access Failed'),
          content: const Text(
            'Unable to get your current location. You can:\n\n'
            '1. Enter your address manually\n'
            '2. Check location permissions in settings\n'
            '3. Make sure GPS is enabled\n'
            '4. Try again with better network connection',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Enter Manually'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _getCurrentLocation();
              },
              child: const Text('Try Again'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }


  void _submitDetails() {
    // Basic validation
    if (_addressController.text.trim().isEmpty ||
        _pinCodeController.text.trim().isEmpty ||
        _contactController.text.trim().isEmpty) {
      _showSnackBar('Please fill all required fields', Colors.red);
      return;
    }

    // Validate pin code (should be exactly 6 digits)
    String pinCode = _pinCodeController.text.trim();
    if (pinCode.length != 6) {
      _showSnackBar('Pin code must be exactly 6 digits', Colors.red);
      return;
    }

    // Validate that pin code contains only digits
    if (!RegExp(r'^[0-9]{6}$').hasMatch(pinCode)) {
      _showSnackBar('Pin code should contain only 6 digits', Colors.red);
      return;
    }

    // Validate contact number (should be exactly 10 digits)
    String contactNumber = _contactController.text.trim();
    if (contactNumber.length != 10) {
      _showSnackBar('Contact number must be exactly 10 digits', Colors.red);
      return;
    }

    // Validate that contact number contains only digits
    if (!RegExp(r'^[0-9]{10}$').hasMatch(contactNumber)) {
      _showSnackBar('Contact number should contain only 10 digits', Colors.red);
      return;
    }

    // Additional validation for Indian pin codes (should not start with 0)
    if (pinCode.startsWith('0')) {
      _showSnackBar('Please enter a valid pin code', Colors.red);
      return;
    }

    // Additional validation for Indian mobile numbers (should start with 6, 7, 8, or 9)
    if (!RegExp(r'^[6-9][0-9]{9}$').hasMatch(contactNumber)) {
      _showSnackBar('Please enter a valid mobile number', Colors.red);
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ContributionsScreen(),
      ),
    );
  }

  Widget _buildDropOffDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Drop off Details',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 5, 53, 93),
          ),
        ),
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile section with new random girl photo
              Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage('https://images.unsplash.com/photo-1544005313-94ddf0286df2?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80'),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rashmika Sharma',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'Upload receipt',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Address section
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.grey,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Plot No. 54, Ashoka Ratna, Shree Ram Nagar, Raipur, CG - 492001',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Phone section
              Row(
                children: [
                  const Icon(
                    Icons.phone,
                    color: Colors.grey,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '+91 9876543210',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Time and distance section
              Row(
                children: [
                  const Icon(
                    Icons.schedule,
                    color: Colors.grey,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '10:00 AM - 1:00 PM',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '1.4 KM Away',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Donate Your Book',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Step 2',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            
            // Drop off Details Section
            _buildDropOffDetailsSection(),
            
            // Pick up Details Section
            const Text(
              'Pick up details',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 5, 53, 93),
              ),
            ),
            const SizedBox(height: 16),
            
            // Address field with location button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your Address ',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                // Enhanced location button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _isLoadingLocation ? null : _getCurrentLocation,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: _isLoadingLocation 
                            ? LinearGradient(
                                colors: [Colors.grey.shade400, Colors.grey.shade500],
                              )
                            : const LinearGradient(
                                colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                              ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            // ignore: deprecated_member_use
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _isLoadingLocation
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.my_location,
                              color: Colors.white,
                              size: 20,
                            ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _addressController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter address or tap "Get Location" button above to get current location',
                hintStyle: const TextStyle(fontSize: 13),
                prefixIcon: const Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pin Code ',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _pinCodeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                hintText: 'Enter 6-digit pin code or get automatically',
                prefixIcon: const Icon(Icons.pin_drop_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                counterText: '',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Contact Number ',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _contactController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: InputDecoration(
                hintText: 'Enter 10-digit mobile number',
                prefixIcon: const Icon(Icons.call_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                counterText: '',
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: MaterialButton(
                onPressed: _submitDetails,
                color: const Color(0xFF2DE18D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}