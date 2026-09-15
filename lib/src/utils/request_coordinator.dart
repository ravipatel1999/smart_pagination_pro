/// Coordinates query generations, stale response rejection, and request deduplication.
class RequestCoordinator {
  int _generation = 0;
  final Set<String> _activeRequestKeys = <String>{};

  /// Returns the current active generation index.
  int get currentGeneration => _generation;

  /// Increments and returns the next query generation token.
  int nextGeneration() {
    return ++_generation;
  }

  /// Checks whether a given generation token is still valid (matches latest generation).
  bool isValidGeneration(int generationToken) {
    return generationToken == _generation;
  }

  /// Registers an active request key. Returns `true` if registered successfully, or `false` if duplicate.
  bool registerRequestKey(String key) {
    if (_activeRequestKeys.contains(key)) {
      return false;
    }
    _activeRequestKeys.add(key);
    return true;
  }

  /// Releases a completed or cancelled request key.
  void releaseRequestKey(String key) {
    _activeRequestKeys.remove(key);
  }

  /// Clears all pending request keys (e.g., on reset or dispose).
  void clear() {
    _activeRequestKeys.clear();
  }
}
