class VersionUtil {
  static bool isVersionGreaterThan(String newVersion, String currentVersion) {
    try {
      List<String> currentV =
          currentVersion.replaceAll("v", "").split(".");
      List<String> newV = newVersion.replaceAll("v", "").split(".");
      
      // Pad with zeros if version parts are missing (e.g., "1.0" vs "1.0.1")
      while (currentV.length < 3) {
        currentV.add("0");
      }
      while (newV.length < 3) {
        newV.add("0");
      }

      for (var i = 0; i < 3; i++) {
        int n = int.tryParse(newV[i]) ?? 0;
        int c = int.tryParse(currentV[i]) ?? 0;
        if (n > c) return true;
        if (n < c) return false;
      }
    } catch (e) {
      return false;
    }
    return false;
  }
}
