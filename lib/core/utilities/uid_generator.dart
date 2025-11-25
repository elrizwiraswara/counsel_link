class UidGenerator {
  UidGenerator._();

  // Create random-looking UID from phone number (28 characters)
  static String createUid(String phoneNumber) {
    // Remove non-digits
    final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // Add timestamp for uniqueness
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final combined = digits + timestamp;

    // Characters to use (alphanumeric, mixed case)
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

    // Generate 28-character UID
    String uid = '';
    int seed = combined.hashCode.abs();

    for (int i = 0; i < 28; i++) {
      // Create pseudo-random index
      seed = (seed * 1103515245 + 12345) & 0x7fffffff;
      final index = seed % chars.length;
      uid += chars[index];
    }

    return uid;
  }
}
