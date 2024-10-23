enum RoleColor {
  primary,
  secondary,
  tertiary,
  danger,
  success,
  warning,
  info,
  mono;

  bool get isPrimary => this == RoleColor.primary;
  bool get isSecondary => this == RoleColor.secondary;
  bool get isTertiary => this == RoleColor.tertiary;
  bool get isDanger => this == RoleColor.danger;
  bool get isSuccess => this == RoleColor.success;
  bool get isWarning => this == RoleColor.warning;
  bool get isInfo => this == RoleColor.info;
  bool get isMono => this == RoleColor.mono;
}
