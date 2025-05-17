// lib/models/student_model.dart

class Student {
  final String email;
  bool isSelected;
  final bool isPresent;

  Student({
    required this.email,
    this.isSelected = false,
    this.isPresent = false,
  });
}
