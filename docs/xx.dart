abstract interface class GdscriptLspClient {
  /// تشخيصات الخادم بصيغة LSP: URI المستند وقائمة التشخيصات.
  Stream<Map<String, Object?>> get diagnostics;

  /// تشغيل الخادم وإرسال initialize ثم initialized.
  Future<void> start({required Uri rootUri});

  /// فتح مستند وإرسال textDocument/didOpen.
  Future<void> didOpen({
    required Uri uri,
    required int version,
    required String text,
    String languageId = 'gdscript',
  });

  /// إرسال تغييرات المستند بصيغة LSP.
  Future<void> didChange({
    required Uri uri,
    required int version,
    required List<Map<String, Object?>> contentChanges,
  });

  /// إغلاق مستند وإرسال textDocument/didClose.
  Future<void> didClose({required Uri uri});

  /// إرسال طلب LSP مثل textDocument/completion أو textDocument/hover.
  Future<Object?> request(
    String method, {
    Map<String, Object?> params = const {},
  });

  /// إرسال إشعار LSP لا ينتظر نتيجة، مثل workspace/didChangeWorkspaceFolders.
  Future<void> notify(
    String method, {
    Map<String, Object?> params = const {},
  });

  /// إنهاء دورة LSP وإغلاق الاتصال والعملية التابعة إن وجدت.
  Future<void> shutdown();

  /// تحرير الموارد؛ يمكن استدعاؤها عند إغلاق الواجهة.
  Future<void> dispose();
}