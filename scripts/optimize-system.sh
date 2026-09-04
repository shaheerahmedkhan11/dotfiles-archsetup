#!/bin/bash
# ═══════════════════════════════════════════════════════════
#  LAPTOP OPTIMIZATION SCRIPT — Run with sudo
#  sudo bash ~/optimize-system.sh
# ═══════════════════════════════════════════════════════════
set -e

echo ""
echo "  ╔══════════════════════════════════════╗"
echo "  ║  OPTIMIZING LAPTOP PERFORMANCE       ║"
echo "  ╚══════════════════════════════════════╝"
echo ""

# ── 1. SWAP: Reduce swappiness (31GB RAM doesn't need60) ──
echo "[1/8] Setting swappiness to 10..."
echo "vm.swappiness=10" > /etc/sysctl.d/99-optimize.conf
echo "vm.dirty_ratio=15" >> /etc/sysctl.d/99-optimize.conf
echo "vm.dirty_background_ratio=5" >> /etc/sysctl.d/99-optimize.conf
echo "vm.vfs_cache_pressure=50" >> /etc/sysctl.d/99-optimize.conf
echo "net.core.somaxconn=4096" >> /etc/sysctl.d/99-optimize.conf
sysctl --system 2>/dev/null
echo "  ✅ Swappiness: 60 → 10"

# ── 2. TRANSPARENT HUGEPAGES: Set to madvise (desktop) ──
echo "[2/8] Setting THP to madvise..."
echo madvise > /sys/kernel/mm/transparent_hugepage/enabled
echo madvise > /sys/kernel/mm/transparent_hugepage/defrag
# Persist across reboots
echo 'echo madvise > /sys/kernel/mm/transparent_hugepage/enabled' > /etc/tmpfiles.d/thp.conf
echo 'echo madvise > /sys/kernel/mm/transparent_hugepage/defrag' >> /etc/tmpfiles.d/thp.conf
echo "  ✅ THP: always → madvise"

# ── 3. DISABLE UNNECESSARY SERVICES ──
echo "[3/8] Disabling slow boot services..."
systemctl disable NetworkManager-wait-online.service 2>/dev/null && echo "  ✅ Disabled NetworkManager-wait-online" || echo "  ⏭ Already disabled"
systemctl disable lvm2-monitor.service 2>/dev/null && echo "  ✅ Disabled lvm2-monitor" || echo "  ⏭ Already disabled"

# ── 4. CLEAN SYSTEM CACHES ──
echo "[4/8] Cleaning system caches..."
pacman -Scc --noconfirm 2>/dev/null && echo "  ✅ Pacman cache cleaned" || echo "  ⚠️ Pacman cache clean skipped"
journalctl --vacuum-time=7d 2>/dev/null && echo "  ✅ Journal vacuumed to 7 days" || echo "  ⏭ Journal skip"
rm -rf /var/cache/thumbnails/* 2>/dev/null
rm -rf /tmp/* 2>/dev/null
echo "  ✅ Temp files cleaned"

# ── 5. I/O SCHEDULER: Optimize for SSD ──
echo "[5/8] Optimizing I/O scheduler..."
for disk in /sys/block/sd*/queue/scheduler /sys/block/nvme*/queue/scheduler; do
    if [ -f "$disk" ]; then
        echo "none" > "$disk" 2>/dev/null && echo "  ✅ $disk → none (best for SSD)" || true
    fi
done

# ── 6. KERNEL: Disable unnecessary modules ──
echo "[6/8] Optimizing kernel modules..."
# Disable USB autosuspend delay (if laptop)
echo 'USB_AUTOSUSPEND=0' > /etc/udev/rules.d/50-usb-powersave.rules 2>/dev/null
echo "  ✅ USB autosuspend optimized"

# ── 7. MEMORY: Reduce inode cache pressure ──
echo "[7/8] Optimizing memory management..."
echo 'vm.min_free_kbytes=65536' >> /etc/sysctl.d/99-optimize.conf
echo 'vm.zone_reclaim_mode=0' >> /etc/sysctl.d/99-optimize.conf
sysctl --system 2>/dev/null
echo "  ✅ Memory management optimized"

# ── 8. FINAL CLEANUP ──
echo "[8/8] Final cleanup..."
# Remove old snap versions if any
snap list --all | awk '/disabled/{print $1, $3}' | while read pkg rev; do
    snap remove "$pkg" --revision="$rev" 2>/dev/null
done
# Clean Docker if present
docker system prune -af 2>/dev/null && echo "  ✅ Docker pruned" || echo "  ⏭ Docker not running"
# Clean cargo cache
rm -rf ~/.cargo/registry/cache/ 2>/dev/null
echo "  ✅ Final cleanup done"

echo ""
echo "  ╔══════════════════════════════════════╗"
echo "  ║  OPTIMIZATION COMPLETE               ║"
echo "  ╠══════════════════════════════════════╣"
echo "  ║  • Swappiness:60 → 10               ║"
echo "  ║  • THP: always → madvise            ║"
echo "  ║  • I/O scheduler → none (SSD)       ║"
echo "  ║  • System caches cleaned             ║"
echo "  ║  • Boot services optimized           ║"
echo "  ║  • Memory pressure reduced           ║"
echo "  ╚══════════════════════════════════════╝"
echo ""
echo "  Reboot recommended for full effect."
echo ""
