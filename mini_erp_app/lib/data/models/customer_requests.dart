/// OpenAPI: CreateCustomerDto (+ nested CreateCustomerAccountDto)
class CreateCustomerRequest {
  const CreateCustomerRequest({
    required this.name,
    required this.phone,
    this.notes,
    required this.username,
    required this.password,
  });

  final String name;
  final String phone;
  final String? notes;
  final String username;
  final String password;

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
        'account': {
          'username': username,
          'password': password,
        },
      };
}

/// OpenAPI: UpdateCustomerDto — no balance field (display-only).
class UpdateCustomerRequest {
  const UpdateCustomerRequest({
    this.name,
    this.phone,
    this.notes,
  });

  final String? name;
  final String? phone;
  final String? notes;

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (notes != null) 'notes': notes,
    };
  }
}

/// OpenAPI: ResetCustomerPasswordDto
class ResetCustomerPasswordRequest {
  const ResetCustomerPasswordRequest({required this.newPassword});

  final String newPassword;

  Map<String, dynamic> toJson() => {'newPassword': newPassword};
}
