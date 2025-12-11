extension ObjectExtensions on Object {

    /// Gets the className from the runtimeType without generic part
    String get className {
        String fullType = runtimeType.toString();
        int pos = fullType.indexOf('<');

        return pos < 0 ? fullType : fullType.substring(0, pos);
    }
}