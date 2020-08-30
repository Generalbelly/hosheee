class ValidationResult {
  String field;
  dynamic input;
  bool valid;
  List<String> messages;

  ValidationResult(this.field, this.valid, this.messages, this.input);
}

class Validator {
  Map<String, dynamic> inputs;
  Map<String, List<String>> fieldRules;

  Validator(this.inputs, this.fieldRules);

  List<ValidationResult> validate() {
    var results = List<ValidationResult>();
    fieldRules.forEach((field, rules) {
      var messages = List<String>();
      final input = inputs[field];
      for (var i = 0; i < rules.length; i++) {
        var rule = rules[i];
        var value;
        if (rule.contains(':')) {
          var splitValue = rule.split(':');
          rule = splitValue[0];
          value = splitValue[1];
        }
        switch (rule) {
          case 'email':
            if (input == null || !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(input)) {
              messages.add('The $field field must be a valid email.');
            }
            break;
          case 'required':
            if (input == null || (input is String && input.length == 0)) {
              messages.add('The $field field is required.');
            }
            break;
          case 'confirmed':
            final confirmationField = inputs['${field}_confirmation'];
            if (confirmationField != input) {
              messages.add('The $field field confirmation does not match.');
            }
            break;
          case 'min':
            if (value == null) {
              continue;
            }
            final threshold = int.parse(value);
            if (input == null || (input is String && input.length < threshold)) {
              messages.add('The $field field must be at least $value characters.');
            }
            break;
          case 'max':
            if (value == null) {
              continue;
            }
            final _value = value as int;
            if (input == null || (input is String && input.length > _value)) {
              messages.add('The $field field may not be greater than $value characters');
            }
            break;
          default:
            break;
        }
      }
      results.add(ValidationResult(field, messages.length == 0, messages, input));
    });
    return results;
  }
}
