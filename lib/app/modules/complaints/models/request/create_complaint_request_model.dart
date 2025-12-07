import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';

class ComplaintRequest {
  final String type;
  final String entity;
  final String description;
  final String location;
  final List<PlatformFile>? attachments;

  ComplaintRequest({
    required this.type,
    required this.entity,
    required this.description,
    required this.location,
    this.attachments,
  });

  Future<FormData> toFormData() async {
    final form = FormData();

    form.fields.add(MapEntry('type', type));
    form.fields.add(MapEntry('entity', entity));
    form.fields.add(MapEntry('description', description));
    form.fields.add(MapEntry('location', location));

    if (attachments != null && attachments!.isNotEmpty) {
      for (final file in attachments!) {
        if (file.path != null && file.path!.isNotEmpty) {
          final multipart = await MultipartFile.fromFile(
            file.path!,
            filename: file.name,
          );
          form.files.add(MapEntry('attachments[]', multipart));
        } else if (file.bytes != null) {
          final multipart = MultipartFile.fromBytes(
            file.bytes!,
            filename: file.name,
          );
          form.files.add(MapEntry('attachments[]', multipart));
        }
      }
    }

    return form;
  }
}
