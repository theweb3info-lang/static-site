#!/bin/bash
# mac-temps.sh — CPU, GPU & Disk temperatures on macOS Apple Silicon
# Dependencies: osx-cpu-temp (brew), smartmontools (brew)

echo "=== 🌡️ Mac Temperature Report ==="
echo "Time: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# CPU temperature
echo "--- CPU ---"
cpu_temp=$(osx-cpu-temp 2>/dev/null)
if [ -n "$cpu_temp" ] && [ "$cpu_temp" != "0.0°C" ]; then
    echo "CPU: $cpu_temp"
else
    echo "CPU: (sensor not exposed on this model)"
fi

# GPU temperature — Apple Silicon shares die, so CPU temp ≈ GPU temp
echo ""
echo "--- GPU ---"
echo "Apple Silicon: GPU shares SoC die with CPU (same thermal zone)"

# Disk temperature via smartctl
echo ""
echo "--- Disk (NVMe) ---"
disk_temp=$(smartctl -a /dev/disk0 2>/dev/null | grep -i 'temperature' | head -1)
if [ -n "$disk_temp" ]; then
    echo "disk0: $disk_temp"
else
    echo "disk0: (unable to read)"
fi

# Additional NVMe channels from ioreg
nand_temps=$(/usr/sbin/ioreg -r -n AppleEmbeddedNVMeTemperatureSensor -w0 2>/dev/null | grep '"Product"' | sed 's/.*"Product" = "//' | sed 's/"//')
if [ -n "$nand_temps" ]; then
    echo "NAND sensors: $nand_temps"
fi

# Disk info
echo ""
echo "--- Disk Info ---"
/usr/sbin/system_profiler SPNVMeDataType 2>/dev/null | grep -iE '^\s*(model|capacity):' | head -2 | sed 's/^ *//'

echo ""
echo "=== Done ==="
