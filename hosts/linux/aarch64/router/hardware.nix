# Raspberry Pi 4 Router Hardware Configuration
{ ... }: {
  boot.kernelModules = [
    # USB Ethernet adapter support
    "r8152" # Realtek USB Ethernet (common)
    "asix" # ASIX USB Ethernet
    "ax88179_178a" # ASIX AX88179
    "cdc_ether" # Generic CDC Ethernet
    "cdc_ncm"
    "smsc95xx" # Built-in ethernet on Pi
  ];
}
