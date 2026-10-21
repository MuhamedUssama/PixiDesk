abstract class PdfMergeDesktopGateway {
  Future<List<String>> selectDocuments();
  Future<String?> selectDestination(String title);
  Future<void> openDocument(String path);
  Future<void> revealDocument(String path);
}
