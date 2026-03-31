class AvatarOption {
  final String name;
  final String assetPath;

  const AvatarOption({required this.name, required this.assetPath});
}

class AppAvatars {
  static const List<AvatarOption> all = [
    AvatarOption(name: 'alena',  assetPath: 'assets/avatars/alena.png'),
    AvatarOption(name: 'ali',    assetPath: 'assets/avatars/ali.png'),
    AvatarOption(name: 'arooca', assetPath: 'assets/avatars/arooca.png'),
    AvatarOption(name: 'eman',   assetPath: 'assets/avatars/eman.png'),
    AvatarOption(name: 'fahad',  assetPath: 'assets/avatars/fahad.png'),
    AvatarOption(name: 'muskan', assetPath: 'assets/avatars/muskan.png'),
    AvatarOption(name: 'nida',   assetPath: 'assets/avatars/nida.png'),
    AvatarOption(name: 'raza',   assetPath: 'assets/avatars/raza.png'),
    AvatarOption(name: 'rida',   assetPath: 'assets/avatars/rida.png'),
    AvatarOption(name: 'sak',    assetPath: 'assets/avatars/sak.png'),
  ];

  // get asset path from name saved in backend
  static String? assetFor(String? name) {
    if (name == null || name.isEmpty) return null;
    try {
      return all.firstWhere(
            (a) => a.name.toLowerCase() == name.toLowerCase(),
      ).assetPath;
    } catch (_) {
      return null;
    }
  }
}