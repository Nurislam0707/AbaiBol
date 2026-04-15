/// Utility to resolve asset paths for teachers and buildings based on naming conventions.
class AssetUtils {
  static String? getTeacherAsset(String name, {String? faculty}) {
    final slug = name.toLowerCase().trim().replaceAll(RegExp(r'\s+'), '_');
    
    // If faculty is known, use specific path
    if (faculty != null) {
      final facultySlug = faculty.toLowerCase().contains('it') ? 'faculty_it' : 'faculty_engineering';
      return 'assets/images/teachers/$facultySlug/$slug.jpg';
    }
    
    // Otherwise return a guess (default to it for now or root)
    return 'assets/images/teachers/faculty_it/$slug.jpg';
  }

  static String? getBuildingAsset(String buildingName, {String? placeName}) {
    final bSlug = buildingName.toLowerCase().contains('a') ? 'building_a' : 'building_b';
    final pSlug = placeName?.toLowerCase().trim().replaceAll(RegExp(r'\s+'), '_') ?? 'hall';
    
    return 'assets/images/buildings/$bSlug/$pSlug.jpg';
  }
}
