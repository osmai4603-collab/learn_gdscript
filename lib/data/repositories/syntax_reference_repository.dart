class SyntaxReference {
  const SyntaxReference({
    required this.id,
    required this.title,
    required this.description,
  });

  final String id;
  final String title;
  final String description;
}

abstract interface class SyntaxReferenceRepository {
  Future<List<SyntaxReference>> search(String query);
}

class EmptySyntaxReferenceRepository implements SyntaxReferenceRepository {
  const EmptySyntaxReferenceRepository();

  @override
  Future<List<SyntaxReference>> search(String query) async => const [];
}
