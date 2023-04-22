class StorageException implements Exception {
  const StorageException();
}

class CouldNotCreateException extends StorageException {}

class AlreadyCreatedException extends StorageException {}

class CouldNotUpdateException extends StorageException {}

class PermissionDeniedException extends StorageException {}

class GenericCloudException extends StorageException {}
